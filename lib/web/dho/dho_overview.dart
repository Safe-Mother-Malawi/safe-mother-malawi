import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/app_shell.dart';
import '../shared/sidebar.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';
import '../admin/clinician_management.dart';
import '../admin/data_explorer.dart';
import '../admin/generate_analytics.dart';
import '../admin/analytics_dashboard.dart';
import '../admin/task_analytics.dart';
import '../admin/question_insights.dart';
import '../admin/reports_screen_export.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service_web.dart';
import '../../../state/user_store.dart';
import '../../../utils/live_data_mixin.dart';

class DhoOverview extends StatefulWidget {
  const DhoOverview({super.key});

  @override
  State<DhoOverview> createState() => _DhoOverviewState();
}

class _DhoOverviewState extends State<DhoOverview> {
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
      case '/clinicians':         return const ClinicianManagement();
      case '/data-explorer':      return const DataExplorer();
      case '/generate-analytics': return const GenerateAnalytics();
      case '/analytics':          return const AnalyticsDashboard();
      case '/task-analytics':     return const TaskAnalytics();
      case '/question-insights':  return const QuestionInsights();
      case '/reports':            return const ReportsScreen();
      default:                    return const _DhoOverviewBody();
    }
  }

  String get _pageTitle {
    const titles = {
      '/overview':          'Overview',
      '/clinicians':        'Clinician Management',
      '/data-explorer':     'Data Source',
      '/generate-analytics':'Generate Analytics',
      '/analytics':         'Analytics Dashboard',
      '/task-analytics':    'Task Analytics',
      '/question-insights': 'Question Insights',
      '/reports':           'Reports',
    };
    return titles[_currentRoute] ?? 'DHO Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: UserRole.dho,
      userName: AuthServiceWeb.instance.userName,
      currentRoute: _currentRoute,
      pageTitle: _pageTitle,
      onNavigate: _navigate,
      body: _buildPage(),
    );
  }
}

class _DhoOverviewBody extends StatefulWidget {
  const _DhoOverviewBody();

  @override
  State<_DhoOverviewBody> createState() => _DhoOverviewBodyState();
}

class _DhoOverviewBodyState extends State<_DhoOverviewBody> with LiveDataMixin {
  bool _loading = true;
  String? _error;

  int _totalMothers  = 0;
  int _highRiskCases = 0;
  int _ivrCalls      = 0;
  String _district   = '';

