import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';

class DhoTaskPerformance extends StatelessWidget {
  const DhoTaskPerformance({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task Performance',
              style: GoogleFonts.publicSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headings)),
          const SizedBox(height: 6),
          Text('Clinician task completion for Blantyre District',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: const [
              KpiCard(
                title: 'Total Tasks',
                value: '3,640',
                icon: Icons.task_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.infoBg,
              ),
              KpiCard(
                title: 'Completed',
                value: '2,795',
                icon: Icons.task_alt_rounded,
                iconColor: AppColors.successText,
                iconBg: AppColors.successBg,
                subtitle: '76.8% rate',
              ),
              KpiCard(
                title: 'Missed',
                value: '438',
                icon: Icons.cancel_outlined,
                iconColor: AppColors.criticalText,
                iconBg: AppColors.criticalBg,
                subtitle: '12.0% rate',
              ),
              KpiCard(
                title: 'Pending',
                value: '407',
                icon: Icons.pending_actions_rounded,
                iconColor: AppColors.warningText,
                iconBg: AppColors.warningBg,
                subtitle: '11.2% rate',
              ),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: ChartCard(
                  title: 'Completion Rate Trend',
                  subtitle: 'Monthly task completion — Blantyre',
                  chart: SizedBox(
                    height: 200,
                    child: LineChart(LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const m = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
                              final i = v.toInt();
                              if (i < 0 || i >= m.length) return const SizedBox();
                              return Text(m[i],
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.mutedText));
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 70), FlSpot(1, 72), FlSpot(2, 69),
                            FlSpot(3, 74), FlSpot(4, 76), FlSpot(5, 77),
                          ],
                          isCurved: true,
                          color: AppColors.successText,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.successText.withOpacity(0.08),
                          ),
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
                  chart: SizedBox(
                    height: 200,
                    child: PieChart(PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                            value: 38,
                            color: AppColors.primary,
                            title: 'ANC\n38%',
                            titleStyle: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                            radius: 50),
                        PieChartSectionData(
                            value: 30,
                            color: AppColors.accent,
                            title: 'PNC\n30%',
                            titleStyle: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                            radius: 50),
                        PieChartSectionData(
                            value: 20,
                            color: AppColors.warningText,
                            title: 'Vacc\n20%',
                            titleStyle: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                            radius: 50),
                        PieChartSectionData(
                            value: 12,
                            color: AppColors.secondary,
                            title: 'Risk\n12%',
                            titleStyle: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                            radius: 50),
                      ],
                    )),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Missed tasks
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 24,
                    offset: Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Missed Tasks',
                    style: GoogleFonts.publicSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.headings)),
                const SizedBox(height: 16),
                ...[
                  {'task': 'ANC Visit Reminder', 'clinician': 'Nurse Phiri', 'risk': 'High', 'days': '3 days'},
                  {'task': 'Postnatal Check', 'clinician': 'Dr. Mwale', 'risk': 'Medium', 'days': '5 days'},
                  {'task': 'Vaccination Follow-up', 'clinician': 'Nurse Tembo', 'risk': 'Low', 'days': '1 day'},
                ].map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.cancel_outlined,
                              size: 16, color: AppColors.criticalText),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Text(t['task']!,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onSurface)),
                          ),
                          Expanded(
                            child: Text(t['clinician']!,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.bodyText)),
                          ),
                          StatusBadge(
                            label: t['risk']!,
                            type: t['risk'] == 'High'
                                ? BadgeType.critical
                                : t['risk'] == 'Medium'
                                    ? BadgeType.warning
                                    : BadgeType.success,
                          ),
                          const SizedBox(width: 12),
                          Text(t['days']!,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.criticalText)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
