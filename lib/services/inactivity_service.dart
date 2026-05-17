import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';

/// Service to handle user inactivity and auto-logout
class InactivityService {
  static const Duration _inactivityTimeout = Duration(minutes: 30);
  static const Duration _warningDuration = Duration(minutes: 29);

  Timer? _inactivityTimer;
  Timer? _warningTimer;
  VoidCallback? _onInactivityWarning;
  VoidCallback? _onLogout;

  /// Start monitoring inactivity
  void startMonitoring({
    required VoidCallback onInactivityWarning,
    required VoidCallback onLogout,
  }) {
    _onInactivityWarning = onInactivityWarning;
    _onLogout = onLogout;
    _resetInactivityTimer();
  }

  /// Stop monitoring inactivity
  void stopMonitoring() {
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();
  }

  /// Reset the inactivity timer (call on user activity)
  void resetOnActivity() {
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    // Cancel existing timers
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();

    // Set warning timer (1 minute before logout)
    _warningTimer = Timer(_warningDuration, () {
      _onInactivityWarning?.call();
    });

    // Set logout timer
    _inactivityTimer = Timer(_inactivityTimeout, () {
      _performLogout();
    });
  }

  Future<void> _performLogout() async {
    try {
      // Call logout endpoint
      await ApiService.instance.post('/auth/logout', {});
    } catch (_) {
      // Ignore errors, just clear tokens
    }

    // Clear tokens
    await ApiService.instance.clearTokens();

    // Call logout callback
    _onLogout?.call();
  }

  /// Dispose the service
  void dispose() {
    stopMonitoring();
  }
}
