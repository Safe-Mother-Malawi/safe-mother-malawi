import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';

class DhoIvrInsights extends StatelessWidget {
  const DhoIvrInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IVR Insights',
              style: GoogleFonts.publicSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headings)),
          const SizedBox(height: 6),
          Text('IVR usage patterns for Blantyre District',
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
                title: 'District Calls',
                value: '1,840',
                icon: Icons.phone_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.infoBg,
              ),
              KpiCard(
                title: 'Avg Wait Time',
                value: '2m 38s',
                icon: Icons.timer_rounded,
                iconColor: AppColors.warningText,
                iconBg: AppColors.warningBg,
              ),
              KpiCard(
                title: 'Drop-off Rate',
                value: '38%',
                icon: Icons.phone_missed_rounded,
                iconColor: AppColors.criticalText,
                iconBg: AppColors.criticalBg,
              ),
              KpiCard(
                title: 'Completion',
                value: '62%',
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.successText,
                iconBg: AppColors.successBg,
              ),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: ChartCard(
                  title: 'Call Trends — Blantyre',
                  subtitle: 'Daily IVR calls over last 14 days',
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
                            getTitlesWidget: (v, _) => Text(
                              'D${v.toInt() + 1}',
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: AppColors.mutedText),
                            ),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 55), FlSpot(1, 68), FlSpot(2, 60),
                            FlSpot(3, 82), FlSpot(4, 75), FlSpot(5, 90),
                            FlSpot(6, 88), FlSpot(7, 102), FlSpot(8, 95),
                            FlSpot(9, 115), FlSpot(10, 108), FlSpot(11, 125),
                            FlSpot(12, 118), FlSpot(13, 132),
                          ],
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.08),
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
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
                      Text('Usage Patterns',
                          style: GoogleFonts.publicSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.headings)),
                      const SizedBox(height: 16),
                      ...[
                        {'label': 'Baby Issues', 'pct': 0.40},
                        {'label': 'Mother Issues', 'pct': 0.32},
                        {'label': 'Immunization', 'pct': 0.18},
                        {'label': 'Feeding', 'pct': 0.10},
                      ].map((t) => _TopicBar(
                            label: t['label'] as String,
                            percent: t['pct'] as double,
                          )),
                    ],
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

class _TopicBar extends StatelessWidget {
  final String label;
  final double percent;
  const _TopicBar({required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.onSurface)),
              Text('${(percent * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.surfaceContainerHighest,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
