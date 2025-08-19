import '../../domain/entities/song.dart';

/// Song data model for JSON serialization
/// Extends Song entity with fromJson/toJson capabilities
class SongModel extends Song {
  const SongModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.duration,
    super.album,
    super.albumArt,
    super.audioUrl,
    super.genre,
    super.releaseDate,
    super.popularity,
    super.isLiked,
    super.isDownloaded,
  });

  /// Creates SongModel from JSON map
  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      duration: json['duration'] ?? 0,
      album: json['album'],
      albumArt: json['albumArt'],
      audioUrl: json['audioUrl'],
      genre: json['genre'],
      releaseDate: json['releaseDate'] != null 
          ? DateTime.parse(json['releaseDate']) 
          : null,
      popularity: json['popularity'],
      isLiked: json['isLiked'] ?? false,
      isDownloaded: json['isDownloaded'] ?? false,
    );
  }

  /// Converts SongModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'duration': duration,
      'album': album,
      'albumArt': albumArt,
      'audioUrl': audioUrl,
      'genre': genre,
      'releaseDate': releaseDate?.toIso8601String(),
      'popularity': popularity,
      'isLiked': isLiked,
      'isDownloaded': isDownloaded,
    };
  }

  /// Creates SongModel from Song entity
  factory SongModel.fromEntity(Song song) {
    return SongModel(
      id: song.id,
      title: song.title,
      artist: song.artist,
      duration: song.duration,
      album: song.album,
      albumArt: song.albumArt,
      audioUrl: song.audioUrl,
      genre: song.genre,
      releaseDate: song.releaseDate,
      popularity: song.popularity,
      isLiked: song.isLiked,
      isDownloaded: song.isDownloaded,
    );
  }

  /// Converts to Song entity
  Song toEntity() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      duration: duration,
      album: album,
      albumArt: albumArt,
      audioUrl: audioUrl,
      genre: genre,
      releaseDate: releaseDate,
      popularity: popularity,
      isLiked: isLiked,
      isDownloaded: isDownloaded,
    );
  }

  /// Creates SongModel from YouTube Music API response
  factory SongModel.fromYouTubeMusic(Map<String, dynamic> json) {
    return SongModel(
      id: json['videoId'] ?? '',
      title: json['title']?['runs']?[0]?['text'] ?? '',
      artist: json['subtitle']?['runs']?[0]?['text'] ?? '',
      duration: _parseDuration(json['lengthText']?['simpleText']),
      album: json['longBylineText']?['runs']?[2]?['text'],
      albumArt: json['thumbnail']?['thumbnails']?.last?['url'],
    );
  }

  /// Creates SongModel from Spotify API response
  factory SongModel.fromSpotify(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? '',
      title: json['name'] ?? '',
      artist: json['artists']?[0]?['name'] ?? '',
      duration: json['duration_ms'] ?? 0,
      album: json['album']?['name'],
      albumArt: json['album']?['images']?[0]?['url'],
      popularity: json['popularity'],
      audioUrl: json['preview_url'],
    );
  }

  /// Creates SongModel from SoundCloud API response
  factory SongModel.fromSoundCloud(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      artist: json['user']?['username'] ?? '',
      duration: json['duration'] ?? 0,
      albumArt: json['artwork_url'],
      audioUrl: json['stream_url'],
      genre: json['genre'],
    );
  }

  /// Parses duration string to milliseconds
  static int _parseDuration(String? durationText) {
    if (durationText == null) return 0;
    
    final parts = durationText.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return (minutes * 60 + seconds) * 1000;
    }
    return 0;
  }
}
