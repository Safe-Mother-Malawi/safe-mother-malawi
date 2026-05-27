import 'package:flutter/material.dart';
import '../../services/api_service.dart';

/// Admin Broadcast Screen
class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({Key? key}) : super(key: key);

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final ApiService _apiService = ApiService();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  String _recipientType = 'all'; // all, role, facility, user
  String _selectedRole = 'patient';
  String _selectedFacility = '';
  String _selectedUserId = '';
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  final List<String> _roles = ['patient', 'clinician', 'admin'];
  final List<Map<String, String>> _facilities = [
    {'id': 'facility_1', 'name': 'Lilongwe Clinic'},
    {'id': 'facility_2', 'name': 'Blantyre Hospital'},
    {'id': 'facility_3', 'name': 'Mzuzu Health Center'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      _showError('Please enter title and message');
      return;
    }

    setState(() {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      final data = {
        'title': _titleController.text,
        'body': _bodyController.text,
        'type': 'emergency_broadcast',
      };

      String endpoint = '';

      switch (_recipientType) {
        case 'all':
          endpoint = '/push-notifications/broadcast/all';
          break;
        case 'role':
          endpoint = '/push-notifications/broadcast/role/$_selectedRole';
          break;
        case 'facility':
          if (_selectedFacility.isEmpty) {
            _showError('Please select a facility');
            return;
          }
          endpoint = '/push-notifications/broadcast/facility/$_selectedFacility';
          break;
        case 'user':
          if (_selectedUserId.isEmpty) {
            _showError('Please enter user ID');
            return;
          }
          endpoint = '/push-notifications/broadcast/user/$_selectedUserId';
          break;
      }

      final response = await _apiService.post(endpoint, data);

      setState(() {
        _successMessage =
            'Broadcast sent successfully to ${response['sentCount']} users';
        _titleController.clear();
        _bodyController.clear();
      });

      _showSuccess('Broadcast sent successfully!');
    } catch (e) {
      _showError('Error sending broadcast: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        title: const Text('Send Broadcast'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            _buildSection(
              title: 'Message Details',
              icon: Icons.message,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter broadcast title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.title),
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bodyController,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      hintText: 'Enter broadcast message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 5,
                    maxLength: 500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recipient Type Section
            _buildSection(
              title: 'Send To',
              icon: Icons.people,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecipientOption('all', 'All Users', Icons.public),
                  _buildRecipientOption('role', 'By Role', Icons.person),
                  _buildRecipientOption('facility', 'By Facility', Icons.location_city),
                  _buildRecipientOption('user', 'Specific User', Icons.person_outline),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recipient Details Section
            if (_recipientType == 'role')
              _buildSection(
                title: 'Select Role',
                icon: Icons.filter_list,
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value ?? 'patient';
                    });
                  },
                ),
              ),
            if (_recipientType == 'facility')
              _buildSection(
                title: 'Select Facility',
                icon: Icons.location_city,
                child: DropdownButton<String>(
                  value: _selectedFacility.isEmpty ? null : _selectedFacility,
                  isExpanded: true,
                  hint: const Text('Select a facility'),
                  items: _facilities.map((facility) {
                    return DropdownMenuItem(
                      value: facility['id'],
                      child: Text(facility['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFacility = value ?? '';
                    });
                  },
                ),
              ),
            if (_recipientType == 'user')
              _buildSection(
                title: 'User ID',
                icon: Icons.person_outline,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _selectedUserId = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter User ID',
                    hintText: 'e.g., user_123',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendBroadcast,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Sending...' : 'Send Broadcast'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Info Section
            _buildSection(
              title: 'Information',
              icon: Icons.info,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('📢', 'All Users', 'Send to all active users in the system'),
                  _buildInfoRow('👥', 'By Role', 'Send to all users with a specific role'),
                  _buildInfoRow('🏥', 'By Facility', 'Send to all users at a specific facility'),
                  _buildInfoRow('👤', 'Specific User', 'Send to a single user by ID'),
                ],
              ),
            ),
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

  Widget _buildRecipientOption(String value, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _recipientType = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _recipientType == value ? Colors.blue : Colors.grey[300]!,
              width: _recipientType == value ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _recipientType == value ? Colors.blue[50] : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                _recipientType == value ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _recipientType == value ? Colors.blue : Colors.grey,
              ),
              const SizedBox(width: 12),
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _recipientType == value ? FontWeight.bold : FontWeight.normal,
                  color: _recipientType == value ? Colors.blue : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
