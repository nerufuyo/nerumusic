import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/network_service.dart';
import '../models/song_model.dart';

/// Abstract interface for YouTube Music data source
/// Defines contract for YouTube Music API operations
abstract class YouTubeMusicDataSource {
  /// Searches for songs on YouTube Music
  Future<List<SongModel>> searchSongs(String query, {int limit = 20});
  
  /// Gets trending songs from YouTube Music
  Future<List<SongModel>> getTrendingSongs({int limit = 20});
  
  /// Gets song details by ID
  Future<SongModel> getSongById(String id);
}

/// Concrete implementation of YouTube Music data source
/// Handles API communication with YouTube Music service
class YouTubeMusicDataSourceImpl implements YouTubeMusicDataSource {
  final NetworkService _networkService;
  
  YouTubeMusicDataSourceImpl(this._networkService);

  @override
  Future<List<SongModel>> searchSongs(String query, {int limit = 20}) async {
    try {
      final apiKey = dotenv.env['YOUTUBE_MUSIC_API_KEY'];
      if (apiKey == null) {
        throw const AuthException(message: 'YouTube Music API key not found');
      }

      final response = await _networkService.get(
        '${ApiConstants.youTubeMusicBaseUrl}${ApiConstants.ytSearchEndpoint}',
        queryParameters: {
          ApiConstants.queryParam: query,
          ApiConstants.limitParam: limit.toString(),
          ApiConstants.keyParam: apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        
        return items
            .map((item) => SongModel.fromYouTubeMusic(item))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to search songs',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is AuthException) {
        rethrow;
      }
      throw NetworkException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<List<SongModel>> getTrendingSongs({int limit = 20}) async {
    try {
      final apiKey = dotenv.env['YOUTUBE_MUSIC_API_KEY'];
      if (apiKey == null) {
        throw const AuthException(message: 'YouTube Music API key not found');
      }

      final response = await _networkService.get(
        '${ApiConstants.youTubeMusicBaseUrl}${ApiConstants.ytPlaylistEndpoint}',
        queryParameters: {
          ApiConstants.limitParam: limit.toString(),
          ApiConstants.keyParam: apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        
        return items
            .map((item) => SongModel.fromYouTubeMusic(item))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to get trending songs',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is AuthException) {
        rethrow;
      }
      throw NetworkException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<SongModel> getSongById(String id) async {
    try {
      final apiKey = dotenv.env['YOUTUBE_MUSIC_API_KEY'];
      if (apiKey == null) {
        throw const AuthException(message: 'YouTube Music API key not found');
      }

      final response = await _networkService.get(
        '${ApiConstants.youTubeMusicBaseUrl}${ApiConstants.ytGetSongEndpoint}',
        queryParameters: {
          'id': id,
          ApiConstants.keyParam: apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return SongModel.fromYouTubeMusic(data);
      } else {
        throw ServerException(
          message: 'Failed to get song details',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is AuthException) {
        rethrow;
      }
      throw NetworkException(message: 'Unexpected error: $e');
    }
  }
}
