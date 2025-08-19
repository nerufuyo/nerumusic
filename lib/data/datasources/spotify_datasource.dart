import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/network_service.dart';
import '../models/song_model.dart';

/// Abstract interface for Spotify data source
/// Defines contract for Spotify Web API operations
abstract class SpotifyDataSource {
  /// Searches for songs on Spotify
  Future<List<SongModel>> searchSongs(String query, {int limit = 20});
  
  /// Gets song details by ID
  Future<SongModel> getSongById(String id);
  
  /// Gets track features (audio analysis)
  Future<Map<String, dynamic>> getTrackFeatures(String id);
}

/// Concrete implementation of Spotify data source
/// Handles API communication with Spotify Web API
class SpotifyDataSourceImpl implements SpotifyDataSource {
  final NetworkService _networkService;
  String? _accessToken;
  
  SpotifyDataSourceImpl(this._networkService);

  @override
  Future<List<SongModel>> searchSongs(String query, {int limit = 20}) async {
    try {
      await _ensureAuthenticated();

      final response = await _networkService.get(
        '${ApiConstants.spotifyBaseUrl}${ApiConstants.spotifySearchEndpoint}',
        queryParameters: {
          ApiConstants.queryParam: query,
          ApiConstants.typeParam: ApiConstants.trackType,
          ApiConstants.limitParam: limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tracks = data['tracks']?['items'] as List<dynamic>? ?? [];
        
        return tracks
            .map((track) => SongModel.fromSpotify(track))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to search Spotify',
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
      await _ensureAuthenticated();

      final response = await _networkService.get(
        '${ApiConstants.spotifyBaseUrl}${ApiConstants.spotifyTracksEndpoint}/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return SongModel.fromSpotify(data);
      } else {
        throw ServerException(
          message: 'Failed to get Spotify track',
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
  Future<Map<String, dynamic>> getTrackFeatures(String id) async {
    try {
      await _ensureAuthenticated();

      final response = await _networkService.get(
        '${ApiConstants.spotifyBaseUrl}/audio-features/$id',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          message: 'Failed to get track features',
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

  /// Ensures user is authenticated with Spotify API
  Future<void> _ensureAuthenticated() async {
    if (_accessToken == null) {
      await _authenticate();
    }
  }

  /// Authenticates with Spotify using client credentials
  Future<void> _authenticate() async {
    try {
      final clientId = dotenv.env['SPOTIFY_CLIENT_ID'];
      final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'];
      
      if (clientId == null || clientSecret == null) {
        throw const AuthException(message: 'Spotify credentials not found');
      }

      final response = await _networkService.post(
        ApiConstants.spotifyTokenEndpoint,
        data: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _accessToken = data['access_token'];
      } else {
        throw const AuthException(message: 'Failed to authenticate with Spotify');
      }
    } catch (e) {
      throw const AuthException(message: 'Spotify authentication failed');
    }
  }
}
