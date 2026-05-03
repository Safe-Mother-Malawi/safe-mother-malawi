import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../../../services/api_service.dart';

class IvrInsights extends StatefulWidget {
  const IvrInsights({super.key});

  @override
  State<IvrInsights> createState() => _IvrInsightsState();
}

class _IvrInsightsState extends State<IvrInsights> {
  bool _loading = true;
  String? _error;

  int _totalCalls      = 0;
  int _completedCalls  = 0;
  int _abandonedCalls  = 0;
  int _completionRate  = 0;
  int _prenatalCalls   = 0;
  int _neonatalCalls   = 0;
  int? _avgDuration;

  List<Map<String, dynamic>> _dailyVolume      = [];
  List<Map<String, dynamic>> _riskBreakdown    = [];
  List<Map<String, dynamic>> _districtBreakdown = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.instance.get('/analytics/ivr') as Map<String, dynamic>;
      setState(() {
        _totalCalls      = data['totalCalls'] ?? 0;
        _completedCalls  = data['completedCalls'] ?? 0;
        _abandonedCalls  = data['abandonedCalls'] ?? 0;
        _completionRate  = data['completionRate'] ?? 0;
        _prenatalCalls   = data['prenatalCalls'] ?? 0;
        _neonatalCalls   = data['neonatalCalls'] ?? 0;
        _avgDuration     = data['avgDurationSeconds'] as int?;
        _dailyVolume     = (data['dailyVolume'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        _riskBreakdown   = (data['riskLevelBreakdown'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        _districtBreakdown = (data['districtBreakdown'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _fmtDuration(int? secs) {
    if (secs == null) return 'N/A';
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        Text('Failed to load IVR data'),
        TextButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Retry')),
      ]));
    }

    // Build daily volume spots
    final spots = <FlSpot>[];
    for (int i = 0; i < _dailyVolume.length; i++) {
      final count = double.tryParse(_dailyVolume[i]['count'].toString()) ?? 0;
      spots.add(FlSpot(i.toDouble(), count));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IVR Insights', style: GoogleFonts.publicSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 6),
          Text('Interactive Voice Response usage and performance', style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3,
            children: [
              KpiCard(title: 'Total Calls', value: _totalCalls.toString(),
                  icon: Icons.phone_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'Avg Duration', value: _fmtDuration(_avgDuration),
                  icon: Icons.timer_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg),
              KpiCard(title: 'Abandoned', value: '$_abandonedCalls',
                  icon: Icons.phone_missed_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg,
                  subtitle: _totalCalls > 0 ? '${((_abandonedCalls / _totalCalls) * 100).toStringAsFixed(0)}% rate' : ''),
              KpiCard(title: 'Completion Rate', value: '$_completionRate%',
                  icon: Icons.check_circle_outline_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg),
            ],
          ),
          const SizedBox(height: 28),

          Row(children: [
            Expanded(flex: 2, child: ChartCard(
              title: 'Call Volume Trend',
              subtitle: 'Daily IVR calls over last 30 days',
              chart: SizedBox(height: 200, child: spots.length < 2
                  ? const Center(child: Text('No call data yet'))
                  : LineChart(LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                          getTitlesWidget: (v, _) => Text('D${v.toInt() + 1}',
                              style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText)))),
                      ),
                      lineBarsData: [LineChartBarData(
                        spots: spots, isCurved: true, color: AppColors.primary, barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.08)),
                      )],
                    ))),
            )),
            const SizedBox(width: 20),
            Expanded(child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Call Breakdown', style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                  const SizedBox(height: 16),
                  _TopicBar(label: 'Prenatal Calls', percent: _totalCalls > 0 ? _prenatalCalls / _totalCalls : 0),
                  _TopicBar(label: 'Neonatal Calls', percent: _totalCalls > 0 ? _neonatalCalls / _totalCalls : 0),
                  _TopicBar(label: 'Completed', percent: _totalCalls > 0 ? _completedCalls / _totalCalls : 0),
                  _TopicBar(label: 'Abandoned', percent: _totalCalls > 0 ? _abandonedCalls / _totalCalls : 0),
                ],
              ),
            )),
          ]),
          const SizedBox(height: 20),

          // Risk breakdown from IVR calls
          if (_riskBreakdown.isNotEmpty) ...[
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
                  Text('Risk Levels from IVR Assessments',
                      style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                  const SizedBox(height: 16),
                  ..._riskBreakdown.map((r) {
                    final total = _riskBreakdown.fold<int>(0, (s, x) => s + (x['count'] as int? ?? 0));
                    final count = r['count'] as int? ?? 0;
                    return _TopicBar(
                      label: r['level'] as String? ?? '',
                      percent: total > 0 ? count / total : 0,
                      count: count,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // District breakdown
          if (_districtBreakdown.isNotEmpty)
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
                  Text('Top Districts by IVR Usage',
                      style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                  const SizedBox(height: 16),
                  ..._districtBreakdown.take(5).map((d) {
                    final maxCount = (_districtBreakdown.first['count'] as int? ?? 1);
                    final count = d['count'] as int? ?? 0;
                    return _TopicBar(
                      label: d['district'] as String? ?? 'Unknown',
                      percent: maxCount > 0 ? count / maxCount : 0,
                      count: count,
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TopicBar extends StatelessWidget {
  final String label;
  final double percent;
  final int? count;
  const _TopicBar({required this.label, required this.percent, this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface)),
            Text(count != null ? '$count (${(percent * 100).toStringAsFixed(0)}%)' : '${(percent * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceContainerHighest,
              color: AppColors.primary, minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
