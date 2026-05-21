import 'package:flutter/material.dart';
import '../../../state/reminders_store.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onReschedule;

  const ReminderCard({
    Key? key,
    required this.reminder,
    this.onAcknowledge,
    this.onCancel,
    this.onDelete,
    this.onReschedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.body,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 12),
            // Details row
            Row(
              children: [
                _buildDetailChip('Type', reminder.typeLabel),
                const SizedBox(width: 8),
                _buildDetailChip('Frequency', reminder.frequencyLabel),
                const SizedBox(width: 8),
                _buildDetailChip('Scheduled', _formatDateTime(reminder.scheduledFor)),
              ],
            ),
            const SizedBox(height: 12),
            // Time until reminder
            if (reminder.status == ReminderStatus.pending)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '⏱️ ${reminder.timeUntilReminder}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (reminder.status == ReminderStatus.pending && onAcknowledge != null)
                  TextButton.icon(
                    onPressed: onAcknowledge,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Acknowledge'),
                  ),
                if (reminder.status == ReminderStatus.pending && onCancel != null)
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                  ),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (reminder.status) {
      case ReminderStatus.pending:
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
        icon = Icons.schedule;
        break;
      case ReminderStatus.sent:
        bgColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
        icon = Icons.check_circle;
        break;
      case ReminderStatus.failed:
        bgColor = Colors.red[100]!;
        textColor = Colors.red[900]!;
        icon = Icons.error;
        break;
      case ReminderStatus.cancelled:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        icon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            reminder.statusLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (reminderDate == today) {
      return 'Today ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (reminderDate == tomorrow) {
      return 'Tomorrow ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
