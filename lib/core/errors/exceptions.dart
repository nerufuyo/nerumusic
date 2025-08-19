/// Custom exceptions for the application
/// Provides specific error types for better error handling
class ServerException implements Exception {
  const ServerException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  const NetworkException({required this.message});

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  const CacheException({required this.message});

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  const AuthException({required this.message});

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

class AudioException implements Exception {
  const AudioException({required this.message});

  final String message;

  @override
  String toString() => 'AudioException: $message';
}

class ValidationException implements Exception {
  const ValidationException({required this.message});

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
