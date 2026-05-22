import 'package:flutter/material.dart';
import '../../../state/notifications_store.dart';
import '../widgets/notification_card.dart';

/// Notifications screen for viewing all notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsStore _store;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _store = NotificationsStore();
    _store.addListener(_onStoreChanged);
    _loadNotifications();
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    setState(() {});
  }

  Future<void> _loadNotifications() async {
    await _store.loadNotifications();
  }

  List<AppNotification> _getFilteredNotifications() {
    if (_filterType == 'all') {
      return _store.notifications;
    } else if (_filterType == 'unread') {
      return _store.unreadNotifications;
    } else {
      return _store.getByType(_filterType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _getFilteredNotifications();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          if (_store.unreadCount > 0)
            TextButton.icon(
              onPressed: _store.markAllAsRead,
              icon: const Icon(Icons.done_all),
              label: const Text('Mark All Read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _buildNotificationsList(filteredNotifications),
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildFilterChip('all', 'All'),
              const SizedBox(width: 8),
              _buildFilterChip('unread', 'Unread (${_store.unreadCount})'),
              const SizedBox(width: 8),
              _buildFilterChip('appointment', 'Appointments'),
              const SizedBox(width: 8),
              _buildFilterChip('alert', 'Alerts'),
              const SizedBox(width: 8),
              _buildFilterChip('info', 'Info'),
            ],
          ),
        ),
        // Notifications list
        Expanded(
          child: notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationCard(
                      notification: notification,
                      onMarkRead: () => _store.markAsRead(notification.id),
                      onDelete: () => _store.deleteNotification(notification.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = value;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}
