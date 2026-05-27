import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching data locally for offline access
class LocalCacheService {
  static final LocalCacheService _instance = LocalCacheService._();
  factory LocalCacheService() => _instance;
  LocalCacheService._();

  late SharedPreferences _prefs;
  static const String _cachePrefix = 'cache_';
  static const String _cacheTimestampPrefix = 'cache_ts_';
  static const Duration _defaultCacheDuration = Duration(hours: 24);

  /// Initialize the cache service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Cache data with optional expiration
  Future<void> set(
    String key,
    dynamic data, {
    Duration cacheDuration = _defaultCacheDuration,
  }) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';

      // Store data
      if (data is String) {
        await _prefs.setString(cacheKey, data);
      } else if (data is List) {
        await _prefs.setString(cacheKey, jsonEncode(data));
      } else if (data is Map) {
        await _prefs.setString(cacheKey, jsonEncode(data));
      } else {
        await _prefs.setString(cacheKey, jsonEncode(data));
      }

      // Store timestamp
      await _prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('💾 Cached: $key');
    } catch (e) {
      debugPrint('❌ Error caching $key: $e');
    }
  }

  /// Get cached data if not expired
  dynamic get(String key) {
    try {
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';

      // Check if cache exists
      if (!_prefs.containsKey(cacheKey)) {
        return null;
      }

      // Check if cache is expired
      final timestamp = _prefs.getInt(timestampKey);
      if (timestamp != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (cacheAge > _defaultCacheDuration.inMilliseconds) {
          await remove(key);
          return null;
        }
      }

      final cached = _prefs.getString(cacheKey);
      if (cached == null) return null;

      // Try to parse as JSON
      try {
        return jsonDecode(cached);
      } catch (_) {
        // Return as string if not valid JSON
        return cached;
      }
    } catch (e) {
      debugPrint('❌ Error retrieving cache for $key: $e');
      return null;
    }
  }

  /// Get cached data as list
  List<dynamic>? getList(String key) {
    final data = get(key);
    if (data is List) return data;
    return null;
  }

  /// Get cached data as map
  Map<String, dynamic>? getMap(String key) {
    final data = get(key);
    if (data is Map) return data.cast<String, dynamic>();
    return null;
  }

  /// Check if cache exists and is valid
  bool has(String key) {
    return get(key) != null;
  }

  /// Remove specific cache
  Future<void> remove(String key) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';
      await _prefs.remove(cacheKey);
      await _prefs.remove(timestampKey);
      debugPrint('🗑️ Removed cache: $key');
    } catch (e) {
      debugPrint('❌ Error removing cache for $key: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_cacheTimestampPrefix)) {
          await _prefs.remove(key);
        }
      }
      debugPrint('🗑️ Cleared all cache');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    try {
      final keys = _prefs.getKeys();
      final cacheKeys = keys.where((k) => k.startsWith(_cachePrefix)).toList();
      int totalSize = 0;

      for (final key in cacheKeys) {
        final value = _prefs.getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }

      return {
        'totalItems': cacheKeys.length,
        'approximateSizeKB': (totalSize / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      debugPrint('❌ Error getting cache statistics: $e');
      return {'totalItems': 0, 'approximateSizeKB': '0'};
    }
  }
}
