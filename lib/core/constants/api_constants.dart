/// API endpoints and configuration constants
/// Centralized API management following DRY principles
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  /// Base URLs for different services
  static const String youTubeMusicBaseUrl = 'https://music.youtube.com/youtubei/v1';
  static const String spotifyBaseUrl = 'https://api.spotify.com/v1';
  static const String soundCloudBaseUrl = 'https://api.soundcloud.com';
  static const String freeMusicArchiveBaseUrl = 'https://freemusicarchive.org/api';

  /// YouTube Music API Endpoints
  static const String ytSearchEndpoint = '/search';
  static const String ytPlaylistEndpoint = '/browse';
  static const String ytPlayerEndpoint = '/player';
  static const String ytGetSongEndpoint = '/get_song';

  /// Spotify API Endpoints
  static const String spotifySearchEndpoint = '/search';
  static const String spotifyTracksEndpoint = '/tracks';
  static const String spotifyArtistsEndpoint = '/artists';
  static const String spotifyAlbumsEndpoint = '/albums';
  static const String spotifyPlaylistsEndpoint = '/playlists';
  static const String spotifyTokenEndpoint = 'https://accounts.spotify.com/api/token';

  /// SoundCloud API Endpoints
  static const String soundCloudSearchEndpoint = '/search/tracks';
  static const String soundCloudTracksEndpoint = '/tracks';
  static const String soundCloudUsersEndpoint = '/users';
  static const String soundCloudPlaylistsEndpoint = '/playlists';

  /// Request Headers
  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  /// Request parameters
  static const String keyParam = 'key';
  static const String queryParam = 'q';
  static const String typeParam = 'type';
  static const String limitParam = 'limit';
  static const String offsetParam = 'offset';

  /// Default limits
  static const int defaultSearchLimit = 20;
  static const int maxSearchLimit = 50;
  static const int defaultPlaylistLimit = 100;

  /// Content types
  static const String trackType = 'track';
  static const String artistType = 'artist';
  static const String albumType = 'album';
  static const String playlistType = 'playlist';

  /// Audio quality settings
  static const String highQuality = 'high';
  static const String mediumQuality = 'medium';
  static const String lowQuality = 'low';
}
