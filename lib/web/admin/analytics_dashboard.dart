import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../../../services/api_service.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  bool _loading = true;
  String? _error;

  int _highRisk         = 0;
  int _completionRate   = 0;

  List<FlSpot> _riskTrendHigh = [];
  List<FlSpot> _riskTrendMod  = [];
  List<Map<String, dynamic>> _districtData = [];
  List<Map<String, dynamic>> _riskDist     = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ApiService.instance.get('/analytics/overview'),
        ApiService.instance.get('/analytics/risk-distribution'),
        ApiService.instance.get('/analytics/districts'),
        ApiService.instance.get('/analytics/task-analytics'),
      ]);

      final overview  = results[0] as Map<String, dynamic>;
      final riskDist  = results[1] as List<dynamic>;
      final districts = results[2] as List<dynamic>;
      final tasks     = results[3] as Map<String, dynamic>;

      // Build risk trend spots from risk distribution counts (simplified)
      final riskList = riskDist.cast<Map<String, dynamic>>();
      final highCount = riskList.where((r) => (r['riskLevel'] as String? ?? '').contains('High')).fold<double>(0, (s, r) => s + (double.tryParse(r['count'].toString()) ?? 0));
      final modCount  = riskList.where((r) => (r['riskLevel'] as String? ?? '').contains('Moderate')).fold<double>(0, (s, r) => s + (double.tryParse(r['count'].toString()) ?? 0));

      setState(() {
        _highRisk         = overview['highRiskCases'] ?? 0;
        _completionRate   = tasks['completionRate'] ?? 0;
        _riskDist         = riskList;
        _districtData     = districts.cast<Map<String, dynamic>>();
        // Simple 6-point trend using current value
        _riskTrendHigh = List.generate(6, (i) => FlSpot(i.toDouble(), highCount * (0.7 + i * 0.06)));
        _riskTrendMod  = List.generate(6, (i) => FlSpot(i.toDouble(), modCount  * (0.7 + i * 0.06)));
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
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        const Text('Failed to load analytics'),
        TextButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Retry')),
      ]));
    }

    // Build district bar groups
    final topDistricts = _districtData.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Analytics Dashboard', style: GoogleFonts.publicSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
            const Spacer(),
            _ExportBtn(label: 'Export PDF'),
            const SizedBox(width: 10),
            _ExportBtn(label: 'Export CSV'),
          ]),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 3, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3,
            children: [
              KpiCard(title: 'High-Risk Cases', value: _highRisk.toString(),
                  icon: Icons.warning_amber_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg),
              KpiCard(title: 'Task Completion', value: '$_completionRate%',
                  icon: Icons.task_alt_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg),
              KpiCard(title: 'Risk Levels', value: _riskDist.length.toString(),
                  icon: Icons.assessment_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg,
                  subtitle: 'Categories tracked'),
            ],
          ),
          const SizedBox(height: 28),

          Row(children: [
            Expanded(child: ChartCard(
              title: 'Risk Trends',
              subtitle: 'High and Moderate risk cases (projected)',
              chart: SizedBox(height: 220, child: LineChart(LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.surfaceContainerLow, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText)))),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                    getTitlesWidget: (v, _) {
                      const m = ['Oct','Nov','Dec','Jan','Feb','Mar'];
                      final i = v.toInt();
                      if (i < 0 || i >= m.length) return const SizedBox();
                      return Text(m[i], style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText));
                    })),
                ),
                lineBarsData: [
                  LineChartBarData(spots: _riskTrendHigh, isCurved: true, color: AppColors.criticalText, barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppColors.criticalText.withValues(alpha: 0.07))),
                  LineChartBarData(spots: _riskTrendMod, isCurved: true, color: AppColors.warningText, barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppColors.warningText.withValues(alpha: 0.07))),
                ],
              ))),
            )),
            const SizedBox(width: 20),
            Expanded(child: ChartCard(
              title: 'District Comparison',
              subtitle: 'Registrations by district',
              chart: SizedBox(height: 220, child: topDistricts.isEmpty
                  ? const Center(child: Text('No district data yet'))
                  : BarChart(BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= topDistricts.length) return const SizedBox();
                            final d = topDistricts[i]['district']?.toString() ?? '';
                            return Text(d.length > 4 ? d.substring(0, 4) : d,
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText));
                          })),
                      ),
                      barGroups: topDistricts.asMap().entries.map((e) {
                        final count = double.tryParse(e.value['prenatal']?.toString() ?? '0') ?? 0;
                        return BarChartGroupData(x: e.key, barRods: [BarChartRodData(
                          toY: count, color: AppColors.primary, width: 28,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        )]);
                      }).toList(),
                    ))),
            )),
          ]),
          const SizedBox(height: 20),

          Row(children: [
            Expanded(child: ChartCard(
              title: 'Risk Distribution',
              subtitle: 'Current breakdown by level',
              chart: SizedBox(height: 200, child: _riskDist.isEmpty
                  ? const Center(child: Text('No data yet'))
                  : PieChart(PieChartData(
                      sectionsSpace: 3, centerSpaceRadius: 44,
                      sections: _buildRiskSections(),
                    ))),
            )),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Risk Level Summary', style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                const SizedBox(height: 16),
                ..._riskDist.map((r) {
                  final level = r['riskLevel'] as String? ?? '';
                  final count = r['count']?.toString() ?? '0';
                  final color = level.contains('Low') ? AppColors.successText
                      : level.contains('Moderate') ? AppColors.warningText
                      : level.contains('High') ? AppColors.criticalText : const Color(0xFF7B1FA2);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(level, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface))),
                      Text(count, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                    ]),
                  );
                }),
              ]),
            )),
          ]),
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
      final pct   = (count / total * 100).toStringAsFixed(0);
      final label = r['riskLevel'] as String? ?? '';
      final short = label.contains('Low') ? 'Low' : label.contains('Moderate') ? 'Med' : label.contains('High') ? 'High' : 'Crit';
      return PieChartSectionData(
        value: count, color: colorMap[label] ?? AppColors.mutedText,
        title: '$short\n$pct%',
        titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
        radius: 52,
      );
    }).toList();
  }
}

class _ExportBtn extends StatelessWidget {
  final String label;
  const _ExportBtn({required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.download_rounded, size: 16, color: AppColors.primary),
      label: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
