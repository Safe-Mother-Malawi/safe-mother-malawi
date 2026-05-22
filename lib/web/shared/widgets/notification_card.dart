import 'package:flutter/material.dart';
import '../../../state/notifications_store.dart';

/// Widget for displaying a single notification
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onMarkRead,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildLeadingIcon(),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!notification.read)
              PopupMenuItem(
                child: const Text('Mark as read'),
                onTap: onMarkRead,
              ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: onDelete,
            ),
          ],
        ),
        onTap: () {
          if (!notification.read) {
            onMarkRead();
          }
        },
      ),
    );
  }

  Widget _buildLeadingIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'appointment':
        icon = Icons.calendar_today;
        color = Colors.blue;
        break;
      case 'alert':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case 'info':
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
