import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';
import '../../utils/live_data_mixin.dart';

/// Question Insights screen — health assessment patterns
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> with LiveDataMixin {

  Map<String, dynamic> _dist = {};
  List<dynamic> _assessments = [];
  bool _loading = true;
  String? _error;

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
        ApiService.getRiskDistribution(),
        ApiService.getRiskAssessments(limit: 200),
      ]);
      if (mounted) setState(() {
        _dist        = results[0] as Map<String, dynamic>;
        _assessments = results[1] as List<dynamic>;
      });
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.getRiskDistribution(),
        ApiService.getRiskAssessments(limit: 200),
      ]);
      setState(() {
        _dist        = results[0] as Map<String, dynamic>;
        _assessments = results[1] as List<dynamic>;
        _loading     = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: AppColors.criticalText, size: 40),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(fontFamily: 'Roboto', color: AppColors.criticalText)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]));
    }

    final total      = (_dist['total'] ?? _assessments.length).toString();
    final completion = (_dist['completionRate'] ?? '—').toString();
    final highRisk   = (_dist['high'] ?? _dist['highRisk'] ?? 0).toString();
    final avgScore   = (_dist['avgScore'] ?? '—').toString();

    final low    = (_dist['low'] ?? 0) as num;
    final medium = (_dist['medium'] ?? 0) as num;
    final high   = (_dist['high'] ?? 0) as num;

    // Build symptom frequency
    final symptomMap = <String, int>{};
    for (final a in _assessments) {
      final s = (a['topSymptom'] ?? a['primarySymptom'] ?? '').toString();
      if (s.isNotEmpty) symptomMap[s] = (symptomMap[s] ?? 0) + 1;
    }
    final symptoms = symptomMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question Insights',
              style: TextStyle(fontFamily: 'Public Sans', 
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 4),
          Text('Health assessment patterns and symptom analysis',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 4, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3,
                    children: [
                      KpiCard(title: 'Total Assessments', value: total, icon: Icons.quiz_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
                      KpiCard(title: 'Completion Rate', value: '$completion%', icon: Icons.check_circle_outline_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg),
                      KpiCard(title: 'High-Risk Flagged', value: highRisk, icon: Icons.warning_amber_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg),
                      KpiCard(title: 'Avg Score', value: '$avgScore%', icon: Icons.analytics_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Common Symptoms',
                                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                              const SizedBox(height: 16),
                              if (symptoms.isEmpty)
                                Text('No symptom data available', style: TextStyle(fontFamily: 'Roboto', color: AppColors.mutedText))
                              else
                                ...symptoms.take(6).map((s) => _SymptomRow(
                                      symptom: s.key,
                                      count: '${s.value}',
                                      risk: s.value > 500 ? 'High' : s.value > 200 ? 'Medium' : 'Low',
                                    )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ChartCard(
                          title: 'Risk Distribution',
                          subtitle: 'Assessment outcomes by risk level',
                          chart: SizedBox(
                            height: 240,
                            child: BarChart(BarChartData(
                              gridData: FlGridData(
                                show: true, drawVerticalLine: false,
                                getDrawingHorizontalLine: (_) => FlLine(color: AppColors.primary.withOpacity(0.06), strokeWidth: 1),
                              ),
                              borderData: FlBorderData(show: false),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (_) => AppColors.primary,
                                  tooltipRoundedRadius: 8,
                                  getTooltipItem: (group, _, rod, __) {
                                    const labels = ['Low', 'Medium', 'High'];
                                    return BarTooltipItem(
                                      '${labels[group.x]}\n${rod.toY.toInt()}',
                                      TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) {
                                    const l = ['Low', 'Medium', 'High'];
                                    final i = v.toInt();
                                    if (i < 0 || i >= l.length) return const SizedBox();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(l[i], style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: AppColors.mutedText)),
                                    );
                                  },
                                )),
                              ),
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [BarChartRodData(
                                  toY: low.toDouble(),
                                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                    colors: [AppColors.successText, AppColors.successText.withOpacity(0.7)]),
                                  width: 44, borderRadius: const BorderRadius.vertical(top: Radius.circular(8)))]),
                                BarChartGroupData(x: 1, barRods: [BarChartRodData(
                                  toY: medium.toDouble(),
                                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                    colors: [AppColors.warningText, AppColors.warningText.withOpacity(0.7)]),
                                  width: 44, borderRadius: const BorderRadius.vertical(top: Radius.circular(8)))]),
                                BarChartGroupData(x: 2, barRods: [BarChartRodData(
                                  toY: high.toDouble(),
                                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                    colors: [AppColors.criticalText, AppColors.criticalText.withOpacity(0.7)]),
                                  width: 44, borderRadius: const BorderRadius.vertical(top: Radius.circular(8)))]),
                              ],
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -- Shared helpers ------------------------------------------------------------

class _SymptomRow extends StatelessWidget {
  final String symptom, count, risk;
  const _SymptomRow({required this.symptom, required this.count, required this.risk});

  @override
  Widget build(BuildContext context) {
    final type = risk == 'High' ? BadgeType.critical
        : risk == 'Medium' ? BadgeType.warning
        : BadgeType.success;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(child: Text(symptom, style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface))),
        Text(count, style: TextStyle(fontFamily: 'Roboto', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.bodyText)),
        const SizedBox(width: 12),
        StatusBadge(label: risk, type: type),
      ]),
    );
  }
}

