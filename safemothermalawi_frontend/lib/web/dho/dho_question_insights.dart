import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';

class DhoQuestionInsights extends StatelessWidget {
  const DhoQuestionInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question Insights',
              style: GoogleFonts.publicSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headings)),
          const SizedBox(height: 6),
          Text('Local symptom trends and risk patterns — Blantyre',
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
                icon: Icons.quiz_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.infoBg,
              ),
              KpiCard(
                title: 'Completion Rate',
                value: '89.4%',
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.successText,
                iconBg: AppColors.successBg,
              ),
              KpiCard(
                title: 'High-Risk',
                value: '841',
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.criticalText,
                iconBg: AppColors.criticalBg,
              ),
              KpiCard(
                title: 'Avg Score',
                value: '31%',
                icon: Icons.analytics_rounded,
                iconColor: AppColors.warningText,
                iconBg: AppColors.warningBg,
              ),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Text('Local Symptom Trends',
                          style: GoogleFonts.publicSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.headings)),
                      const SizedBox(height: 16),
                      ...[
                        {'symptom': 'Severe headache', 'count': '620', 'risk': 'High'},
                        {'symptom': 'Swollen feet', 'count': '940', 'risk': 'Medium'},
                        {'symptom': 'Difficulty breathing', 'count': '410', 'risk': 'High'},
                        {'symptom': 'Mild fatigue', 'count': '1,580', 'risk': 'Low'},
                        {'symptom': 'Reduced fetal movement', 'count': '380', 'risk': 'High'},
                      ].map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(s['symptom']!,
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.onSurface)),
                                ),
                                Text(s['count']!,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.bodyText)),
                                const SizedBox(width: 12),
                                StatusBadge(
                                  label: s['risk']!,
                                  type: s['risk'] == 'High'
                                      ? BadgeType.critical
                                      : s['risk'] == 'Medium'
                                          ? BadgeType.warning
                                          : BadgeType.success,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ChartCard(
                  title: 'Risk Patterns',
                  subtitle: 'District risk distribution',
                  chart: SizedBox(
                    height: 260,
                    child: PieChart(PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 44,
                      sections: [
                        PieChartSectionData(
                            value: 52,
                            color: AppColors.successText,
                            title: 'Low\n52%',
                            titleStyle: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                            radius: 55),
                        PieChartSectionData(
                            value: 30,
                            color: AppColors.warningText,
                            title: 'Med\n30%',
                            titleStyle: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                            radius: 55),
                        PieChartSectionData(
                            value: 18,
                            color: AppColors.criticalText,
                            title: 'High\n18%',
                            titleStyle: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                            radius: 55),
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
}
