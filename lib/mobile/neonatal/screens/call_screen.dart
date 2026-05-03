import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/notification_icon.dart';
import 'notifications_screen.dart';
import '../../ivr/screens/ivr_simulator_screen.dart';

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
  final String _apiBaseUrl = 'http://localhost:3000/api/v1/ivr';

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

  void _startIVR() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IvrSimulatorScreen(selectedLanguage: _selectedLanguage)),
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
          title: const Text('Call', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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
        title: const Text('Call',
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
            const Icon(Icons.language, size: 64, color: Color(0xFF1A237E)),
            const SizedBox(height: 24),
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 32),
            ..._supportedLanguages.map((lang) {
              final isSelected = _selectedLanguage == lang['code'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? const Color(0xFF1A237E) : Colors.white,
                    foregroundColor: isSelected ? Colors.white : const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    side: BorderSide(
                      color: const Color(0xFF1A237E),
                      width: isSelected ? 0 : 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() => _selectedLanguage = lang['code']!);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang['name']!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            lang['nativeName']!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.white),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _startIVR,
                child: const Text(
                  'Start Call',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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


