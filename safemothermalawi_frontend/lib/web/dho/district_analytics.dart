import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../state/user_store.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';

class DistrictAnalytics extends StatefulWidget {
  const DistrictAnalytics({super.key});
  @override
  State<DistrictAnalytics> createState() => _DistrictAnalyticsState();
}

class _DistrictAnalyticsState extends State<DistrictAnalytics> {
  Map<String, dynamic> _overview = {};
  Map<String, dynamic> _ivr = {};
  Map<String, dynamic> _risk = {};
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
        ApiService.getAnalyticsOverview(),
        ApiService.getIvrAnalytics(),
        ApiService.getRiskDistribution(),
      ]);
      setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _ivr      = results[1] as Map<String, dynamic>;
        _risk     = results[2] as Map<String, dynamic>;
        _loading  = false;
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

    final assessments    = (_risk['total'] ?? _overview['totalAssessments'] ?? 0).toString();
    final highRisk       = (_risk['high'] ?? _overview['highRisk'] ?? 0).toString();
    final ivrCalls       = (_ivr['totalCalls'] ?? _ivr['total'] ?? 0).toString();
    final taskRate       = (_overview['taskCompletionRate'] ?? '—').toString();

    final riskTrend = (_overview['riskTrend'] ?? []) as List;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('District Analytics',
                  style: GoogleFonts.publicSans(
                      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(20)),
                child: Text('Read-only',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.infoText)),
              ),
              const Spacer(),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Pre-generated insights${_district.isNotEmpty ? ' for $_district District' : ''}',
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
              KpiCard(title: 'Assessments', value: assessments, icon: Icons.assignment_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'High-Risk', value: highRisk, icon: Icons.warning_amber_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg),
              KpiCard(title: 'IVR Calls', value: ivrCalls, icon: Icons.phone_in_talk_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg),
              KpiCard(title: 'Task Rate', value: '$taskRate%', icon: Icons.task_alt_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: ChartCard(
                  title: 'Risk Trends${_district.isNotEmpty ? ' — $_district' : ''}',
                  subtitle: 'Monthly high-risk cases',
                  chart: SizedBox(
                    height: 200,
                    child: LineChart(LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const m = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
                              final i = v.toInt();
                              if (i < 0 || i >= m.length) return const SizedBox();
                              return Text(m[i], style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText));
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: riskTrend.isNotEmpty
                              ? riskTrend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value as num).toDouble())).toList()
                              : const [FlSpot(0, 110), FlSpot(1, 130), FlSpot(2, 120), FlSpot(3, 155), FlSpot(4, 148), FlSpot(5, 170)],
                          isCurved: true, color: AppColors.criticalText, barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: AppColors.criticalText.withValues(alpha: 0.07)),
                        ),
                      ],
                    )),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ChartCard(
                  title: 'District Performance',
                  subtitle: 'vs national average',
                  chart: SizedBox(
                    height: 200,
                    child: BarChart(BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const labels = ['ANC', 'PNC', 'IVR', 'Tasks'];
                              final i = v.toInt();
                              if (i < 0 || i >= labels.length) return const SizedBox();
                              return Text(labels[i], style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText));
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        _bar(0, (_overview['ancRate'] ?? 78) as num),
                        _bar(1, (_overview['pncRate'] ?? 82) as num),
                        _bar(2, (_ivr['completionRate'] ?? 65) as num),
                        _bar(3, (_overview['taskCompletionRate'] ?? 77) as num),
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

  BarChartGroupData _bar(int x, num val) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: val.toDouble(),
          color: AppColors.primary,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
