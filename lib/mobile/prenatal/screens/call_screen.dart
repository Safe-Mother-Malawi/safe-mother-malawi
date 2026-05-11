import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class CallScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  const CallScreen({super.key, this.onOpenDrawer});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // Emergency contacts including 700
  final List<Map<String, String>> _emergencyContacts = [
    {
      'name': 'Emergency Hotline',
      'number': '700',
      'description': 'Emergency medical assistance',
      'icon': 'emergency'
    },
    {
      'name': 'Ambulance Service',
      'number': '998',
      'description': 'Emergency ambulance',
      'icon': 'ambulance'
    },
    {
      'name': 'Police Emergency',
      'number': '997',
      'description': 'Police emergency line',
      'icon': 'police'
    },
    {
      'name': 'Fire Emergency',
      'number': '999',
      'description': 'Fire emergency services',
      'icon': 'fire'
    },
  ];

  Future<void> _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot make call to $phoneNumber'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getContactIcon(String iconType) {
    switch (iconType) {
      case 'emergency':
        return Icons.local_hospital;
      case 'ambulance':
        return Icons.local_shipping;
      case 'police':
        return Icons.local_police;
      case 'fire':
        return Icons.local_fire_department;
      default:
        return Icons.phone;
    }
  }

  Color _getContactColor(String iconType) {
    switch (iconType) {
      case 'emergency':
        return Colors.red;
      case 'ambulance':
        return Colors.blue;
      case 'police':
        return Colors.indigo;
      case 'fire':
        return Colors.orange;
      default:
        return AppColors.mobileNavy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.mobileNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => widget.onOpenDrawer?.call(),
        ),
        title: const Text('Emergency Contacts',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Contacts Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emergency, size: 32, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mobileNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap any contact to make an emergency call',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._emergencyContacts.map((contact) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getContactColor(contact['icon']!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getContactColor(contact['icon']!).withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getContactColor(contact['icon']!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getContactIcon(contact['icon']!),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            contact['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact['description']!,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                contact['number']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getContactColor(contact['icon']!),
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getContactColor(contact['icon']!),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          onTap: () => _makeCall(contact['number']!),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Additional Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 32, color: AppColors.mobileNavy),
                      const SizedBox(width: 12),
                      Text(
                        'Important Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mobileNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoItem(
                    icon: Icons.warning_amber,
                    title: 'When to call 700',
                    description: 'Severe bleeding, difficulty breathing, severe pain, or any life-threatening emergency',
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _InfoItem(
                    icon: Icons.local_hospital,
                    title: 'Medical Emergency Signs',
                    description: 'High fever, severe headache, blurred vision, or sudden swelling',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _InfoItem(
                    icon: Icons.phone_in_talk,
                    title: 'Stay Calm',
                    description: 'Speak clearly, provide your location, and follow the operator\'s instructions',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}