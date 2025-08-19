/// Core application constants following DRY principles
/// Maintains consistency across the entire application
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// Application information
  static const String appName = 'Neru Music';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Modern music streaming with offline capabilities';

  /// API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const String apiVersion = 'v1';

  /// UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;

  /// Animation durations (in milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  /// Audio Player Constants
  static const int maxQueueSize = 1000;
  static const double defaultVolume = 0.8;
  static const int skipDurationSeconds = 15;

  /// Cache Configuration
  static const int cacheMaxSize = 100 * 1024 * 1024; // 100MB
  static const int imageCacheMaxAge = 7; // days
  static const int apiCacheMaxAge = 1; // hours

  /// Performance Limits
  static const int maxSearchResults = 50;
  static const int maxPlaylistSize = 10000;
  static const int maxRecentSearches = 20;
}
