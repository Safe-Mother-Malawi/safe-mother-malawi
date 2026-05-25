import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/pregnancy_data.dart';
import 'package:intl/intl.dart';

class ANCVisitsScreen extends StatefulWidget {
  const ANCVisitsScreen({super.key});

  @override
  State<ANCVisitsScreen> createState() => _ANCVisitsScreenState();
}

class _ANCVisitsScreenState extends State<ANCVisitsScreen> {
  bool _loading = true;
  PregnancyData? _data;
  List<Map<String, dynamic>> _appointments = [];

  final List<Map<String, dynamic>> _whoSchedule = [
    {'visit': 1, 'weeks': 12, 'label': '≤12 weeks', 'purpose': 'Registration & risk screening'},
    {'visit': 2, 'weeks': 20, 'label': '20 weeks', 'purpose': 'Growth monitoring'},
    {'visit': 3, 'weeks': 26, 'label': '26 weeks', 'purpose': 'BP & fetal checks'},
    {'visit': 4, 'weeks': 30, 'label': '30 weeks', 'purpose': 'Danger sign screening'},
    {'visit': 5, 'weeks': 34, 'label': '34 weeks', 'purpose': 'Birth planning'},
    {'visit': 6, 'weeks': 36, 'label': '36 weeks', 'purpose': 'Delivery preparation'},
    {'visit': 7, 'weeks': 38, 'label': '38 weeks', 'purpose': 'Final review'},
    {'visit': 8, 'weeks': 40, 'label': '40 weeks', 'purpose': 'Post-date assessment'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null && user.lmpDate.isNotEmpty) {
        _data = PregnancyData(lmp: DateTime.tryParse(user.lmpDate) ?? DateTime.now());
      } else {
        _data = PregnancyData.fromTotalWeeks(20); // Fallback
      }

      final data = await ApiService.getAppointments().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );
      
      if (data is! List) {
        throw Exception('Invalid data format');
      }
      
      setState(() {
        _appointments = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Failed to load ANC data: $e');
      setState(() => _loading = false);
    }
  }

  String _getVisitStatus(int targetWeek) {
    if (_data == null) return 'upcoming';
    
    final currentWeek = _data!.currentWeek;
    
    // Simple logic: if past the week and no appointment, missed.
    // If we have an appointment around that week that is completed, completed.
    // Otherwise upcoming.
    
    // Check if we have a completed appointment within +/- 2 weeks of the target week's date
    if (_data?.lmp != null) {
      final targetDate = _data!.lmp.add(Duration(days: targetWeek * 7));
      final hasCompleted = _appointments.any((a) {
        if (a['status'] != 'completed') return false;
        final date = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
        final diff = date.difference(targetDate).inDays.abs();
        return diff <= 14;
      });
      if (hasCompleted) return 'completed';
      
      if (currentWeek > targetWeek + 1) return 'missed';
      if (currentWeek == targetWeek || currentWeek == targetWeek - 1 || currentWeek == targetWeek + 1) return 'due';
      return 'upcoming';
    }
    
    return 'upcoming';
  }

  DateTime? _getExpectedDate(int targetWeek) {
    if (_data?.lmp != null) {
      return _data!.lmp.add(Duration(days: targetWeek * 7));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        title: const Text('WHO ANC Schedule', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _whoSchedule.length,
              itemBuilder: (context, index) {
                final visit = _whoSchedule[index];
                final status = _getVisitStatus(visit['weeks']);
                final expectedDate = _getExpectedDate(visit['weeks']);
                
                return _VisitCard(
                  visit: visit,
                  status: status,
                  expectedDate: expectedDate,
                );
              },
            ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final Map<String, dynamic> visit;
  final String status;
  final DateTime? expectedDate;

  const _VisitCard({required this.visit, required this.status, this.expectedDate});

  Color _getStatusColor() {
    switch (status) {
      case 'completed': return const Color(0xFF4CAF50);
      case 'missed': return const Color(0xFFF44336);
      case 'due': return const Color(0xFFFF9800);
      case 'upcoming': default: return const Color(0xFF9E9E9E);
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'completed': return 'Completed';
      case 'missed': return 'Missed';
      case 'due': return 'Due Now';
      case 'upcoming': default: return 'Upcoming';
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'completed': return Icons.check_circle;
      case 'missed': return Icons.cancel;
      case 'due': return Icons.warning_rounded;
      case 'upcoming': default: return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final dateStr = expectedDate != null ? DateFormat('MMM d, yyyy').format(expectedDate!) : 'Unknown Date';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 6)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ANC ${visit['visit']}',
                      style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(_getStatusIcon(), color: color, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                visit['purpose'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16, color: Color(0xFF757575)),
                  const SizedBox(width: 6),
                  Text(
                    'Target: ${visit['label']} ($dateStr)',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                  ),
                ],
              ),
              if (status == 'missed')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFD32F2F), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please contact your health facility to reschedule your missed appointment.',
                            style: TextStyle(fontSize: 12, color: Color(0xFFD32F2F)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

