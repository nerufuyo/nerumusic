import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Analytics event types
enum AnalyticsEvent {
  appOpen,
  appClose,
  songPlay,
  songPause,
  songSkip,
  playlistCreate,
  playlistPlay,
  searchQuery,
  downloadStart,
  downloadComplete,
  settingsChange,
  errorOccurred,
  crashReported,
  userAction,
}

/// Analytics data model
class AnalyticsData {
  const AnalyticsData({
    required this.event,
    required this.timestamp,
    this.properties = const {},
    this.userId,
    this.sessionId,
  });

  final AnalyticsEvent event;
  final DateTime timestamp;
  final Map<String, dynamic> properties;
  final String? userId;
  final String? sessionId;

  Map<String, dynamic> toJson() {
    return {
      'event': event.name,
      'timestamp': timestamp.toIso8601String(),
      'properties': properties,
      'userId': userId,
      'sessionId': sessionId,
    };
  }

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      event: AnalyticsEvent.values.firstWhere(
        (e) => e.name == json['event'],
        orElse: () => AnalyticsEvent.userAction,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      userId: json['userId'],
      sessionId: json['sessionId'],
    );
  }
}

/// Crash report data model
class CrashReport {
  const CrashReport({
    required this.error,
    required this.stackTrace,
    required this.timestamp,
    this.userId,
    this.deviceInfo = const {},
    this.appInfo = const {},
    this.customData = const {},
  });

  final String error;
  final String stackTrace;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> appInfo;
  final Map<String, dynamic> customData;

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'stackTrace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'deviceInfo': deviceInfo,
      'appInfo': appInfo,
      'customData': customData,
    };
  }

  factory CrashReport.fromJson(Map<String, dynamic> json) {
    return CrashReport(
      error: json['error'],
      stackTrace: json['stackTrace'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      deviceInfo: Map<String, dynamic>.from(json['deviceInfo'] ?? {}),
      appInfo: Map<String, dynamic>.from(json['appInfo'] ?? {}),
      customData: Map<String, dynamic>.from(json['customData'] ?? {}),
    );
  }
}

