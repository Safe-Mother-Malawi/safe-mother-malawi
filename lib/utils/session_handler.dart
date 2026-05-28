import 'package:flutter/material.dart';
import '../mobile/auth/screens/login_screen.dart';
import '../main_mobile.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

/// Handles session expiration and unauthorized access
class SessionHandler {
  /// Check if error is a session/auth error
  static bool isSessionError(dynamic error) {
    final errorStr = error.toString();
    return errorStr.contains('401') || 
           errorStr.contains('Unauthorized') ||
           errorStr.contains('Not authenticated');
  }

  /// Handle session expiration - logs out user and redirects to login
  static Future<void> handleSessionExpired(BuildContext? context) async {
    try {
      // Clear stored session
      await AuthService().logout();
      
      // Clear API tokens
      await ApiService.instance.clearTokens();
      
      // Navigate to login screen using root navigator
      if (context != null && context.mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      } else {
        // Fallback: use global navigator key
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ Error handling session expiration: $e');
    }
  }

  /// Show session expired dialog and redirect to login
  static Future<void> showSessionExpiredDialog(BuildContext context) async {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.red, size: 24),
            SizedBox(width: 12),
            Text('Session Expired'),
          ],
        ),
        content: const Text(
          'Your session has expired. Please log in again to continue.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await handleSessionExpired(context);
            },
            child: const Text(
              'Log In',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Wrap API call with session error handling
  static Future<T> withSessionCheck<T>(
    Future<T> Function() apiCall,
    BuildContext context,
  ) async {
    try {
      return await apiCall();
    } catch (e) {
      if (isSessionError(e)) {
        if (context.mounted) {
          await showSessionExpiredDialog(context);
        }
        rethrow;
      }
      rethrow;
    }
  }
}
