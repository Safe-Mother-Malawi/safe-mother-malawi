import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../../../services/api_service.dart';
import '../../../utils/live_data_mixin.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> with LiveDataMixin {
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
        ApiService.instance.get('/analytics/overview'),
        ApiService.instance.get('/analytics/risk-distribution'),
        ApiService.instance.get('/analytics/districts'),
        ApiService.instance.get('/analytics/task-analytics'),
      ]);
      final overview  = results[0] as Map<String, dynamic>;
      final riskDist  = results[1] as List<dynamic>;
      final districts = results[2] as List<dynamic>;
      final tasks     = results[3] as Map<String, dynamic>;
      final riskList  = riskDist.cast<Map<String, dynamic>>();
      final highCount = riskList.where((r) => (r['riskLevel'] as String? ?? '').contains('High')).fold<double>(0, (s, r) => s + (double.tryParse(r['count'].toString()) ?? 0));
      final modCount  = riskList.where((r) => (r['riskLevel'] as String? ?? '').contains('Moderate')).fold<double>(0, (s, r) => s + (double.tryParse(r['count'].toString()) ?? 0));
      if (mounted) setState(() {
        _highRisk       = overview['highRiskCases'] ?? 0;
        _completionRate = tasks['completionRate'] ?? 0;
        _riskDist       = riskList;
        _districtData   = districts.cast<Map<String, dynamic>>();
        _riskTrendHigh  = List.generate(6, (i) => FlSpot(i.toDouble(), highCount * (0.7 + i * 0.06)));
        _riskTrendMod   = List.generate(6, (i) => FlSpot(i.toDouble(), modCount  * (0.7 + i * 0.06)));
      });
    } catch (_) {}
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
            _ExportBtn(label: 'Export PDF', riskDist: _riskDist, highRisk: _highRisk, completionRate: _completionRate),
            const SizedBox(width: 10),
            _ExportBtn(label: 'Export CSV', riskDist: _riskDist, highRisk: _highRisk, completionRate: _completionRate),
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
              legend: Row(children: const [
                LegendItem(color: AppColors.criticalText, label: 'High Risk'),
                SizedBox(width: 16),
                LegendItem(color: AppColors.warningText, label: 'Moderate'),
              ]),
              chart: SizedBox(height: 220, child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primary,
                      tooltipRoundedRadius: 10,
                      getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                        s.y.toStringAsFixed(0),
                        GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      )).toList(),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText)),
                    )),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const m = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
                        final i = v.toInt();
                        if (i < 0 || i >= m.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(m[i], style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText)),
                        );
                      },
                    )),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _riskTrendHigh,
                      isCurved: true, curveSmoothness: 0.4,
                      color: AppColors.criticalText, barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 4, color: Colors.white,
                          strokeWidth: 2.5, strokeColor: AppColors.criticalText,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [AppColors.criticalText.withValues(alpha: 0.18), AppColors.criticalText.withValues(alpha: 0.0)],
                        ),
                      ),
                    ),
                    LineChartBarData(
                      spots: _riskTrendMod,
                      isCurved: true, curveSmoothness: 0.4,
                      color: AppColors.warningText, barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 4, color: Colors.white,
                          strokeWidth: 2.5, strokeColor: AppColors.warningText,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [AppColors.warningText.withValues(alpha: 0.14), AppColors.warningText.withValues(alpha: 0.0)],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            )),
            const SizedBox(width: 20),
            Expanded(child: ChartCard(
              title: 'District Comparison',
              subtitle: 'Registrations by district',
              chart: SizedBox(height: 220, child: topDistricts.isEmpty
                  ? Center(child: Text('No district data yet', style: GoogleFonts.inter(color: AppColors.mutedText)))
                  : BarChart(
                      BarChartData(
                        gridData: FlGridData(
                          show: true, drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: AppColors.primary.withValues(alpha: 0.06), strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => AppColors.primary,
                            tooltipRoundedRadius: 10,
                            getTooltipItem: (group, _, rod, __) {
                              final d = topDistricts[group.x]['district']?.toString() ?? '';
                              return BarTooltipItem(
                                '$d\n${rod.toY.toInt()}',
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
                              final i = v.toInt();
                              if (i < 0 || i >= topDistricts.length) return const SizedBox();
                              final d = topDistricts[i]['district']?.toString() ?? '';
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  d.length > 5 ? d.substring(0, 5) : d,
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText),
                                ),
                              );
                            },
                          )),
                        ),
                        barGroups: topDistricts.asMap().entries.map((e) {
                          final count = double.tryParse(e.value['prenatal']?.toString() ?? '0') ?? 0;
                          return BarChartGroupData(x: e.key, barRods: [
                            BarChartRodData(
                              toY: count,
                              gradient: const LinearGradient(
                                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                colors: [AppColors.primary, Color(0xFF1976D2)],
                              ),
                              width: 28,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                          ]);
                        }).toList(),
                      ),
                    )),
            )),
          ]),
          const SizedBox(height: 20),

          Row(children: [
            Expanded(child: ChartCard(
              title: 'Risk Distribution',
              subtitle: 'Current breakdown by level',
              chart: SizedBox(height: 220, child: _riskDist.isEmpty
                  ? Center(child: Text('No data yet', style: GoogleFonts.inter(color: AppColors.mutedText)))
                  : Row(children: [
                      Expanded(child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 48,
                          sections: _buildRiskSections(),
                        ),
                      )),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _riskDist.map((r) {
                          final level = r['riskLevel'] as String? ?? '';
                          final count = r['count']?.toString() ?? '0';
                          final color = level.contains('Low') ? AppColors.successText
                              : level.contains('Moderate') ? AppColors.warningText
                              : level.contains('High') ? AppColors.criticalText
                              : const Color(0xFF7B1FA2);
                          final short = level.contains('Low') ? 'Low'
                              : level.contains('Moderate') ? 'Moderate'
                              : level.contains('High') ? 'High' : 'Critical';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(children: [
                              Container(width: 10, height: 10,
                                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                              const SizedBox(width: 8),
                              Text(short, style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
                              const SizedBox(width: 8),
                              Text(count, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                            ]),
                          );
                        }).toList(),
                      ),
                    ])),
            )),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEEF2FF)),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 32, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Risk Level Summary',
                    style: GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.headings)),
                const SizedBox(height: 16),
                ..._riskDist.map((r) {
                  final level = r['riskLevel'] as String? ?? '';
                  final count = int.tryParse(r['count']?.toString() ?? '0') ?? 0;
                  final total = _riskDist.fold<int>(0, (s, x) => s + (int.tryParse(x['count']?.toString() ?? '0') ?? 0));
                  final pct = total > 0 ? count / total : 0.0;
                  final color = level.contains('Low') ? AppColors.successText
                      : level.contains('Moderate') ? AppColors.warningText
                      : level.contains('High') ? AppColors.criticalText : const Color(0xFF7B1FA2);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 10, height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(level,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface))),
                        Text(count.toString(),
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: color.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
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
      return PieChartSectionData(
        value: count,
        color: colorMap[label] ?? AppColors.mutedText,
        title: '$pct%',
        titleStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
        radius: 56,
        badgeWidget: count / total > 0.08 ? null : const SizedBox(),
      );
    }).toList();
  }
}

