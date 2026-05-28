import 'package:flutter/foundation.dart';

/// Utility for handling and formatting API errors
class ErrorHandler {
  /// Convert exception to user-friendly error message
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return 'An unknown error occurred';
    }

    final errorStr = error.toString();

    // Handle ApiException format: ApiException(statusCode): message
    if (errorStr.contains('ApiException')) {
      if (errorStr.contains('401')) {
        return 'Your session has expired. Please log in again.';
      }
      if (errorStr.contains('403')) {
        return 'You do not have permission to perform this action.';
      }
      if (errorStr.contains('404')) {
        return 'The requested resource was not found.';
      }
      if (errorStr.contains('429')) {
        return 'Too many requests. Please wait a moment and try again.';
      }
      if (errorStr.contains('500')) {
        return 'Server error. Please try again later.';
      }
      if (errorStr.contains('503')) {
        return 'Service temporarily unavailable. Please try again later.';
      }
      // Extract message from ApiException
      final match = RegExp(r'ApiException\(\d+\):\s*(.+)').firstMatch(errorStr);
      if (match != null) {
        return match.group(1) ?? 'API error occurred';
      }
    }

    // Handle timeout errors
    if (errorStr.contains('timeout') || errorStr.contains('TimeoutException')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    // Handle connection errors
    if (errorStr.contains('Connection') || errorStr.contains('SocketException')) {
      return 'Connection failed. Please check your internet connection.';
    }

    // Handle offline errors
    if (errorStr.contains('offline') || errorStr.contains('Offline')) {
      return 'You are offline. Please check your internet connection.';
    }

    // Handle JSON parsing errors
    if (errorStr.contains('FormatException') || errorStr.contains('JSON')) {
      return 'Invalid response from server. Please try again.';
    }

    // Remove "Exception: " prefix if present
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.replaceFirst('Exception: ', '');
    }

    // Return original error if it's already a reasonable message
    if (errorStr.length < 100 && !errorStr.contains('Stack')) {
      return errorStr;
    }

    return 'An error occurred. Please try again.';
  }

  /// Log error for debugging
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    debugPrint('❌ [$context] Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Check if error is retryable
  static bool isRetryable(dynamic error) {
    final errorStr = error.toString();
    
    // Retryable errors
    if (errorStr.contains('429') || // Rate limited
        errorStr.contains('timeout') ||
        errorStr.contains('Connection') ||
        errorStr.contains('SocketException') ||
        errorStr.contains('503') || // Service unavailable
        errorStr.contains('502')) { // Bad gateway
      return true;
    }

    // Non-retryable errors
    if (errorStr.contains('401') || // Unauthorized
        errorStr.contains('403') || // Forbidden
        errorStr.contains('404')) { // Not found
      return false;
    }

    return true; // Default to retryable
  }

  /// Check if error is a session/auth error
  static bool isSessionError(dynamic error) {
    final errorStr = error.toString();
    return errorStr.contains('401') || 
           errorStr.contains('Unauthorized') ||
           errorStr.contains('Not authenticated');
  }
}
