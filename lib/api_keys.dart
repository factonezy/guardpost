/// API keys for external services.
/// These are set via dart-defines during build (see GitHub Actions workflow).
class ApiKeys {
  /// Google Safe Browsing API key.
  /// Set via --dart-define=SAFE_BROWSING_API_KEY=your_key_here
  static const String safeBrowsingApiKey =
      String.fromEnvironment('SAFE_BROWSING_API_KEY', defaultValue: '');

  /// Have I Been Pwned API key (optional, not used in the free tier).
  /// Set via --dart-define=HIBP_API_KEY=your_key_here
  static const String hibpApiKey =
      String.fromEnvironment('HIBP_API_KEY', defaultValue: '');

  /// RevenueCat public API key (for iOS/Android, but we use the RevenueCat Flutter SDK which uses the app user ID).
  /// Actually, RevenueCat SDK uses the app user ID and we configure the SDK with the API key in the native code.
  /// For simplicity, we don't use a dart-define for RevenueCat here; we'll set it in the native Android/iOS code.
  /// However, if we want to set it via dart-define, we can.
  static const String revenueCatApiKey =
      String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');
}
