import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

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
    // Backend field is 'read', not 'isRead'
    if (n['read'] == true) return;
    try {
      await ApiService.markNotificationRead(n['id'].toString());
      setState(() => n['read'] = true);
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      // Use bulk endpoint instead of looping
      await ApiService.markAllNotificationsRead();
      setState(() {
        for (final n in _notifs) {
          n['read'] = true;
        }
      });
    } catch (_) {}
  }

  int get _unread => _notifs.where((n) => n['read'] != true).length;

  String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final local = dt.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${local.day}/${local.month}/${local.year}';
  }

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
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _load),
          if (_unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _load, child: const Text('Retry')),
                ]))
              : _notifs.isEmpty
                  ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.notifications_none, size: 64, color: Color(0xFFE8EAF6)),
                      SizedBox(height: 16),
                      Text('No notifications', style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E))),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _notifs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 2),
                        itemBuilder: (_, i) {
                          final n = _notifs[i];
                          final isRead = n['read'] == true;
                          final title = (n['title'] ?? 'Notification').toString();
                          final body = (n['body'] ?? n['message'] ?? '').toString();
                          final type = (n['type'] ?? 'info').toString().toLowerCase();
                          final time = _formatTime(n['createdAt']?.toString());

                          return Dismissible(
                            key: ValueKey(n['id']?.toString() ?? i.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: Color(0xFFC62828), size: 22),
                            ),
                            onDismissed: (_) async {
                              final id = n['id']?.toString();
                              if (id != null) {
                                try {
                                  await ApiService.instance.delete('/notifications/$id');
                                } catch (_) {}
                              }
                              setState(() => _notifs.removeAt(i));
                            },
                            child: GestureDetector(
                            onTap: () => _markRead(n),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isRead ? Colors.white : const Color(0xFFE8EAF6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isRead ? const Color(0xFFF0F0F0) : const Color(0xFFC5CAE9),
                                ),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Container(
                                  width: 42, height: 42,
                                  decoration: BoxDecoration(color: _iconBg(type), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(_iconData(type), color: _iconColor(type), size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    Expanded(child: Text(title, style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                      color: const Color(0xFF212121),
                                    ))),
                                    if (!isRead)
                                      Container(width: 8, height: 8,
                                          decoration: const BoxDecoration(color: Color(0xFF1A237E), shape: BoxShape.circle)),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(body, style: const TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.4)),
                                  const SizedBox(height: 6),
                                  Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                                ])),
                              ]),
                            ),
                          ),
                          );
                        },
                      ),
                    ),
    );
  }

  IconData _iconData(String type) {
    if (type.contains('appointment')) return Icons.event;
    if (type.contains('alert')) return Icons.warning_amber;
    if (type.contains('milestone')) return Icons.star;
    return Icons.lightbulb_outline;
  }

  Color _iconBg(String type) {
    if (type.contains('appointment')) return const Color(0xFFE3F2FD);
    if (type.contains('alert')) return const Color(0xFFFFEBEE);
    if (type.contains('milestone')) return const Color(0xFFFFF8E1);
    return const Color(0xFFE8F5E9);
  }

  Color _iconColor(String type) {
    if (type.contains('appointment')) return const Color(0xFF1A237E);
    if (type.contains('alert')) return const Color(0xFFC62828);
    if (type.contains('milestone')) return const Color(0xFFF9A825);
    return const Color(0xFF2E7D32);
  }
}
