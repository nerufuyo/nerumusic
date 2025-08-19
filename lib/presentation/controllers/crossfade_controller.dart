import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Crossfade state
class CrossfadeState {
  const CrossfadeState({
    this.isEnabled = false,
    this.duration = const Duration(seconds: 3),
    this.curve = CrossfadeCurve.linear,
    this.isActive = false,
    this.progress = 0.0,
    this.currentTrackVolume = 1.0,
    this.nextTrackVolume = 0.0,
    this.autoEnable = true,
    this.enableOnShuffle = true,
    this.enableOnManualSkip = true,
  });

  final bool isEnabled;
  final Duration duration;
  final CrossfadeCurve curve;
  final bool isActive;
  final double progress; // 0.0 to 1.0
  final double currentTrackVolume;
  final double nextTrackVolume;
  final bool autoEnable;
  final bool enableOnShuffle;
  final bool enableOnManualSkip;

  CrossfadeState copyWith({
    bool? isEnabled,
    Duration? duration,
    CrossfadeCurve? curve,
    bool? isActive,
    double? progress,
    double? currentTrackVolume,
    double? nextTrackVolume,
    bool? autoEnable,
    bool? enableOnShuffle,
    bool? enableOnManualSkip,
  }) {
    return CrossfadeState(
      isEnabled: isEnabled ?? this.isEnabled,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      isActive: isActive ?? this.isActive,
      progress: progress ?? this.progress,
      currentTrackVolume: currentTrackVolume ?? this.currentTrackVolume,
      nextTrackVolume: nextTrackVolume ?? this.nextTrackVolume,
      autoEnable: autoEnable ?? this.autoEnable,
      enableOnShuffle: enableOnShuffle ?? this.enableOnShuffle,
      enableOnManualSkip: enableOnManualSkip ?? this.enableOnManualSkip,
    );
  }
}

/// Crossfade curve types
enum CrossfadeCurve {
  linear,
  exponential,
  logarithmic,
  smoothStep,
  cosine,
}

/// Track transition types
enum TransitionType {
  automatic, // Natural track ending
  manualSkip, // User skipped
  shuffle, // Shuffle mode transition
  playlistEnd, // End of playlist
}

/// Crossfade controller managing smooth transitions between tracks
/// Provides various curve types and automatic/manual crossfading
class CrossfadeController extends StateNotifier<CrossfadeState> {
  // ignore: unused_field
  final Ref _ref; // Reserved for future music player integration
  Timer? _crossfadeTimer;
  Timer? _monitorTimer;

  CrossfadeController(this._ref) : super(const CrossfadeState()) {
    _startMonitoring();
  }

  @override
  void dispose() {
    _stopCrossfade();
    _stopMonitoring();
    super.dispose();
  }

  /// Enable or disable crossfade
  void setEnabled(bool enabled) {
    state = state.copyWith(isEnabled: enabled);
    if (!enabled && state.isActive) {
      _stopCrossfade();
    }
  }

  /// Set crossfade duration
  void setDuration(Duration duration) {
    // Clamp duration between 500ms and 30 seconds
    Duration clampedDuration;
    if (duration < const Duration(milliseconds: 500)) {
      clampedDuration = const Duration(milliseconds: 500);
    } else if (duration > const Duration(seconds: 30)) {
      clampedDuration = const Duration(seconds: 30);
    } else {
      clampedDuration = duration;
    }
    
    state = state.copyWith(duration: clampedDuration);
  }

  /// Set crossfade curve
  void setCurve(CrossfadeCurve curve) {
    state = state.copyWith(curve: curve);
  }

  /// Set auto-enable settings
  void setAutoSettings({
    bool? autoEnable,
    bool? enableOnShuffle,
    bool? enableOnManualSkip,
  }) {
    state = state.copyWith(
      autoEnable: autoEnable ?? state.autoEnable,
      enableOnShuffle: enableOnShuffle ?? state.enableOnShuffle,
      enableOnManualSkip: enableOnManualSkip ?? state.enableOnManualSkip,
    );
  }

  /// Start crossfade transition
  Future<void> startCrossfade({
    required TransitionType transitionType,
    Duration? customDuration,
  }) async {
    if (!state.isEnabled || state.isActive) return;

    // Check if crossfade should be enabled for this transition type
    if (!_shouldCrossfade(transitionType)) return;

    final duration = customDuration ?? state.duration;
    
    state = state.copyWith(
      isActive: true,
      progress: 0.0,
      currentTrackVolume: 1.0,
      nextTrackVolume: 0.0,
    );

    // Start crossfade timer
    _startCrossfadeTimer(duration);

    // TODO: Notify music player to prepare next track
    // await _ref.read(musicPlayerProvider.notifier).prepareNextTrack();
  }

  /// Stop crossfade immediately
  void stopCrossfade() {
    _stopCrossfade();
  }

  /// Preview crossfade with current settings
  Future<void> previewCrossfade() async {
    if (state.isActive) return;

    const previewDuration = Duration(seconds: 5);
    await startCrossfade(
      transitionType: TransitionType.automatic,
      customDuration: previewDuration,
    );
  }

  /// Calculate volume for current track based on progress and curve
  double _calculateCurrentTrackVolume(double progress) {
    final adjustedProgress = _applyCurve(progress, state.curve);
    return 1.0 - adjustedProgress;
  }

  /// Calculate volume for next track based on progress and curve
  double _calculateNextTrackVolume(double progress) {
    final adjustedProgress = _applyCurve(progress, state.curve);
    return adjustedProgress;
  }

