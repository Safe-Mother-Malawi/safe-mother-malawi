import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../state/user_store.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';

class DhoQuestionInsights extends StatefulWidget {
  const DhoQuestionInsights({super.key});
  @override
  State<DhoQuestionInsights> createState() => _DhoQuestionInsightsState();
}

class _DhoQuestionInsightsState extends State<DhoQuestionInsights> {
  Map<String, dynamic> _dist = {};
  List<dynamic> _assessments = [];
  bool _loading = true;
  String? _error;

  String get _district => UserStore.instance.district;

  @override
  void initState() {
    super.initState();
    _load();
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
        Text(_error!, style: GoogleFonts.inter(color: AppColors.criticalText)),
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
                style: GoogleFonts.publicSans(
                    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
            const Spacer(),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: AppColors.primary)),
          ]),
          const SizedBox(height: 6),
          Text('Local symptom trends and risk patterns${_district.isNotEmpty ? ' — $_district' : ''}',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
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
                          style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                      const SizedBox(height: 16),
                      if (symptoms.isEmpty)
                        Text('No symptom data available', style: GoogleFonts.inter(color: AppColors.mutedText))
                      else
                        ...symptoms.take(6).map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(child: Text(s.key, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface))),
                                  Text('${s.value}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.bodyText)),
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
                  chart: SizedBox(
                    height: 260,
                    child: PieChart(PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 44,
                      sections: [
                        PieChartSectionData(value: low.toDouble(), color: AppColors.successText, title: 'Low\n${low.toStringAsFixed(0)}', titleStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white), radius: 55),
                        PieChartSectionData(value: medium.toDouble(), color: AppColors.warningText, title: 'Med\n${medium.toStringAsFixed(0)}', titleStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white), radius: 55),
                        PieChartSectionData(value: high.toDouble(), color: AppColors.criticalText, title: 'High\n${high.toStringAsFixed(0)}', titleStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white), radius: 55),
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
