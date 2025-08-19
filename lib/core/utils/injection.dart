import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import '../network/network_service.dart';
import '../../data/datasources/youtube_music_datasource.dart';
import '../../data/datasources/spotify_datasource.dart';
import '../../data/repositories/music_repository_impl.dart';
import '../../domain/repositories/music_repository.dart';
import '../../domain/usecases/search_songs.dart';
import '../../domain/usecases/get_trending_songs.dart';

/// Dependency injection container using GetIt
/// Centralizes all service registrations following SOLID principles
final GetIt getIt = GetIt.instance;

/// Configures dependency injection for the application
Future<void> configureDependencies() async {
  await registerDependencies();
}

/// Initializes core services that need setup
Future<void> initializeCoreServices() async {
  // Initialize Hive boxes
  await Hive.openBox<Map<String, dynamic>>('music_cache');
}

/// Registers all dependencies
Future<void> registerDependencies() async {
  // Core services
  getIt.registerLazySingleton<NetworkService>(() => NetworkServiceImpl());
  
  // Data sources
  getIt.registerLazySingleton<YouTubeMusicDataSource>(
    () => YouTubeMusicDataSourceImpl(getIt<NetworkService>()),
  );
  
  getIt.registerLazySingleton<SpotifyDataSource>(
    () => SpotifyDataSourceImpl(getIt<NetworkService>()),
  );
  
  // Cache box
  getIt.registerLazySingleton<Box<Map<String, dynamic>>>(
    () => Hive.box<Map<String, dynamic>>('music_cache'),
  );
  
  // Repositories
  getIt.registerLazySingleton<MusicRepository>(
    () => MusicRepositoryImpl(
      youtubeMusicDataSource: getIt<YouTubeMusicDataSource>(),
      spotifyDataSource: getIt<SpotifyDataSource>(),
      cacheBox: getIt<Box<Map<String, dynamic>>>(),
    ),
  );
  
  // Use cases
  getIt.registerLazySingleton<SearchSongs>(
    () => SearchSongs(getIt<MusicRepository>()),
  );
  
  getIt.registerLazySingleton<GetTrendingSongs>(
    () => GetTrendingSongs(getIt<MusicRepository>()),
  );
}
