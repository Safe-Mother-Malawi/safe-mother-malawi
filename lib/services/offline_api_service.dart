import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'offline_service.dart';
import 'local_cache_service.dart';

/// Wrapper around ApiService that handles offline mode
class OfflineApiService {
  static final OfflineApiService _instance = OfflineApiService._();
  factory OfflineApiService() => _instance;
  OfflineApiService._();

  final _offlineService = OfflineService();
  final _cacheService = LocalCacheService();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _offlineService.initialize();
    await _cacheService.initialize();
    _initialized = true;
  }

  /// Initialize services
  Future<void> initialize() async {
    await _ensureInitialized();
  }

  /// GET request with offline fallback
  Future<dynamic> get(String path, {bool useCache = true}) async {
    await _ensureInitialized();
    try {
      if (_offlineService.isOnline) {
        final result = await ApiService.instance.get(path);
        // Cache successful response
        if (useCache) {
          await _cacheService.set(path, result);
        }
        return result;
      } else {
        // Try to return cached data
        final cached = await _cacheService.get(path);
        if (cached != null) {
          debugPrint('📦 Using cached data for: $path');
          return cached;
        }
        throw Exception('No internet connection and no cached data available');
      }
    } catch (e) {
      // Fallback to cache if online request fails
      if (useCache) {
        final cached = await _cacheService.get(path);
        if (cached != null) {
          debugPrint('📦 Using cached data (fallback) for: $path');
          return cached;
        }
      }
      rethrow;
    }
  }

  /// POST request with offline queueing
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    await _ensureInitialized();
    try {
      if (_offlineService.isOnline) {
        return await ApiService.instance.post(path, body);
      } else {
        // Queue for later sync
        await _offlineService.queueAction(
          method: 'POST',
          endpoint: path,
          body: body,
        );
        return {'queued': true, 'message': 'Action queued for sync'};
      }
    } catch (e) {
      // Queue on failure if offline
      if (_offlineService.isOffline) {
        await _offlineService.queueAction(
          method: 'POST',
          endpoint: path,
          body: body,
        );
        return {'queued': true, 'message': 'Action queued for sync'};
      }
      rethrow;
    }
  }

  /// PUT request with offline queueing
  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    await _ensureInitialized();
    try {
      if (_offlineService.isOnline) {
        return await ApiService.instance.put(path, body);
      } else {
        // Queue for later sync
        await _offlineService.queueAction(
          method: 'PUT',
          endpoint: path,
          body: body,
        );
        return {'queued': true, 'message': 'Action queued for sync'};
      }
    } catch (e) {
      // Queue on failure if offline
      if (_offlineService.isOffline) {
        await _offlineService.queueAction(
          method: 'PUT',
          endpoint: path,
          body: body,
        );
        return {'queued': true, 'message': 'Action queued for sync'};
      }
      rethrow;
    }
  }

  /// DELETE request with offline queueing
  Future<dynamic> delete(String path) async {
    await _ensureInitialized();
    try {
      if (_offlineService.isOnline) {
        return await ApiService.instance.delete(path);
      } else {
        // Queue for later sync
        await _offlineService.queueAction(
          method: 'DELETE',
          endpoint: path,
        );
        return {'queued': true, 'message': 'Action queued for sync'};
      }
    } catch (e) {
      // Queue on failure if offline
      if (_offlineService.isOffline) {
        await _offlineService.queueAction(
          method: 'DELETE',
          endpoint: path,
        );
        return {'queued': true, 'message': 'Action queued for sync'};
      }
      rethrow;
    }
  }

  /// Clear cache
  Future<void> clearCache() => _cacheService.clearAll();

  /// Get offline service
  OfflineService get offlineService => _offlineService;

  /// Get cache service
  LocalCacheService get cacheService => _cacheService;
}
