import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_keys.dart';

/// Handles real in-app subscriptions via RevenueCat.
///
/// Money flows through here: when a user buys the "premium" entitlement in
/// the App Store / Play Store, RevenueCat reports it and we unlock premium.
class SubscriptionService {
  static const String _premiumKey = 'is_premium';
  static const String _expiryKey = 'premium_expiry';
  static const String _trialUsedKey = 'trial_used';

  /// Must match the entitlement ID you create in the RevenueCat dashboard.
  static const String entitlementId = 'premium';

  // Shared (static) state so every screen reads the same premium status.
  static bool _isPremium = false;
  static DateTime? _expiryDate;
  static bool _isLoading = false;
  static bool _configured = false;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  DateTime? get expiryDate => _expiryDate;

  /// True only after RevenueCat has been successfully configured with a key.
  static bool get isConfigured => _configured;

  /// Configure RevenueCat once. Safe to call multiple times.
  static Future<void> configure() async {
    if (_configured) return;

    if (ApiKeys.revenueCatApiKey.isEmpty) {
      debugPrint(
        'RevenueCat API key missing — subscriptions disabled. '
        'Pass --dart-define=REVENUECAT_API_KEY=... when building.',
      );
      return;
    }

    try {
      await Purchases.configure(PurchasesConfiguration(ApiKeys.revenueCatApiKey));
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate);
      _configured = true;

      // Pull the latest entitlement status from RevenueCat.
      await refreshStatus();
    } catch (e) {
      debugPrint('RevenueCat configure failed (subscriptions disabled): $e');
      _configured = false;
    }
  }

  static void _onCustomerInfoUpdate(CustomerInfo info) => _applyCustomerInfo(info);

  /// Re-sync premium status from RevenueCat (used on app start / after purchase).
  static Future<void> refreshStatus() async {
    if (!_configured) return;
    try {
      final info = await Purchases.getCustomerInfo();
      _applyCustomerInfo(info);
    } catch (e) {
      debugPrint('refreshStatus failed: $e');
    }
  }

  /// Call once on app start (e.g. from HomeScreen) to load cache + sync RC.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    final expiryTimestamp = prefs.getInt(_expiryKey);
    if (expiryTimestamp != null) {
      _expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      if (_expiryDate!.isBefore(DateTime.now())) {
        _isPremium = false;
        await prefs.setBool(_premiumKey, false);
      }
    }
    await configure();
  }

  static void _applyCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.all[entitlementId];
    _isPremium = entitlement?.isActive ?? false;
    final expStr = entitlement?.expirationDate;
    _expiryDate = expStr != null ? DateTime.tryParse(expStr) : null;
    _persist();
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, _isPremium);
    if (_expiryDate != null) {
      await prefs.setInt(_expiryKey, _expiryDate!.millisecondsSinceEpoch);
    }
  }

  /// Check if the free trial has already been used (stored locally).
  Future<bool> isTrialUsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trialUsedKey) ?? false;
  }

  /// Fetch current store offerings (use this to show real prices in the UI).
  static Future<Offerings?> getOfferings() async {
    if (!_configured) {
      debugPrint('RevenueCat not configured — getOfferings unavailable.');
      return null;
    }
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('getOfferings failed: $e');
      return null;
    }
  }

  /// Purchase the monthly plan.
  Future<bool> purchaseMonthly() async {
    if (!_configured) return false;
    final pkg = (await SubscriptionService.getOfferings())?.current?.monthly;
    if (pkg == null) return false;
    return _purchasePackage(pkg);
  }

  /// Purchase the yearly plan.
  Future<bool> purchaseYearly() async {
    if (!_configured) return false;
    final pkg = (await SubscriptionService.getOfferings())?.current?.annual;
    if (pkg == null) return false;
    return _purchasePackage(pkg);
  }

  /// Start the 7-day free trial (buys the monthly package; the free trial is
  /// configured on that product inside RevenueCat / the store).
  Future<bool> startFreeTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trialUsedKey, true);
    return purchaseMonthly();
  }

  static Future<bool> _purchasePackage(Package package) async {
    try {
      _isLoading = true;
      final info = await Purchases.purchasePackage(package);
      _applyCustomerInfo(info);
      return _isPremium;
    } on PlatformException catch (e) {
      debugPrint('Purchase failed: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Restore previous purchases (for users who reinstalled the app).
  Future<bool> restorePurchases() async {
    if (!_configured) {
      debugPrint('RevenueCat not configured — cannot restore purchases.');
      return false;
    }
    try {
      final info = await Purchases.restorePurchases();
      _applyCustomerInfo(info);
      return _isPremium;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }

  /// Remaining days until premium expires (0 if not premium).
  Future<int> getRemainingTrialDays() async {
    if (_expiryDate == null) return 0;
    return DateTime.now().difference(_expiryDate!).inDays.abs();
  }
}
