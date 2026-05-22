import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// FCM Token Management Service
class FCMService {
  static final FCMService _instance = FCMService._internal();

  factory FCMService() {
    return _instance;
  }

  FCMService._internal();

  late FirebaseMessaging _messaging;
  late ApiService _apiService;
  String? _currentToken;

  /// Initialize FCM service
  Future<void> initialize(ApiService apiService) async {
    _apiService = apiService;
    _messaging = FirebaseMessaging.instance;

    // Request notification permission
    await _requestPermission();

    // Get initial token
    await _getAndRegisterToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _registerToken(newToken);
    });

    print('✓ FCM Service initialized');
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✓ Notification permission granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('✓ Provisional notification permission granted');
      } else {
        print('✗ Notification permission denied');
      }
    } catch (e) {
      print('Error requesting permission: $e');
    }
  }

  /// Get FCM token and register with backend
  Future<void> _getAndRegisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        print('✓ FCM Token obtained: $token');
        await _registerToken(token);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  /// Register token with backend
  Future<void> _registerToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastToken = prefs.getString('fcm_token');

      // Only register if token changed
      if (lastToken != token) {
        print('Registering FCM token with backend...');

        final response = await _apiService.post(
          '/push-notifications/register',
          {
            'token': token,
            'platform': 'mobile',
            'deviceName': 'Flutter App',
          },
        );

        await prefs.setString('fcm_token', token);
        _currentToken = token;

        print('✓ FCM token registered successfully');
        print('Response: $response');
      }
    } catch (e) {
      print('Error registering token: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      if (_currentToken != null) {
        return _currentToken;
      }
      final token = await _messaging.getToken();
      _currentToken = token;
      return token;
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

  /// Get Firebase Messaging instance
  FirebaseMessaging getMessaging() {
    return _messaging;
  }
}
