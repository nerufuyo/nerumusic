import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Performance optimization utilities for the music app
/// Provides memory management, caching, and background processing
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();

  final Map<String, dynamic> _cache = {};
  final Map<String, Timer> _cacheTimers = {};
  final List<StreamSubscription> _subscriptions = [];
  bool _isOptimizationEnabled = true;

  /// Enable or disable performance optimizations
  void setOptimizationEnabled(bool enabled) {
    _isOptimizationEnabled = enabled;
    if (!enabled) {
      clearCache();
    }
  }

  /// Clear all cached data
  void clearCache() {
    _cache.clear();
    for (final timer in _cacheTimers.values) {
      timer.cancel();
    }
    _cacheTimers.clear();
  }

  /// Cache data with optional expiration
  void cacheData(String key, dynamic data, {Duration? expiration}) {
    if (!_isOptimizationEnabled) return;

    _cache[key] = data;
    
    if (expiration != null) {
      _cacheTimers[key]?.cancel();
      _cacheTimers[key] = Timer(expiration, () {
        _cache.remove(key);
        _cacheTimers.remove(key);
      });
    }
  }

  /// Get cached data
  T? getCachedData<T>(String key) {
    if (!_isOptimizationEnabled) return null;
    return _cache[key] as T?;
  }

  /// Remove specific cached data
  void removeCachedData(String key) {
    _cache.remove(key);
    _cacheTimers[key]?.cancel();
    _cacheTimers.remove(key);
  }

  /// Preload frequently accessed data
  Future<void> preloadData(List<String> keys, Future<dynamic> Function(String) loader) async {
    if (!_isOptimizationEnabled) return;

    await Future.wait(
      keys.map((key) async {
        if (!_cache.containsKey(key)) {
          try {
            final data = await loader(key);
            cacheData(key, data, expiration: const Duration(minutes: 30));
          } catch (e) {
            debugPrint('Failed to preload data for key: $key, error: $e');
          }
        }
      }),
    );
  }

  /// Optimize memory usage by clearing old cache entries
  void optimizeMemory() {
    if (!_isOptimizationEnabled) return;

    // Remove expired entries
    final expiredKeys = <String>[];
    for (final entry in _cache.entries) {
      if (entry.value is Map && 
          entry.value['timestamp'] != null &&
          DateTime.now().difference(entry.value['timestamp'] as DateTime) > 
          const Duration(hours: 1)) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      removeCachedData(key);
    }

    // Force garbage collection if on debug mode
    if (kDebugMode) {
      SystemChannels.platform.invokeMethod('System.requestGC');
    }
  }

  /// Batch process multiple operations efficiently
  Future<List<T>> batchProcess<T>(
    List<dynamic> items,
    Future<T> Function(dynamic) processor, {
    int? batchSize,
    Duration? delay,
  }) async {
    if (!_isOptimizationEnabled) {
      return Future.wait(items.map(processor));
    }

    final size = batchSize ?? 10;
    final batchDelay = delay ?? const Duration(milliseconds: 10);
    final results = <T>[];

    for (int i = 0; i < items.length; i += size) {
      final batch = items.skip(i).take(size);
      final batchResults = await Future.wait(batch.map(processor));
      results.addAll(batchResults);
      
      // Small delay between batches to prevent blocking
      if (i + size < items.length) {
        await Future.delayed(batchDelay);
      }
    }

    return results;
  }

  /// Process heavy operations in background isolate
  static Future<T> processInBackground<T>(
    T Function() computation,
    {String? debugName}
  ) async {
    final receivePort = ReceivePort();
    
    await Isolate.spawn(
      _isolateEntryPoint,
      [receivePort.sendPort, computation],
      debugName: debugName ?? 'background_computation',
    );

    final result = await receivePort.first;
    receivePort.close();
    
    if (result is Exception) {
      throw result;
    }
    
    return result as T;
  }

  /// Entry point for background isolate
  static void _isolateEntryPoint(List<dynamic> args) {
    final sendPort = args[0] as SendPort;
    final computation = args[1] as Function();
    
    try {
      final result = computation();
      sendPort.send(result);
    } catch (e) {
      sendPort.send(Exception('Background computation failed: $e'));
    }
  }

  /// Dispose of all resources
  void dispose() {
    clearCache();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}

/// Image optimization utilities
class ImageOptimizer {
  static final Map<String, Uint8List> _imageCache = {};
  static const int _maxCacheSize = 50; // Maximum number of cached images

  /// Optimize image for display
  static Future<Uint8List?> optimizeImage(
    Uint8List imageData, {
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    final cacheKey = '${imageData.hashCode}_${maxWidth}_${maxHeight}_$quality';
    
    // Check cache first
    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey];
    }

