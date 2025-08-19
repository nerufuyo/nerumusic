import 'package:equatable/equatable.dart';

/// Song entity representing music track data
/// Core business entity following Clean Architecture principles
class Song extends Equatable {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.album,
    this.albumArt,
    this.audioUrl,
    this.genre,
    this.releaseDate,
    this.popularity,
    this.isLiked = false,
    this.isDownloaded = false,
  });

  /// Unique identifier for the song
  final String id;
  
  /// Song title
  final String title;
  
  /// Primary artist name
  final String artist;
  
  /// Song duration in milliseconds
  final int duration;
  
  /// Album name (optional)
  final String? album;
  
  /// Album artwork URL (optional)
  final String? albumArt;
  
  /// Audio stream URL (optional)
  final String? audioUrl;
  
  /// Music genre (optional)
  final String? genre;
  
  /// Release date (optional)
  final DateTime? releaseDate;
  
  /// Popularity score 0-100 (optional)
  final int? popularity;
  
  /// User favorite status
  final bool isLiked;
  
  /// Download status for offline playback
  final bool isDownloaded;

  /// Creates a copy with updated properties
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    int? duration,
    String? album,
    String? albumArt,
    String? audioUrl,
    String? genre,
    DateTime? releaseDate,
    int? popularity,
    bool? isLiked,
    bool? isDownloaded,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      album: album ?? this.album,
      albumArt: albumArt ?? this.albumArt,
      audioUrl: audioUrl ?? this.audioUrl,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
      popularity: popularity ?? this.popularity,
      isLiked: isLiked ?? this.isLiked,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        duration,
        album,
        albumArt,
        audioUrl,
        genre,
        releaseDate,
        popularity,
        isLiked,
        isDownloaded,
      ];
}
