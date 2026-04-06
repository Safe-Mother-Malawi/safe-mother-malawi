import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';

class DistrictAnalytics extends StatelessWidget {
  const DistrictAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('District Analytics',
                  style: GoogleFonts.publicSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.headings)),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Read-only',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.infoText)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Pre-generated insights for Blantyre District',
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
                title: 'Assessments',
                value: '4,820',
                icon: Icons.assignment_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.infoBg,
              ),
              KpiCard(
                title: 'High-Risk',
                value: '841',
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.criticalText,
                iconBg: AppColors.criticalBg,
              ),
              KpiCard(
                title: 'IVR Calls',
                value: '1,840',
                icon: Icons.phone_in_talk_rounded,
                iconColor: AppColors.warningText,
                iconBg: AppColors.warningBg,
              ),
              KpiCard(
                title: 'Task Rate',
                value: '76.8%',
                icon: Icons.task_alt_rounded,
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
                  title: 'Risk Trends — Blantyre',
                  subtitle: 'Monthly high-risk cases',
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
                            FlSpot(0, 110), FlSpot(1, 130), FlSpot(2, 120),
                            FlSpot(3, 155), FlSpot(4, 148), FlSpot(5, 170),
                          ],
                          isCurved: true,
                          color: AppColors.criticalText,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.criticalText.withValues(alpha: 0.07),
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
                  title: 'District Performance',
                  subtitle: 'vs national average',
                  chart: SizedBox(
                    height: 200,
                    child: BarChart(BarChartData(
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
                              const labels = ['ANC', 'PNC', 'IVR', 'Tasks'];
                              final i = v.toInt();
                              if (i < 0 || i >= labels.length) return const SizedBox();
                              return Text(labels[i],
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppColors.mutedText));
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        _groupBar(0, 78, 72),
                        _groupBar(1, 82, 75),
                        _groupBar(2, 65, 70),
                        _groupBar(3, 77, 78),
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

  BarChartGroupData _groupBar(int x, double district, double national) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: district,
          color: AppColors.primary,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
