import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../../../services/api_service.dart';

class TaskAnalytics extends StatefulWidget {
  const TaskAnalytics({super.key});

  @override
  State<TaskAnalytics> createState() => _TaskAnalyticsState();
}

class _TaskAnalyticsState extends State<TaskAnalytics> {
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
              chart: SizedBox(height: 200, child: _total == 0
                  ? const Center(child: Text('No appointment data yet'))
                  : PieChart(PieChartData(
                      sectionsSpace: 3, centerSpaceRadius: 44,
                      sections: [
                        if (_completed > 0) PieChartSectionData(
                          value: _completed.toDouble(), color: AppColors.successText,
                          title: 'Done\n$_completionRate%',
                          titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                          radius: 52),
                        if (_cancelled > 0) PieChartSectionData(
                          value: _cancelled.toDouble(), color: AppColors.criticalText,
                          title: 'Cancelled\n$_missedRate%',
                          titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                          radius: 52),
                        if (_pending > 0) PieChartSectionData(
                          value: _pending.toDouble(), color: AppColors.warningText,
                          title: 'Pending',
                          titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                          radius: 52),
                      ],
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Summary', style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                const SizedBox(height: 16),
                _SummaryRow(label: 'Total Appointments', value: _total.toString(), color: AppColors.primary),
                _SummaryRow(label: 'Completed', value: _completed.toString(), color: AppColors.successText),
                _SummaryRow(label: 'Cancelled', value: _cancelled.toString(), color: AppColors.criticalText),
                _SummaryRow(label: 'Pending', value: _pending.toString(), color: AppColors.warningText),
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
