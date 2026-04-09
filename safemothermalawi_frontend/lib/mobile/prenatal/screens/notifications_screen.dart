import 'package:flutter/material.dart';

class _Notif {
  final String title;
  final String body;
  final String time;
  final String type; // 'appointment' | 'tip' | 'alert' | 'milestone'
  bool read;
  _Notif({required this.title, required this.body, required this.time, required this.type, this.read = false});
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notif> _notifs = [
    _Notif(title: 'Appointment Tomorrow', body: 'Antenatal check-up at 10:00 AM · City Clinic', time: '2h ago', type: 'appointment'),
    _Notif(title: 'Weekly Milestone 🎉', body: 'Your baby is now the size of a banana! Week 20 reached.', time: '5h ago', type: 'milestone'),
    _Notif(title: 'Nutrition Reminder', body: 'Iron & calcium are key this week. Check your nutrition tips.', time: 'Yesterday', type: 'tip', read: true),
    _Notif(title: 'Health Alert', body: 'You reported headaches. Please monitor and consult your midwife if it persists.', time: 'Yesterday', type: 'alert'),
    _Notif(title: 'Ultrasound Scan', body: 'Upcoming scan on Apr 22 at 9:30 AM · Radiology Dept.', time: '2 days ago', type: 'appointment', read: true),
    _Notif(title: 'Daily Tip 💡', body: 'Stay hydrated — drink at least 8 glasses of water today.', time: '2 days ago', type: 'tip', read: true),
    _Notif(title: 'Baby Movement', body: 'Have you felt your baby move today? Track movements in the app.', time: '3 days ago', type: 'milestone', read: true),
    _Notif(title: 'Medication Reminder', body: 'Take your prenatal vitamins with your morning meal.', time: '3 days ago', type: 'tip', read: true),
  ];

  void _markAllRead() => setState(() { for (final n in _notifs) n.read = true; });
  void _markRead(int i) => setState(() => _notifs[i].read = true);
  void _delete(int i) => setState(() => _notifs.removeAt(i));

  int get _unread => _notifs.where((n) => !n.read).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            if (_unread > 0)
              Text('$_unread unread', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
        actions: [
          if (_unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: _notifs.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Color(0xFFFFCDD2)),
                  SizedBox(height: 16),
                  Text('No notifications', style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E))),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _notifs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (_, i) {
                final n = _notifs[i];
                return Dismissible(
                  key: ValueKey('$i${n.title}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: const Color(0xFFFFEBEE),
                    child: const Icon(Icons.delete_outline, color: Color(0xFFC62828)),
                  ),
                  onDismissed: (_) => _delete(i),
                  child: GestureDetector(
                    onTap: () => _markRead(i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n.read ? Colors.white : const Color(0xFFFFF0F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: n.read ? const Color(0xFFF0F0F0) : const Color(0xFFFFCDD2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _iconBg(n.type),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_iconData(n.type), color: _iconColor(n.type), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(n.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
                                            color: const Color(0xFF212121),
                                          )),
                                    ),
                                    if (!n.read)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE91E8C),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(n.body,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.4)),
                                const SizedBox(height: 6),
                                Text(n.time,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _iconData(String type) {
    switch (type) {
      case 'appointment': return Icons.event;
      case 'milestone': return Icons.star;
      case 'alert': return Icons.warning_amber;
      default: return Icons.lightbulb_outline;
    }
  }

  Color _iconBg(String type) {
    switch (type) {
      case 'appointment': return const Color(0xFFE3F2FD);
      case 'milestone': return const Color(0xFFFFF8E1);
      case 'alert': return const Color(0xFFFFEBEE);
      default: return const Color(0xFFE8F5E9);
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'appointment': return const Color(0xFF1565C0);
      case 'milestone': return const Color(0xFFF9A825);
      case 'alert': return const Color(0xFFC62828);
      default: return const Color(0xFF2E7D32);
    }
  }
}
