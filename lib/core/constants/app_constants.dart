class AppConstants {
  AppConstants._();

  static const String appName = 'Luna';
  static const String appVersion = '1.0.0';

  static const String revenueCatApiKeyAndroid = 'YOUR_RC_ANDROID_KEY';
  static const String revenueCatApiKeyIos = 'YOUR_RC_IOS_KEY';
  static const String premiumEntitlement = 'premium';
  static const String monthlyOffering = 'monthly';
  static const String yearlyOffering = 'yearly';

  static const String dbName = 'luna_db';
  static const String encryptionKeyStorageKey = 'luna_encryption_key';

  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int minCycleLength = 21;
  static const int maxCycleLength = 45;

  /// Minimum cycles required for a statistically meaningful prediction.
  static const int minCyclesForPrediction = 3;

  static const String backupFileExtension = '.luna';
  static const String backupMimeType = 'application/octet-stream';
}
