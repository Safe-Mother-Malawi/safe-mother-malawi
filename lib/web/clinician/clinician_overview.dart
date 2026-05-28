import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/app_shell.dart';
import '../shared/sidebar.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';
import '../shared/utils/responsive_helper.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service_web.dart';
import '../../../state/user_store.dart';
import '../../../utils/live_data_mixin.dart';

class ClinicianOverview extends StatefulWidget {
  const ClinicianOverview({super.key});

  @override
  State<ClinicianOverview> createState() => _ClinicianOverviewState();
}

class _ClinicianOverviewState extends State<ClinicianOverview> {
  String _currentRoute = '/overview';

  @override
  void initState() {
    super.initState();
    UserStore.instance.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    UserStore.instance.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() => setState(() {});

  void _navigate(String route) => setState(() => _currentRoute = route);

  Widget _buildPage() {
    switch (_currentRoute) {
      default:
        return const _ClinicianOverviewBody();
    }
  }

  String get _pageTitle {
    const titles = {
      '/overview': 'Overview',
    };
    return titles[_currentRoute] ?? 'Clinician Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: UserRole.clinician,
      userName: AuthServiceWeb.instance.userName,
      currentRoute: _currentRoute,
      pageTitle: _pageTitle,
      onNavigate: _navigate,
      body: _buildPage(),
    );
  }
}

class _ClinicianOverviewBody extends StatefulWidget {
  const _ClinicianOverviewBody();

  @override
  State<_ClinicianOverviewBody> createState() => _ClinicianOverviewBodyState();
}

class _ClinicianOverviewBodyState extends State<_ClinicianOverviewBody> with LiveDataMixin {
  bool _loading = true;
  String? _error;

  int _prenatalCount = 0;
  int _neonatalCount = 0;
  int _alertCount = 0;
  int _appointmentCount = 0;

  List<Map<String, dynamic>> _recentPrenatal = [];
  List<Map<String, dynamic>> _todayAppts = [];

  @override
  void initState() {
    super.initState();
    _load();
    startPolling(_silentLoad);
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  Future<void> _silentLoad() async {
    try {
      final results = await Future.wait([
        ApiService.instance.get('/patients/prenatal').timeout(const Duration(seconds: 10)),
        ApiService.instance.get('/patients/neonatal').timeout(const Duration(seconds: 10)),
        ApiService.instance.get('/alerts/active').timeout(const Duration(seconds: 10)),
        ApiService.getAppointments().timeout(const Duration(seconds: 10)),
      ], eagerError: false).catchError((e) {
        debugPrint('❌ Clinician dashboard polling error: $e');
        return <dynamic>[];
      });

      if (results.isEmpty || results.length < 4) return;

      final prenatal = _parseList(results[0]);
      final neonatal = _parseList(results[1]);
      final alerts = _parseList(results[2]);
      final appointments = _parseList(results[3]);

      if (mounted) {
        setState(() {
          _prenatalCount = prenatal.length;
          _neonatalCount = neonatal.length;
          _alertCount = alerts.length;
          _appointmentCount = appointments.length;
          _recentPrenatal = prenatal.take(5).toList();
          _todayAppts = appointments.take(5).toList();
        });
      }
    } catch (e) {
      debugPrint('⚠️ Silent load error: $e');
    }
  }

  Future<void> _load() async {
    try {
      await _silentLoad();
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('❌ Failed to load clinician dashboard: $e');
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            const Text('Failed to load dashboard'),
            TextButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _load();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : (isTablet ? 200 : 220),
                child: KpiCard(
                  icon: Icons.people_outline,
                  value: '$_prenatalCount',
                  label: 'Prenatal',
                  sublabel: 'Active patients',
                  color: AppColors.navy,
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : (isTablet ? 200 : 220),
                child: KpiCard(
                  icon: Icons.child_friendly_outlined,
                  value: '$_neonatalCount',
                  label: 'Neonatal',
                  sublabel: 'Active patients',
                  color: AppColors.navy,
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : (isTablet ? 200 : 220),
                child: KpiCard(
                  icon: Icons.notifications_active_outlined,
                  value: '$_alertCount',
                  label: 'Alerts',
                  sublabel: 'Active alerts',
                  color: Colors.orange,
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : (isTablet ? 200 : 220),
                child: KpiCard(
                  icon: Icons.calendar_today_outlined,
                  value: '$_appointmentCount',
                  label: 'Appointments',
                  sublabel: 'Total scheduled',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Patients and Today's Appointments
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildRecentPatients(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildTodayAppointments(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPatients() {
    return ChartCard(
      title: 'Recent Prenatal Patients',
      subtitle: 'Latest registered patients',
      chart: _recentPrenatal.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No patients yet'),
              ),
            )
          : Column(
              children: _recentPrenatal.map((p) {
                final name = p['fullName'] as String? ?? 'Unknown';
                final age = p['age']?.toString() ?? '?';
                final months = p['pregnancyMonths']?.toString() ?? '?';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.navyL,
                        child: Text(
                          name[0],
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.g800,
                              ),
                            ),
                            Text(
                              '$age yrs · $months months pregnant',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.g400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.navyL,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Prenatal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildTodayAppointments() {
    return ChartCard(
      title: "Today's Appointments",
      subtitle: 'Scheduled for today',
      chart: _todayAppts.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No appointments today'),
              ),
            )
          : Column(
              children: _todayAppts.map((a) {
                final time = a['time'] as String? ?? '--:--';
                final title = a['title'] as String? ?? a['patientName'] as String? ?? 'Appointment';
                final status = a['status'] as String? ?? 'Scheduled';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.g600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 3,
                        height: 32,
                        color: AppColors.navy,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.g800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: status),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
