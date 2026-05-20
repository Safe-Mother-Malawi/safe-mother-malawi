import '../services/api_service.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

enum NotifType { alert, appointment, info }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotifType type;
  final DateTime timestamp;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.read = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    final typeStr = (j['type'] ?? 'info').toString();
    final type = typeStr == 'alert'
        ? NotifType.alert
        : typeStr == 'appointment'
        ? NotifType.appointment
        : NotifType.info;
    // Support both 'read' and 'isRead' fields from API
    final isRead = (j['read'] ?? j['isRead']) == true;
    return AppNotification(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      body: j['body']?.toString() ?? '',
      type: type,
      timestamp:
          DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      read: isRead,
    );
  }

  /// Returns a human-readable time ago string (e.g., "2 minutes ago", "1 hour ago")
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${(diff.inDays / 7).floor()}w ago';
    }
  }
}

class NotificationStore extends ChangeNotifier {
  NotificationStore._();
  static final NotificationStore instance = NotificationStore._();

  final List<AppNotification> _items = [];
  bool _loaded = false;
  Timer? _refreshTimer;

  List<AppNotification> get all =>
      List.from(_items)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  int get unreadCount => _items.where((n) => !n.read).length;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final data =
          await ApiService.instance.get('/notifications') as List<dynamic>;
      _items.clear();
      _items.addAll(
        data.cast<Map<String, dynamic>>().map(AppNotification.fromJson),
      );
      _loaded = true;
      notifyListeners();
      // Start auto-refresh timer after initial load
      _startAutoRefresh();
    } catch (_) {}
  }

  Future<void> markRead(String id) async {
    try {
      await ApiService.instance.patch('/notifications/$id/read', {});
      final n = _items.firstWhere(
        (n) => n.id == id,
        orElse: () => _items.first,
      );
      n.read = true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await ApiService.instance.patch('/notifications/mark-all-read', {});
      for (final n in _items) {
        n.read = true;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    try {
      await ApiService.instance.delete('/notifications/$id');
      _items.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (_) {}
  }

  void add(AppNotification n) {
    _items.insert(0, n);
    notifyListeners();
  }

  void reload() {
    _loaded = false;
    load();
  }

  /// Start auto-refresh timer to periodically reload notifications
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final data =
            await ApiService.instance.get('/notifications') as List<dynamic>;
        final newItems = data
            .cast<Map<String, dynamic>>()
            .map(AppNotification.fromJson)
            .toList();

        // Update existing items and add new ones
        for (final newItem in newItems) {
          final existingIndex = _items.indexWhere((n) => n.id == newItem.id);
          if (existingIndex >= 0) {
            // Update existing notification's read status
            _items[existingIndex].read = newItem.read;
          } else {
            // Add new notification
            _items.insert(0, newItem);
          }
        }

        // Remove notifications that no longer exist
        _items.removeWhere((n) => !newItems.any((ni) => ni.id == n.id));

        notifyListeners();
      } catch (_) {}
    });
  }

  /// Stop auto-refresh timer
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
