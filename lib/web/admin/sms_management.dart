import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class SMSManagementScreen extends StatefulWidget {
  const SMSManagementScreen({super.key});

  @override
  State<SMSManagementScreen> createState() => _SMSManagementScreenState();
}

class _SMSManagementScreenState extends State<SMSManagementScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _smsLogs = [];
  Map<String, dynamic> _gatewayConfig = {
    'provider': 'Twilio',
    'status': 'Connected',
    'balance': 1450,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Mocking SMS logs fetch
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _smsLogs = [
          {'to': '+265888123456', 'status': 'Delivered', 'type': 'Reminder', 'date': '2026-05-19 10:00'},
          {'to': '+265999654321', 'status': 'Failed', 'type': 'Alert', 'date': '2026-05-19 09:30'},
          {'to': '+265888987654', 'status': 'Delivered', 'type': 'OTP', 'date': '2026-05-18 14:20'},
          {'to': '+265999112233', 'status': 'Delivered', 'type': 'Reminder', 'date': '2026-05-18 08:00'},
        ];
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SMS Management', style: TextStyle(fontFamily: 'Public Sans', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 6),
          Text('Manage SMS gateway configurations and view message logs.', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          // Gateway Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.g200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.message_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gateway: ${_gatewayConfig['provider']}', style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.headings)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.successText, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('${_gatewayConfig['status']}  •  Balance: ${_gatewayConfig['balance']} Credits', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText)),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Configure Gateway'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Text('Recent Messages', style: TextStyle(fontFamily: 'Public Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.g200),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('Recipient', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedText))),
                      Expanded(flex: 2, child: Text('Type', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedText))),
                      Expanded(flex: 2, child: Text('Date', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedText))),
                      Expanded(flex: 2, child: Text('Status', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedText))),
                    ],
                  ),
                ),
                ..._smsLogs.map((log) {
                  final status = log['status'] as String;
                  final color = status == 'Delivered' ? AppColors.successText : AppColors.criticalText;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.g200))),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(log['to'], style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface))),
                        Expanded(flex: 2, child: Text(log['type'], style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface))),
                        Expanded(flex: 2, child: Text(log['date'], style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText))),
                        Expanded(flex: 2, child: Row(
                          children: [
                            Icon(status == 'Delivered' ? Icons.check_circle : Icons.error, size: 14, color: color),
                            const SizedBox(width: 6),
                            Text(status, style: TextStyle(fontFamily: 'Roboto', fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                          ],
                        )),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

