import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/music_repository.dart';
import 'base_usecase.dart';

/// Use case for getting trending songs
/// Implements business logic for trending content functionality
class GetTrendingSongs implements NoParamsUseCase<List<Song>> {
  final MusicRepository _repository;

  GetTrendingSongs(this._repository);

  @override
  Future<Either<Failure, List<Song>>> call() async {
    // Get trending songs with default limit
    return await _repository.getTrendingSongs(limit: 20);
  }
}
