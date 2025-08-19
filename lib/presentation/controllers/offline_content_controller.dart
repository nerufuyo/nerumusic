import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../../domain/entities/offline_content.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/playlist.dart';

/// Offline content state containing download queue and storage info
class OfflineContentState {
  const OfflineContentState({
    this.downloads = const [],
    this.downloadQueue = const [],
    this.activeDownloads = const {},
    this.storageInfo = const OfflineStorageInfo(
      totalSize: 0,
      usedSize: 0,
      availableSize: 0,
      contentCount: 0,
      songsCount: 0,
      playlistsCount: 0,
    ),
    this.isLoading = false,
    this.error,
  });

  final List<OfflineContent> downloads;
  final List<String> downloadQueue; // Content IDs
  final Map<String, DownloadProgress> activeDownloads;
  final OfflineStorageInfo storageInfo;
  final bool isLoading;
  final String? error;

  OfflineContentState copyWith({
    List<OfflineContent>? downloads,
    List<String>? downloadQueue,
    Map<String, DownloadProgress>? activeDownloads,
    OfflineStorageInfo? storageInfo,
    bool? isLoading,
    String? error,
  }) {
    return OfflineContentState(
      downloads: downloads ?? this.downloads,
      downloadQueue: downloadQueue ?? this.downloadQueue,
      activeDownloads: activeDownloads ?? this.activeDownloads,
      storageInfo: storageInfo ?? this.storageInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Offline content controller managing downloads and local storage
/// Handles download queue, progress tracking, and storage management
class OfflineContentController extends StateNotifier<OfflineContentState> {
  static const String _downloadsFile = 'offline_downloads.json';
  static const int _maxConcurrentDownloads = 3;
  
  late Directory _documentsDir;
  late Directory _downloadDir;
  final Map<String, StreamSubscription> _downloadSubscriptions = {};
  Timer? _progressTimer;

  OfflineContentController() : super(const OfflineContentState()) {
    _initialize();
  }

  /// Initialize offline content system
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Setup directories
      _documentsDir = await getApplicationDocumentsDirectory();
      _downloadDir = Directory('${_documentsDir.path}/downloads');
      if (!await _downloadDir.exists()) {
        await _downloadDir.create(recursive: true);
      }
      
      // Load existing downloads
      await _loadDownloads();
      
      // Update storage info
      await _updateStorageInfo();
      
      // Start download queue processor
      _startDownloadProcessor();
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize offline content: $e',
      );
    }
  }

  /// Load downloads from local storage
  Future<void> _loadDownloads() async {
    try {
      final downloadsFile = File('${_documentsDir.path}/$_downloadsFile');
      if (await downloadsFile.exists()) {
        final jsonString = await downloadsFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final downloads = jsonList
            .map((json) => OfflineContent.fromJson(json))
            .toList();
        
        state = state.copyWith(downloads: downloads);
      }
    } catch (e) {
      // Handle loading error - keep empty list
    }
  }

  /// Save downloads to local storage
  Future<void> _saveDownloads() async {
    try {
      final downloadsFile = File('${_documentsDir.path}/$_downloadsFile');
      final jsonList = state.downloads.map((d) => d.toJson()).toList();
      await downloadsFile.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      // Handle save error
    }
  }

  /// Update storage statistics
  Future<void> _updateStorageInfo() async {
    try {
      int totalSize = 0;
      int usedSize = 0;
      int songsCount = 0;
      int playlistsCount = 0;

      // Calculate used space
      for (final download in state.downloads) {
        if (download.isCompleted) {
          usedSize += download.fileSize;
          if (download.type == OfflineContentType.song) {
            songsCount++;
          } else {
            playlistsCount++;
          }
        }
      }

      // Get available space
      final availableSpace = await _getAvailableSpace();
      
      final storageInfo = OfflineStorageInfo(
        totalSize: totalSize,
        usedSize: usedSize,
        availableSize: availableSpace,
        contentCount: state.downloads.where((d) => d.isCompleted).length,
        songsCount: songsCount,
        playlistsCount: playlistsCount,
      );

      state = state.copyWith(storageInfo: storageInfo);
    } catch (e) {
      // Handle storage info error
    }
  }

  /// Get available storage space
  Future<int> _getAvailableSpace() async {
    try {
      // This is a simplified implementation
      // In a real app, you'd use platform-specific code
      return 1024 * 1024 * 1024; // 1GB placeholder
    } catch (e) {
      return 0;
    }
  }

