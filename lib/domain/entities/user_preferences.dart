import 'package:equatable/equatable.dart';

/// User preference entity for app settings and customization
/// Manages user's personal settings and listening preferences
class UserPreferences extends Equatable {
  const UserPreferences({
    this.theme = AppTheme.dark,
    this.language = 'en',
    this.audioQuality = AudioQuality.high,
    this.downloadQuality = AudioQuality.medium,
    this.autoplay = true,
    this.crossfade = false,
    this.crossfadeDuration = 3,
    this.equalizerEnabled = false,
    this.equalizerPreset = 'normal',
    this.downloadOnWiFiOnly = true,
    this.streamOnMobileData = true,
    this.offlineMode = false,
    this.showExplicitContent = true,
    this.enableNotifications = true,
    this.enableHapticFeedback = true,
    this.sleepTimerDuration = 0,
    this.maxCacheSize = 2048, // MB
    this.autoSyncOffline = true,
    this.lastFmScrobbling = false,
    this.lastFmUsername,
    this.customEqualizerValues,
    this.favoriteGenres = const [],
    this.blockedArtists = const [],
    this.recentSearches = const [],
  });

  /// App theme preference
  final AppTheme theme;
  
  /// Language preference
  final String language;
  
  /// Streaming audio quality
  final AudioQuality audioQuality;
  
  /// Download audio quality
  final AudioQuality downloadQuality;
  
  /// Auto-play next song
  final bool autoplay;
  
  /// Enable crossfade between songs
  final bool crossfade;
  
  /// Crossfade duration in seconds
  final int crossfadeDuration;
  
  /// Enable equalizer
  final bool equalizerEnabled;
  
  /// Equalizer preset name
  final String equalizerPreset;
  
  /// Download only on WiFi
  final bool downloadOnWiFiOnly;
  
  /// Allow streaming on mobile data
  final bool streamOnMobileData;
  
  /// Offline mode enabled
  final bool offlineMode;
  
  /// Show explicit content
  final bool showExplicitContent;
  
  /// Enable push notifications
  final bool enableNotifications;
  
  /// Enable haptic feedback
  final bool enableHapticFeedback;
  
  /// Sleep timer duration in minutes (0 = disabled)
  final int sleepTimerDuration;
  
  /// Maximum cache size in MB
  final int maxCacheSize;
  
  /// Auto-sync offline content
  final bool autoSyncOffline;
  
  /// Enable Last.fm scrobbling
  final bool lastFmScrobbling;
  
  /// Last.fm username
  final String? lastFmUsername;
  
  /// Custom equalizer values [bass, mid, treble]
  final List<double>? customEqualizerValues;
  
  /// User's favorite genres
  final List<String> favoriteGenres;
  
  /// Blocked artists
  final List<String> blockedArtists;
  
  /// Recent search queries
  final List<String> recentSearches;

