import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/user_preferences.dart';

/// User preferences controller managing app settings and user customization
/// Handles persistence using SharedPreferences for local storage
class UserPreferencesController extends StateNotifier<UserPreferences> {
  static const String _prefsKey = 'user_preferences';
  late SharedPreferences _prefs;

  UserPreferencesController() : super(const UserPreferences()) {
    _initializePreferences();
  }

  /// Initialize and load preferences from storage
  Future<void> _initializePreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadPreferences();
    } catch (e) {
      // Handle initialization error - use default preferences
      state = const UserPreferences();
    }
  }

  /// Load preferences from local storage
  Future<void> _loadPreferences() async {
    try {
      final prefsJson = _prefs.getString(_prefsKey);
      if (prefsJson != null) {
        final prefsMap = jsonDecode(prefsJson) as Map<String, dynamic>;
        state = UserPreferences.fromJson(prefsMap);
      }
    } catch (e) {
      // Handle JSON parsing error - keep default preferences
      state = const UserPreferences();
    }
  }

  /// Save preferences to local storage
  Future<void> _savePreferences() async {
    try {
      final prefsJson = jsonEncode(state.toJson());
      await _prefs.setString(_prefsKey, prefsJson);
    } catch (e) {
      // Handle save error - log or show user feedback
      throw Exception('Failed to save preferences: $e');
    }
  }

  /// Update theme preference
  Future<void> updateTheme(AppTheme theme) async {
    state = state.copyWith(theme: theme);
    await _savePreferences();
  }

  /// Update language preference
  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    await _savePreferences();
  }

  /// Update audio quality settings
  Future<void> updateAudioQuality({
    AudioQuality? streamingQuality,
    AudioQuality? downloadQuality,
  }) async {
    state = state.copyWith(
      audioQuality: streamingQuality ?? state.audioQuality,
      downloadQuality: downloadQuality ?? state.downloadQuality,
    );
    await _savePreferences();
  }

  /// Update playback settings
  Future<void> updatePlaybackSettings({
    bool? autoplay,
    bool? crossfade,
    int? crossfadeDuration,
  }) async {
    state = state.copyWith(
      autoplay: autoplay ?? state.autoplay,
      crossfade: crossfade ?? state.crossfade,
      crossfadeDuration: crossfadeDuration ?? state.crossfadeDuration,
    );
    await _savePreferences();
  }

  /// Update equalizer settings
  Future<void> updateEqualizerSettings({
    bool? enabled,
    String? preset,
    List<double>? customValues,
  }) async {
    state = state.copyWith(
      equalizerEnabled: enabled ?? state.equalizerEnabled,
      equalizerPreset: preset ?? state.equalizerPreset,
      customEqualizerValues: customValues ?? state.customEqualizerValues,
    );
    await _savePreferences();
  }

  /// Update download settings
  Future<void> updateDownloadSettings({
    bool? wifiOnly,
    bool? streamOnMobileData,
    int? maxCacheSize,
    bool? autoSync,
  }) async {
    state = state.copyWith(
      downloadOnWiFiOnly: wifiOnly ?? state.downloadOnWiFiOnly,
      streamOnMobileData: streamOnMobileData ?? state.streamOnMobileData,
      maxCacheSize: maxCacheSize ?? state.maxCacheSize,
      autoSyncOffline: autoSync ?? state.autoSyncOffline,
    );
    await _savePreferences();
  }

  /// Update privacy settings
  Future<void> updatePrivacySettings({
    bool? showExplicitContent,
    bool? enableNotifications,
  }) async {
    state = state.copyWith(
      showExplicitContent: showExplicitContent ?? state.showExplicitContent,
      enableNotifications: enableNotifications ?? state.enableNotifications,
    );
    await _savePreferences();
  }

  /// Update interface settings
  Future<void> updateInterfaceSettings({
    bool? hapticFeedback,
  }) async {
    state = state.copyWith(
      enableHapticFeedback: hapticFeedback ?? state.enableHapticFeedback,
    );
    await _savePreferences();
  }

  /// Update Last.fm settings
  Future<void> updateLastFmSettings({
    bool? enabled,
    String? username,
  }) async {
    state = state.copyWith(
      lastFmScrobbling: enabled ?? state.lastFmScrobbling,
      lastFmUsername: username ?? state.lastFmUsername,
    );
    await _savePreferences();
  }

  /// Set sleep timer
  Future<void> setSleepTimer(int minutes) async {
    state = state.copyWith(sleepTimerDuration: minutes);
    await _savePreferences();
  }

  /// Toggle offline mode
  Future<void> toggleOfflineMode() async {
    state = state.copyWith(offlineMode: !state.offlineMode);
    await _savePreferences();
  }

  /// Add to favorite genres
  Future<void> addFavoriteGenre(String genre) async {
    if (!state.favoriteGenres.contains(genre)) {
      final updatedGenres = [...state.favoriteGenres, genre];
      state = state.copyWith(favoriteGenres: updatedGenres);
      await _savePreferences();
    }
  }

  /// Remove from favorite genres
  Future<void> removeFavoriteGenre(String genre) async {
    final updatedGenres = state.favoriteGenres.where((g) => g != genre).toList();
    state = state.copyWith(favoriteGenres: updatedGenres);
    await _savePreferences();
  }

  /// Block an artist
  Future<void> blockArtist(String artist) async {
    if (!state.blockedArtists.contains(artist)) {
      final updatedBlocked = [...state.blockedArtists, artist];
      state = state.copyWith(blockedArtists: updatedBlocked);
      await _savePreferences();
    }
  }

  /// Unblock an artist
  Future<void> unblockArtist(String artist) async {
    final updatedBlocked = state.blockedArtists.where((a) => a != artist).toList();
    state = state.copyWith(blockedArtists: updatedBlocked);
    await _savePreferences();
  }

  /// Add to recent searches
  Future<void> addRecentSearch(String query) async {
    // Remove if already exists to avoid duplicates
    final updatedSearches = state.recentSearches.where((q) => q != query).toList();
    
    // Add to beginning of list
    updatedSearches.insert(0, query);
    
    // Keep only last 20 searches
    if (updatedSearches.length > 20) {
      updatedSearches.removeRange(20, updatedSearches.length);
    }
    
    state = state.copyWith(recentSearches: updatedSearches);
    await _savePreferences();
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    state = state.copyWith(recentSearches: []);
    await _savePreferences();
  }

  /// Reset all preferences to defaults
  Future<void> resetToDefaults() async {
    state = const UserPreferences();
    await _savePreferences();
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    // TODO: Implement cache clearing logic
    // This would clear downloaded songs, cached images, etc.
  }

  /// Export preferences as JSON string
  String exportPreferences() {
    return jsonEncode(state.toJson());
  }

  /// Import preferences from JSON string
  Future<void> importPreferences(String jsonString) async {
    try {
      final prefsMap = jsonDecode(jsonString) as Map<String, dynamic>;
      state = UserPreferences.fromJson(prefsMap);
      await _savePreferences();
    } catch (e) {
      throw Exception('Invalid preferences format: $e');
    }
  }

  /// Get available languages
  List<LanguageOption> getAvailableLanguages() {
    return [
      const LanguageOption(code: 'en', name: 'English'),
      const LanguageOption(code: 'es', name: 'Español'),
      const LanguageOption(code: 'fr', name: 'Français'),
      const LanguageOption(code: 'de', name: 'Deutsch'),
      const LanguageOption(code: 'it', name: 'Italiano'),
      const LanguageOption(code: 'pt', name: 'Português'),
      const LanguageOption(code: 'ru', name: 'Русский'),
      const LanguageOption(code: 'ja', name: '日本語'),
      const LanguageOption(code: 'ko', name: '한국어'),
      const LanguageOption(code: 'zh', name: '中文'),
    ];
  }

  /// Get available equalizer presets
  List<EqualizerPreset> getEqualizerPresets() {
    return [
      const EqualizerPreset(
        name: 'normal',
        displayName: 'Normal',
        values: [0.0, 0.0, 0.0, 0.0, 0.0],
      ),
      const EqualizerPreset(
        name: 'rock',
        displayName: 'Rock',
        values: [3.0, 1.0, -1.0, 1.0, 3.0],
      ),
      const EqualizerPreset(
        name: 'pop',
        displayName: 'Pop',
        values: [-1.0, 2.0, 3.0, 1.0, -1.0],
      ),
      const EqualizerPreset(
        name: 'jazz',
        displayName: 'Jazz',
        values: [2.0, 1.0, 0.0, 1.0, 3.0],
      ),
      const EqualizerPreset(
        name: 'classical',
        displayName: 'Classical',
        values: [3.0, 2.0, -1.0, 2.0, 3.0],
      ),
      const EqualizerPreset(
        name: 'bass_boost',
        displayName: 'Bass Boost',
        values: [5.0, 3.0, 1.0, 0.0, 0.0],
      ),
      const EqualizerPreset(
        name: 'treble_boost',
        displayName: 'Treble Boost',
        values: [0.0, 0.0, 1.0, 3.0, 5.0],
      ),
      const EqualizerPreset(
        name: 'vocal',
        displayName: 'Vocal',
        values: [-2.0, 1.0, 4.0, 3.0, 1.0],
      ),
    ];
  }
}

/// Language option model
class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;
}

/// Equalizer preset model
class EqualizerPreset {
  const EqualizerPreset({
    required this.name,
    required this.displayName,
    required this.values,
  });

  final String name;
  final String displayName;
  final List<double> values; // [60Hz, 170Hz, 310Hz, 600Hz, 1kHz, 3kHz, 6kHz, 12kHz, 14kHz, 16kHz]
}

/// Provider for user preferences controller
final userPreferencesControllerProvider = 
    StateNotifierProvider<UserPreferencesController, UserPreferences>(
  (ref) => UserPreferencesController(),
);
