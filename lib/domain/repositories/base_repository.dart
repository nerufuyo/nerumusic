import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Base repository interface following Clean Architecture principles
/// Provides common methods for all repository implementations
abstract class BaseRepository<T> {
  /// Generic method for handling API calls with error handling
  Future<Either<Failure, T>> call(Future<T> Function() apiCall);

  /// Generic method for caching data
  Future<Either<Failure, bool>> cacheData(String key, T data);

  /// Generic method for retrieving cached data
  Future<Either<Failure, T?>> getCachedData(String key);

  /// Generic method for clearing cache
  Future<Either<Failure, bool>> clearCache();
}
