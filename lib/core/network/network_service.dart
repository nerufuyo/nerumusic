import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Network service interface following dependency inversion principle
/// Provides abstraction for HTTP operations with error handling
abstract class NetworkService {
  /// Performs GET request with error handling
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters});
  
  /// Performs POST request with error handling
  Future<Response> post(String endpoint, {dynamic data});
  
  /// Performs PUT request with error handling
  Future<Response> put(String endpoint, {dynamic data});
  
  /// Performs DELETE request with error handling
  Future<Response> delete(String endpoint);
}

/// Concrete implementation of NetworkService using Dio
/// Handles network configuration, timeouts, and error mapping
class NetworkServiceImpl implements NetworkService {
  late final Dio _dio;
  
  NetworkServiceImpl() {
    _initializeDio();
  }

  /// Initializes Dio with configuration and interceptors
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConstants.apiTimeoutSeconds),
      headers: {'Content-Type': 'application/json'},
    ));
    
    _dio.interceptors.add(_createLogInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
  }

  /// Creates logging interceptor for debugging
  Interceptor _createLogInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
        // Only log in debug mode
        assert(() {
          debugPrint('[API] $object');
          return true;
        }());
      },
    );
  }

  /// Creates error handling interceptor
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final exception = _mapDioErrorToException(error);
        handler.reject(DioException.requestCancelled(
          requestOptions: error.requestOptions,
          reason: exception.toString(),
        ));
      },
    );
  }

  @override
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } catch (e) {
      throw _mapDioErrorToException(e);
    }
  }

  @override
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      throw _mapDioErrorToException(e);
    }
  }

  @override
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      throw _mapDioErrorToException(e);
    }
  }

  @override
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      throw _mapDioErrorToException(e);
    }
  }

  /// Maps Dio errors to custom exceptions
  Exception _mapDioErrorToException(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException(message: 'Connection timeout');
        case DioExceptionType.badResponse:
          return ServerException(
            message: 'Server error: ${error.message}',
            statusCode: error.response?.statusCode,
          );
        default:
          return NetworkException(message: 'Network error: ${error.message}');
      }
    }
    return NetworkException(message: error.toString());
  }
}
