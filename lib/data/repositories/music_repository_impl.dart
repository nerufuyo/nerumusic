import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/youtube_music_datasource.dart';
import '../datasources/spotify_datasource.dart';
import '../models/song_model.dart';

/// Concrete implementation of MusicRepository
/// Orchestrates data from multiple sources with caching
class MusicRepositoryImpl implements MusicRepository {
  final YouTubeMusicDataSource _youtubeMusicDataSource;
  final SpotifyDataSource _spotifyDataSource;
  final Box<Map<String, dynamic>> _cacheBox;

  MusicRepositoryImpl({
    required YouTubeMusicDataSource youtubeMusicDataSource,
    required SpotifyDataSource spotifyDataSource,
    required Box<Map<String, dynamic>> cacheBox,
  })  : _youtubeMusicDataSource = youtubeMusicDataSource,
        _spotifyDataSource = spotifyDataSource,
        _cacheBox = cacheBox;

  @override
  Future<Either<Failure, List<Song>>> searchSongs(String query, {int limit = 20}) async {
    try {
      // First check cache
      final cachedResult = await getCachedSearchResults(query);
      if (cachedResult.isRight()) {
        return cachedResult;
      }

      // Search across multiple platforms
      final futures = [
        _searchYouTubeMusic(query, limit ~/ 2),
        _searchSpotify(query, limit ~/ 2),
      ];

      final results = await Future.wait(futures);
      final allSongs = <Song>[];

      for (final result in results) {
        result.fold(
          (failure) => null, // Continue with other sources
          (songs) => allSongs.addAll(songs),
        );
      }

      if (allSongs.isEmpty) {
        return const Left(GeneralFailure(message: 'No songs found'));
      }

      // Cache results for offline access
      await cacheSearchResults(query, allSongs);

      return Right(allSongs);
    } catch (e) {
      return Left(GeneralFailure(message: 'Search failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Song>>> getTrendingSongs({int limit = 20}) async {
    try {
      // Check cache first
      const cacheKey = 'trending_songs';
      final cached = await getCachedData(cacheKey);
      
      return cached.fold(
        (failure) => _fetchTrendingSongs(limit),
        (cachedSongs) {
          if (cachedSongs != null && cachedSongs.isNotEmpty) {
            return Right(cachedSongs);
          }
          return _fetchTrendingSongs(limit);
        },
      );
    } catch (e) {
      return Left(GeneralFailure(message: 'Failed to get trending songs: $e'));
    }
  }

  @override
  Future<Either<Failure, Song>> getSongById(String id, String platform) async {
    try {
      SongModel songModel;
      
      switch (platform.toLowerCase()) {
        case 'youtube':
          songModel = await _youtubeMusicDataSource.getSongById(id);
          break;
        case 'spotify':
          songModel = await _spotifyDataSource.getSongById(id);
          break;
        default:
          return const Left(GeneralFailure(message: 'Unsupported platform'));
      }

      return Right(songModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Failed to get song: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Song>>> getCachedSearchResults(String query) async {
    try {
      final cacheKey = 'search_$query';
      final cached = _cacheBox.get(cacheKey);
      
      if (cached != null) {
        final songs = (cached['songs'] as List<dynamic>)
            .map((json) => SongModel.fromJson(json).toEntity())
            .toList();
        return Right(songs);
      }
      
      return const Left(CacheFailure(message: 'No cached results found'));
    } catch (e) {
      return Left(CacheFailure(message: 'Cache read failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> cacheSearchResults(String query, List<Song> songs) async {
    try {
      final cacheKey = 'search_$query';
      final songsJson = songs
          .map((song) => SongModel.fromEntity(song).toJson())
          .toList();
      
      await _cacheBox.put(cacheKey, {
        'songs': songsJson,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(message: 'Cache write failed: $e'));
    }
  }

  /// Searches YouTube Music specifically
  Future<Either<Failure, List<Song>>> _searchYouTubeMusic(String query, int limit) async {
    try {
      final songs = await _youtubeMusicDataSource.searchSongs(query, limit: limit);
      return Right(songs.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'YouTube Music search failed: $e'));
    }
  }

  /// Searches Spotify specifically
  Future<Either<Failure, List<Song>>> _searchSpotify(String query, int limit) async {
    try {
      final songs = await _spotifyDataSource.searchSongs(query, limit: limit);
      return Right(songs.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Spotify search failed: $e'));
    }
  }

  /// Fetches trending songs from multiple sources
  Future<Either<Failure, List<Song>>> _fetchTrendingSongs(int limit) async {
    try {
      final songs = await _youtubeMusicDataSource.getTrendingSongs(limit: limit);
      final entities = songs.map((model) => model.toEntity()).toList();
      
      // Cache trending songs
      await cacheData('trending_songs', entities);
      
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Failed to fetch trending songs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Song>>> call(Future<List<Song>> Function() apiCall) async {
    try {
      final result = await apiCall();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> cacheData(String key, List<Song> data) async {
    return cacheSearchResults(key, data);
  }

  @override
  Future<Either<Failure, List<Song>?>> getCachedData(String key) async {
    return getCachedSearchResults(key);
  }

  @override
  Future<Either<Failure, bool>> clearCache() async {
    try {
      await _cacheBox.clear();
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear cache: $e'));
    }
  }
}
