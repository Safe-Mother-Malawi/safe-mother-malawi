import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// FCM Token Management Service (mobile only)
class FCMService {
  static final FCMService _instance = FCMService._internal();

  factory FCMService() {
    return _instance;
  }

  FCMService._internal();

  late ApiService _apiService;
  String? _currentToken;
  Function(Map<String, dynamic>)? _onForegroundMessage;

  /// Initialize FCM service
  Future<void> initialize(
    ApiService apiService, {
    Function(Map<String, dynamic>)? onForegroundMessage,
  }) async {
    _apiService = apiService;
    _onForegroundMessage = onForegroundMessage;
    
    // FCM initialization would go here on mobile
    // On web, this is a no-op
    print('✓ FCM Service initialized (stub)');
  }

  /// Set foreground message handler
  void setForegroundMessageHandler(Function(Map<String, dynamic>) handler) {
    _onForegroundMessage = handler;
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      if (_currentToken != null) {
        return _currentToken;
      }
      return null;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  /// Get stored FCM token from SharedPreferences
  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      print('Error getting stored token: $e');
      return null;
    }
  }

  /// Unregister device token
  Future<void> unregisterDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');

      if (token != null) {
        await _apiService.delete('/push-notifications/unregister/$token');
        await prefs.remove('fcm_token');
        _currentToken = null;
        print('✓ Device token unregistered');
      }
    } catch (e) {
      print('Error unregistering device: $e');
    }
  }
}
