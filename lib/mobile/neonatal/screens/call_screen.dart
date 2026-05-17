import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/notification_icon.dart';
import 'notifications_screen.dart';

class CallScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  const CallScreen({super.key, this.onOpenDrawer});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String _selectedLanguage = 'en';
  List<Map<String, String>> _supportedLanguages = [];
  bool _languagesLoading = true;
  final String _apiBaseUrl = 'https://backend-gsgb.onrender.com/api/v1';

  // Emergency contact - only 700 for help
  final List<Map<String, String>> _emergencyContacts = [
    {
      'name': 'Emergency Help',
      'number': '700',
      'description': 'Call for emergency assistance',
      'icon': 'emergency'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSupportedLanguages();
  }

  Future<void> _loadSupportedLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/languages'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _supportedLanguages = List<Map<String, String>>.from(
            (data['languages'] as List).map((lang) => {
              'code': lang['code'] as String,
              'name': lang['name'] as String,
              'nativeName': lang['nativeName'] as String,
            }),
          );
          _languagesLoading = false;
        });
      }
    } catch (e) {
      setState(() => _languagesLoading = false);
    }
  }

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
        return const Color(0xFF1A237E);
    }
  }

  void _startCall() {
    // Call functionality removed - show message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling feature is currently unavailable'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show language selection first
    if (_languagesLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A237E),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => widget.onOpenDrawer?.call(),
          ),
          title: const Text('Emergency Help', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A237E)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => widget.onOpenDrawer?.call(),
        ),
        title: const Text('Emergency Help',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NotificationIcon(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NeonatalNotificationsScreen()),
              ),
              iconColor: Colors.white,
            ),
          ),
        ],
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
                      const Text(
                        'Emergency Help',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to call for emergency help',
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
            
            // Language Selection Section (if languages are available)
            if (_supportedLanguages.isNotEmpty) ...[
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
                        const Icon(Icons.language, size: 32, color: Color(0xFF1A237E)),
                        const SizedBox(width: 12),
                        const Text(
                          'Language Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select your preferred language for emergency calls',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._supportedLanguages.map((lang) {
                      final isSelected = _selectedLanguage == lang['code'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1A237E).withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF1A237E) : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              lang['name']!,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? const Color(0xFF1A237E) : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              lang['nativeName']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? const Color(0xFF1A237E) : Colors.grey,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Color(0xFF1A237E))
                                : null,
                            onTap: () {
                              setState(() => _selectedLanguage = lang['code']!);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}