import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';

/// Standalone notification bell button + dropdown panel.
/// Drop this into any AppBar/TopNavbar in place of the old _IconBtn.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _overlayKey = GlobalKey();
  OverlayEntry? _overlay;

  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _poll();
  }

  // Poll every 30 seconds for new notifications
  Future<void> _poll() async {
    while (mounted) {
      await _load();
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    try {
      final data = await ApiService.getNotifications();
      if (mounted) {
        setState(() => _notifications = data.cast<Map<String, dynamic>>());
      }
    } catch (_) {}
  }

  int get _unread => _notifications.where((n) => n['read'] == false).length;

  void _togglePanel() {
    if (_overlay != null) {
      _closePanel();
    } else {
      _openPanel();
    }
  }

  void _openPanel() {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlay = OverlayEntry(
      builder: (_) => _NotificationDropdown(
        top: offset.dy + size.height + 8,
        right: MediaQuery.of(context).size.width - offset.dx - size.width,
        notifications: _notifications,
        onMarkRead: _markRead,
        onMarkAllRead: _markAllRead,
        onDelete: _delete,
        onClose: _closePanel,
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _closePanel() {
    _overlay?.remove();
    _overlay = null;
  }

  Future<void> _markRead(String id) async {
    try {
      await ApiService.markNotificationRead(id);
      await _load();
      // Refresh overlay
      _overlay?.markNeedsBuild();
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      await ApiService.markAllNotificationsRead();
      await _load();
      _overlay?.markNeedsBuild();
    } catch (_) {}
  }

  Future<void> _delete(String id) async {
    try {
      await ApiService.deleteNotification(id);
      await _load();
      _overlay?.markNeedsBuild();
    } catch (_) {}
  }

  @override
  void dispose() {
    _closePanel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _overlayKey,
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: _togglePanel,
          icon: Icon(
            _overlay != null
                ? Icons.notifications_rounded
                : Icons.notifications_none_rounded,
            color: AppColors.secondary,
            size: 22,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (_unread > 0)
          Positioned(
            top: 4, right: 4,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: AppColors.criticalText, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  _unread > 9 ? '9+' : '$_unread',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationDropdown extends StatelessWidget {
  final double top, right;
  final List<Map<String, dynamic>> notifications;
  final Future<void> Function(String) onMarkRead;
  final Future<void> Function() onMarkAllRead;
  final Future<void> Function(String) onDelete;
  final VoidCallback onClose;

  const _NotificationDropdown({
    required this.top,
    required this.right,
    required this.notifications,
    required this.onMarkRead,
    required this.onMarkAllRead,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dismiss tap outside
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          top: top,
          right: right,
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(14),
            color: AppColors.surfaceContainerLowest,
            child: Container(
              width: 360,
              constraints: const BoxConstraints(maxHeight: 480),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.shadowColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                    child: Row(children: [
                      Text('Notifications',
                          style: GoogleFonts.publicSans(
                              fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.headings)),
                      const Spacer(),
                      if (notifications.any((n) => n['read'] == false))
                        TextButton(
                          onPressed: onMarkAllRead,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                          child: Text('Mark all read',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary)),
                        ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.mutedText),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      ),
                    ]),
                  ),
                  const Divider(height: 1, color: AppColors.shadowColor),

                  // List
                  if (notifications.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(children: [
                        const Icon(Icons.notifications_off_outlined, size: 36, color: AppColors.mutedText),
                        const SizedBox(height: 8),
                        Text('No notifications', style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
                      ]),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.shadowColor),
                        itemBuilder: (_, i) => _NotifTile(
                          notif: notifications[i],
                          onMarkRead: onMarkRead,
                          onDelete: onDelete,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotifTile extends StatelessWidget {
  final Map<String, dynamic> notif;
  final Future<void> Function(String) onMarkRead;
  final Future<void> Function(String) onDelete;

  const _NotifTile({required this.notif, required this.onMarkRead, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final id = notif['id']?.toString() ?? '';
    final isRead = notif['read'] == true;
    final type = notif['type']?.toString() ?? 'info';
    final title = notif['title']?.toString() ?? '';
    final body = notif['body']?.toString() ?? '';
    final createdAt = notif['createdAt']?.toString() ?? '';

    Color typeColor;
    IconData typeIcon;
    switch (type) {
      case 'alert':
        typeColor = AppColors.criticalText;
        typeIcon = Icons.warning_amber_rounded;
        break;
      case 'appointment':
        typeColor = AppColors.primary;
        typeIcon = Icons.calendar_today_rounded;
        break;
      default:
        typeColor = AppColors.infoText;
        typeIcon = Icons.info_outline_rounded;
    }

    return InkWell(
      onTap: isRead ? null : () => onMarkRead(id),
      borderRadius: BorderRadius.circular(0),
      child: Container(
        color: isRead ? Colors.transparent : AppColors.infoBg.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, size: 16, color: typeColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                          color: AppColors.onSurface)),
                ),
                if (!isRead)
                  Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  ),
              ]),
              const SizedBox(height: 2),
              Text(body,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(_timeAgo(createdAt),
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText)),
            ]),
          ),
          IconButton(
            onPressed: () => onDelete(id),
            icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.mutedText),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            tooltip: 'Dismiss',
          ),
        ]),
      ),
    );
  }

  String _timeAgo(String iso) {
    try {
      final diff = DateTime.now().difference(DateTime.parse(iso));
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}
