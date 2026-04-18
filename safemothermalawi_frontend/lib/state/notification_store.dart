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
}

class NotificationStore {
  NotificationStore._();
  static final NotificationStore instance = NotificationStore._();

  final List<AppNotification> _items = [
    AppNotification(id: '1', title: 'High Alert — Grace Banda',    body: 'BP 148/96. Severe hypertension. Immediate review required.',  type: NotifType.alert,       timestamp: DateTime.now().subtract(const Duration(minutes: 12))),
    AppNotification(id: '2', title: 'High Alert — Faith Mwale',    body: 'BP 152/98. Pre-eclampsia risk detected at week 34.',           type: NotifType.alert,       timestamp: DateTime.now().subtract(const Duration(minutes: 35))),
    AppNotification(id: '3', title: 'Appointment — Grace Banda',   body: 'ANC check scheduled for today at 09:00 AM.',                  type: NotifType.appointment, timestamp: DateTime.now().subtract(const Duration(hours: 1))),
    AppNotification(id: '4', title: 'Appointment — Mercy Tembo',   body: 'PNC day 8 visit scheduled for today at 11:30 AM.',            type: NotifType.appointment, timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    AppNotification(id: '5', title: 'Overdue Checkup',             body: 'Liness Kachali has a gestational diabetes review overdue.',   type: NotifType.info,        timestamp: DateTime.now().subtract(const Duration(hours: 3))),
  ];

  List<AppNotification> get all => List.from(_items)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  int get unreadCount => _items.where((n) => !n.read).length;

  void markRead(String id) {
    final n = _items.firstWhere((n) => n.id == id, orElse: () => _items.first);
    n.read = true;
    _notify();
  }

  void markAllRead() {
    for (final n in _items) {
      n.read = true;
    }
    _notify();
  }

  void add(AppNotification n) {
    _items.insert(0, n);
    _notify();
  }

  final List<void Function()> _listeners = [];
  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void _notify() { for (final l in _listeners) {
    l();
  } }
}