  /// Creates a copy with updated properties
  UserPreferences copyWith({
    AppTheme? theme,
    String? language,
    AudioQuality? audioQuality,
    AudioQuality? downloadQuality,
    bool? autoplay,
    bool? crossfade,
    int? crossfadeDuration,
    bool? equalizerEnabled,
    String? equalizerPreset,
    bool? downloadOnWiFiOnly,
    bool? streamOnMobileData,
    bool? offlineMode,
    bool? showExplicitContent,
    bool? enableNotifications,
    bool? enableHapticFeedback,
    int? sleepTimerDuration,
    int? maxCacheSize,
    bool? autoSyncOffline,
    bool? lastFmScrobbling,
    String? lastFmUsername,
    List<double>? customEqualizerValues,
    List<String>? favoriteGenres,
    List<String>? blockedArtists,
    List<String>? recentSearches,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      audioQuality: audioQuality ?? this.audioQuality,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      autoplay: autoplay ?? this.autoplay,
      crossfade: crossfade ?? this.crossfade,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      equalizerEnabled: equalizerEnabled ?? this.equalizerEnabled,
      equalizerPreset: equalizerPreset ?? this.equalizerPreset,
      downloadOnWiFiOnly: downloadOnWiFiOnly ?? this.downloadOnWiFiOnly,
      streamOnMobileData: streamOnMobileData ?? this.streamOnMobileData,
      offlineMode: offlineMode ?? this.offlineMode,
      showExplicitContent: showExplicitContent ?? this.showExplicitContent,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      sleepTimerDuration: sleepTimerDuration ?? this.sleepTimerDuration,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      autoSyncOffline: autoSyncOffline ?? this.autoSyncOffline,
      lastFmScrobbling: lastFmScrobbling ?? this.lastFmScrobbling,
      lastFmUsername: lastFmUsername ?? this.lastFmUsername,
      customEqualizerValues: customEqualizerValues ?? this.customEqualizerValues,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      blockedArtists: blockedArtists ?? this.blockedArtists,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'theme': theme.name,
      'language': language,
      'audioQuality': audioQuality.name,
      'downloadQuality': downloadQuality.name,
      'autoplay': autoplay,
      'crossfade': crossfade,
      'crossfadeDuration': crossfadeDuration,
      'equalizerEnabled': equalizerEnabled,
      'equalizerPreset': equalizerPreset,
      'downloadOnWiFiOnly': downloadOnWiFiOnly,
      'streamOnMobileData': streamOnMobileData,
      'offlineMode': offlineMode,
      'showExplicitContent': showExplicitContent,
      'enableNotifications': enableNotifications,
      'enableHapticFeedback': enableHapticFeedback,
      'sleepTimerDuration': sleepTimerDuration,
      'maxCacheSize': maxCacheSize,
      'autoSyncOffline': autoSyncOffline,
      'lastFmScrobbling': lastFmScrobbling,
      'lastFmUsername': lastFmUsername,
      'customEqualizerValues': customEqualizerValues,
      'favoriteGenres': favoriteGenres,
      'blockedArtists': blockedArtists,
      'recentSearches': recentSearches,
    };
  }

  /// Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: AppTheme.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => AppTheme.dark,
      ),
      language: json['language'] ?? 'en',
      audioQuality: AudioQuality.values.firstWhere(
        (e) => e.name == json['audioQuality'],
        orElse: () => AudioQuality.high,
      ),
      downloadQuality: AudioQuality.values.firstWhere(
        (e) => e.name == json['downloadQuality'],
        orElse: () => AudioQuality.medium,
      ),
      autoplay: json['autoplay'] ?? true,
      crossfade: json['crossfade'] ?? false,
      crossfadeDuration: json['crossfadeDuration'] ?? 3,
      equalizerEnabled: json['equalizerEnabled'] ?? false,
      equalizerPreset: json['equalizerPreset'] ?? 'normal',
      downloadOnWiFiOnly: json['downloadOnWiFiOnly'] ?? true,
      streamOnMobileData: json['streamOnMobileData'] ?? true,
      offlineMode: json['offlineMode'] ?? false,
      showExplicitContent: json['showExplicitContent'] ?? true,
      enableNotifications: json['enableNotifications'] ?? true,
      enableHapticFeedback: json['enableHapticFeedback'] ?? true,
      sleepTimerDuration: json['sleepTimerDuration'] ?? 0,
      maxCacheSize: json['maxCacheSize'] ?? 2048,
      autoSyncOffline: json['autoSyncOffline'] ?? true,
      lastFmScrobbling: json['lastFmScrobbling'] ?? false,
      lastFmUsername: json['lastFmUsername'],
      customEqualizerValues: json['customEqualizerValues']?.cast<double>(),
      favoriteGenres: (json['favoriteGenres'] as List<dynamic>?)?.cast<String>() ?? [],
      blockedArtists: (json['blockedArtists'] as List<dynamic>?)?.cast<String>() ?? [],
      recentSearches: (json['recentSearches'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  List<Object?> get props => [
        theme,
        language,
        audioQuality,
        downloadQuality,
        autoplay,
        crossfade,
        crossfadeDuration,
        equalizerEnabled,
        equalizerPreset,
        downloadOnWiFiOnly,
        streamOnMobileData,
        offlineMode,
        showExplicitContent,
        enableNotifications,
        enableHapticFeedback,
        sleepTimerDuration,
        maxCacheSize,
        autoSyncOffline,
        lastFmScrobbling,
        lastFmUsername,
        customEqualizerValues,
        favoriteGenres,
        blockedArtists,
        recentSearches,
      ];
}

/// App theme options
enum AppTheme {
  dark,
  light,
  black, // AMOLED
  system,
}

/// Audio quality options
enum AudioQuality {
  low,    // 128 kbps
  medium, // 256 kbps
  high,   // 320 kbps
  lossless, // FLAC
}
