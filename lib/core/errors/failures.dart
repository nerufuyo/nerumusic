import 'package:equatable/equatable.dart';

/// Base class for all application failures
/// Follows OOP principles with proper inheritance hierarchy
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final dynamic details;

  @override
  List<Object?> get props => [message, code, details];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Audio playback failures
class AudioFailure extends Failure {
  const AudioFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// General application failures
class GeneralFailure extends Failure {
  const GeneralFailure({
    required super.message,
    super.code,
    super.details,
  });
}