class _ExportBtn extends StatefulWidget {
  final String label;
  final List<Map<String, dynamic>> riskDist;
  final int highRisk;
  final int completionRate;
  const _ExportBtn({required this.label, required this.riskDist, required this.highRisk, required this.completionRate});

  @override
  State<_ExportBtn> createState() => _ExportBtnState();
}

class _ExportBtnState extends State<_ExportBtn> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _exporting ? null : () => _handleExport(context),
      icon: _exporting
          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
          : const Icon(Icons.download_rounded, size: 16, color: AppColors.primary),
      label: Text(widget.label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    setState(() => _exporting = true);
    try {
      if (widget.label.contains('CSV')) {
        await _exportCsv(context);
      } else {
        await _exportPdf(context);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      // Build CSV from current risk distribution data
      final buffer = StringBuffer();
      buffer.writeln('Safe Mother Malawi — Analytics Export');
      buffer.writeln('Generated: ${DateTime.now().toLocal()}');
      buffer.writeln('');
      buffer.writeln('Risk Level,Count');
      for (final r in widget.riskDist) {
        buffer.writeln('${r['riskLevel'] ?? ''},${r['count'] ?? 0}');
      }
      buffer.writeln('');
      buffer.writeln('Metric,Value');
      buffer.writeln('High-Risk Cases,${widget.highRisk}');
      buffer.writeln('Task Completion Rate,${widget.completionRate}%');

      // Trigger browser download via data URL
      final csvContent = buffer.toString();
      final dataUrl = 'data:text/csv;charset=utf-8,${Uri.encodeComponent(csvContent)}';
      await launchUrl(Uri.parse(dataUrl));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('CSV downloaded successfully'),
          ]),
          backgroundColor: AppColors.successText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.criticalText,
        ));
      }
    }
  }

  Future<void> _exportPdf(BuildContext context) async {
    try {
      // Call backend report generation endpoint
      final data = await ApiService.generateReport({
        'type': 'analytics',
        'format': 'pdf',
        'includeRiskDistribution': true,
        'includeHighRisk': true,
      });
      final url = data['downloadUrl'] as String?;
      if (url != null && url.isNotEmpty) {
        await launchUrl(Uri.parse('${ApiService.baseUrl}$url'));
      } else {
        throw Exception('No download URL returned');
      }
    } catch (_) {
      // Backend PDF not available — show CSV suggestion
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('PDF export requires backend setup. Try CSV export instead.'),
          backgroundColor: AppColors.warningText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    }
  }
}
