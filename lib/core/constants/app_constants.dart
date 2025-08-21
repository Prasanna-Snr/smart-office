class AppConstants {
  // App Info
  static const String appName = 'Smart Office';
  static const String appVersion = '1.0.0';

  // Temperature Constants
  static const double minTemperature = 15.0;
  static const double maxTemperature = 30.0;
  static const double optimalTempMin = 20.0;
  static const double optimalTempMax = 25.0;

  // User Roles
  static const String defaultRole = 'Employee';
  static const String adminRole = 'Admin';

  // Image Constraints
  static const int maxImageSize = 300000; // 300KB
  static const int imageQuality = 50;
  static const double maxImageDimension = 800;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration serverCheckTimeout = Duration(seconds: 10);

  // Default Values
  static const double defaultTemperature = 22.0;
  static const double defaultHumidity = 50.0;

  // Garbage Level Constants
  static const double maxGarbageLevel = 100.0;
  static const double warningGarbageLevel = 80.0;
  static const double criticalGarbageLevel = 95.0;
  static const double defaultGarbageLevel = 45.0;

  // 🔹 Dashboard card size (add this)
  static const double dashboardCardHeight = 220.0;
}
