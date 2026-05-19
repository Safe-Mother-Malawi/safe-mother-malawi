import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../state/user_store.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../../../utils/live_data_mixin.dart';

class DistrictAnalytics extends StatefulWidget {
  const DistrictAnalytics({super.key});
  @override
  State<DistrictAnalytics> createState() => _DistrictAnalyticsState();
}

class _DistrictAnalyticsState extends State<DistrictAnalytics> with LiveDataMixin {
  Map<String, dynamic> _overview = {};
  Map<String, dynamic> _risk = {};
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
        ApiService.getAnalyticsOverview(),
        ApiService.getRiskDistribution(),
      ]);
      if (mounted) setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _risk     = results[1] as Map<String, dynamic>;
      });
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.getAnalyticsOverview(),
        ApiService.getRiskDistribution(),
      ]);
      setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _risk     = results[1] as Map<String, dynamic>;
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
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              KpiCard(title: 'Assessments', value: assessments, icon: Icons.assignment_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'High-Risk', value: highRisk, icon: Icons.warning_amber_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg),
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
                      gridData: FlGridData(
                        show: true, drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(color: AppColors.primary.withValues(alpha: 0.06), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.primary,
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                            s.y.toStringAsFixed(0),
                            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                          )).toList(),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const m = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
                            final i = v.toInt();
                            if (i < 0 || i >= m.length) return const SizedBox();
                            return Padding(padding: const EdgeInsets.only(top: 6),
                              child: Text(m[i], style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText)));
                          },
                        )),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: riskTrend.isNotEmpty
                              ? riskTrend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value as num).toDouble())).toList()
                              : const [FlSpot(0, 110), FlSpot(1, 130), FlSpot(2, 120), FlSpot(3, 155), FlSpot(4, 148), FlSpot(5, 170)],
                          isCurved: true, curveSmoothness: 0.4,
                          color: AppColors.criticalText, barWidth: 3,
                          dotData: FlDotData(show: true,
                            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                              radius: 4, color: Colors.white,
                              strokeWidth: 2.5, strokeColor: AppColors.criticalText)),
                          belowBarData: BarAreaData(show: true,
                            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [AppColors.criticalText.withValues(alpha: 0.18), AppColors.criticalText.withValues(alpha: 0.0)])),
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
                      gridData: FlGridData(
                        show: true, drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(color: AppColors.primary.withValues(alpha: 0.06), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.primary,
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, _, rod, __) {
                            const labels = ['ANC', 'PNC', 'Tasks'];
                            return BarTooltipItem(
                              '${labels[group.x]}: ${rod.toY.toInt()}%',
                              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
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
                            const labels = ['ANC', 'PNC', 'Tasks'];
                            final i = v.toInt();
                            if (i < 0 || i >= labels.length) return const SizedBox();
                            return Padding(padding: const EdgeInsets.only(top: 6),
                              child: Text(labels[i], style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText)));
                          },
                        )),
                      ),
                      barGroups: [
                        _bar(0, (_overview['ancRate'] ?? 78) as num),
                        _bar(1, (_overview['pncRate'] ?? 82) as num),
                        _bar(2, (_overview['taskCompletionRate'] ?? 77) as num),
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
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: val.toDouble(),
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [AppColors.primary, Color(0xFF1976D2)],
        ),
        width: 28,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
    ]);
  }
}
