import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../services/api_service.dart';
import '../config/api_config.dart';

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
    final type = typeStr == 'alert' ? NotifType.alert
        : typeStr == 'appointment' ? NotifType.appointment
        : NotifType.info;
    return AppNotification(
      id:        j['id']?.toString() ?? '',
      title:     j['title']?.toString() ?? '',
      body:      j['body']?.toString() ?? '',
      type:      type,
      timestamp: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
      read:      j['read'] == true,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

/// Singleton notification store with real-time Socket.IO updates + 30s polling fallback.
class NotificationStore extends ChangeNotifier {
  NotificationStore._();
  static final NotificationStore instance = NotificationStore._();

  final List<AppNotification> _items = [];
  io.Socket? _socket;
  Timer? _pollTimer;

  List<AppNotification> get all =>
      List.from(_items)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  int get unreadCount => _items.where((n) => !n.read).length;

  // ── Init ──────────────────────────────────────────────────────────────────

  /// Call once after login to start real-time updates.
  void start() {
    load();
    _connectSocket();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => reload());
  }

  /// Call on logout to clean up.
  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void _connectSocket() {
    try {
      _socket = io.io(
        ApiConfig.wsUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .enableReconnection()
            .build(),
      );
      // Reload notifications when any relevant event fires
      for (final event in ['alert:created', 'patient:registered', 'appointment:changed']) {
        _socket!.on(event, (_) => reload());
      }
      _socket!.connect();
    } catch (_) {}
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    try {
      final data = await ApiService.instance.get('/notifications') as List<dynamic>;
      _items.clear();
      _items.addAll(data.cast<Map<String, dynamic>>().map(AppNotification.fromJson));
      notifyListeners();
    } catch (_) {}
  }

  void reload() => load();

  Future<void> markRead(String id) async {
    try {
      await ApiService.instance.patch('/notifications/$id/read', {});
      final idx = _items.indexWhere((n) => n.id == id);
      if (idx != -1) { _items[idx].read = true; notifyListeners(); }
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await ApiService.instance.patch('/notifications/mark-all-read', {});
      for (final n in _items) { n.read = true; }
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

  // ── Legacy listener API (for widgets not using ListenableBuilder) ─────────
  @override
  void addListener(VoidCallback listener) => super.addListener(listener);
  @override
  void removeListener(VoidCallback listener) => super.removeListener(listener);
}
