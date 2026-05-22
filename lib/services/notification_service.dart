import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'fcm_service.dart';

/// Notification service for handling push and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin _localNotifications;
  late ApiService _apiService;
  late FCMService _fcmService;

  final StreamController<Map<String, dynamic>> _notificationStream =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStream.stream;

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize(ApiService apiService) async {
    if (_isInitialized) return;

    _apiService = apiService;
    _firebaseMessaging = FirebaseMessaging.instance;
    _localNotifications = FlutterLocalNotificationsPlugin();
    _fcmService = FCMService();

    // Initialize FCM service (handles token registration)
    await _fcmService.initialize(apiService);

    // Initialize Firebase Messaging handlers
    await _initializeFirebaseMessaging();

    // Initialize local notifications
    await _initializeLocalNotifications();

    _isInitialized = true;
    print('✓ Notification Service initialized');
  }

  /// Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle terminated state messages
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      print('✓ Firebase Messaging handlers registered');
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
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

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('═══════════════════════════════════════════');
    print('📬 FOREGROUND MESSAGE RECEIVED');
    print('═══════════════════════════════════════════');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
    print('═══════════════════════════════════════════');

    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      data: message.data,
    );

    // Emit to stream
    _notificationStream.add({
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
      'type': 'foreground',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle message opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('═══════════════════════════════════════════');
    print('📭 BACKGROUND MESSAGE OPENED');
    print('═══════════════════════════════════════════');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
    print('═══════════════════════════════════════════');

    _notificationStream.add({
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
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
