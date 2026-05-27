import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../state/user_store.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';
import '../../../utils/live_data_mixin.dart';

class DhoQuestionInsights extends StatefulWidget {
  const DhoQuestionInsights({super.key});
  @override
  State<DhoQuestionInsights> createState() => _DhoQuestionInsightsState();
}

class _DhoQuestionInsightsState extends State<DhoQuestionInsights> with LiveDataMixin {
  Map<String, dynamic> _dist = {};
  List<dynamic> _assessments = [];
  bool _loading = true;
  String? _error;

  String get _district => UserStore.instance.district;

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
        _dist = results[0] as Map<String, dynamic>;
        _assessments = results[1] as List<dynamic>;
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
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: AppColors.criticalText, size: 40),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(fontFamily: 'Roboto', color: AppColors.criticalText)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]));
    }

    final total    = (_dist['total'] ?? _assessments.length).toString();
    final highRisk = (_dist['high'] ?? _dist['highRisk'] ?? 0).toString();
    final completion = (_dist['completionRate'] ?? '—').toString();
    final avgScore   = (_dist['avgScore'] ?? '—').toString();

    final low    = (_dist['low'] ?? 0) as num;
    final medium = (_dist['medium'] ?? 0) as num;
    final high   = (_dist['high'] ?? 0) as num;

    final symptomMap = <String, int>{};
    for (final a in _assessments) {
      final symptom = (a['topSymptom'] ?? a['primarySymptom'] ?? '').toString();
      if (symptom.isNotEmpty) {
        symptomMap[symptom] = (symptomMap[symptom] ?? 0) + 1;
      }
    }
    final symptoms = symptomMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Question Insights',
                style: TextStyle(fontFamily: 'Public Sans', 
                    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
            const Spacer(),
          ]),
          const SizedBox(height: 6),
          Text('Local symptom trends and risk patterns${_district.isNotEmpty ? ' — $_district' : ''}',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              KpiCard(title: 'Assessments', value: total, icon: Icons.quiz_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'Completion Rate', value: '$completion%', icon: Icons.check_circle_outline_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg),
              KpiCard(title: 'High-Risk', value: highRisk, icon: Icons.warning_amber_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg),
              KpiCard(title: 'Avg Score', value: '$avgScore%', icon: Icons.analytics_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg),
            ],
          ),
          const SizedBox(height: 28),

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
                      Text('Local Symptom Trends',
                          style: TextStyle(fontFamily: 'Public Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                      const SizedBox(height: 16),
                      if (symptoms.isEmpty)
                        Text('No symptom data available', style: TextStyle(fontFamily: 'Roboto', color: AppColors.mutedText))
                      else
                        ...symptoms.take(6).map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(child: Text(s.key, style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface))),
                                  Text('${s.value}', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.bodyText)),
                                  const SizedBox(width: 12),
                                  StatusBadge(label: 'Reported', type: BadgeType.info),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ChartCard(
                  title: 'Risk Patterns',
                  subtitle: 'District risk distribution',
                  legend: Row(children: [
                    const LegendItem(color: AppColors.successText, label: 'Low'),
                    const SizedBox(width: 12),
                    const LegendItem(color: AppColors.warningText, label: 'Moderate'),
                    const SizedBox(width: 12),
                    const LegendItem(color: AppColors.criticalText, label: 'High'),
                  ]),
                  chart: SizedBox(
                    height: 240,
                    child: PieChart(PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 48,
                      sections: [
                        if (low > 0) PieChartSectionData(
                          value: low.toDouble(), color: AppColors.successText,
                          title: '${low.toStringAsFixed(0)}',
                          titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          radius: 58),
                        if (medium > 0) PieChartSectionData(
                          value: medium.toDouble(), color: AppColors.warningText,
                          title: '${medium.toStringAsFixed(0)}',
                          titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          radius: 58),
                        if (high > 0) PieChartSectionData(
                          value: high.toDouble(), color: AppColors.criticalText,
                          title: '${high.toStringAsFixed(0)}',
                          titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          radius: 58),
                      ],
                    )),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

