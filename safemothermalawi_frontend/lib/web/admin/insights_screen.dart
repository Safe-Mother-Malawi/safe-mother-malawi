import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
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

// ── IVR Tab ───────────────────────────────────────────────────────────────────

class _IvrTab extends StatefulWidget {
  const _IvrTab();
  @override
  State<_IvrTab> createState() => _IvrTabState();
}

class _IvrTabState extends State<_IvrTab> {
  Map<String, dynamic> _data = {};
  List<dynamic> _calls = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.getIvrAnalytics(),
        ApiService.getIvrCalls(limit: 50),
      ]);
      setState(() {
        _data  = results[0] as Map<String, dynamic>;
        _calls = results[1] as List<dynamic>;
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
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: AppColors.criticalText, size: 40),
        const SizedBox(height: 8),
        Text(_error!, style: GoogleFonts.inter(color: AppColors.criticalText)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]));
    }

    final total      = (_data['totalCalls'] ?? _data['total'] ?? _calls.length).toString();
    final avgWait    = (_data['avgWaitTime'] ?? _data['avgDuration'] ?? '—').toString();
    final dropOff    = (_data['dropOffRate'] ?? _data['dropRate'] ?? '—').toString();
    final completion = (_data['completionRate'] ?? '—').toString();

    // Build topic frequency from calls
    final topicMap = <String, int>{};
    for (final c in _calls) {
      final topic = (c['topic'] ?? c['category'] ?? 'Other').toString();
      topicMap[topic] = (topicMap[topic] ?? 0) + 1;
    }
    final topics = topicMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTotal = topics.fold(0, (s, e) => s + e.value);

    // Build daily trend from calls
    final trendMap = <int, int>{};
    for (final c in _calls) {
      final date = DateTime.tryParse(c['createdAt']?.toString() ?? '');
      if (date != null) {
        final dayAgo = DateTime.now().difference(date).inDays;
        if (dayAgo < 14) trendMap[13 - dayAgo] = (trendMap[13 - dayAgo] ?? 0) + 1;
      }
    }
    final trendSpots = List.generate(14, (i) => FlSpot(i.toDouble(), (trendMap[i] ?? 0).toDouble()));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3,
            children: [
              KpiCard(title: 'Total Calls', value: total, icon: Icons.phone_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'Avg Duration', value: '$avgWait s', icon: Icons.timer_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg),
              KpiCard(title: 'Drop-off Rate', value: '$dropOff%', icon: Icons.phone_missed_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg),
              KpiCard(title: 'Completion Rate', value: '$completion%', icon: Icons.check_circle_outline_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg),
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
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text('D${v.toInt() + 1}',
                              style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText)),
                        )),
                      ),
                      lineBarsData: [LineChartBarData(
                        spots: trendSpots,
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
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Popular Topics',
                          style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                      const SizedBox(height: 16),
                      if (topics.isEmpty)
                        Text('No topic data available', style: GoogleFonts.inter(color: AppColors.mutedText))
                      else
                        ...topics.take(5).map((t) => _TopicBar(
                              label: t.key,
                              percent: topTotal > 0 ? t.value / topTotal : 0,
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

// ── Question Tab ──────────────────────────────────────────────────────────────

class _QuestionTab extends StatefulWidget {
  const _QuestionTab();
  @override
  State<_QuestionTab> createState() => _QuestionTabState();
}

class _QuestionTabState extends State<_QuestionTab> {
  Map<String, dynamic> _dist = {};
  List<dynamic> _assessments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.getRiskDistribution(),
        ApiService.getRiskAssessments(limit: 200),
      ]);
      setState(() {
        _dist        = results[0] as Map<String, dynamic>;
        _assessments = results[1] as List<dynamic>;
        _loading     = false;
      });
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
        Text(_error!, style: GoogleFonts.inter(color: AppColors.criticalText)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]));
    }

    final total      = (_dist['total'] ?? _assessments.length).toString();
    final completion = (_dist['completionRate'] ?? '—').toString();
    final highRisk   = (_dist['high'] ?? _dist['highRisk'] ?? 0).toString();
    final avgScore   = (_dist['avgScore'] ?? '—').toString();

    final low    = (_dist['low'] ?? 0) as num;
    final medium = (_dist['medium'] ?? 0) as num;
    final high   = (_dist['high'] ?? 0) as num;

    // Build symptom frequency
    final symptomMap = <String, int>{};
    for (final a in _assessments) {
      final s = (a['topSymptom'] ?? a['primarySymptom'] ?? '').toString();
      if (s.isNotEmpty) symptomMap[s] = (symptomMap[s] ?? 0) + 1;
    }
    final symptoms = symptomMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3,
            children: [
              KpiCard(title: 'Total Assessments', value: total, icon: Icons.quiz_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'Completion Rate', value: '$completion%', icon: Icons.check_circle_outline_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg),
              KpiCard(title: 'High-Risk Flagged', value: highRisk, icon: Icons.warning_amber_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg),
              KpiCard(title: 'Avg Score', value: '$avgScore%', icon: Icons.analytics_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Common Symptoms',
                          style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                      const SizedBox(height: 16),
                      if (symptoms.isEmpty)
                        Text('No symptom data available', style: GoogleFonts.inter(color: AppColors.mutedText))
                      else
                        ...symptoms.take(6).map((s) => _SymptomRow(
                              symptom: s.key,
                              count: '${s.value}',
                              risk: s.value > 500 ? 'High' : s.value > 200 ? 'Medium' : 'Low',
                            )),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ChartCard(
                  title: 'Risk Distribution',
                  subtitle: 'Assessment outcomes by risk level',
                  chart: SizedBox(
                    height: 240,
                    child: BarChart(BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const l = ['Low', 'Medium', 'High'];
                            final i = v.toInt();
                            if (i < 0 || i >= l.length) return const SizedBox();
                            return Text(l[i], style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText));
                          },
                        )),
                      ),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: low.toDouble(), color: AppColors.successText, width: 40, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: medium.toDouble(), color: AppColors.warningText, width: 40, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: high.toDouble(), color: AppColors.criticalText, width: 40, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
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

// ── Shared helpers ────────────────────────────────────────────────────────────

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
            Text('${(percent * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
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

class _SymptomRow extends StatelessWidget {
  final String symptom, count, risk;
  const _SymptomRow({required this.symptom, required this.count, required this.risk});

  @override
  Widget build(BuildContext context) {
    final type = risk == 'High' ? BadgeType.critical
        : risk == 'Medium' ? BadgeType.warning
        : BadgeType.success;
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
