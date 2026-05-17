import '../services/api_service.dart';

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
}

class NotificationStore {
  NotificationStore._();
  static final NotificationStore instance = NotificationStore._();

  final List<AppNotification> _items = [];
  bool _loaded = false;

  List<AppNotification> get all => List.from(_items)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  int get unreadCount => _items.where((n) => !n.read).length;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final data = await ApiService.instance.get('/notifications') as List<dynamic>;
      _items.clear();
      _items.addAll(data.cast<Map<String, dynamic>>().map(AppNotification.fromJson));
      _loaded = true;
      _notify();
    } catch (_) {}
  }

  Future<void> markRead(String id) async {
    try {
      await ApiService.instance.patch('/notifications/$id/read', {});
      final n = _items.firstWhere((n) => n.id == id, orElse: () => _items.first);
      n.read = true;
      _notify();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await ApiService.instance.patch('/notifications/mark-all-read', {});
      for (final n in _items) { n.read = true; }
      _notify();
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    try {
      await ApiService.instance.delete('/notifications/$id');
      _items.removeWhere((n) => n.id == id);
      _notify();
    } catch (_) {}
  }

  void add(AppNotification n) {
    _items.insert(0, n);
    _notify();
  }

  void reload() {
    _loaded = false;
    load();
  }

  final List<void Function()> _listeners = [];
  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void _notify() { for (final l in _listeners) { l(); } }
}
