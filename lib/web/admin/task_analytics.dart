import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../../../utils/live_data_mixin.dart';

class TaskAnalytics extends StatefulWidget {
  const TaskAnalytics({super.key});

  @override
  State<TaskAnalytics> createState() => _TaskAnalyticsState();
}

class _TaskAnalyticsState extends State<TaskAnalytics> with LiveDataMixin {
  bool _loading = true;
  String? _error;

  int _total       = 0;
  int _completed   = 0;
  int _cancelled   = 0;
  int _pending     = 0;
  int _completionRate = 0;
  int _missedRate  = 0;

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
      final data = await ApiService.instance.get('/analytics/task-analytics') as Map<String, dynamic>;
      if (mounted) setState(() {
        _total          = data['total'] ?? 0;
        _completed      = data['completed'] ?? 0;
        _cancelled      = data['cancelled'] ?? 0;
        _pending        = data['pending'] ?? 0;
        _completionRate = data['completionRate'] ?? 0;
        _missedRate     = data['missedRate'] ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.instance.get('/analytics/task-analytics') as Map<String, dynamic>;
      setState(() {
        _total          = data['total'] ?? 0;
        _completed      = data['completed'] ?? 0;
        _cancelled      = data['cancelled'] ?? 0;
        _pending        = data['pending'] ?? 0;
        _completionRate = data['completionRate'] ?? 0;
        _missedRate     = data['missedRate'] ?? 0;
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
        Text('Failed to load task analytics'),
        TextButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Retry')),
      ]));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task Analytics', style: GoogleFonts.publicSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 6),
          Text('Appointment task performance and completion tracking', style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3,
            children: [
              KpiCard(title: 'Total Tasks', value: _total.toString(),
                  icon: Icons.task_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'Completed', value: _completed.toString(),
                  icon: Icons.task_alt_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg,
                  subtitle: '$_completionRate% rate'),
              KpiCard(title: 'Cancelled', value: _cancelled.toString(),
                  icon: Icons.cancel_outlined, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg,
                  subtitle: '$_missedRate% rate'),
              KpiCard(title: 'Pending', value: _pending.toString(),
                  icon: Icons.pending_actions_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg),
            ],
          ),
          const SizedBox(height: 28),

          Row(children: [
            Expanded(flex: 2, child: ChartCard(
              title: 'Task Status Breakdown',
              subtitle: 'Completed vs Cancelled vs Pending',
              legend: Row(children: [
                const LegendItem(color: AppColors.successText, label: 'Completed'),
                const SizedBox(width: 14),
                const LegendItem(color: AppColors.criticalText, label: 'Cancelled'),
                const SizedBox(width: 14),
                const LegendItem(color: AppColors.warningText, label: 'Pending'),
              ]),
              chart: SizedBox(height: 220, child: _total == 0
                  ? Center(child: Text('No appointment data yet', style: GoogleFonts.inter(color: AppColors.mutedText)))
                  : Row(children: [
                      Expanded(child: PieChart(PieChartData(
                        sectionsSpace: 4, centerSpaceRadius: 52,
                        pieTouchData: PieTouchData(
                          touchCallback: (_, __) {},
                        ),
                        sections: [
                          if (_completed > 0) PieChartSectionData(
                            value: _completed.toDouble(), color: AppColors.successText,
                            title: '$_completionRate%',
                            titleStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                            radius: 58),
                          if (_cancelled > 0) PieChartSectionData(
                            value: _cancelled.toDouble(), color: AppColors.criticalText,
                            title: '$_missedRate%',
                            titleStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                            radius: 58),
                          if (_pending > 0) PieChartSectionData(
                            value: _pending.toDouble(), color: AppColors.warningText,
                            title: '${_total > 0 ? (_pending * 100 ~/ _total) : 0}%',
                            titleStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                            radius: 58),
                        ],
                      ))),
                      const SizedBox(width: 16),
                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _StatPill(label: 'Done', value: _completed.toString(), color: AppColors.successText),
                        const SizedBox(height: 10),
                        _StatPill(label: 'Cancelled', value: _cancelled.toString(), color: AppColors.criticalText),
                        const SizedBox(height: 10),
                        _StatPill(label: 'Pending', value: _pending.toString(), color: AppColors.warningText),
                      ]),
                    ])),
            )),
            const SizedBox(width: 20),
            Expanded(child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEEF2FF)),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 32, offset: const Offset(0, 8))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Summary', style: GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.headings)),
                const SizedBox(height: 16),
                _SummaryRow(label: 'Total', value: _total.toString(), color: AppColors.primary),
                _SummaryRow(label: 'Completed', value: _completed.toString(), color: AppColors.successText),
                _SummaryRow(label: 'Cancelled', value: _cancelled.toString(), color: AppColors.criticalText),
                _SummaryRow(label: 'Pending', value: _pending.toString(), color: AppColors.warningText),
                const Divider(height: 24),
                _SummaryRow(label: 'Completion Rate', value: '$_completionRate%', color: AppColors.successText),
              ]),
            )),
          ]),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface))),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: color)),
      ]),
    );
  }
}