    try {
      // TODO: Implement actual image optimization
      // This would typically use image processing libraries
      // For now, return original data
      final optimizedData = imageData;

      // Cache the result
      _cacheOptimizedImage(cacheKey, optimizedData);
      
      return optimizedData;
    } catch (e) {
      debugPrint('Image optimization failed: $e');
      return imageData;
    }
  }

  /// Cache optimized image with LRU eviction
  static void _cacheOptimizedImage(String key, Uint8List data) {
    if (_imageCache.length >= _maxCacheSize) {
      // Remove oldest entry (simplified LRU)
      final oldestKey = _imageCache.keys.first;
      _imageCache.remove(oldestKey);
    }
    
    _imageCache[key] = data;
  }

  /// Clear image cache
  static void clearImageCache() {
    _imageCache.clear();
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    final totalSize = _imageCache.values
        .fold<int>(0, (sum, data) => sum + data.length);
    
    return {
      'cached_images': _imageCache.length,
      'total_size_bytes': totalSize,
      'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'max_cache_size': _maxCacheSize,
    };
  }
}

/// Audio processing optimization utilities
class AudioOptimizer {
  static final Map<String, dynamic> _audioCache = {};
  static Timer? _cleanupTimer;

  /// Initialize audio optimization
  static void initialize() {
    // Schedule periodic cleanup
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _cleanupCache(),
    );
  }

  /// Cache audio metadata
  static void cacheAudioMetadata(String trackId, Map<String, dynamic> metadata) {
    _audioCache[trackId] = {
      'metadata': metadata,
      'timestamp': DateTime.now(),
    };
  }

  /// Get cached audio metadata
  static Map<String, dynamic>? getCachedAudioMetadata(String trackId) {
    final cached = _audioCache[trackId];
    if (cached == null) return null;

    // Check if cache is still valid (1 hour)
    final timestamp = cached['timestamp'] as DateTime;
    if (DateTime.now().difference(timestamp) > const Duration(hours: 1)) {
      _audioCache.remove(trackId);
      return null;
    }

    return cached['metadata'] as Map<String, dynamic>;
  }

  /// Preprocess audio for efficient playback
  static Future<void> preprocessAudio(String trackId) async {
    try {
      // TODO: Implement audio preprocessing
      // This could include:
      // - Format conversion
      // - Bitrate optimization
      // - Silence removal
      // - Volume normalization
      
      await Future.delayed(const Duration(milliseconds: 100));
      
    } catch (e) {
      debugPrint('Audio preprocessing failed for $trackId: $e');
    }
  }

  /// Clean up old cache entries
  static void _cleanupCache() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 2));
    final keysToRemove = <String>[];

    for (final entry in _audioCache.entries) {
      final timestamp = entry.value['timestamp'] as DateTime;
      if (timestamp.isBefore(cutoff)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _audioCache.remove(key);
    }
  }

  /// Dispose audio optimizer
  static void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _audioCache.clear();
  }
}

/// Network optimization utilities
class NetworkOptimizer {
  static final Map<String, dynamic> _networkCache = {};
  static final Map<String, DateTime> _requestTimes = {};
  static const Duration _cacheTimeout = Duration(minutes: 10);
  static const Duration _requestDelay = Duration(milliseconds: 500);

  /// Cache network response
  static void cacheResponse(String url, dynamic data) {
    _networkCache[url] = data;
    _requestTimes[url] = DateTime.now();
  }

  /// Get cached network response
  static T? getCachedResponse<T>(String url) {
    final cachedTime = _requestTimes[url];
    if (cachedTime == null) return null;

    // Check if cache is still valid
    if (DateTime.now().difference(cachedTime) > _cacheTimeout) {
      _networkCache.remove(url);
      _requestTimes.remove(url);
      return null;
    }

    return _networkCache[url] as T?;
  }

  /// Debounce network requests
  static Future<T?> debounceRequest<T>(
    String key,
    Future<T> Function() request,
  ) async {
    final lastRequest = _requestTimes[key];
    if (lastRequest != null &&
        DateTime.now().difference(lastRequest) < _requestDelay) {
      // Request too recent, skip
      return null;
    }

    _requestTimes[key] = DateTime.now();
    return await request();
  }

  /// Batch similar network requests
  static Future<List<T>> batchRequests<T>(
    List<Future<T>> requests, {
    int batchSize = 5,
  }) async {
    final results = <T>[];
    
    for (int i = 0; i < requests.length; i += batchSize) {
      final batch = requests.skip(i).take(batchSize);
      final batchResults = await Future.wait(batch);
      results.addAll(batchResults);
      
      // Small delay between batches
      if (i + batchSize < requests.length) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    return results;
  }

  /// Clear network cache
  static void clearCache() {
    _networkCache.clear();
    _requestTimes.clear();
  }
}
