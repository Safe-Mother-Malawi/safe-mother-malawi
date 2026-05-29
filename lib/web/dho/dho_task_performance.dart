import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../state/user_store.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';
import '../../utils/live_data_mixin.dart';

class DhoTaskPerformance extends StatefulWidget {
  const DhoTaskPerformance({super.key});
  @override
  State<DhoTaskPerformance> createState() => _DhoTaskPerformanceState();
}

class _DhoTaskPerformanceState extends State<DhoTaskPerformance> with LiveDataMixin {
  Map<String, dynamic> _data = {};
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
      final data = await ApiService.getTaskAnalytics();
      if (mounted) setState(() => _data = data);
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getTaskAnalytics();
      setState(() { _data = data; _loading = false; });
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

    final total     = (_data['total'] ?? _data['totalTasks'] ?? 0).toString();
    final completed = (_data['completed'] ?? _data['completedTasks'] ?? 0).toString();
    final missed    = (_data['missed'] ?? _data['missedTasks'] ?? 0).toString();
    final pending   = (_data['pending'] ?? _data['pendingTasks'] ?? 0).toString();
    final completionRate = (_data['completionRate'] ?? '—').toString();
    final missedRate     = (_data['missedRate'] ?? '—').toString();
    final pendingRate    = (_data['pendingRate'] ?? '—').toString();

    final missedList = (_data['missedTasksList'] ?? _data['recentMissed'] ?? []) as List;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Task Performance',
                style: TextStyle(fontFamily: 'Public Sans', 
                    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
            const Spacer(),
          ]),
          const SizedBox(height: 6),
          Text('Clinician task completion${_district.isNotEmpty ? ' for $_district District' : ''}',
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
              KpiCard(title: 'Total Tasks', value: total, icon: Icons.task_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'Completed', value: completed, icon: Icons.task_alt_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg, subtitle: '$completionRate%'),
              KpiCard(title: 'Missed', value: missed, icon: Icons.cancel_outlined, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg, subtitle: '$missedRate%'),
              KpiCard(title: 'Pending', value: pending, icon: Icons.pending_actions_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg, subtitle: '$pendingRate%'),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: ChartCard(
                  title: 'Completion Rate Trend',
                  subtitle: 'Monthly task completion',
                  chart: SizedBox(
                    height: 200,
                    child: LineChart(LineChartData(
                      gridData: FlGridData(
                        show: true, drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(color: AppColors.primary.withOpacity(0.06), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.successText,
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                            '${s.y.toStringAsFixed(0)}%',
                            TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
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
                              child: Text(m[i], style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: AppColors.mutedText)));
                          },
                        )),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _buildTrend(_data['completionTrend']),
                          isCurved: true, curveSmoothness: 0.4,
                          color: AppColors.successText, barWidth: 3,
                          dotData: FlDotData(show: true,
                            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                              radius: 4, color: Colors.white,
                              strokeWidth: 2.5, strokeColor: AppColors.successText)),
                          belowBarData: BarAreaData(show: true,
                            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [AppColors.successText.withOpacity(0.18), AppColors.successText.withOpacity(0.0)])),
                        ),
                      ],
                    )),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ChartCard(
                  title: 'Task Types',
                  subtitle: 'By category',
                  legend: Row(children: [
                    const LegendItem(color: AppColors.primary, label: 'ANC'),
                    const SizedBox(width: 10),
                    const LegendItem(color: AppColors.accent, label: 'PNC'),
                    const SizedBox(width: 10),
                    const LegendItem(color: AppColors.warningText, label: 'Vacc'),
                  ]),
                  chart: SizedBox(
                    height: 200,
                    child: PieChart(PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 44,
                      sections: [
                        PieChartSectionData(value: 38, color: AppColors.primary, title: '38%', titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white), radius: 56),
                        PieChartSectionData(value: 30, color: AppColors.accent, title: '30%', titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white), radius: 56),
                        PieChartSectionData(value: 20, color: AppColors.warningText, title: '20%', titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white), radius: 56),
                        PieChartSectionData(value: 12, color: AppColors.secondary, title: '12%', titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white), radius: 56),
                      ],
                    )),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

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
                Text('Missed Tasks',
                    style: TextStyle(fontFamily: 'Public Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                const SizedBox(height: 16),
                if (missedList.isEmpty)
                  Text('No missed tasks data available', style: TextStyle(fontFamily: 'Roboto', color: AppColors.mutedText))
                else
                  ...missedList.take(5).map((t) {
                    final task = t as Map<String, dynamic>;
                    final risk = (task['riskLevel'] ?? task['risk'] ?? 'Low').toString();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.cancel_outlined, size: 16, color: AppColors.criticalText),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: Text((task['title'] ?? '—').toString(), style: TextStyle(fontFamily: 'Roboto', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
                          Expanded(child: Text((task['clinician']?['fullName'] ?? '—').toString(), style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.bodyText))),
                          StatusBadge(label: risk, type: risk == 'High' ? BadgeType.critical : risk == 'Medium' ? BadgeType.warning : BadgeType.success),
                          const SizedBox(width: 12),
                          Text(task['overdueDays'] != null ? '${task['overdueDays']} days' : '—', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.criticalText)),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _buildTrend(dynamic trend) {
    if (trend is List && trend.isNotEmpty) {
      return trend.asMap().entries.map((e) {
        final val = (e.value is num) ? (e.value as num).toDouble() : 0.0;
        return FlSpot(e.key.toDouble(), val);
      }).toList();
    }
    return const [FlSpot(0, 70), FlSpot(1, 72), FlSpot(2, 69), FlSpot(3, 74), FlSpot(4, 76), FlSpot(5, 77)];
  }
}

