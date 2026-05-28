import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/notification_sound_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getNotifications();
      setState(() {
        _notifs = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _markRead(Map<String, dynamic> n) async {
    // Check both 'read' and 'isRead' fields
    final isAlreadyRead = (n['read'] ?? n['isRead']) == true;
    if (isAlreadyRead) return;
    
    // Play notification sound
    final soundService = NotificationSoundService();
    final notificationType = (n['type'] ?? 'default').toString().toLowerCase();
    await soundService.playNotificationSound(soundType: notificationType);
    
    try {
      await ApiService.markNotificationRead(n['id'].toString());
      // Update both fields for consistency
      setState(() {
        n['read'] = true;
        n['isRead'] = true;
      });
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    for (final n in _notifs) {
      final isAlreadyRead = (n['read'] ?? n['isRead']) == true;
      if (!isAlreadyRead) {
        try {
          await ApiService.markNotificationRead(n['id'].toString());
        } catch (_) {}
      }
    }
    setState(() {
      for (final n in _notifs) {
        n['read'] = true;
        n['isRead'] = true;
      }
    });
  }

  int get _unread => _notifs.where((n) => (n['read'] ?? n['isRead']) != true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            if (_unread > 0)
              Text('$_unread unread',
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
        actions: [
          if (_unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
                  ]),
                )
              : _notifs.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none,
                              size: 64, color: Color(0xFFE8EAF6)),
                          SizedBox(height: 16),
                          Text('No notifications',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _notifs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 2),
                        itemBuilder: (_, i) {
                          final n = _notifs[i];
                          final isRead = (n['read'] ?? n['isRead']) == true;
                          final title = (n['title'] ?? 'Notification').toString();
                          final body = (n['message'] ?? n['body'] ?? '').toString();
                          final type = (n['type'] ?? 'tip').toString().toLowerCase();
                          final time = (n['createdAt'] ?? '').toString();

                          return GestureDetector(
                            onTap: () => _markRead(n),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? Colors.white
                                    : const Color(0xFFE8EAF6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isRead
                                      ? const Color(0xFFF0F0F0)
                                      : const Color(0xFFC5CAE9),
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
                                      color: _iconBg(type),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(_iconData(type),
                                        color: _iconColor(type), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(title,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: isRead
                                                        ? FontWeight.w500
                                                        : FontWeight.w700,
                                                    color: const Color(0xFF212121),
                                                  )),
                                            ),
                                            if (!isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF1A237E),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(body,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF757575),
                                                height: 1.4)),
                                        const SizedBox(height: 6),
                                        Text(time,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFFBDBDBD))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  IconData _iconData(String type) {
    if (type.contains('appointment') || type.contains('reminder')) return Icons.event;
    if (type.contains('alert') || type.contains('emergency')) return Icons.warning_amber;
    if (type.contains('system_update')) return Icons.system_update;
    if (type.contains('milestone')) return Icons.star;
    return Icons.lightbulb_outline; // info or tip
  }

  Color _iconBg(String type) {
    if (type.contains('appointment') || type.contains('reminder')) return const Color(0xFFE3F2FD);
    if (type.contains('alert') || type.contains('emergency')) return const Color(0xFFFFEBEE);
    if (type.contains('system_update')) return const Color(0xFFEDE7F6);
    if (type.contains('milestone')) return const Color(0xFFFFF8E1);
    return const Color(0xFFE8F5E9);
  }

  Color _iconColor(String type) {
    if (type.contains('appointment') || type.contains('reminder')) return const Color(0xFF1A237E);
    if (type.contains('alert') || type.contains('emergency')) return const Color(0xFFC62828);
    if (type.contains('system_update')) return const Color(0xFF512DA8);
    if (type.contains('milestone')) return const Color(0xFFF9A825);
    return const Color(0xFF2E7D32);
  }
}

