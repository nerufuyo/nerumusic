import 'package:equatable/equatable.dart';

/// Offline content entity for managing downloaded music
/// Tracks download status, storage paths, and metadata
class OfflineContent extends Equatable {
  const OfflineContent({
    required this.id,
    required this.type,
    required this.downloadedAt,
    required this.filePath,
    required this.fileSize,
    required this.title,
    required this.artist,
    this.artworkUrl,
    this.quality = OfflineQuality.medium,
    this.status = DownloadStatus.completed,
    this.progress = 1.0,
    this.expiresAt,
    this.lastPlayedAt,
    this.playCount = 0,
  });

  /// Unique identifier for offline content
  final String id;
  
  /// Type of content (song, playlist)
  final OfflineContentType type;
  
  /// Download completion timestamp
  final DateTime downloadedAt;
  
  /// Local file storage path
  final String filePath;
  
  /// File size in bytes
  final int fileSize;
  
  /// Content title
  final String title;
  
  /// Content artist/creator
  final String artist;
  
  /// Artwork URL
  final String? artworkUrl;
  
  /// Download quality
  final OfflineQuality quality;
  
  /// Current download status
  final DownloadStatus status;
  
  /// Download progress (0.0 to 1.0)
  final double progress;
  
  /// Expiration date for temporary content
  final DateTime? expiresAt;
  
  /// Last played timestamp
  final DateTime? lastPlayedAt;
  
  /// Number of times played offline
  final int playCount;

  /// Check if content is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if download is in progress
  bool get isDownloading => status == DownloadStatus.downloading;

  /// Check if download is completed
  bool get isCompleted => status == DownloadStatus.completed;

  /// Check if download failed
  bool get isFailed => status == DownloadStatus.failed;

  /// Check if download is paused
  bool get isPaused => status == DownloadStatus.paused;

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Creates a copy with updated properties
  OfflineContent copyWith({
    String? id,
    OfflineContentType? type,
    DateTime? downloadedAt,
    String? filePath,
    int? fileSize,
    String? title,
    String? artist,
    String? artworkUrl,
    OfflineQuality? quality,
    DownloadStatus? status,
    double? progress,
    DateTime? expiresAt,
    DateTime? lastPlayedAt,
    int? playCount,
  }) {
    return OfflineContent(
      id: id ?? this.id,
      type: type ?? this.type,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      quality: quality ?? this.quality,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      expiresAt: expiresAt ?? this.expiresAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'downloadedAt': downloadedAt.toIso8601String(),
      'filePath': filePath,
      'fileSize': fileSize,
      'title': title,
      'artist': artist,
      'artworkUrl': artworkUrl,
      'quality': quality.name,
      'status': status.name,
      'progress': progress,
      'expiresAt': expiresAt?.toIso8601String(),
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      'playCount': playCount,
    };
  }

  /// Create from JSON
  factory OfflineContent.fromJson(Map<String, dynamic> json) {
    return OfflineContent(
      id: json['id'],
      type: OfflineContentType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      downloadedAt: DateTime.parse(json['downloadedAt']),
      filePath: json['filePath'],
      fileSize: json['fileSize'],
      title: json['title'],
      artist: json['artist'],
      artworkUrl: json['artworkUrl'],
      quality: OfflineQuality.values.firstWhere(
        (e) => e.name == json['quality'],
        orElse: () => OfflineQuality.medium,
      ),
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DownloadStatus.completed,
      ),
      progress: json['progress']?.toDouble() ?? 1.0,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      lastPlayedAt: json['lastPlayedAt'] != null ? DateTime.parse(json['lastPlayedAt']) : null,
      playCount: json['playCount'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        downloadedAt,
        filePath,
        fileSize,
        title,
        artist,
        artworkUrl,
        quality,
        status,
        progress,
        expiresAt,
        lastPlayedAt,
        playCount,
      ];
}

/// Types of offline content
enum OfflineContentType {
  song,
  playlist,
}

/// Download status options
enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

/// Offline content quality options
enum OfflineQuality {
  low,     // 128 kbps
  medium,  // 256 kbps
  high,    // 320 kbps
  lossless, // FLAC
}

/// Download progress information
class DownloadProgress {
  const DownloadProgress({
    required this.contentId,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.speed,
    this.estimatedTimeRemaining,
    this.status = DownloadStatus.downloading,
  });

  final String contentId;
  final double progress; // 0.0 to 1.0
  final int downloadedBytes;
  final int totalBytes;
  final double speed; // bytes per second
  final Duration? estimatedTimeRemaining;
  final DownloadStatus status;

  /// Get formatted download speed
  String get formattedSpeed {
    if (speed < 1024) return '${speed.toStringAsFixed(0)}B/s';
    if (speed < 1024 * 1024) return '${(speed / 1024).toStringAsFixed(1)}KB/s';
    return '${(speed / (1024 * 1024)).toStringAsFixed(1)}MB/s';
  }

  /// Get formatted time remaining
  String get formattedTimeRemaining {
    if (estimatedTimeRemaining == null) return 'Unknown';
    
    final duration = estimatedTimeRemaining!;
    if (duration.inMinutes < 1) return '${duration.inSeconds}s';
    if (duration.inHours < 1) return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }

  /// Get percentage string
  String get progressPercentage => '${(progress * 100).toStringAsFixed(0)}%';
}

/// Offline storage statistics
class OfflineStorageInfo {
  const OfflineStorageInfo({
    required this.totalSize,
    required this.usedSize,
    required this.availableSize,
    required this.contentCount,
    required this.songsCount,
    required this.playlistsCount,
  });

  final int totalSize;
  final int usedSize;
  final int availableSize;
  final int contentCount;
  final int songsCount;
  final int playlistsCount;

  /// Get usage percentage
  double get usagePercentage => totalSize > 0 ? usedSize / totalSize : 0.0;

  /// Get formatted sizes
  String get formattedUsedSize => _formatBytes(usedSize);
  String get formattedTotalSize => _formatBytes(totalSize);
  String get formattedAvailableSize => _formatBytes(availableSize);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
