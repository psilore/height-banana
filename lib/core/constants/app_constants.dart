/// Application-wide constants
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // App Info
  static const String appName = 'Height Banana';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String sessionsCollection = 'training_sessions';

  // Hive Boxes
  static const String userBoxName = 'user_box';
  static const String sessionsBoxName = 'sessions_box';
  static const String cacheBoxName = 'cache_box';

  // Hive Type IDs
  static const int userTypeId = 0;
  static const int trainingSessionTypeId = 1;
  static const int endTypeId = 2;
  static const int arrowTypeId = 3;
  static const int targetFaceTypeId = 4;

  // Default Values
  static const int defaultArrowsPerEnd = 6;
  static const double defaultTargetDistance = 18.0; // meters
  static const List<String> bowTypes = [
    'Recurve',
    'Compound',
    'Longbow',
    'Barebow',
  ];

  // Score Values
  static const List<String> scoreValues = [
    'X',
    '10',
    '9',
    '8',
    '7',
    '6',
    '5',
    '4',
    '3',
    '2',
    '1',
    'M',
  ];

  // Camera Settings
  static const int imageCaptureQuality = 95; // 0-100
  static const double imageCompressionRatio = 0.8;

  // ML Settings
  static const double mlConfidenceThreshold = 0.7;
  static const int mlMaxDetections = 10;
}