/// Analytics and crash reporting service
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _analyticsKey = 'analytics_events';
  static const String _crashReportsKey = 'crash_reports';
  static const String _userIdKey = 'analytics_user_id';

  final List<AnalyticsData> _pendingEvents = [];
  final List<CrashReport> _pendingCrashReports = [];
  
  String? _currentSessionId;
  String? _currentUserId;
  bool _isInitialized = false;
  bool _analyticsEnabled = true;
  bool _crashReportingEnabled = true;
  Timer? _flushTimer;

  /// Initialize analytics service
  Future<void> initialize({
    bool analyticsEnabled = true,
    bool crashReportingEnabled = true,
    String? userId,
  }) async {
    if (_isInitialized) return;

    _analyticsEnabled = analyticsEnabled;
    _crashReportingEnabled = crashReportingEnabled;
    _currentUserId = userId ?? await _generateUserId();
    _currentSessionId = _generateSessionId();

    // Load pending events from storage
    await _loadPendingData();

    // Set up automatic flushing
    _flushTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => flushEvents(),
    );

    // Set up crash handling
    if (_crashReportingEnabled) {
      _setupCrashHandling();
    }

    _isInitialized = true;

    // Track app open
    await trackEvent(AnalyticsEvent.appOpen, {
      'app_version': await _getAppVersion(),
      'platform': Platform.operatingSystem,
      'session_id': _currentSessionId,
    });
  }

  /// Track analytics event
  Future<void> trackEvent(
    AnalyticsEvent event, [
    Map<String, dynamic>? properties,
  ]) async {
    if (!_isInitialized || !_analyticsEnabled) return;

    final eventData = AnalyticsData(
      event: event,
      timestamp: DateTime.now(),
      properties: properties ?? {},
      userId: _currentUserId,
      sessionId: _currentSessionId,
    );

    _pendingEvents.add(eventData);
    await _savePendingEvents();

    // Auto-flush critical events
    if (_isCriticalEvent(event)) {
      await flushEvents();
    }

    debugPrint('Analytics: ${event.name} - ${properties ?? {}}');
  }

  /// Track custom event with properties
  Future<void> trackCustomEvent(
    String eventName, [
    Map<String, dynamic>? properties,
  ]) async {
    await trackEvent(
      AnalyticsEvent.userAction,
      {
        'custom_event': eventName,
        ...?properties,
      },
    );
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName) async {
    await trackEvent(AnalyticsEvent.userAction, {
      'action': 'screen_view',
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track user property
  Future<void> setUserProperty(String key, dynamic value) async {
    await trackEvent(AnalyticsEvent.userAction, {
      'action': 'user_property_set',
      'property_key': key,
      'property_value': value,
    });
  }

  /// Report crash
  Future<void> reportCrash(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? customData,
  }) async {
    if (!_crashReportingEnabled) return;

    final crashReport = CrashReport(
      error: error.toString(),
      stackTrace: stackTrace?.toString() ?? '',
      timestamp: DateTime.now(),
      userId: _currentUserId,
      deviceInfo: await _getDeviceInfo(),
      appInfo: await _getAppInfo(),
      customData: customData ?? {},
    );

    _pendingCrashReports.add(crashReport);
    await _savePendingCrashReports();

    // Immediately flush crash reports
    await flushCrashReports();

    debugPrint('Crash reported: $error');
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    _currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  /// Start new session
  Future<void> startNewSession() async {
    _currentSessionId = _generateSessionId();
    await trackEvent(AnalyticsEvent.appOpen, {
      'session_id': _currentSessionId,
      'session_start': DateTime.now().toIso8601String(),
    });
  }

  /// End current session
  Future<void> endSession() async {
    await trackEvent(AnalyticsEvent.appClose, {
      'session_id': _currentSessionId,
      'session_end': DateTime.now().toIso8601String(),
    });
    await flushEvents();
  }

  /// Flush pending events to remote service
  Future<void> flushEvents() async {
    if (_pendingEvents.isEmpty) return;

    try {
      // TODO: Send events to analytics service
      // This would typically send to Firebase Analytics, Mixpanel, etc.
      
      // Simulated implementation
      debugPrint('Flushing ${_pendingEvents.length} analytics events');
      
      // For demo purposes, just clear the events
      _pendingEvents.clear();
      await _savePendingEvents();
      
    } catch (e) {
      debugPrint('Failed to flush analytics events: $e');
    }
  }

  /// Flush pending crash reports
  Future<void> flushCrashReports() async {
    if (_pendingCrashReports.isEmpty) return;

    try {
      // TODO: Send crash reports to service
      // This would typically send to Crashlytics, Sentry, etc.
      
      // Simulated implementation
      debugPrint('Flushing ${_pendingCrashReports.length} crash reports');
      
      // For demo purposes, just clear the reports
      _pendingCrashReports.clear();
      await _savePendingCrashReports();
      
    } catch (e) {
      debugPrint('Failed to flush crash reports: $e');
    }
  }

  /// Enable or disable analytics
  void setAnalyticsEnabled(bool enabled) {
    _analyticsEnabled = enabled;
  }

  /// Enable or disable crash reporting
  void setCrashReportingEnabled(bool enabled) {
    _crashReportingEnabled = enabled;
  }

  /// Get analytics statistics
  Map<String, dynamic> getAnalyticsStats() {
    return {
      'pending_events': _pendingEvents.length,
      'pending_crash_reports': _pendingCrashReports.length,
      'analytics_enabled': _analyticsEnabled,
      'crash_reporting_enabled': _crashReportingEnabled,
      'current_session': _currentSessionId,
      'user_id': _currentUserId,
    };
  }

  /// Setup crash handling
  void _setupCrashHandling() {
    // Handle Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      reportCrash(
        details.exception,
        details.stack,
        customData: {
          'library': details.library,
          'context': details.context?.toString(),
          'information_collector': details.informationCollector?.toString(),
        },
      );
    };

    // Handle async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      reportCrash(error, stack, customData: {'type': 'async_error'});
      return true;
    };
  }

  /// Check if event is critical and should be flushed immediately
  bool _isCriticalEvent(AnalyticsEvent event) {
    return [
      AnalyticsEvent.errorOccurred,
      AnalyticsEvent.crashReported,
      AnalyticsEvent.appClose,
    ].contains(event);
  }

  /// Generate unique user ID
  Future<String> _generateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? existingId = prefs.getString(_userIdKey);
    
    if (existingId != null) {
      return existingId;
    }

    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_userIdKey, newId);
    return newId;
  }

  /// Generate session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      return {
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
        'locale': Platform.localeName,
        'number_of_processors': Platform.numberOfProcessors,
      };
    } catch (e) {
      return {'error': 'Failed to get device info: $e'};
    }
  }

  /// Get app information
  Future<Map<String, dynamic>> _getAppInfo() async {
    try {
      // TODO: Get actual app version from package info
      return {
        'app_version': await _getAppVersion(),
        'build_mode': kDebugMode ? 'debug' : 'release',
        'flutter_version': 'unknown', // Could be injected at build time
      };
    } catch (e) {
      return {'error': 'Failed to get app info: $e'};
    }
  }

  /// Get app version
  Future<String> _getAppVersion() async {
    // TODO: Implement actual version retrieval
    return '1.0.0';
  }

  /// Load pending events from storage
  Future<void> _loadPendingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load analytics events
      final eventsJson = prefs.getStringList(_analyticsKey) ?? [];
      _pendingEvents.clear();
      for (final eventStr in eventsJson) {
        try {
          final eventData = AnalyticsData.fromJson(json.decode(eventStr));
          _pendingEvents.add(eventData);
        } catch (e) {
          debugPrint('Failed to parse analytics event: $e');
        }
      }

      // Load crash reports
      final crashReportsJson = prefs.getStringList(_crashReportsKey) ?? [];
      _pendingCrashReports.clear();
      for (final reportStr in crashReportsJson) {
        try {
          final reportData = CrashReport.fromJson(json.decode(reportStr));
          _pendingCrashReports.add(reportData);
        } catch (e) {
          debugPrint('Failed to parse crash report: $e');
        }
      }

    } catch (e) {
      debugPrint('Failed to load pending analytics data: $e');
    }
  }

  /// Save pending events to storage
  Future<void> _savePendingEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = _pendingEvents
          .map((event) => json.encode(event.toJson()))
          .toList();
      await prefs.setStringList(_analyticsKey, eventsJson);
    } catch (e) {
      debugPrint('Failed to save pending events: $e');
    }
  }

  /// Save pending crash reports to storage
  Future<void> _savePendingCrashReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = _pendingCrashReports
          .map((report) => json.encode(report.toJson()))
          .toList();
      await prefs.setStringList(_crashReportsKey, reportsJson);
    } catch (e) {
      debugPrint('Failed to save pending crash reports: $e');
    }
  }

  /// Dispose analytics service
  Future<void> dispose() async {
    await endSession();
    _flushTimer?.cancel();
    _flushTimer = null;
    _isInitialized = false;
  }
}

/// Convenience methods for common analytics events
extension AnalyticsConvenience on AnalyticsService {
  /// Track song play
  Future<void> trackSongPlay(String songId, String songTitle, String artist) async {
    await trackEvent(AnalyticsEvent.songPlay, {
      'song_id': songId,
      'song_title': songTitle,
      'artist': artist,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track search
  Future<void> trackSearch(String query, int resultsCount) async {
    await trackEvent(AnalyticsEvent.searchQuery, {
      'query': query,
      'results_count': resultsCount,
      'query_length': query.length,
    });
  }

  /// Track playlist creation
  Future<void> trackPlaylistCreation(String playlistId, int songCount) async {
    await trackEvent(AnalyticsEvent.playlistCreate, {
      'playlist_id': playlistId,
      'song_count': songCount,
    });
  }

  /// Track download
  Future<void> trackDownload(String contentId, String contentType) async {
    await trackEvent(AnalyticsEvent.downloadStart, {
      'content_id': contentId,
      'content_type': contentType,
    });
  }
}
