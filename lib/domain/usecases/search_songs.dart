import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/music_repository.dart';
import 'base_usecase.dart';

/// Use case for searching songs across multiple platforms
/// Implements business logic for song search functionality
class SearchSongs implements UseCase<List<Song>, SearchSongsParams> {
  final MusicRepository _repository;

  SearchSongs(this._repository);

  @override
  Future<Either<Failure, List<Song>>> call(SearchSongsParams params) async {
    // Validate search query
    if (params.query.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Search query cannot be empty'));
    }

    if (params.query.length < 2) {
      return const Left(ValidationFailure(message: 'Search query must be at least 2 characters'));
    }

    // Perform search with repository
    return await _repository.searchSongs(
      params.query.trim(),
      limit: params.limit,
    );
  }
}

/// Parameters for search songs use case
class SearchSongsParams extends UseCaseParams {
  final String query;
  final int limit;

  const SearchSongsParams({
    required this.query,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, limit];
}

/// Validation failure for use case errors
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
