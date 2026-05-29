import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import '../state/user_store.dart';

/// Web portal authentication — calls POST /auth/login
class AuthServiceWeb {
  AuthServiceWeb._();
  static final AuthServiceWeb instance = AuthServiceWeb._();
  static const String _sessionKey = 'offline_web_user_session';

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  String get userName => _currentUser?['fullName'] ?? _currentUser?['email'] ?? 'User';
  String get userRole => _currentUser?['role'] ?? '';

  /// Call this after a successful profile update so the in-memory session
  /// reflects the latest data without requiring a full re-login.
  void updateCurrentUser(Map<String, dynamic> updated) {
    if (_currentUser == null) return;
    _currentUser = {..._currentUser!, ...updated};
    persistSession(_currentUser!);
    // Notify UserStore listeners so any widget watching the name rebuilds
    UserStore.instance.refresh();
  }

  Future<Map<String, dynamic>?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = prefs.getString(_sessionKey);
    if (serialized == null || serialized.isEmpty) return null;
    try {
      final decoded = jsonDecode(serialized);
      if (decoded is! Map<String, dynamic>) return null;
      _currentUser = decoded;
      UserStore.instance.refresh();
      return decoded;
    } catch (_) {
      return null;
    }
  }

  Future<void> persistSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user));
  }

  Future<String> login(String email, String password) async {
    debugPrint('🔐 AuthServiceWeb.login() called with email: $email');
    debugPrint('📡 API Base URL: ${ApiService.baseUrl}');

    try {
      final data = await ApiService.instance.post('/auth/login', {
        'identifier': email,
        'password': password,
      });

      debugPrint('✅ Login successful, received data: ${data.keys}');

      final tokens = data['tokens'];
      await ApiService.instance.saveToken(
        tokens['accessToken'] as String,
        tokens['refreshToken'] as String,
      );

      _currentUser = data['user'] as Map<String, dynamic>;
      await persistSession(_currentUser!);
      debugPrint('✅ User role: ${_currentUser!['role']}');
      return _currentUser!['role'] as String;
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      // Clear cached session on login failure - don't allow fallback to cached user
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      _currentUser = null;
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.instance.post('/auth/logout', {});
    } catch (_) {}
    await ApiService.instance.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _currentUser = null;
    UserStore.instance.refresh();
  }

  Future<void> forgotPassword(String email) async {
    // Backend: POST /auth/forgot-password/question
    // For web portal we just call the question endpoint
    await ApiService.instance.post('/auth/forgot-password/question', {
      'identifier': email,
    });
  }
}

