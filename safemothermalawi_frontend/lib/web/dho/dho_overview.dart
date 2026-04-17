import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/app_shell.dart';
import '../shared/sidebar.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';
import '../admin/clinician_management.dart';
import '../admin/data_explorer.dart';
import '../admin/generate_analytics.dart';
import '../admin/analytics_dashboard.dart';
import '../admin/reports_screen.dart';
import '../../../screens/splash_screen.dart';

class DhoOverview extends StatefulWidget {
  const DhoOverview({super.key});

  @override
  State<DhoOverview> createState() => _DhoOverviewState();
}

class _DhoOverviewState extends State<DhoOverview> {
  String _currentRoute = '/overview';

  void _navigate(String route) => setState(() => _currentRoute = route);

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  Widget _buildPage() {
    switch (_currentRoute) {
      case '/clinicians':
        return const ClinicianManagement();
      case '/data-explorer':
        return const DataExplorer();
      case '/generate-analytics':
        return const GenerateAnalytics();
      case '/analytics':
        return const AnalyticsDashboard();
      case '/reports':
        return const ReportsScreen();
      default:
        return const _DhoOverviewBody();
    }
  }

  String get _pageTitle {
    const titles = {
      '/overview': 'Overview',
      '/clinicians': 'Clinician Management',
      '/data-explorer': 'Data Source',
      '/generate-analytics': 'Generate Analytics',
      '/analytics': 'Analytics Dashboard',
      '/reports': 'Reports',
    };
    return titles[_currentRoute] ?? 'DHO Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: UserRole.dho,
      userName: 'DHO Blantyre',
      currentRoute: _currentRoute,
      pageTitle: _pageTitle,
      onNavigate: _navigate,
      onLogout: _logout,
      body: _buildPage(),
    );
  }
}

class _DhoOverviewBody extends StatelessWidget {
  const _DhoOverviewBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text('Blantyre District',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1,
            children: const [
              KpiCard(title: 'Total Mothers', value: '9,102', icon: Icons.pregnant_woman_rounded, iconColor: AppColors.tertiary, iconBg: Color(0xFFE0F2F1), subtitle: 'Blantyre district'),
              KpiCard(title: 'High-Risk Cases', value: '841', icon: Icons.warning_amber_rounded, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg, subtitle: '9.2% of total'),
              KpiCard(title: 'Task Completion', value: '76.8%', icon: Icons.task_alt_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg, subtitle: 'This month'),
              KpiCard(title: 'IVR Usage', value: '1,840', icon: Icons.phone_in_talk_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg, subtitle: 'Calls this month'),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: ChartCard(
                  title: 'District Trends',
                  subtitle: 'Monthly registrations — Blantyre',
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
                          getTitlesWidget: (v, _) {
                            const m = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
                            final i = v.toInt();
                            if (i < 0 || i >= m.length) return const SizedBox();
                            return Text(m[i], style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText));
                          })),
                      ),
                      lineBarsData: [LineChartBarData(
                        spots: const [FlSpot(0,1200),FlSpot(1,1380),FlSpot(2,1290),FlSpot(3,1520),FlSpot(4,1610),FlSpot(5,1840)],
                        isCurved: true, color: AppColors.primary, barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.08)),
                      )],
                    )),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ChartCard(
                  title: 'Risk Breakdown', subtitle: 'Current distribution',
                  chart: SizedBox(height: 200, child: PieChart(PieChartData(
                    sectionsSpace: 3, centerSpaceRadius: 44,
                    sections: [
                      PieChartSectionData(value: 55, color: AppColors.successText, title: 'Low\n55%', titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 50),
                      PieChartSectionData(value: 28, color: AppColors.warningText, title: 'Med\n28%', titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 50),
                      PieChartSectionData(value: 17, color: AppColors.criticalText, title: 'High\n17%', titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 50),
                    ],
                  ))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

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
                Text('District Alerts', style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                const SizedBox(height: 16),
                _AlertRow(icon: Icons.trending_up_rounded, color: AppColors.criticalText, bg: AppColors.criticalBg, title: 'High-Risk Spike — Blantyre South', subtitle: '+18% increase this week', badge: BadgeType.critical),
                const SizedBox(height: 12),
                _AlertRow(icon: Icons.cancel_outlined, color: AppColors.warningText, bg: AppColors.warningBg, title: 'Missed Care Trend', subtitle: '14 ANC visits missed this week', badge: BadgeType.warning),
                const SizedBox(height: 12),
                _AlertRow(icon: Icons.phone_missed_rounded, color: AppColors.infoText, bg: AppColors.infoBg, title: 'IVR Drop-off Increase', subtitle: '38% calls abandoned in Blantyre', badge: BadgeType.info),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String title, subtitle;
  final BadgeType badge;

  const _AlertRow({required this.icon, required this.color, required this.bg, required this.title, required this.subtitle, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
        ])),
        StatusBadge(label: badge.name, type: badge),
      ],
    );
  }
}
