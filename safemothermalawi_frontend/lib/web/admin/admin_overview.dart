import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/app_shell.dart';
import '../shared/sidebar.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/status_badge.dart';
import '../shared/widgets/chart_card.dart';
import 'system_users.dart';
import 'reports_screen.dart';
import 'system_logs.dart';
import 'audit_export.dart';

class AdminOverview extends StatefulWidget {
  const AdminOverview({super.key});

  @override
  State<AdminOverview> createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<AdminOverview> {
  String _currentRoute = '/overview';

  void _navigate(String route) {
    setState(() => _currentRoute = route);
  }

  Widget _buildPage() {
    switch (_currentRoute) {
      case '/clinicians':
        return const SystemUsers();
      case '/system-logs':
        return const SystemLogs();
      case '/audit-export':
        return const AuditExport();
      case '/reports':
        return const ReportsScreen();
      default:
        return const _OverviewBody();
    }
  }

  String get _pageTitle {
    const titles = {
      '/overview': 'Overview',
      '/clinicians': 'System Users',
      '/system-logs': 'System Logs',
      '/audit-export': 'Audit Export',
      '/reports': 'Reports',
    };
    return titles[_currentRoute] ?? 'Admin Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: UserRole.admin,
      userName: 'Admin User',
      currentRoute: _currentRoute,
      pageTitle: _pageTitle,
      onNavigate: _navigate,
      body: _buildPage(),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: const [
              KpiCard(
                title: 'Total Clinicians',
                value: '1,240',
                icon: Icons.people_alt_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.infoBg,
                subtitle: '+12 this month',
              ),
              KpiCard(
                title: 'Active Clinicians',
                value: '1,108',
                icon: Icons.verified_user_rounded,
                iconColor: AppColors.successText,
                iconBg: AppColors.successBg,
                subtitle: '89.4% active rate',
              ),
              KpiCard(
                title: 'Total Mothers',
                value: '48,320',
                icon: Icons.pregnant_woman_rounded,
                iconColor: AppColors.tertiary,
                iconBg: Color(0xFFE0F2F1),
                subtitle: '+340 this week',
              ),
              KpiCard(
                title: 'High-Risk Cases',
                value: '2,841',
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.criticalText,
                iconBg: AppColors.criticalBg,
                subtitle: '5.9% of total',
              ),
              KpiCard(
                title: 'IVR Usage',
                value: '9,102',
                icon: Icons.phone_in_talk_rounded,
                iconColor: AppColors.warningText,
                iconBg: AppColors.warningBg,
                subtitle: 'Calls this month',
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Charts row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ChartCard(
                  title: 'Monthly Registrations',
                  subtitle: 'Mothers registered over the last 6 months',
                  chart: SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
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
                              getTitlesWidget: (val, meta) {
                                const months = [
                                  'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'
                                ];
                                final idx = val.toInt();
                                if (idx < 0 || idx >= months.length) {
                                  return const SizedBox();
                                }
                                return Text(months[idx],
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
                              FlSpot(0, 6200),
                              FlSpot(1, 7100),
                              FlSpot(2, 6800),
                              FlSpot(3, 7800),
                              FlSpot(4, 8200),
                              FlSpot(5, 9100),
                            ],
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: ChartCard(
                  title: 'Risk Distribution',
                  subtitle: 'Current case breakdown',
                  chart: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 48,
                        sections: [
                          PieChartSectionData(
                            value: 60,
                            color: AppColors.successText,
                            title: 'Low\n60%',
                            titleStyle: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                            radius: 55,
                          ),
                          PieChartSectionData(
                            value: 25,
                            color: AppColors.warningText,
                            title: 'Med\n25%',
                            titleStyle: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                            radius: 55,
                          ),
                          PieChartSectionData(
                            value: 15,
                            color: AppColors.criticalText,
                            title: 'High\n15%',
                            titleStyle: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                            radius: 55,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Alerts + Activity Feed
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alerts
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
                      Text('System Alerts',
                          style: GoogleFonts.publicSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.headings)),
                      const SizedBox(height: 16),
                      _AlertTile(
                        icon: Icons.person_off_rounded,
                        color: AppColors.warningText,
                        bg: AppColors.warningBg,
                        title: '132 Inactive Clinicians',
                        subtitle: 'No activity in 30+ days',
                        badge: BadgeType.warning,
                      ),
                      const SizedBox(height: 12),
                      _AlertTile(
                        icon: Icons.trending_up_rounded,
                        color: AppColors.criticalText,
                        bg: AppColors.criticalBg,
                        title: 'High-Risk Spike — Blantyre',
                        subtitle: '+18% increase this week',
                        badge: BadgeType.critical,
                      ),
                      const SizedBox(height: 12),
                      _AlertTile(
                        icon: Icons.phone_missed_rounded,
                        color: AppColors.infoText,
                        bg: AppColors.infoBg,
                        title: 'IVR Drop-off Rate Up',
                        subtitle: '34% calls abandoned',
                        badge: BadgeType.info,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Activity Feed
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
                      Text('Recent Activity',
                          style: GoogleFonts.publicSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.headings)),
                      const SizedBox(height: 16),
                      ..._activities.map((a) => _ActivityTile(
                            action: a['action']!,
                            user: a['user']!,
                            time: a['time']!,
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

const _activities = [
  {'action': 'New clinician registered', 'user': 'Dr. Banda', 'time': '2m ago'},
  {'action': 'High-risk case flagged', 'user': 'System', 'time': '14m ago'},
  {'action': 'Report generated', 'user': 'Admin', 'time': '1h ago'},
  {'action': 'Clinician deactivated', 'user': 'Admin', 'time': '2h ago'},
  {'action': 'IVR rule updated', 'user': 'Admin', 'time': '3h ago'},
];

class _AlertTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String subtitle;
  final BadgeType badge;

  const _AlertTile({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface)),
              Text(subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.mutedText)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String action;
  final String user;
  final String time;

  const _ActivityTile(
      {required this.action, required this.user, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.onSurface),
                children: [
                  TextSpan(text: action),
                  TextSpan(
                      text: ' · $user',
                      style: const TextStyle(color: AppColors.mutedText)),
                ],
              ),
            ),
          ),
          Text(time,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.mutedText)),
        ],
      ),
    );
  }
}
