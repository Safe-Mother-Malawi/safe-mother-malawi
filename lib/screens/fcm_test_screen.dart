import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/notification_service.dart';

/// FCM Testing Screen
class FCMTestScreen extends StatefulWidget {
  const FCMTestScreen({Key? key}) : super(key: key);

  @override
  State<FCMTestScreen> createState() => _FCMTestScreenState();
}

class _FCMTestScreenState extends State<FCMTestScreen> {
  final NotificationService _notificationService = NotificationService();
  String? _fcmToken;
  String? _storedToken;
  bool _isLoading = true;
  List<Map<String, dynamic>> _receivedNotifications = [];

  @override
  void initState() {
    super.initState();
    _initializeAndLoadToken();
    _listenToNotifications();
  }

  Future<void> _initializeAndLoadToken() async {
    try {
      // Get current FCM token
      final token = await _notificationService.getFCMToken();
      
      // Get stored token
      final storedToken = await _notificationService.getStoredFCMToken();

      setState(() {
        _fcmToken = token;
        _storedToken = storedToken;
        _isLoading = false;
      });

      print('✓ FCM Token loaded: $token');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error loading FCM token: $e');
    }
  }

  void _listenToNotifications() {
    _notificationService.notificationStream.listen((notification) {
      setState(() {
        _receivedNotifications.insert(0, {
          ...notification,
          'receivedAt': DateTime.now(),
        });
      });

      print('📬 Notification received: ${notification['title']}');
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token copied to clipboard')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Testing'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FCM Token Section
                  _buildSection(
                    title: 'FCM Token',
                    icon: Icons.vpn_key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTokenCard(
                          label: 'Current Token',
                          token: _fcmToken,
                          onCopy: () => _copyToClipboard(_fcmToken ?? ''),
                        ),
                        const SizedBox(height: 12),
                        _buildTokenCard(
                          label: 'Stored Token',
                          token: _storedToken,
                          onCopy: () => _copyToClipboard(_storedToken ?? ''),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status Section
                  _buildSection(
                    title: 'Status',
                    icon: Icons.info,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusRow(
                          'Token Generated',
                          _fcmToken != null,
                        ),
                        _buildStatusRow(
                          'Token Registered',
                          _storedToken != null,
                        ),
                        _buildStatusRow(
                          'Tokens Match',
                          _fcmToken == _storedToken,
                        ),
                        _buildStatusRow(
                          'Notifications Received',
                          _receivedNotifications.isNotEmpty,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions Section
                  _buildSection(
                    title: 'Actions',
                    icon: Icons.touch_app,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _initializeAndLoadToken,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Token'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(_fcmToken ?? ''),
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Current Token'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions Section
                  _buildSection(
                    title: 'Testing Instructions',
                    icon: Icons.description,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInstructionStep(
                          '1',
                          'Copy the FCM token above',
                        ),
                        _buildInstructionStep(
                          '2',
                          'Send it to your backend via POST /push-notifications/register',
                        ),
                        _buildInstructionStep(
                          '3',
                          'Backend sends test notification via Firebase',
                        ),
                        _buildInstructionStep(
                          '4',
                          'Notification appears below in "Received Notifications"',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Received Notifications Section
                  if (_receivedNotifications.isNotEmpty)
                    _buildSection(
                      title: 'Received Notifications (${_receivedNotifications.length})',
                      icon: Icons.notifications,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _receivedNotifications
                            .map((notification) => _buildNotificationCard(notification))
                            .toList(),
                      ),
                    ),
                  if (_receivedNotifications.isEmpty)
                    _buildSection(
                      title: 'Received Notifications',
                      icon: Icons.notifications_none,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No notifications received yet. Send a test notification from your backend.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTokenCard({
    required String label,
    required String? token,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            token ?? 'Not available',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: status ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status ? '✓ OK' : '✗ Failed',
              style: TextStyle(
                color: status ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final receivedAt = notification['receivedAt'] as DateTime?;
    final timeStr = receivedAt != null
        ? '${receivedAt.hour}:${receivedAt.minute}:${receivedAt.second}'
        : 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green[300]!),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.green[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  notification['title'] ?? 'No title',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification['body'] ?? 'No body',
            style: const TextStyle(fontSize: 13),
          ),
          if (notification['type'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Chip(
                label: Text(notification['type']),
                backgroundColor: Colors.blue[100],
                labelStyle: const TextStyle(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