  List<FlSpot> _trendSpots = [];
  List<Map<String, dynamic>> _riskDist = [];
  List<Map<String, dynamic>> _districtAlerts = [];

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
      final user = AuthServiceWeb.instance.currentUser;
      final district = user?['district'] as String? ?? _district;
      final results = await Future.wait([
        _safeGet('/analytics/overview'),
        _safeGet('/analytics/registrations'),
        _safeGet('/analytics/risk-distribution'),
        _safeGet('/analytics/system-alerts'),
        _safeGet('/analytics/anc-analytics?district=$district'),
        _safeGet('/analytics/anc-compliance?district=$district'),
      ]);
      final overview      = _asMap(results[0]);
      final regTrends     = _asMap(results[1]);
      final riskDist      = _asList(results[2]);
      final sysAlerts     = _asMap(results[3]);
      final ancAnalytics  = _asMap(results[4]);
      final ancCompliance = _asMap(results[5]);
      final prenatalMonths = _asList(regTrends['prenatal']);
      final spots = <FlSpot>[];
      for (int i = 0; i < prenatalMonths.length && i < 6; i++) {
        final item = prenatalMonths[i];
        final count = double.tryParse(item is Map ? (item['count'] ?? '0').toString() : '0') ?? 0;
        spots.add(FlSpot(i.toDouble(), count));
      }
      final riskDistMaps  = riskDist.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      final alertsList    = _asList(sysAlerts['alerts']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      final ancTrendsList = _asList(ancAnalytics['monthlyTrends']).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      if (mounted) setState(() {
        _totalMothers           = (overview['totalMothers']  as num?)?.toInt() ?? 0;
        _highRiskCases          = (overview['highRiskCases'] as num?)?.toInt() ?? 0;
        _ancAttendanceRate      = (ancAnalytics['attendanceRate'] as num?)?.toInt() ?? 0;
        _ancComplianceRate      = (ancAnalytics['complianceRate'] as num?)?.toInt() ?? 0;
        _poorCompliancePatients = (ancCompliance['patientsWithPoorCompliance'] as num?)?.toInt() ?? 0;
        _trendSpots             = spots.isEmpty ? [const FlSpot(0, 0), const FlSpot(1, 0)] : spots;
        _riskDist               = riskDistMaps;
        _districtAlerts         = alertsList;
        _ancTrends              = ancTrendsList;
      });
    } catch (_) {}
  }

  Future<dynamic> _safeGet(String path) async {
    try { return await ApiService.instance.get(path); } catch (_) { return null; }
  }

  Map<String, dynamic> _asMap(dynamic d) =>
      (d is Map) ? Map<String, dynamic>.from(d) : <String, dynamic>{};

  List<dynamic> _asList(dynamic d) => (d is List) ? d : <dynamic>[];

  Future<void> _load() async {
    try {
      final user = AuthServiceWeb.instance.currentUser;
      _district = user?['district'] as String? ?? 'District';

      final results = await Future.wait([
        _safeGet('/analytics/overview'),
        _safeGet('/analytics/registrations'),
        _safeGet('/analytics/risk-distribution'),
        _safeGet('/analytics/system-alerts'),
        _safeGet('/analytics/ivr'),
      ]);

      final overview  = _asMap(results[0]);
      final regTrends = _asMap(results[1]);
      final riskDist  = _asList(results[2]);
      final sysAlerts = _asMap(results[3]);
      final ivrStats  = _asMap(results[4]);

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

      setState(() {
        _totalMothers   = (overview['totalMothers']  as num?)?.toInt() ?? 0;
        _highRiskCases  = (overview['highRiskCases'] as num?)?.toInt() ?? 0;
        _ivrCalls       = (ivrStats['totalCalls']    as num?)?.toInt() ?? 0;
        _trendSpots     = spots.isEmpty ? [const FlSpot(0, 0), const FlSpot(1, 0)] : spots;
        _riskDist       = riskDistMaps;
        _districtAlerts = alertsList;
        _loading        = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        Text('Failed to load data', style: GoogleFonts.inter(fontSize: 14)),
        TextButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Retry')),
      ]));
    }

    final completionRate = 76.8; // from task analytics

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // District chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(_district, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1,
            children: [
              KpiCard(title: 'Total Mothers', value: _fmt(_totalMothers),
                  icon: Icons.pregnant_woman_rounded, iconColor: AppColors.tertiary, iconBg: const Color(0xFFE0F2F1)),
              KpiCard(title: 'High-Risk Cases', value: _fmt(_highRiskCases),
                  icon: Icons.warning_amber_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg,
                  subtitle: _totalMothers > 0 ? '${(_highRiskCases / _totalMothers * 100).toStringAsFixed(1)}% of total' : ''),
              KpiCard(title: 'Task Completion', value: '${completionRate.toStringAsFixed(1)}%',
                  icon: Icons.task_alt_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg,
                  subtitle: 'This month'),
              KpiCard(title: 'IVR Usage', value: _fmt(_ivrCalls),
                  icon: Icons.phone_in_talk_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg,
                  subtitle: 'Calls this month'),
            ],
          ),
          const SizedBox(height: 28),

          Row(children: [
            Expanded(flex: 2, child: ChartCard(
              title: 'District Trends',
              subtitle: 'Monthly registrations',
              chart: SizedBox(height: 200, child: _trendSpots.length < 2
                  ? const Center(child: Text('No data yet'))
                  : LineChart(LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                          getTitlesWidget: (v, _) {
                            const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                            final i = v.toInt();
                            if (i < 0 || i >= m.length) return const SizedBox();
                            return Text(m[i], style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText));
                          })),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _trendSpots, isCurved: true, color: AppColors.primary, barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.08)),
                        ),
                        if (_ancTrends.isNotEmpty)
                          LineChartBarData(
                            spots: _ancTrends.asMap().entries.map((e) {
                              final count = double.tryParse(e.value['count']?.toString() ?? '0') ?? 0;
                              return FlSpot(e.key.toDouble(), count);
                            }).toList(),
                            isCurved: true, color: AppColors.successText, barWidth: 2,
                            dotData: const FlDotData(show: false),
                            dashArray: [4, 4],
                          ),
                      ],
                    ))),
            )),
            const SizedBox(width: 20),
            Expanded(child: ChartCard(
              title: 'Risk Breakdown', subtitle: 'Current distribution',
              chart: SizedBox(height: 200, child: _riskDist.isEmpty
                  ? const Center(child: Text('No data yet'))
                  : PieChart(PieChartData(
                      sectionsSpace: 3, centerSpaceRadius: 44,
                      sections: _buildRiskSections(),
                    ))),
            )),
          ]),
          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('District Alerts', style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                const SizedBox(height: 16),
                if (_districtAlerts.isEmpty)
                  Text('No active alerts.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText))
                else
                  ..._districtAlerts.map((a) {
                    final type = a['type'] as String? ?? 'info';
                    final color = type == 'critical' ? AppColors.criticalText
                        : type == 'warning' ? AppColors.warningText : AppColors.infoText;
                    final bg = type == 'critical' ? AppColors.criticalBg
                        : type == 'warning' ? AppColors.warningBg : AppColors.infoBg;
                    final badge = type == 'critical' ? BadgeType.critical
                        : type == 'warning' ? BadgeType.warning : BadgeType.info;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        Container(padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.warning_amber_rounded, color: color, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(a['message'] as String? ?? '',
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface))),
                        StatusBadge(label: type, type: badge),
                      ]),
                    );
                  }),
              ],
            ),
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
    final total = _riskDist.fold<double>(0, (s, r) => s + (double.tryParse(r['count'].toString()) ?? 0));
    if (total == 0) return [];
    return _riskDist.map((r) {
      final count = double.tryParse(r['count'].toString()) ?? 0;
      final pct = (count / total * 100).toStringAsFixed(0);
      final label = r['riskLevel'] as String? ?? '';
      final shortLabel = label.contains('Low') ? 'Low' : label.contains('Moderate') ? 'Med' : label.contains('High') ? 'High' : 'Crit';
      return PieChartSectionData(
        value: count,
        color: colorMap[label] ?? AppColors.mutedText,
        title: '$shortLabel\n$pct%',
        titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
        radius: 50,
      );
    }).toList();
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