  /// Apply crossfade curve to linear progress
  double _applyCurve(double linearProgress, CrossfadeCurve curve) {
    switch (curve) {
      case CrossfadeCurve.linear:
        return linearProgress;
      
      case CrossfadeCurve.exponential:
        return linearProgress * linearProgress;
      
      case CrossfadeCurve.logarithmic:
        return sqrt(linearProgress);
      
      case CrossfadeCurve.smoothStep:
        return linearProgress * linearProgress * (3.0 - 2.0 * linearProgress);
      
      case CrossfadeCurve.cosine:
        return (1.0 - cos(linearProgress * pi)) / 2.0;
    }
  }

  /// Check if crossfade should be enabled for transition type
  bool _shouldCrossfade(TransitionType transitionType) {
    if (!state.autoEnable) return false;

    switch (transitionType) {
      case TransitionType.automatic:
        return true;
      case TransitionType.manualSkip:
        return state.enableOnManualSkip;
      case TransitionType.shuffle:
        return state.enableOnShuffle;
      case TransitionType.playlistEnd:
        return false; // Usually don't crossfade at playlist end
    }
  }

  /// Start crossfade timer
  void _startCrossfadeTimer(Duration duration) {
    _crossfadeTimer?.cancel();
    
    const updateInterval = Duration(milliseconds: 50);
    final totalSteps = duration.inMilliseconds / updateInterval.inMilliseconds;
    int currentStep = 0;

    _crossfadeTimer = Timer.periodic(updateInterval, (timer) {
      currentStep++;
      final progress = (currentStep / totalSteps).clamp(0.0, 1.0);
      
      final currentVolume = _calculateCurrentTrackVolume(progress);
      final nextVolume = _calculateNextTrackVolume(progress);
      
      state = state.copyWith(
        progress: progress,
        currentTrackVolume: currentVolume,
        nextTrackVolume: nextVolume,
      );

      // TODO: Apply volumes to music player
      // await _ref.read(musicPlayerProvider.notifier).setCurrentTrackVolume(currentVolume);
      // await _ref.read(musicPlayerProvider.notifier).setNextTrackVolume(nextVolume);

      if (progress >= 1.0) {
        _completeCrossfade();
      }
    });
  }

  /// Complete crossfade transition
  void _completeCrossfade() {
    _stopCrossfade();
    
    // TODO: Notify music player that crossfade is complete
    // await _ref.read(musicPlayerProvider.notifier).completeTrackTransition();
  }

  /// Stop crossfade timer and reset state
  void _stopCrossfade() {
    _crossfadeTimer?.cancel();
    _crossfadeTimer = null;
    
    state = state.copyWith(
      isActive: false,
      progress: 0.0,
      currentTrackVolume: 1.0,
      nextTrackVolume: 0.0,
    );
  }

  /// Start monitoring for automatic crossfade triggers
  void _startMonitoring() {
    _monitorTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _checkForCrossfadeTriggers(),
    );
  }

  /// Stop monitoring
  void _stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  /// Check if crossfade should be triggered automatically
  void _checkForCrossfadeTriggers() {
    if (!state.isEnabled || state.isActive) return;

    // TODO: Check music player state for crossfade triggers
    // This would typically check:
    // - Current track remaining time vs crossfade duration
    // - If next track is available
    // - Current playback state
    
    // Example logic:
    // final musicState = _ref.read(musicPlayerProvider);
    // final remainingTime = musicState.duration - musicState.position;
    // 
    // if (remainingTime <= state.duration && musicState.hasNextTrack) {
    //   startCrossfade(transitionType: TransitionType.automatic);
    // }
  }

  /// Get available crossfade durations
  static List<Duration> getAvailableDurations() {
    return [
      const Duration(milliseconds: 500),
      const Duration(seconds: 1),
      const Duration(seconds: 2),
      const Duration(seconds: 3),
      const Duration(seconds: 5),
      const Duration(seconds: 8),
      const Duration(seconds: 10),
      const Duration(seconds: 15),
      const Duration(seconds: 20),
      const Duration(seconds: 30),
    ];
  }

  /// Get curve descriptions
  static Map<CrossfadeCurve, String> getCurveDescriptions() {
    return {
      CrossfadeCurve.linear: 'Linear - Equal power transition',
      CrossfadeCurve.exponential: 'Exponential - Gradual fade in, quick fade out',
      CrossfadeCurve.logarithmic: 'Logarithmic - Quick fade in, gradual fade out',
      CrossfadeCurve.smoothStep: 'Smooth Step - Smooth acceleration and deceleration',
      CrossfadeCurve.cosine: 'Cosine - Natural S-curve transition',
    };
  }

  /// Get crossfade statistics
  Map<String, dynamic> getCrossfadeStats() {
    return {
      'is_enabled': state.isEnabled,
      'is_active': state.isActive,
      'duration_seconds': state.duration.inSeconds,
      'curve': state.curve.name,
      'current_progress': state.progress,
      'current_track_volume': state.currentTrackVolume,
      'next_track_volume': state.nextTrackVolume,
      'auto_settings': {
        'auto_enable': state.autoEnable,
        'enable_on_shuffle': state.enableOnShuffle,
        'enable_on_manual_skip': state.enableOnManualSkip,
      },
    };
  }
}

/// Provider for crossfade controller
final crossfadeControllerProvider = 
    StateNotifierProvider<CrossfadeController, CrossfadeState>(
  (ref) => CrossfadeController(ref),
);
