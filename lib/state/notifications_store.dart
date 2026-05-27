import 'dart:async';
import '../services/api_service.dart';

/// Notification model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'info',
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Notifications store for state management
class NotificationsStore {
  static final NotificationsStore _instance = NotificationsStore._internal();

  factory NotificationsStore() {
    return _instance;
  }

  NotificationsStore._internal();

  late ApiService _apiService;
  final List<AppNotification> _notifications = [];
  final List<Function()> _listeners = [];

  bool _isInitialized = false;

  /// Initialize store
  void initialize(ApiService apiService) {
    if (_isInitialized) return;
    _apiService = apiService;
    _isInitialized = true;
  }

  /// Get all notifications
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Get unread count
  int get unreadCount => _notifications.where((n) => !n.read).length;

  /// Get unread notifications
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.read).toList();

  /// Get notifications by type
  List<AppNotification> getByType(String type) =>
      _notifications.where((n) => n.type == type).toList();

  /// Load notifications from backend
  Future<void> loadNotifications() async {
    try {
      final response = await _apiService.get('/notifications');
      if (response is List) {
        _notifications.clear();
        _notifications.addAll(
          response.map((n) => AppNotification.fromJson(n)).toList(),
        );
        _notifyListeners();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.put(
        '/notifications/$notificationId/read',
        {},
      );

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        _notifications[index] = AppNotification(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          type: notification.type,
          read: true,
          createdAt: notification.createdAt,
        );
        _notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiService.put('/notifications/mark-all-read', {});

      for (int i = 0; i < _notifications.length; i++) {
        final notification = _notifications[i];
        _notifications[i] = AppNotification(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          type: notification.type,
          read: true,
          createdAt: notification.createdAt,
        );
      }
      _notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiService.delete('/notifications/$notificationId');
      _notifications.removeWhere((n) => n.id == notificationId);
      _notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  /// Add local notification (for push notifications)
  void addLocalNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _notifyListeners();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    _notifyListeners();
  }

  /// Add listener
  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Dispose
  void dispose() {
    _listeners.clear();
    _notifications.clear();
  }
}
