import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/playlist.dart';
import '../../core/utils/string_utils.dart';

/// Playlist manager state representing current playlist state
/// Manages user playlists and current queue
class PlaylistManagerState {
  const PlaylistManagerState({
    this.playlists = const [],
    this.currentQueue = const [],
    this.currentIndex = -1,
    this.shuffleMode = false,
    this.repeatMode = RepeatMode.off,
    this.isLoading = false,
    this.error,
  });

  final List<Playlist> playlists;
  final List<Song> currentQueue;
  final int currentIndex;
  final bool shuffleMode;
  final RepeatMode repeatMode;
  final bool isLoading;
  final String? error;

  /// Creates a copy with updated properties
  PlaylistManagerState copyWith({
    List<Playlist>? playlists,
    List<Song>? currentQueue,
    int? currentIndex,
    bool? shuffleMode,
    RepeatMode? repeatMode,
    bool? isLoading,
    String? error,
  }) {
    return PlaylistManagerState(
      playlists: playlists ?? this.playlists,
      currentQueue: currentQueue ?? this.currentQueue,
      currentIndex: currentIndex ?? this.currentIndex,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      repeatMode: repeatMode ?? this.repeatMode,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Current song in queue
  Song? get currentSong {
    if (currentIndex >= 0 && currentIndex < currentQueue.length) {
      return currentQueue[currentIndex];
    }
    return null;
  }

  /// Next song in queue
  Song? get nextSong {
    final nextIndex = _getNextIndex();
    if (nextIndex >= 0 && nextIndex < currentQueue.length) {
      return currentQueue[nextIndex];
    }
    return null;
  }

  /// Previous song in queue
  Song? get previousSong {
    final prevIndex = _getPreviousIndex();
    if (prevIndex >= 0 && prevIndex < currentQueue.length) {
      return currentQueue[prevIndex];
    }
    return null;
  }

  /// Gets next index based on repeat and shuffle modes
  int _getNextIndex() {
    if (currentQueue.isEmpty) return -1;
    
    switch (repeatMode) {
      case RepeatMode.one:
        return currentIndex;
      case RepeatMode.all:
        return (currentIndex + 1) % currentQueue.length;
      case RepeatMode.off:
        final nextIndex = currentIndex + 1;
        return nextIndex < currentQueue.length ? nextIndex : -1;
    }
  }

  /// Gets previous index
  int _getPreviousIndex() {
    if (currentQueue.isEmpty) return -1;
    
    if (currentIndex > 0) {
      return currentIndex - 1;
    } else if (repeatMode == RepeatMode.all) {
      return currentQueue.length - 1;
    }
    return -1;
  }
}

/// Repeat mode enumeration
enum RepeatMode { off, one, all }

/// Playlist manager controller handling playlist operations
/// Manages playlist CRUD operations and queue management
class PlaylistManagerController extends StateNotifier<PlaylistManagerState> {
  PlaylistManagerController() : super(const PlaylistManagerState()) {
    _loadPlaylists();
  }

  /// Loads playlists from local storage
  Future<void> _loadPlaylists() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // TODO: Load from Hive storage
      // For now, create default playlists
      final defaultPlaylists = [
        Playlist(
          id: 'favorites',
          name: 'Favorites',
          songs: const [],
          description: 'Your favorite tracks',
          isPublic: false,
          createdAt: DateTime.now(),
        ),
        Playlist(
          id: 'recent',
          name: 'Recently Played',
          songs: const [],
          description: 'Your recently played tracks',
          isPublic: false,
          createdAt: DateTime.now(),
        ),
      ];
      
      state = state.copyWith(
        playlists: defaultPlaylists,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load playlists: $e',
      );
    }
  }

