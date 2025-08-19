import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/song.dart';
import '../../core/errors/exceptions.dart';

/// Audio player state representing current playback status
/// Follows immutable state pattern for predictable UI updates
class AudioPlayerState {
  const AudioPlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.isPaused = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 0.8,
    this.playbackSpeed = 1.0,
    this.error,
  });

  final Song? currentSong;
  final bool isPlaying;
  final bool isPaused;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double volume;
  final double playbackSpeed;
  final String? error;

  /// Creates a copy with updated properties
  AudioPlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    bool? isPaused,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? volume,
    double? playbackSpeed,
    String? error,
  }) {
    return AudioPlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      error: error ?? this.error,
    );
  }

  /// Progress percentage (0.0 to 1.0)
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  /// Remaining time in current song
  Duration get remainingTime {
    return duration - position;
  }
}

/// Audio player controller managing playback state and operations
/// Implements just_audio integration with state management
class AudioPlayerController extends StateNotifier<AudioPlayerState> {
  late AudioPlayer _audioPlayer;
  
  AudioPlayerController() : super(const AudioPlayerState()) {
    _initializePlayer();
  }

  /// Initializes the audio player with event listeners
  void _initializePlayer() {
    _audioPlayer = AudioPlayer();
    _setupEventListeners();
  }

  /// Sets up audio player event listeners for state updates
  void _setupEventListeners() {
    // Position updates
    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    // Duration updates
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    // Playing state updates
    _audioPlayer.playingStream.listen((isPlaying) {
      state = state.copyWith(
        isPlaying: isPlaying,
        isPaused: !isPlaying && state.position.inMilliseconds > 0,
      );
    });

    // Player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      final isLoading = playerState.processingState == ProcessingState.loading ||
                       playerState.processingState == ProcessingState.buffering;
      
      state = state.copyWith(isLoading: isLoading);
      
      // Handle completion
      if (playerState.processingState == ProcessingState.completed) {
        _onSongCompleted();
      }
    });
  }

  /// Plays a song by setting audio source and starting playback
  Future<void> playSong(Song song) async {
    try {
      if (song.audioUrl == null) {
        throw const AudioException(message: 'No audio URL available for this song');
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        currentSong: song,
      );

      await _audioPlayer.setUrl(song.audioUrl!);
      await _audioPlayer.play();
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to play song: ${e.toString()}',
      );
    }
  }

  /// Pauses current playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      state = state.copyWith(error: 'Failed to pause: ${e.toString()}');
    }
  }

  /// Resumes playback from current position
  Future<void> resume() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      state = state.copyWith(error: 'Failed to resume: ${e.toString()}');
    }
  }

  /// Stops playback and resets position
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      state = state.copyWith(
        isPlaying: false,
        isPaused: false,
        position: Duration.zero,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to stop: ${e.toString()}');
    }
  }

  /// Seeks to specific position in current song
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      state = state.copyWith(error: 'Failed to seek: ${e.toString()}');
    }
  }

  /// Sets playback volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);
      state = state.copyWith(volume: clampedVolume);
    } catch (e) {
      state = state.copyWith(error: 'Failed to set volume: ${e.toString()}');
    }
  }

  /// Sets playback speed (0.5 to 2.0)
  Future<void> setSpeed(double speed) async {
    try {
      final clampedSpeed = speed.clamp(0.5, 2.0);
      await _audioPlayer.setSpeed(clampedSpeed);
      state = state.copyWith(playbackSpeed: clampedSpeed);
    } catch (e) {
      state = state.copyWith(error: 'Failed to set speed: ${e.toString()}');
    }
  }

  /// Handles song completion event
  void _onSongCompleted() {
    state = state.copyWith(
      isPlaying: false,
      isPaused: false,
      position: state.duration,
    );
  }

  /// Disposes audio player resources
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Provider for audio player controller
final audioPlayerControllerProvider = StateNotifierProvider<AudioPlayerController, AudioPlayerState>(
  (ref) => AudioPlayerController(),
);
