import 'package:flutter/material.dart';
import 'dart:async';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service_web.dart';
import '../../../utils/live_data_mixin.dart';

class ClinicianDashboardPage extends StatefulWidget {
  final VoidCallback? onRegisterPatient;
  const ClinicianDashboardPage({super.key, this.onRegisterPatient});

  @override
  State<ClinicianDashboardPage> createState() => _ClinicianDashboardPageState();
}

class _ClinicianDashboardPageState extends State<ClinicianDashboardPage> with LiveDataMixin<ClinicianDashboardPage> {
  bool _loading = true;
  String? _error;

  int _prenatalCount  = 0;
  int _neonatalCount  = 0;
  int _alertCount     = 0;
  String _userName    = '';

  List<Map<String, dynamic>> _recentPrenatal = [];
  List<Map<String, dynamic>> _todayAppts     = [];
  bool _loadingAppointments = true;
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _userName = AuthServiceWeb.instance.userName;
    _load();
    startLive(_load);
    // Refresh appointments every 10 seconds to catch updates/deletions
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadTodayAppointments();
    });
  }

  @override
  void dispose() {
    stopLive();
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      // Load patient and alert data with individual error handling
      final prenatalFuture = ApiService.instance.get('/patients/prenatal')
          .timeout(const Duration(seconds: 10))
          .catchError((e) {
            debugPrint('⚠️ Failed to load prenatal patients: $e');
            return <dynamic>[];
          });
      
      final neonatalFuture = ApiService.instance.get('/patients/neonatal')
          .timeout(const Duration(seconds: 10))
          .catchError((e) {
            debugPrint('⚠️ Failed to load neonatal patients: $e');
            return <dynamic>[];
          });
      
      final alertsFuture = ApiService.instance.get('/alerts/active')
          .timeout(const Duration(seconds: 10))
          .catchError((e) {
            debugPrint('⚠️ Failed to load alerts: $e');
            return <dynamic>[];
          });

      final results = await Future.wait([prenatalFuture, neonatalFuture, alertsFuture]);

      // Safely parse results with validation
      final prenatal = _parseList(results[0]);
      final neonatal = _parseList(results[1]);
      final alerts = _parseList(results[2]);

      if (!mounted) return;
      setState(() {
        _prenatalCount  = prenatal.length;
        _neonatalCount  = neonatal.length;
        _alertCount     = alerts.length;
        _recentPrenatal = prenatal.take(5).toList();
        _loading        = false;
      });
      
      // Load today's appointments separately
      await _loadTodayAppointments();
    } catch (e) {
      debugPrint('❌ Failed to load clinician dashboard: $e');
      if (!mounted) return;
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _loading = false; });
    }
  }

  /// Safely parse API response to List<Map<String, dynamic>>
  List<Map<String, dynamic>> _parseList(dynamic data) {
    try {
      if (data is List) {
        return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
      if (data is Map<String, dynamic>) {
        final items = data['data'] ?? data['items'] ?? data['results'] ?? [];
        if (items is List) {
          return items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('⚠️ Error parsing list data: $e');
      return [];
    }
  }

  Future<void> _loadTodayAppointments() async {
    try {
      // Get all appointments (not filtered by clinician ID - that's done server-side)
      final allAppointments = await ApiService.getAppointments().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );
      
      if (allAppointments is! List) {
        throw Exception('Invalid data format');
      }
      
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      final todayAppointments = (allAppointments as List)
          .cast<Map<String, dynamic>>()
          .where((a) {
            // Try multiple date field names
            final dateStr = (a['date'] ?? a['appointmentDate'] ?? a['appointment_date'] ?? '').toString().trim();
            if (dateStr.isEmpty) return false;
            
            DateTime? date;
            
            // Try parsing as ISO format (2024-05-19 or 2024-05-19T10:30:00)
            if (dateStr.contains('-')) {
              date = DateTime.tryParse(dateStr);
            }
            
            // If parsing failed, try other formats
            if (date == null) {
              // Try DD/MM/YYYY format
              try {
                final parts = dateStr.split('/');
                if (parts.length == 3) {
                  date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                }
              } catch (e) {
                // Ignore parsing errors
              }
            }
            
            if (date == null) return false;
            
            // Compare only year, month, and day (ignore time)
            final appointmentDate = DateTime(date.year, date.month, date.day);
            return appointmentDate == todayDate;
          })
          .toList();
      
      if (mounted) {
        setState(() {
          _todayAppts = todayAppointments.take(5).toList();
          _loadingAppointments = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load clinician appointments: $e');
      if (mounted) {
        setState(() => _loadingAppointments = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        const Text('Failed to load dashboard'),
        TextButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Retry')),
      ]));
    }

    final now = DateTime.now();
    final dateStr = '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
        const SizedBox(height: 20),

        // Welcome banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome back, $_userName', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Text('Clinician Dashboard', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.calendar_today, color: Colors.white54, size: 12),
                const SizedBox(width: 4),
                Text(dateStr, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ]),
            ])),
            ElevatedButton.icon(
              onPressed: widget.onRegisterPatient,
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Register Patient', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Metric cards
        Row(children: [
          Expanded(child: _metricCard(Icons.people_outline, '${_prenatalCount + _neonatalCount}', 'Active Patients', 'Total', AppColors.navy, AppColors.navyL)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard(Icons.pregnant_woman, '$_prenatalCount', 'Pregnant', 'ANC active', AppColors.navy, AppColors.navyL)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard(Icons.child_friendly_outlined, '$_neonatalCount', 'Neonatal', 'PNC active', AppColors.navy, AppColors.navyL)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard(Icons.notifications_active_outlined, '$_alertCount', 'Alerts', 'Active alerts', AppColors.orange, AppColors.orangeL)),
        ]),
        const SizedBox(height: 20),

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 3, child: _buildRecentPatients()),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildTodayAppointments()),
        ]),
      ]),
    );
  }

  Widget _metricCard(IconData icon, String value, String label, String sub, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, color: color, size: 20),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ]),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color, height: 1)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.g400)),
      ]),
    );
  }

  Widget _buildRecentPatients() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(children: [
            Icon(Icons.people_outline, color: AppColors.navy, size: 18),
            SizedBox(width: 8),
            Text('Recent Prenatal Patients', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
          ]),
        ),
        const Divider(height: 1, color: AppColors.g200),
        if (_recentPrenatal.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No patients yet.', style: TextStyle(color: AppColors.g400))),
          )
        else
          ..._recentPrenatal.map((p) {
            final name = p['fullName'] as String? ?? 'Unknown';
            final age  = p['age']?.toString() ?? '?';
            final months = p['pregnancyMonths']?.toString() ?? '?';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.g200, width: 0.5))),
              child: Row(children: [
                CircleAvatar(radius: 16, backgroundColor: AppColors.navyL,
                    child: Text(name[0], style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.g800)),
                  Text('$age yrs · $months months pregnant', style: const TextStyle(fontSize: 10, color: AppColors.g400)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Prenatal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navy)),
                ),
              ]),
            );
          }),
      ]),
    );
  }

  Widget _buildTodayAppointments() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined, color: AppColors.navy, size: 18),
            SizedBox(width: 8),
            Text("Today's Appointments", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
          ]),
        ),
        const Divider(height: 1, color: AppColors.g200),
        if (_loadingAppointments)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: AppColors.navy)),
          )
        else if (_todayAppts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 40,
                    color: AppColors.navy.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No Appointments Today',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.g800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You have no appointments scheduled for today.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.g400,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._todayAppts.map((a) {
            final time  = a['time'] as String? ?? '--:--';
            final title = a['title'] as String? ?? a['patientName'] as String? ?? 'Appointment';
            final location = (a['location'] ?? a['facility'] ?? 'TBD').toString();
            final doctor = (a['doctor'] ?? a['clinician']?['fullName'] ?? 'TBD').toString();
            final dateStr = (a['date'] ?? a['appointmentDate'] ?? a['appointment_date'] ?? '').toString();
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.g200, width: 0.5))),
              child: Row(children: [
                Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.g600)),
                const SizedBox(width: 12),
                Container(width: 3, height: 32, color: AppColors.navy),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 12, color: AppColors.g800))),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Appointment Details',
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Title', title),
                              _buildDetailRow('Date', _fmtFull(DateTime.tryParse(dateStr) ?? DateTime.now())),
                              _buildDetailRow('Time', time),
                              _buildDetailRow('Location', location),
                              _buildDetailRow('Doctor', doctor),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                  ),
                ),
              ]),
            );
          }),
      ]),
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.g600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.g800),
          ),
        ],
      ),
    );
  }

  static String _fmtFull(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _weekday(int d) => const ['','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'][d];
  String _month(int m) => const ['','January','February','March','April','May','June','July','August','September','October','November','December'][m];
}

