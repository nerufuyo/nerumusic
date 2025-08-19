import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sleep timer state
class SleepTimerState {
  const SleepTimerState({
    this.isActive = false,
    this.remainingDuration = Duration.zero,
    this.originalDuration = Duration.zero,
    this.fadeOutDuration = const Duration(seconds: 10),
    this.pauseAfterCurrentSong = false,
    this.stopAfterCurrentPlaylist = false,
    this.isLoading = false,
    this.error,
  });

  final bool isActive;
  final Duration remainingDuration;
  final Duration originalDuration;
  final Duration fadeOutDuration;
  final bool pauseAfterCurrentSong;
  final bool stopAfterCurrentPlaylist;
  final bool isLoading;
  final String? error;

  SleepTimerState copyWith({
    bool? isActive,
    Duration? remainingDuration,
    Duration? originalDuration,
    Duration? fadeOutDuration,
    bool? pauseAfterCurrentSong,
    bool? stopAfterCurrentPlaylist,
    bool? isLoading,
    String? error,
  }) {
    return SleepTimerState(
      isActive: isActive ?? this.isActive,
      remainingDuration: remainingDuration ?? this.remainingDuration,
      originalDuration: originalDuration ?? this.originalDuration,
      fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
      pauseAfterCurrentSong: pauseAfterCurrentSong ?? this.pauseAfterCurrentSong,
      stopAfterCurrentPlaylist: stopAfterCurrentPlaylist ?? this.stopAfterCurrentPlaylist,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  double get progress {
    if (originalDuration == Duration.zero) return 0.0;
    return 1.0 - (remainingDuration.inMilliseconds / originalDuration.inMilliseconds);
  }

  String get formattedRemainingTime {
    final hours = remainingDuration.inHours;
    final minutes = remainingDuration.inMinutes.remainder(60);
    final seconds = remainingDuration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// Sleep timer controller managing scheduled playback stopping
/// Provides various timer modes and fade-out functionality
class SleepTimerController extends StateNotifier<SleepTimerState> {
  // ignore: unused_field
  final Ref _ref; // Reserved for future music player integration
  Timer? _timer;
  Timer? _fadeTimer;

  SleepTimerController(this._ref) : super(const SleepTimerState()) {
    // TODO: Initialize music player integration
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  /// Start sleep timer with specified duration
  Future<void> startTimer(Duration duration) async {
    await _cancelTimer();
    
    state = state.copyWith(
      isActive: true,
      remainingDuration: duration,
      originalDuration: duration,
      pauseAfterCurrentSong: false,
      stopAfterCurrentPlaylist: false,
      isLoading: false,
      error: null,
    );

    _startCountdown();
  }

  /// Start timer to pause after current song
  Future<void> pauseAfterCurrentSong() async {
    await _cancelTimer();
    
    state = state.copyWith(
      isActive: true,
      pauseAfterCurrentSong: true,
      stopAfterCurrentPlaylist: false,
      remainingDuration: Duration.zero,
      originalDuration: Duration.zero,
      isLoading: false,
      error: null,
    );

    // Listen for song completion
    _listenForSongCompletion();
  }

  /// Start timer to stop after current playlist
  Future<void> stopAfterCurrentPlaylist() async {
    await _cancelTimer();
    
    state = state.copyWith(
      isActive: true,
      pauseAfterCurrentSong: false,
      stopAfterCurrentPlaylist: true,
      remainingDuration: Duration.zero,
      originalDuration: Duration.zero,
      isLoading: false,
      error: null,
    );

    // Listen for playlist completion
    _listenForPlaylistCompletion();
  }

  /// Cancel active sleep timer
  Future<void> cancelTimer() async {
    await _cancelTimer();
    
    state = state.copyWith(
      isActive: false,
      remainingDuration: Duration.zero,
      originalDuration: Duration.zero,
      pauseAfterCurrentSong: false,
      stopAfterCurrentPlaylist: false,
      error: null,
    );
  }

  /// Set fade out duration
  void setFadeOutDuration(Duration duration) {
    state = state.copyWith(fadeOutDuration: duration);
  }

  /// Add time to active timer
  Future<void> addTime(Duration duration) async {
    if (!state.isActive || state.pauseAfterCurrentSong || state.stopAfterCurrentPlaylist) {
      return;
    }

    final newRemaining = state.remainingDuration + duration;
    final newOriginal = state.originalDuration + duration;
    
    state = state.copyWith(
      remainingDuration: newRemaining,
      originalDuration: newOriginal,
    );
  }

  /// Subtract time from active timer
  Future<void> subtractTime(Duration duration) async {
    if (!state.isActive || state.pauseAfterCurrentSong || state.stopAfterCurrentPlaylist) {
      return;
    }

    final calculated = state.remainingDuration - duration;
    final newRemaining = calculated < Duration.zero 
        ? Duration.zero 
        : (calculated > state.originalDuration ? state.originalDuration : calculated);
    
    state = state.copyWith(remainingDuration: newRemaining);
    
    // If time reduced to zero, trigger timer completion
    if (newRemaining == Duration.zero) {
      await _onTimerComplete();
    }
  }

  /// Start countdown timer
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newRemaining = state.remainingDuration - const Duration(seconds: 1);
      
      if (newRemaining <= Duration.zero) {
        _onTimerComplete();
      } else {
        state = state.copyWith(remainingDuration: newRemaining);
        
        // Start fade out if approaching end
        if (newRemaining <= state.fadeOutDuration && _fadeTimer == null) {
          _startFadeOut();
        }
      }
    });
  }

  /// Listen for current song completion
  void _listenForSongCompletion() {
    // TODO: Implement actual music player integration
    // This would listen to the music player's state changes
    
    // Simulated implementation
    Timer.periodic(const Duration(seconds: 1), (timer) {
      // Check if current song has ended
      // This would typically check the music player's current position
      // against the song duration
      
      // For simulation, we'll just wait for a random time
      if (DateTime.now().millisecondsSinceEpoch % 30000 < 1000) {
        timer.cancel();
        _onTimerComplete();
      }
    });
  }

  /// Listen for playlist completion
  void _listenForPlaylistCompletion() {
    // TODO: Implement actual playlist completion detection
    // This would monitor when the current playlist finishes
    
    // Simulated implementation
    Timer.periodic(const Duration(seconds: 5), (timer) {
      // Check if playlist has ended
      // This would typically check if there are no more songs in queue
      
      // For simulation, we'll just wait for a longer random time
      if (DateTime.now().millisecondsSinceEpoch % 60000 < 5000) {
        timer.cancel();
        _onTimerComplete();
      }
    });
  }

  /// Start fade out process
  void _startFadeOut() {
    const fadeSteps = 20;
    final stepDuration = state.fadeOutDuration ~/ fadeSteps;
    
    _fadeTimer = Timer.periodic(stepDuration, (timer) {
      // TODO: Apply volume fade to music player
      // final progress = timer.tick / fadeSteps;
      // final volume = 1.0 - progress;
      // _musicPlayer.setVolume(volume);
      
      if (timer.tick >= fadeSteps) {
        timer.cancel();
        _fadeTimer = null;
      }
    });
  }

  /// Handle timer completion
  Future<void> _onTimerComplete() async {
    await _cancelTimer();
    
    try {
      // TODO: Integrate with actual music player
      // await _ref.read(musicPlayerProvider.notifier).pause();
      
      // Reset volume after fade out
      // await _ref.read(musicPlayerProvider.notifier).setVolume(1.0);
      
      state = state.copyWith(
        isActive: false,
        remainingDuration: Duration.zero,
        pauseAfterCurrentSong: false,
        stopAfterCurrentPlaylist: false,
      );
      
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to execute sleep timer: $e',
        isActive: false,
      );
    }
  }

  /// Cancel all active timers
  Future<void> _cancelTimer() async {
    _timer?.cancel();
    _timer = null;
    
    _fadeTimer?.cancel();
    _fadeTimer = null;
    
    // Reset volume if fade was in progress
    // TODO: Reset volume in music player
    // await _ref.read(musicPlayerProvider.notifier).setVolume(1.0);
  }

  /// Get quick timer presets
  static List<SleepTimerPreset> getPresets() {
    return [
      SleepTimerPreset(
        name: '5 minutes',
        duration: const Duration(minutes: 5),
        icon: '⏰',
      ),
      SleepTimerPreset(
        name: '10 minutes',
        duration: const Duration(minutes: 10),
        icon: '⏰',
      ),
      SleepTimerPreset(
        name: '15 minutes',
        duration: const Duration(minutes: 15),
        icon: '⏰',
      ),
      SleepTimerPreset(
        name: '30 minutes',
        duration: const Duration(minutes: 30),
        icon: '⏰',
      ),
      SleepTimerPreset(
        name: '45 minutes',
        duration: const Duration(minutes: 45),
        icon: '⏰',
      ),
      SleepTimerPreset(
        name: '1 hour',
        duration: const Duration(hours: 1),
        icon: '⏰',
      ),
      SleepTimerPreset(
        name: '1.5 hours',
        duration: const Duration(hours: 1, minutes: 30),
        icon: '⏰',
      ),
      SleepTimerPreset(
        name: '2 hours',
        duration: const Duration(hours: 2),
        icon: '⏰',
      ),
    ];
  }

  /// Get fade out duration presets
  static List<Duration> getFadeOutPresets() {
    return [
      const Duration(seconds: 5),
      const Duration(seconds: 10),
      const Duration(seconds: 15),
      const Duration(seconds: 30),
      const Duration(minutes: 1),
      const Duration(minutes: 2),
    ];
  }
}

/// Sleep timer preset
class SleepTimerPreset {
  const SleepTimerPreset({
    required this.name,
    required this.duration,
    required this.icon,
  });

  final String name;
  final Duration duration;
  final String icon;
}

/// Provider for sleep timer controller
final sleepTimerControllerProvider = 
    StateNotifierProvider<SleepTimerController, SleepTimerState>(
  (ref) => SleepTimerController(ref),
);
