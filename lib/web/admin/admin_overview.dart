import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/app_shell.dart';
import '../shared/sidebar.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import 'system_users.dart';
import 'reports_screen_export.dart';
import 'audit_export_export.dart';
import 'question_insights.dart';
import 'insights_screen.dart';
import 'facilities_management.dart';
import 'system_logs.dart';
import 'broadcast_messages_screen.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service_web.dart';
import '../../../state/user_store.dart';
import '../../../utils/live_data_mixin.dart';

class AdminOverview extends StatefulWidget {
  const AdminOverview({super.key});

  @override
  State<AdminOverview> createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<AdminOverview> {
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
      case '/clinicians':        return const SystemUsers();
      case '/audit-export':      return const AuditExport();
      case '/question-insights': return const QuestionInsights();
      case '/insights':          return const InsightsScreen();
      case '/reports':           return const ReportsScreen();
      case '/facilities':        return const FacilitiesManagementScreen();
      case '/logs':              return const SystemLogs();
      case '/broadcasts':        return const BroadcastMessagesScreen();
      default:                   return const _OverviewBody();
    }
  }

  String get _pageTitle {
    const titles = {
      '/overview':          'Overview',
      '/clinicians':        'System Users',
      '/audit-export':      'Audit Export',
      '/question-insights': 'Question Insights',
      '/insights':          'Insights',
      '/reports':           'Reports',
      '/facilities':        'Health Facilities',
      '/logs':              'Audit Logs',
      '/broadcasts':        'Broadcast Messages',
    };
    return titles[_currentRoute] ?? 'Admin Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: UserRole.admin,
      userName: AuthServiceWeb.instance.userName,
      currentRoute: _currentRoute,
      pageTitle: _pageTitle,
      onNavigate: _navigate,
      body: _buildPage(),
    );
  }
}

// ── Overview body — loads real data ──────────────────────────────────────────

class _OverviewBody extends StatefulWidget {
  const _OverviewBody();

  @override
  State<_OverviewBody> createState() => _OverviewBodyState();
}

class _OverviewBodyState extends State<_OverviewBody> with LiveDataMixin {
  bool _loading = true;
  String? _error;

  // KPI data
  int _totalClinicians = 0;
  int _totalMothers    = 0;
  int _highRiskCases   = 0;
  int _activeAlerts    = 0;

  // ANC data
  int _totalANCAppointments = 0;
  int _ancAttendanceRate = 0;
  int _ancComplianceRate = 0;
  int _poorCompliancePatients = 0;

