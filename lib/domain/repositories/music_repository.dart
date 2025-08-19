import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/base_repository.dart';

/// Repository interface for music operations
/// Defines contract for music data access following Clean Architecture
abstract class MusicRepository extends BaseRepository<List<Song>> {
  /// Searches for songs across multiple platforms
  Future<Either<Failure, List<Song>>> searchSongs(String query, {int limit = 20});
  
  /// Gets trending songs from all platforms
  Future<Either<Failure, List<Song>>> getTrendingSongs({int limit = 20});
  
  /// Gets song details by ID and platform
  Future<Either<Failure, Song>> getSongById(String id, String platform);
  
  /// Gets cached search results
  Future<Either<Failure, List<Song>>> getCachedSearchResults(String query);
  
  /// Caches search results for offline access
  Future<Either<Failure, bool>> cacheSearchResults(String query, List<Song> songs);
}
