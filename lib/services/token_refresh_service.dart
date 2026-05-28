import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Handles automatic token refresh when access token expires
class TokenRefreshService {
  TokenRefreshService._();
  static final TokenRefreshService instance = TokenRefreshService._();

  static String get _base => ApiConfig.baseUrl;
  bool _isRefreshing = false;
  final List<Future<String?>> _refreshQueue = [];

  /// Attempt to refresh the access token using the refresh token
  /// Returns new access token on success, null on failure
  Future<String?> refreshAccessToken() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      debugPrint('⏳ Token refresh already in progress, queuing request...');
      final completer = Future<String?>.delayed(const Duration(milliseconds: 100));
      _refreshQueue.add(completer);
      return completer;
    }

    _isRefreshing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('❌ No refresh token available');
        return null;
      }

      debugPrint('🔄 Attempting to refresh access token...');

      final response = await http.post(
        Uri.parse('$_base/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null) {
          // Save new tokens
          await prefs.setString('access_token', newAccessToken);
          if (newRefreshToken != null) {
            await prefs.setString('refresh_token', newRefreshToken);
          }

          debugPrint('✅ Token refreshed successfully');
          return newAccessToken;
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ Refresh token expired or invalid (401)');
        // Clear tokens - user needs to login again
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        return null;
      } else {
        debugPrint('❌ Token refresh failed: ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        debugPrint('Error: ${errorData['message']}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Token refresh error: $e');
      return null;
    } finally {
      _isRefreshing = false;
      _refreshQueue.clear();
    }
  }

  /// Check if token is expired (basic check based on JWT structure)
  /// Returns true if token appears to be expired
  static bool isTokenExpired(String token) {
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return true;

      // Decode payload (add padding if needed)
      String payload = parts[1];
      payload = payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');
      
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      final exp = decoded['exp'] as int?;

      if (exp == null) return true;

      // Check if expiration time has passed (with 30-second buffer)
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      final bufferTime = now.add(const Duration(seconds: 30));

      return bufferTime.isAfter(expirationTime);
    } catch (e) {
      debugPrint('⚠️ Error checking token expiration: $e');
      return true; // Assume expired if we can't parse
    }
  }

  /// Get remaining time until token expires
  static Duration? getTokenTimeRemaining(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      payload = payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');
      
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      final exp = decoded['exp'] as int?;

      if (exp == null) return null;

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      if (now.isAfter(expirationTime)) {
        return Duration.zero;
      }

      return expirationTime.difference(now);
    } catch (e) {
      debugPrint('⚠️ Error calculating token time remaining: $e');
      return null;
    }
  }
}