  /// Download a song for offline playback
  Future<void> downloadSong(Song song) async {
    final contentId = 'song_${song.id}';
    
    // Check if already downloaded or in queue
    if (_isAlreadyDownloaded(contentId) || _isInQueue(contentId)) {
      return;
    }

    // Add to queue
    final updatedQueue = [...state.downloadQueue, contentId];
    state = state.copyWith(downloadQueue: updatedQueue);

    // Create offline content entry
    final offlineContent = OfflineContent(
      id: contentId,
      type: OfflineContentType.song,
      downloadedAt: DateTime.now(),
      filePath: '${_downloadDir.path}/${song.id}.mp3',
      fileSize: 0, // Will be updated during download
      title: song.title,
      artist: song.artist,
      artworkUrl: song.albumArt,
      status: DownloadStatus.pending,
    );

    final updatedDownloads = [...state.downloads, offlineContent];
    state = state.copyWith(downloads: updatedDownloads);
    
    await _saveDownloads();
  }

  /// Download a playlist for offline playback
  Future<void> downloadPlaylist(Playlist playlist) async {
    final contentId = 'playlist_${playlist.id}';
    
    // Check if already downloaded or in queue
    if (_isAlreadyDownloaded(contentId) || _isInQueue(contentId)) {
      return;
    }

    // Download all songs in playlist
    for (final song in playlist.songs) {
      await downloadSong(song);
    }

    // Create playlist entry
    final offlineContent = OfflineContent(
      id: contentId,
      type: OfflineContentType.playlist,
      downloadedAt: DateTime.now(),
      filePath: '${_downloadDir.path}/playlist_${playlist.id}',
      fileSize: 0,
      title: playlist.name,
      artist: playlist.creator ?? 'Unknown',
      artworkUrl: playlist.imageUrl,
      status: DownloadStatus.completed,
    );

    final updatedDownloads = [...state.downloads, offlineContent];
    state = state.copyWith(downloads: updatedDownloads);
    
    await _saveDownloads();
  }