  // Chart data
  List<FlSpot> _registrationSpots = [];
  List<Map<String, dynamic>> _riskDistribution = [];
  List<Map<String, dynamic>> _systemAlerts = [];
  List<Map<String, dynamic>> _activityLogs = [];
  List<Map<String, dynamic>> _ancTrends = [];
  List<Map<String, dynamic>> _clinicianActivity = [];
  List<Map<String, dynamic>> _appointmentStatuses = [];

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
      print('[AdminOverview] Starting silent load...');
      final results = await Future.wait([
        _safeGet('/analytics/overview'),
        _safeGet('/analytics/registrations'),
        _safeGet('/analytics/risk-distribution'),
        _safeGet('/analytics/system-alerts'),
        _safeGet('/activity-logs'),
        _safeGet('/analytics/anc-analytics'),
        _safeGet('/analytics/anc-compliance'),
        _safeGet('/analytics/clinician-activity'),
        _safeGet('/analytics/appointment-statuses'),
      ]);
      print('[AdminOverview] Results received: ${results.map((r) => r != null ? 'OK' : 'NULL').toList()}');
      final overview      = _asMap(results[0]);
      final regTrends     = _asMap(results[1]);
      final riskDist      = _asList(results[2]);
      final sysAlerts     = _asMap(results[3]);
      final actLogs       = _asList(results[4]);
      final ancAnalytics  = _asMap(results[5]);
      final ancCompliance = _asMap(results[6]);
      final clinAct       = _asList(results[7]);
      final apptStatus    = _asList(results[8]);
      final prenatalMonths = _asList(regTrends['prenatal']);
      final spots = <FlSpot>[];
      for (int i = 0; i < prenatalMonths.length && i < 6; i++) {
        final item = prenatalMonths[i];
        final count = double.tryParse(item is Map ? (item['count'] ?? '0').toString() : '0') ?? 0;
        spots.add(FlSpot(i.toDouble(), count));
      }
      final riskDistMaps = riskDist.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      final alertsList   = _asList(sysAlerts['alerts']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      final actLogsList  = actLogs.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).take(5).toList();
      final ancTrendsList = _asList(ancAnalytics['monthlyTrends']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      if (mounted) setState(() {
        _totalClinicians        = (overview['totalClinicians'] as num?)?.toInt() ?? 0;
        _totalMothers           = (overview['totalMothers']    as num?)?.toInt() ?? 0;
        _highRiskCases          = (overview['highRiskCases']   as num?)?.toInt() ?? 0;
        _activeAlerts           = (overview['activeAlerts']    as num?)?.toInt() ?? 0;
        _totalANCAppointments   = (ancAnalytics['totalANCAppointments'] as num?)?.toInt() ?? 0;
        _ancAttendanceRate      = (ancAnalytics['attendanceRate'] as num?)?.toInt() ?? 0;
        _ancComplianceRate      = (ancAnalytics['complianceRate'] as num?)?.toInt() ?? 0;
        _poorCompliancePatients = (ancCompliance['patientsWithPoorCompliance'] as num?)?.toInt() ?? 0;
        _registrationSpots      = spots.isEmpty ? [const FlSpot(0, 0), const FlSpot(1, 0)] : spots;
        _riskDistribution       = riskDistMaps;
        _systemAlerts           = alertsList;
        _activityLogs           = actLogsList;
        _ancTrends              = ancTrendsList;
        _clinicianActivity      = clinAct.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _appointmentStatuses    = apptStatus.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (_) {}
  }

  Future<dynamic> _safeGet(String path) async {
    try { 
      final result = await ApiService.instance.get(path);
      print('[AdminOverview] GET $path: OK');
      return result;
    } catch (e) { 
      print('[AdminOverview] GET $path: ERROR - $e');
      return null; 
    }
  }

  Map<String, dynamic> _asMap(dynamic d) =>
      (d is Map) ? Map<String, dynamic>.from(d) : <String, dynamic>{};

  List<dynamic> _asList(dynamic d) => (d is List) ? d : <dynamic>[];

  Future<void> _load() async {
    try {
      print('[AdminOverview] Loading data...');
      final results = await Future.wait([
        _safeGet('/analytics/overview'),
        _safeGet('/analytics/registrations'),
        _safeGet('/analytics/risk-distribution'),
        _safeGet('/analytics/system-alerts'),
        _safeGet('/activity-logs'),
        _safeGet('/analytics/anc-analytics'),
        _safeGet('/analytics/anc-compliance'),
        _safeGet('/analytics/clinician-activity'),
        _safeGet('/analytics/appointment-statuses'),
      ]);

      print('[AdminOverview] Data loaded, processing...');
      final overview  = _asMap(results[0]);
      final regTrends = _asMap(results[1]);
      final riskDist  = _asList(results[2]);
      final sysAlerts = _asMap(results[3]);
      final actLogs   = _asList(results[4]);
      final ancAnalytics = _asMap(results[5]);
      final ancCompliance = _asMap(results[6]);
      final clinAct = _asList(results[7]);
      final apptStatus = _asList(results[8]);

      print('[AdminOverview] Overview: $overview');
      print('[AdminOverview] RegTrends: $regTrends');
      print('[AdminOverview] RiskDist: $riskDist');

      // Build registration spots from prenatal monthly data
      final prenatalMonths = _asList(regTrends['prenatal']);
      final spots = <FlSpot>[];
      for (int i = 0; i < prenatalMonths.length && i < 6; i++) {
        final item = prenatalMonths[i];
        final count = double.tryParse(item is Map ? (item['count'] ?? '0').toString() : '0') ?? 0;
        spots.add(FlSpot(i.toDouble(), count));
      }

      final riskDistMaps = riskDist
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final alertsList = _asList(sysAlerts['alerts'])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final actLogsList = actLogs
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .take(5)
          .toList();

      final ancTrendsList = _asList(ancAnalytics['monthlyTrends'])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      setState(() {
        _totalClinicians   = (overview['totalClinicians'] as num?)?.toInt() ?? 0;
        _totalMothers      = (overview['totalMothers']    as num?)?.toInt() ?? 0;
        _highRiskCases     = (overview['highRiskCases']   as num?)?.toInt() ?? 0;
        _activeAlerts      = (overview['activeAlerts']    as num?)?.toInt() ?? 0;
        _totalANCAppointments = (ancAnalytics['totalANCAppointments'] as num?)?.toInt() ?? 0;
        _ancAttendanceRate = (ancAnalytics['attendanceRate'] as num?)?.toInt() ?? 0;
        _ancComplianceRate = (ancAnalytics['complianceRate'] as num?)?.toInt() ?? 0;
        _poorCompliancePatients = (ancCompliance['patientsWithPoorCompliance'] as num?)?.toInt() ?? 0;
        _registrationSpots = spots.isEmpty ? [const FlSpot(0, 0), const FlSpot(1, 0)] : spots;
        _riskDistribution  = riskDistMaps;
        _systemAlerts      = alertsList;
        _activityLogs      = actLogsList;
        _ancTrends         = ancTrendsList;
        _clinicianActivity = clinAct.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _appointmentStatuses = apptStatus.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _loading           = false;
      });
    } catch (e) {
      print('[AdminOverview] Error loading data: $e');
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        Text('Failed to load data', style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: AppColors.onSurface)),
        const SizedBox(height: 8),
        TextButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Retry')),
      ]));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1,
            children: [
              KpiCard(title: 'Total Clinicians', value: _fmt(_totalClinicians),
                  icon: Icons.people_alt_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'Total Mothers', value: _fmt(_totalMothers),
                  icon: Icons.pregnant_woman_rounded, iconColor: AppColors.tertiary, iconBg: const Color(0xFFE0F2F1)),
              KpiCard(title: 'High-Risk Cases', value: _fmt(_highRiskCases),
                  icon: Icons.warning_amber_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg,
                  subtitle: _totalMothers > 0 ? '${(_highRiskCases / _totalMothers * 100).toStringAsFixed(1)}% of total' : ''),
              KpiCard(title: 'Active Alerts', value: _fmt(_activeAlerts),
                  icon: Icons.notifications_active_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg),
            ],
          ),

          const SizedBox(height: 20),

          // ANC Attendance KPI Cards
          GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1,
            children: [
              KpiCard(title: 'ANC Appointments', value: _fmt(_totalANCAppointments),
                  icon: Icons.calendar_today_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg,
                  subtitle: 'Total scheduled'),
              KpiCard(title: 'Attendance Rate', value: '$_ancAttendanceRate%',
                  icon: Icons.check_circle_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg,
                  subtitle: 'Patients attending'),
              KpiCard(title: 'ANC Compliance', value: '$_ancComplianceRate%',
                  icon: Icons.schedule_rounded, iconColor: AppColors.infoText, iconBg: AppColors.infoBg,
                  subtitle: 'WHO schedule adherence'),
              KpiCard(title: 'Poor Compliance', value: _fmt(_poorCompliancePatients),
                  icon: Icons.warning_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg,
                  subtitle: 'Patients needing follow-up'),
            ],
          ),

          const SizedBox(height: 28),

          // Charts Row 1: Line Chart (Full Width)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ChartCard(
                  title: 'Monthly Registrations',
                  subtitle: 'Mothers registered over the last 6 months',
                  chart: SizedBox(
                    height: 250, // Slightly taller since it's full width
                    child: _registrationSpots.length < 2
                        ? const Center(child: Text('No data yet'))
                        : LineChart(LineChartData(
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                                  final idx = val.toInt();
                                  if (idx < 0 || idx >= months.length) return const SizedBox();
                                  return Text(months[idx], style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: AppColors.mutedText));
                                },
                              )),
                            ),
                            lineBarsData: [LineChartBarData(
                              spots: _registrationSpots,
                              isCurved: true, 
                              curveSmoothness: 0.35,
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true, 
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.25),
                                    AppColors.primary.withValues(alpha: 0.02),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              shadow: Shadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            )],
                          )),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Charts Row 2: Pie Charts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: ChartCard(
                  title: 'Risk Distribution',
                  subtitle: 'Current case breakdown',
                  chart: SizedBox(
                    height: 220,
                    child: _riskDistribution.isEmpty
                        ? const Center(child: Text('No data yet'))
                        : PieChart(PieChartData(
                            sectionsSpace: 3, centerSpaceRadius: 55,
                            sections: _buildRiskSections(),
                          )),
                  ),
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                flex: 1,
                child: ChartCard(
                  title: 'Appointment Statuses',
                  subtitle: 'Overall breakdown',
                  chart: SizedBox(
                    height: 220,
                    child: _appointmentStatuses.isEmpty
                        ? const Center(child: Text('No data yet'))
                        : PieChart(PieChartData(
                            sectionsSpace: 3, centerSpaceRadius: 55,
                            sections: _buildAppointmentStatusSections(),
                          )),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Alerts + Activity Feed
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildAlertsCard()),
              const SizedBox(width: 20),
              Expanded(child: _buildActivityCard()),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildRiskSections() {
    final colorMap = {
      'Low Risk': AppColors.successText,
      'Moderate Risk': AppColors.warningText,
      'High Risk': AppColors.criticalText,
      'Seek Help Immediately': const Color(0xFF7B1FA2),
    };
    final total = _riskDistribution.fold<double>(
        0, (s, r) => s + (double.tryParse(r['count'].toString()) ?? 0));
    if (total == 0) return [];
    return _riskDistribution.map((r) {
      final count = double.tryParse(r['count'].toString()) ?? 0;
      final pct = (count / total * 100).toStringAsFixed(0);
      final label = r['riskLevel'] as String? ?? '';
      final shortLabel = label.contains('Low') ? 'Low' : label.contains('Moderate') ? 'Med' : label.contains('High') ? 'High' : 'Crit';
      return PieChartSectionData(
        value: count,
        color: colorMap[label] ?? AppColors.mutedText,
        title: '$shortLabel\n$pct%',
        titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
        radius: 55,
      );
    }).toList();
  }

  List<PieChartSectionData> _buildAppointmentStatusSections() {
    final colors = [AppColors.primary, AppColors.successText, AppColors.warningText, AppColors.criticalText, AppColors.infoText, Colors.teal, Colors.orange];
    final total = _appointmentStatuses.fold<double>(0, (s, r) => s + (double.tryParse(r['count']?.toString() ?? '0') ?? 0));
    if (total == 0) return [];
    int i = 0;
    return _appointmentStatuses.map((r) {
      final count = double.tryParse(r['count']?.toString() ?? '0') ?? 0;
      final pct = (count / total * 100).toStringAsFixed(0);
      String label = r['status'] as String? ?? 'Unknown';
      label = label.replaceAll('_', ' ');
      final shortLabel = label.length > 10 ? label.substring(0, 10) : label;
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        value: count,
        color: color,
        title: '$shortLabel\n$pct%',
        titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
        radius: 55,
      );
    }).toList();
  }

  Widget _buildAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Alerts', style: TextStyle(fontFamily: 'Public Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
          const SizedBox(height: 16),
          if (_systemAlerts.isEmpty)
            Text('No active system alerts.', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText))
          else
            ..._systemAlerts.map((a) {
              final type = a['type'] as String? ?? 'info';
              final color = type == 'critical' ? AppColors.criticalText
                  : type == 'warning' ? AppColors.warningText : AppColors.infoText;
              final bg = type == 'critical' ? AppColors.criticalBg
                  : type == 'warning' ? AppColors.warningBg : AppColors.infoBg;
              final icon = type == 'critical' ? Icons.trending_up_rounded
                  : type == 'warning' ? Icons.person_off_rounded : Icons.info_outline_rounded;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, color: color, size: 18)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(a['message'] as String? ?? '',
                      style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface))),
                ]),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: TextStyle(fontFamily: 'Public Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
          const SizedBox(height: 16),
          if (_activityLogs.isEmpty)
            Text('No recent activity.', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText))
          else
            ..._activityLogs.map((a) {
              final action = a['action'] as String? ?? '';
              final desc   = a['description'] as String? ?? action;
              final ts     = a['createdAt'] as String? ?? '';
              final timeAgo = _timeAgo(ts);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(children: [
                  Container(width: 8, height: 8,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(desc,
                      style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface))),
                  Text(timeAgo, style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: AppColors.mutedText)),
                ]),
              );
            }),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  String _timeAgo(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}

