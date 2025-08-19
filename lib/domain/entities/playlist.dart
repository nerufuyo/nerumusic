import 'package:equatable/equatable.dart';
import 'song.dart';

/// Playlist entity representing music playlist data
/// Business entity for user-created and curated playlists
class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.name,
    required this.songs,
    this.description,
    this.imageUrl,
    this.creator,
    this.isPublic = true,
    this.followers,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for the playlist
  final String id;
  
  /// Playlist name
  final String name;
  
  /// List of songs in the playlist
  final List<Song> songs;
  
  /// Playlist description (optional)
  final String? description;
  
  /// Playlist cover image URL (optional)
  final String? imageUrl;
  
  /// Creator/owner of the playlist (optional)
  final String? creator;
  
  /// Public visibility status
  final bool isPublic;
  
  /// Number of followers (optional)
  final int? followers;
  
  /// Creation date (optional)
  final DateTime? createdAt;
  
  /// Last update date (optional)
  final DateTime? updatedAt;

  /// Total duration of all songs in milliseconds
  int get totalDuration => songs.fold(0, (sum, song) => sum + song.duration);
  
  /// Number of songs in playlist
  int get songCount => songs.length;
  
  /// Check if playlist is empty
  bool get isEmpty => songs.isEmpty;

  /// Creates a copy with updated properties
  Playlist copyWith({
    String? id,
    String? name,
    List<Song>? songs,
    String? description,
    String? imageUrl,
    String? creator,
    bool? isPublic,
    int? followers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      creator: creator ?? this.creator,
      isPublic: isPublic ?? this.isPublic,
      followers: followers ?? this.followers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        songs,
        description,
        imageUrl,
        creator,
        isPublic,
        followers,
        createdAt,
        updatedAt,
      ];
}
