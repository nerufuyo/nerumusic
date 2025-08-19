import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';

/// Base class for all use cases following Clean Architecture
/// Implements common patterns for business logic execution
abstract class UseCase<Type, Params> {
  /// Main execution method for the use case
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters
abstract class NoParamsUseCase<Type> {
  /// Main execution method for the use case
  Future<Either<Failure, Type>> call();
}

/// Base class for use case parameters
/// Ensures all parameters are equatable for testing
abstract class UseCaseParams extends Equatable {
  const UseCaseParams();
}

/// No parameters class for use cases that don't require input
class NoParams extends UseCaseParams {
  const NoParams();

  @override
  List<Object?> get props => [];
}
