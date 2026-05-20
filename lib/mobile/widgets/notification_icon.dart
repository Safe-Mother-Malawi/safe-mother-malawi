import 'package:flutter/material.dart';
import '../../services/api_service.dart';

/// Consistent notification icon with badge for unread count
/// Used throughout the mobile application
class NotificationIcon extends StatefulWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final Color badgeColor;
  final double iconSize;
  
  const NotificationIcon({
    super.key,
    required this.onTap,
    this.iconColor = Colors.white,
    this.badgeColor = const Color(0xFFE53935),
    this.iconSize = 20,
  });

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  int _unreadCount = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    if (_loading) return;
    setState(() => _loading = true);
    
    try {
      final notifications = await ApiService.getNotifications();
      final unread = notifications.where((n) => n['read'] != true).length;
      if (mounted) {
        setState(() {
          _unreadCount = unread;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// Call this method to refresh the unread count
  void refresh() {
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        // Refresh count after a delay to allow for mark as read
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _loadUnreadCount();
        });
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: widget.iconColor == Colors.white 
              ? Colors.white.withOpacity(0.25)
              : widget.iconColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_outlined,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.iconColor == Colors.white 
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