  /// Start download queue processor
  void _startDownloadProcessor() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _processDownloadQueue();
    });
  }

  /// Process download queue
  void _processDownloadQueue() {
    // Check if we can start more downloads
    final activeCount = state.activeDownloads.length;
    if (activeCount >= _maxConcurrentDownloads || state.downloadQueue.isEmpty) {
      return;
    }

    // Start next download
    final nextContentId = state.downloadQueue.first;
    _startDownload(nextContentId);
  }

  /// Start downloading content
  void _startDownload(String contentId) {
    // Remove from queue and add to active downloads
    final updatedQueue = state.downloadQueue.where((id) => id != contentId).toList();
    final updatedActiveDownloads = {
      ...state.activeDownloads,
      contentId: DownloadProgress(
        contentId: contentId,
        progress: 0.0,
        downloadedBytes: 0,
        totalBytes: 1024 * 1024 * 4, // 4MB placeholder
        speed: 1024 * 100, // 100KB/s placeholder
      ),
    };

    state = state.copyWith(
      downloadQueue: updatedQueue,
      activeDownloads: updatedActiveDownloads,
    );

    // Simulate download progress
    _simulateDownload(contentId);
  }

  /// Simulate download progress (replace with actual download logic)
  void _simulateDownload(String contentId) {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final progress = state.activeDownloads[contentId];
      if (progress == null) {
        timer.cancel();
        return;
      }

      final newProgress = (progress.progress + 0.1).clamp(0.0, 1.0);
      final updatedProgress = DownloadProgress(
        contentId: contentId,
        progress: newProgress,
        downloadedBytes: (newProgress * progress.totalBytes).round(),
        totalBytes: progress.totalBytes,
        speed: progress.speed,
        estimatedTimeRemaining: Duration(
          seconds: ((1.0 - newProgress) * progress.totalBytes / progress.speed).round(),
        ),
      );

      final updatedActiveDownloads = {
        ...state.activeDownloads,
        contentId: updatedProgress,
      };

      state = state.copyWith(activeDownloads: updatedActiveDownloads);

      if (newProgress >= 1.0) {
        timer.cancel();
        _completeDownload(contentId);
      }
    });
  }

  /// Complete download
  void _completeDownload(String contentId) {
    // Update content status
    final updatedDownloads = state.downloads.map((content) {
      if (content.id == contentId) {
        return content.copyWith(
          status: DownloadStatus.completed,
          progress: 1.0,
          fileSize: 1024 * 1024 * 4, // 4MB placeholder
        );
      }
      return content;
    }).toList();

    // Remove from active downloads
    final updatedActiveDownloads = Map<String, DownloadProgress>.from(state.activeDownloads);
    updatedActiveDownloads.remove(contentId);

    state = state.copyWith(
      downloads: updatedDownloads,
      activeDownloads: updatedActiveDownloads,
    );

    _saveDownloads();
    _updateStorageInfo();
  }

  /// Pause download
  void pauseDownload(String contentId) {
    final updatedDownloads = state.downloads.map((content) {
      if (content.id == contentId) {
        return content.copyWith(status: DownloadStatus.paused);
      }
      return content;
    }).toList();

    // Remove from active downloads
    final updatedActiveDownloads = Map<String, DownloadProgress>.from(state.activeDownloads);
    updatedActiveDownloads.remove(contentId);

    state = state.copyWith(
      downloads: updatedDownloads,
      activeDownloads: updatedActiveDownloads,
    );

    _saveDownloads();
  }

  /// Resume download
  void resumeDownload(String contentId) {
    final updatedDownloads = state.downloads.map((content) {
      if (content.id == contentId) {
        return content.copyWith(status: DownloadStatus.pending);
      }
      return content;
    }).toList();

    // Add back to queue
    final updatedQueue = [...state.downloadQueue, contentId];

    state = state.copyWith(
      downloads: updatedDownloads,
      downloadQueue: updatedQueue,
    );

    _saveDownloads();
  }

  /// Cancel download
  void cancelDownload(String contentId) {
    // Remove from queue and active downloads
    final updatedQueue = state.downloadQueue.where((id) => id != contentId).toList();
    final updatedActiveDownloads = Map<String, DownloadProgress>.from(state.activeDownloads);
    updatedActiveDownloads.remove(contentId);

    // Update download status
    final updatedDownloads = state.downloads.map((content) {
      if (content.id == contentId) {
        return content.copyWith(status: DownloadStatus.cancelled);
      }
      return content;
    }).toList();

    state = state.copyWith(
      downloads: updatedDownloads,
      downloadQueue: updatedQueue,
      activeDownloads: updatedActiveDownloads,
    );

    _saveDownloads();
  }

  /// Delete downloaded content
  Future<void> deleteDownload(String contentId) async {
    try {
      final content = state.downloads.firstWhere((d) => d.id == contentId);
      
      // Delete file
      final file = File(content.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from state
      final updatedDownloads = state.downloads.where((d) => d.id != contentId).toList();
      state = state.copyWith(downloads: updatedDownloads);

      await _saveDownloads();
      await _updateStorageInfo();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete download: $e');
    }
  }

  /// Clear all downloads
  Future<void> clearAllDownloads() async {
    try {
      // Delete all files
      for (final content in state.downloads) {
        final file = File(content.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Clear state
      state = state.copyWith(
        downloads: [],
        downloadQueue: [],
        activeDownloads: {},
      );

      await _saveDownloads();
      await _updateStorageInfo();
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear downloads: $e');
    }
  }

  /// Get offline songs
  List<OfflineContent> getOfflineSongs() {
    return state.downloads
        .where((d) => d.type == OfflineContentType.song && d.isCompleted)
        .toList();
  }

  /// Get offline playlists
  List<OfflineContent> getOfflinePlaylists() {
    return state.downloads
        .where((d) => d.type == OfflineContentType.playlist && d.isCompleted)
        .toList();
  }

  /// Check if content is available offline
  bool isAvailableOffline(String contentId) {
    return state.downloads.any((d) => d.id == contentId && d.isCompleted);
  }

  /// Helper methods
  bool _isAlreadyDownloaded(String contentId) {
    return state.downloads.any((d) => d.id == contentId);
  }

  bool _isInQueue(String contentId) {
    return state.downloadQueue.contains(contentId);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    for (final subscription in _downloadSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
}

/// Provider for offline content controller
final offlineContentControllerProvider = 
    StateNotifierProvider<OfflineContentController, OfflineContentState>(
  (ref) => OfflineContentController(),
);
