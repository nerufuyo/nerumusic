import 'package:equatable/equatable.dart';
import 'song.dart';

/// Artist entity representing music artist data
/// Business entity for artist information and associated songs
class Artist extends Equatable {
  const Artist({
    required this.id,
    required this.name,
    this.biography,
    this.imageUrl,
    this.genres,
    this.followers,
    this.popularity,
    this.topSongs,
    this.albums,
  });

  /// Unique identifier for the artist
  final String id;
  
  /// Artist name
  final String name;
  
  /// Artist biography (optional)
  final String? biography;
  
  /// Artist profile image URL (optional)
  final String? imageUrl;
  
  /// List of genres associated with the artist
  final List<String>? genres;
  
  /// Number of followers (optional)
  final int? followers;
  
  /// Popularity score 0-100 (optional)
  final int? popularity;
  
  /// List of top songs by the artist
  final List<Song>? topSongs;
  
  /// List of album names by the artist
  final List<String>? albums;

  /// Creates a copy with updated properties
  Artist copyWith({
    String? id,
    String? name,
    String? biography,
    String? imageUrl,
    List<String>? genres,
    int? followers,
    int? popularity,
    List<Song>? topSongs,
    List<String>? albums,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      biography: biography ?? this.biography,
      imageUrl: imageUrl ?? this.imageUrl,
      genres: genres ?? this.genres,
      followers: followers ?? this.followers,
      popularity: popularity ?? this.popularity,
      topSongs: topSongs ?? this.topSongs,
      albums: albums ?? this.albums,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        biography,
        imageUrl,
        genres,
        followers,
        popularity,
        topSongs,
        albums,
      ];
}
