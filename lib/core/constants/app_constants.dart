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

  static const Duration quickAnim = Duration(milliseconds: 200);
}

class AppRadius {
  AppRadius._();

  static const double card = 14;
  static const double container = 16;
  static const double button = 18;
  static const double pill = 20;
  static const double sheet = 24;
}
