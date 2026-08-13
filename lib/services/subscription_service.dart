import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  static const String _premiumKey = 'is_premium';
  static const String _expiryKey = 'premium_expiry';
  static const String _trialUsedKey = 'trial_used';

  bool _isPremium = false;
  DateTime? _expiryDate;
  bool _isLoading = false;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  DateTime? get expiryDate => _expiryDate;

  /// Initialize subscription status
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
  }

  /// Check if trial is used
  Future<bool> isTrialUsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trialUsedKey) ?? false;
  }

  /// Start 7-day free trial
  Future<bool> startFreeTrial() async {
    try {
      // In production, use RevenueCat SDK
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_trialUsedKey, true);
      await prefs.setBool(_premiumKey, true);
      final expiry = DateTime.now().add(const Duration(days: 7));
      await prefs.setInt(_expiryKey, expiry.millisecondsSinceEpoch);
      _isPremium = true;
      _expiryDate = expiry;
      return true;
    } catch (e) {
      debugPrint('Trial start failed: $e');
      return false;
    }
  }

  /// Purchase monthly subscription
  Future<bool> purchaseMonthly() async {
    try {
      // In production, use RevenueCat Purchases.purchasePackage()
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, true);
      final expiry = DateTime.now().add(const Duration(days: 30));
      await prefs.setInt(_expiryKey, expiry.millisecondsSinceEpoch);
      _isPremium = true;
      _expiryDate = expiry;
      return true;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  /// Purchase yearly subscription
  Future<bool> purchaseYearly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, true);
      final expiry = DateTime.now().add(const Duration(days: 365));
      await prefs.setInt(_expiryKey, expiry.millisecondsSinceEpoch);
      _isPremium = true;
      _expiryDate = expiry;
      return true;
    } catch (e) {
      debugPrint('Yearly purchase failed: $e');
      return false;
    }
  }

  /// Restore purchases (for existing subscribers)
  Future<bool> restorePurchases() async {
    try {
      // In production, use RevenueCat Purchases.restorePurchases()
      return true;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }

  /// Get remaining trial days
  Future<int> getRemainingTrialDays() async {
    if (_expiryDate == null) return 0;
    return DateTime.now().difference(_expiryDate!).inDays.abs();
  }
}
