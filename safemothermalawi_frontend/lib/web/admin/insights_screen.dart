import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';

/// Combined Insights screen — IVR Insights + Question Insights as tabs
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Insights',
              style: GoogleFonts.publicSans(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 4),
          Text('IVR call analytics and health assessment patterns',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
            ),
            child: TabBar(
              controller: _tab,
              labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 14),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.mutedText,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(icon: Icon(Icons.phone_in_talk_rounded, size: 18), text: 'IVR Insights'),
                Tab(icon: Icon(Icons.quiz_rounded, size: 18), text: 'Question Insights'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [_IvrTab(), _QuestionTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _IvrTab extends StatelessWidget {
  const _IvrTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3,
            children: const [
              KpiCard(title: 'Total Calls', value: '9,102', icon: Icons.phone_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'Avg Wait Time', value: '2m 14s', icon: Icons.timer_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg),
              KpiCard(title: 'Drop-off Rate', value: '34%', icon: Icons.phone_missed_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg),
              KpiCard(title: 'Completion Rate', value: '66%', icon: Icons.check_circle_outline_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ChartCard(
                  title: 'Call Trends',
                  subtitle: 'Daily IVR calls over last 14 days',
                  chart: SizedBox(
                    height: 200,
                    child: LineChart(LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                          getTitlesWidget: (v, _) => Text('D${v.toInt() + 1}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText)))),
                      ),
                      lineBarsData: [LineChartBarData(
                        spots: const [FlSpot(0,280),FlSpot(1,320),FlSpot(2,290),FlSpot(3,410),FlSpot(4,380),FlSpot(5,450),FlSpot(6,420),FlSpot(7,510),FlSpot(8,480),FlSpot(9,560),FlSpot(10,530),FlSpot(11,610),FlSpot(12,580),FlSpot(13,640)],
                        isCurved: true, color: AppColors.primary, barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.08)),
                      )],
                    )),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Popular Topics', style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                      const SizedBox(height: 16),
                      ...[{'label':'Baby Issues','pct':0.38},{'label':'Mother Issues','pct':0.30},{'label':'Immunization','pct':0.20},{'label':'Feeding Guidance','pct':0.12}]
                          .map((t) => _TopicBar(label: t['label'] as String, percent: t['pct'] as double)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ChartCard(
                  title: 'Wait Time Distribution',
                  subtitle: 'Minutes callers waited before connecting',
                  chart: SizedBox(height: 180, child: BarChart(BarChartData(
                    gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                        getTitlesWidget: (v, _) { const l = ['<1m','1-2m','2-3m','3-5m','>5m']; final i = v.toInt(); if (i < 0 || i >= l.length) return const SizedBox(); return Text(l[i], style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText)); })),
                    ),
                    barGroups: [_ivrBar(0,1200,AppColors.successText),_ivrBar(1,3400,AppColors.primary),_ivrBar(2,2800,AppColors.warningText),_ivrBar(3,1100,AppColors.criticalText),_ivrBar(4,600,AppColors.criticalText)],
                  ))),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ChartCard(
                  title: 'Drop-off by Topic', subtitle: 'Where callers hang up',
                  chart: SizedBox(height: 180, child: PieChart(PieChartData(sectionsSpace: 3, centerSpaceRadius: 40, sections: [
                    PieChartSectionData(value: 40, color: AppColors.criticalText, title: '40%', titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 48),
                    PieChartSectionData(value: 28, color: AppColors.warningText, title: '28%', titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 48),
                    PieChartSectionData(value: 20, color: AppColors.primary, title: '20%', titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 48),
                    PieChartSectionData(value: 12, color: AppColors.secondary, title: '12%', titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 48),
                  ]))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _ivrBar(int x, double y, Color color) => BarChartGroupData(x: x, barRods: [BarChartRodData(toY: y, color: color, width: 28, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]);
}

class _QuestionTab extends StatelessWidget {
  const _QuestionTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3,
            children: const [
              KpiCard(title: 'Total Assessments', value: '24,810', icon: Icons.quiz_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'Completion Rate', value: '91.2%', icon: Icons.check_circle_outline_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg),
              KpiCard(title: 'High-Risk Flagged', value: '2,841', icon: Icons.warning_amber_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg),
              KpiCard(title: 'Avg Score', value: '28%', icon: Icons.analytics_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Common Symptoms', style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                      const SizedBox(height: 16),
                      ...[
                        {'symptom':'Severe headache','count':'3,241','risk':'High'},
                        {'symptom':'Difficulty breathing','count':'2,180','risk':'High'},
                        {'symptom':'Swollen feet','count':'4,820','risk':'Medium'},
                        {'symptom':'Reduced fetal movement','count':'1,940','risk':'High'},
                        {'symptom':'Mild fatigue','count':'8,100','risk':'Low'},
                      ].map((s) => _SymptomRow(symptom: s['symptom']!, count: s['count']!, risk: s['risk']!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ChartCard(
                  title: 'Risk Distribution', subtitle: 'Assessment outcomes by risk level',
                  chart: SizedBox(height: 240, child: BarChart(BarChartData(
                    gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                        getTitlesWidget: (v, _) { const l = ['Low','Medium','High']; final i = v.toInt(); if (i < 0 || i >= l.length) return const SizedBox(); return Text(l[i], style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText)); })),
                    ),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 14800, color: AppColors.successText, width: 40, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 7200, color: AppColors.warningText, width: 40, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2841, color: AppColors.criticalText, width: 40, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                    ],
                  ))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ChartCard(
            title: 'Completion Rate Trend', subtitle: 'Monthly assessment completion over 6 months',
            chart: SizedBox(height: 180, child: LineChart(LineChartData(
              gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                  getTitlesWidget: (v, _) { const m = ['Oct','Nov','Dec','Jan','Feb','Mar']; final i = v.toInt(); if (i < 0 || i >= m.length) return const SizedBox(); return Text(m[i], style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText)); })),
              ),
              lineBarsData: [LineChartBarData(
                spots: const [FlSpot(0,82),FlSpot(1,85),FlSpot(2,84),FlSpot(3,88),FlSpot(4,90),FlSpot(5,91)],
                isCurved: true, color: AppColors.successText, barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: AppColors.successText.withValues(alpha: 0.08)),
              )],
            ))),
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface)),
            Text('${(percent * 100).toStringAsFixed(0)}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: percent, backgroundColor: AppColors.surfaceContainerHighest, color: AppColors.primary, minHeight: 6)),
        ],
      ),
    );
  }
}

class _SymptomRow extends StatelessWidget {
  final String symptom, count, risk;
  const _SymptomRow({required this.symptom, required this.count, required this.risk});

  @override
  Widget build(BuildContext context) {
    final type = risk == 'High' ? BadgeType.critical : risk == 'Medium' ? BadgeType.warning : BadgeType.success;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(child: Text(symptom, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface))),
        Text(count, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.bodyText)),
        const SizedBox(width: 12),
        StatusBadge(label: risk, type: type),
      ]),
    );
  }
}
