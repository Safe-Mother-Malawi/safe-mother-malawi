import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'fcm_service.dart';
import 'notification_sound_service.dart';

/// Notification service for handling push and local notifications
/// Note: Firebase Messaging is only available on mobile platforms
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _localNotifications;
  late ApiService _apiService;
  late FCMService _fcmService;
  late NotificationSoundService _soundService;

  final StreamController<Map<String, dynamic>> _notificationStream =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStream.stream;

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize(ApiService apiService) async {
    if (_isInitialized) return;

    _apiService = apiService;
    _localNotifications = FlutterLocalNotificationsPlugin();
    _fcmService = FCMService();
    _soundService = NotificationSoundService();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Initialize sound service
    await _soundService.initialize();

    // Initialize FCM service with foreground message handler
    await _fcmService.initialize(
      apiService,
      onForegroundMessage: _handleForegroundMessage,
    );

    _isInitialized = true;
    print('✓ Notification Service initialized');
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleLocalNotificationTap,
      );

      // Create notification channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'default',
        'Default Notifications',
        description: 'This channel is used for default notifications.',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  /// Handle foreground messages - plays sound and shows notification in real-time
  void _handleForegroundMessage(dynamic message) {
    print('📬 Message received in foreground');
    
    // Extract notification data
    final title = message['notification']?['title'] ?? 'Notification';
    final body = message['notification']?['body'] ?? 'New message';
    final data = message['data'] as Map<String, dynamic>? ?? {};
    
    // Play notification sound immediately (real-time)
    _playNotificationSoundAsync(data);
    
    // Show local notification
    _showLocalNotification(
      title: title,
      body: body,
      data: data,
    );
    
    // Emit to stream for UI listeners
    _notificationStream.add({
      'type': 'foreground',
      'title': title,
      'body': body,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Play notification sound asynchronously based on notification type (fire-and-forget)
  void _playNotificationSoundAsync(Map<String, dynamic> data) {
    // Determine sound type from notification data
    final soundType = (data['soundType'] ?? 'alert').toString().toLowerCase();
    final volume = double.tryParse(data['volume']?.toString() ?? '1.0') ?? 1.0;
    
    // Fire and forget - don't wait for completion
    _soundService.playNotificationSound(
      soundType: soundType,
      volume: volume,
    ).catchError((e) {
      print('❌ Error playing notification sound: $e');
    });
  }

  /// Handle message opened from background (stub for mobile)
  void _handleMessageOpenedApp(dynamic message) {
    print('📭 Message opened');
    _notificationStream.add({
      'type': 'background',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(
    NotificationResponse response,
  ) {
    print('Local notification tapped: ${response.payload}');

    _notificationStream.add({
      'payload': response.payload,
      'type': 'local_tap',
    });
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('📲 Showing local notification: $title');

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'default',
        'Default Notifications',
        channelDescription: 'This channel is used for default notifications.',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
        payload: data != null ? data.toString() : null,
      );

      print('✓ Local notification displayed');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getFCMToken() async {
    return await _fcmService.getToken();
  }

  /// Get stored FCM token from SharedPreferences
  Future<String?> getStoredFCMToken() async {
    return await _fcmService.getStoredToken();
  }

  /// Unregister device token
  Future<void> unregisterDevice() async {
    await _fcmService.unregisterDevice();
  }

  /// Get notification statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _apiService.get('/push-notifications/statistics');
      return response;
    } catch (e) {
      print('Error getting notification statistics: $e');
      return {};
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationStream.close();
  }
}