  /// Creates a new playlist
  Future<void> createPlaylist(String name, {String? description}) async {
    try {
      if (name.trim().isEmpty) {
        state = state.copyWith(error: 'Playlist name cannot be empty');
        return;
      }

      final playlist = Playlist(
        id: StringUtils.generateMd5(name + DateTime.now().toString()),
        name: name.trim(),
        songs: const [],
        description: description?.trim(),
        isPublic: false,
        createdAt: DateTime.now(),
      );

      final updatedPlaylists = [...state.playlists, playlist];
      state = state.copyWith(playlists: updatedPlaylists);
      
      // TODO: Save to Hive storage
    } catch (e) {
      state = state.copyWith(error: 'Failed to create playlist: $e');
    }
  }

  /// Deletes a playlist
  Future<void> deletePlaylist(String playlistId) async {
    try {
      final updatedPlaylists = state.playlists
          .where((playlist) => playlist.id != playlistId)
          .toList();
      
      state = state.copyWith(playlists: updatedPlaylists);
      
      // TODO: Save to Hive storage
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete playlist: $e');
    }
  }

  /// Adds a song to a playlist
  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    try {
      final updatedPlaylists = state.playlists.map((playlist) {
        if (playlist.id == playlistId) {
          final updatedSongs = [...playlist.songs, song];
          return playlist.copyWith(
            songs: updatedSongs,
            updatedAt: DateTime.now(),
          );
        }
        return playlist;
      }).toList();
      
      state = state.copyWith(playlists: updatedPlaylists);
      
      // TODO: Save to Hive storage
    } catch (e) {
      state = state.copyWith(error: 'Failed to add song to playlist: $e');
    }
  }

  /// Removes a song from a playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final updatedPlaylists = state.playlists.map((playlist) {
        if (playlist.id == playlistId) {
          final updatedSongs = playlist.songs
              .where((song) => song.id != songId)
              .toList();
          return playlist.copyWith(
            songs: updatedSongs,
            updatedAt: DateTime.now(),
          );
        }
        return playlist;
      }).toList();
      
      state = state.copyWith(playlists: updatedPlaylists);
      
      // TODO: Save to Hive storage
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove song from playlist: $e');
    }
  }

  /// Sets the current playback queue
  void setQueue(List<Song> songs, {int startIndex = 0}) {
    state = state.copyWith(
      currentQueue: songs,
      currentIndex: startIndex.clamp(0, songs.length - 1),
    );
  }

  /// Moves to next song in queue
  void nextSong() {
    final nextIndex = state._getNextIndex();
    if (nextIndex >= 0) {
      state = state.copyWith(currentIndex: nextIndex);
    }
  }

  /// Moves to previous song in queue
  void previousSong() {
    final prevIndex = state._getPreviousIndex();
    if (prevIndex >= 0) {
      state = state.copyWith(currentIndex: prevIndex);
    }
  }

  /// Toggles shuffle mode
  void toggleShuffle() {
    state = state.copyWith(shuffleMode: !state.shuffleMode);
    
    if (state.shuffleMode) {
      _shuffleQueue();
    } else {
      // TODO: Restore original order
    }
  }

  /// Cycles through repeat modes
  void toggleRepeat() {
    final nextMode = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    
    state = state.copyWith(repeatMode: nextMode);
  }

  /// Shuffles the current queue
  void _shuffleQueue() {
    if (state.currentQueue.length <= 1) return;
    
    final shuffledQueue = [...state.currentQueue];
    final currentSong = state.currentSong;
    
    // Remove current song temporarily
    if (currentSong != null) {
      shuffledQueue.removeAt(state.currentIndex);
    }
    
    // Shuffle remaining songs
    shuffledQueue.shuffle();
    
    // Add current song back at the beginning
    if (currentSong != null) {
      shuffledQueue.insert(0, currentSong);
    }
    
    state = state.copyWith(
      currentQueue: shuffledQueue,
      currentIndex: currentSong != null ? 0 : -1,
    );
  }
}

/// Provider for playlist manager controller
final playlistManagerProvider = StateNotifierProvider<PlaylistManagerController, PlaylistManagerState>(
  (ref) => PlaylistManagerController(),
);
