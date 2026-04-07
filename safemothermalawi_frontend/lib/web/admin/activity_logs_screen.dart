import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';

/// Combined Activity Logs screen — System Logs + Task Analytics as tabs
class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen>
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
          Text('Activity Logs',
              style: GoogleFonts.publicSans(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 4),
          Text('System audit trail and clinician task performance',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 20),

          // Tab bar
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
                Tab(icon: Icon(Icons.receipt_long_rounded, size: 18), text: 'System Logs'),
                Tab(icon: Icon(Icons.task_alt_rounded, size: 18), text: 'Task Analytics'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tab content fills remaining space
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [
                _SystemLogsTab(),
                _TaskAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── System Logs Tab ───────────────────────────────────────────────────────────

class _SystemLogsTab extends StatefulWidget {
  const _SystemLogsTab();

  @override
  State<_SystemLogsTab> createState() => _SystemLogsTabState();
}

class _SystemLogsTabState extends State<_SystemLogsTab> {
  final _searchCtrl = TextEditingController();
  String _eventFilter = 'All';
  String _roleFilter = 'All';
  int _page = 0;
  static const int _perPage = 10;

  final List<Map<String, String>> _logs = [
    {'time': '2026-03-26 08:12:04', 'event': 'LOGIN', 'user': 'admin@moh.gov.mw', 'role': 'Admin', 'ip': '192.168.1.10', 'status': 'Success'},
    {'time': '2026-03-26 08:45:22', 'event': 'CREATE_CLINICIAN', 'user': 'admin@moh.gov.mw', 'role': 'Admin', 'ip': '192.168.1.10', 'status': 'Success'},
    {'time': '2026-03-26 09:10:11', 'event': 'DEACTIVATE_USER', 'user': 'admin@moh.gov.mw', 'role': 'Admin', 'ip': '192.168.1.10', 'status': 'Success'},
    {'time': '2026-03-26 09:30:55', 'event': 'EXPORT_REPORT', 'user': 'dho.blantyre@moh.gov.mw', 'role': 'DHO', 'ip': '10.0.0.5', 'status': 'Success'},
    {'time': '2026-03-26 10:02:33', 'event': 'VIEW_ANALYTICS', 'user': 'dho.lilongwe@moh.gov.mw', 'role': 'DHO', 'ip': '10.0.0.8', 'status': 'Success'},
    {'time': '2026-03-26 10:45:18', 'event': 'LOGIN_FAILED', 'user': 'unknown@test.com', 'role': 'Unknown', 'ip': '203.0.113.5', 'status': 'Failed'},
    {'time': '2026-03-26 11:00:02', 'event': 'GENERATE_ANALYTICS', 'user': 'admin@moh.gov.mw', 'role': 'Admin', 'ip': '192.168.1.10', 'status': 'Success'},
    {'time': '2026-03-26 11:30:44', 'event': 'UPDATE_RULE', 'user': 'admin@moh.gov.mw', 'role': 'Admin', 'ip': '192.168.1.10', 'status': 'Success'},
    {'time': '2026-03-26 12:05:09', 'event': 'DELETE_CLINICIAN', 'user': 'admin@moh.gov.mw', 'role': 'Admin', 'ip': '192.168.1.10', 'status': 'Success'},
    {'time': '2026-03-26 12:40:31', 'event': 'LOGIN', 'user': 'dho.mzuzu@moh.gov.mw', 'role': 'DHO', 'ip': '10.0.0.12', 'status': 'Success'},
    {'time': '2026-03-26 13:10:22', 'event': 'VIEW_HEATMAP', 'user': 'dho.mzuzu@moh.gov.mw', 'role': 'DHO', 'ip': '10.0.0.12', 'status': 'Success'},
    {'time': '2026-03-26 14:00:00', 'event': 'EXPORT_REPORT', 'user': 'admin@moh.gov.mw', 'role': 'Admin', 'ip': '192.168.1.10', 'status': 'Success'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filtered => _logs.where((l) {
        final matchSearch = _searchCtrl.text.isEmpty ||
            l.values.any((v) => v.toLowerCase().contains(_searchCtrl.text.toLowerCase()));
        final matchEvent = _eventFilter == 'All' || l['event'] == _eventFilter;
        final matchRole = _roleFilter == 'All' || l['role'] == _roleFilter;
        return matchSearch && matchEvent && matchRole;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final totalPages = (filtered.length / _perPage).ceil().clamp(1, 999);
    final pageData = filtered.skip(_page * _perPage).take(_perPage).toList();

    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() => _page = 0),
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.mutedText),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _Drop(label: 'Event', value: _eventFilter,
                  items: const ['All', 'LOGIN', 'LOGIN_FAILED', 'CREATE_CLINICIAN', 'DEACTIVATE_USER', 'EXPORT_REPORT', 'GENERATE_ANALYTICS', 'UPDATE_RULE', 'DELETE_CLINICIAN', 'VIEW_ANALYTICS', 'VIEW_HEATMAP'],
                  onChanged: (v) => setState(() { _eventFilter = v!; _page = 0; })),
              const SizedBox(width: 12),
              _Drop(label: 'Role', value: _roleFilter,
                  items: const ['All', 'Admin', 'DHO', 'Unknown'],
                  onChanged: (v) => setState(() { _roleFilter = v!; _page = 0; })),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 16, color: AppColors.primary),
                label: Text('Export', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Table fills remaining space
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  // Header
                  Container(
                    color: AppColors.pageBg,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        _headerCell('#', 1), _headerCell('Timestamp', 3), _headerCell('Event', 3),
                        _headerCell('User', 4), _headerCell('Role', 2), _headerCell('IP Address', 3), _headerCell('Status', 2),
                      ],
                    ),
                  ),
                  // Rows
                  Expanded(
                    child: ListView.builder(
                      itemCount: pageData.length,
                      itemBuilder: (context, i) {
                        final log = pageData[i];
                        final idx = _page * _perPage + i + 1;
                        return Container(
                          color: i.isEven ? AppColors.surfaceContainerLowest : AppColors.pageBg.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(flex: 1, child: _c('$idx', muted: true)),
                              Expanded(flex: 3, child: _c(log['time']!)),
                              Expanded(flex: 3, child: _c(log['event']!, bold: true)),
                              Expanded(flex: 4, child: _c(log['user']!)),
                              Expanded(flex: 2, child: _c(log['role']!)),
                              Expanded(flex: 3, child: _c(log['ip']!, muted: true)),
                              Expanded(flex: 2, child: StatusBadge(
                                label: log['status']!,
                                type: log['status'] == 'Success' ? BadgeType.success : BadgeType.critical,
                              )),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Pagination
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    color: AppColors.pageBg,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${filtered.length} records', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _page > 0 ? () => setState(() => _page--) : null,
                          icon: const Icon(Icons.chevron_left_rounded), color: AppColors.primary,
                        ),
                        Text('${_page + 1} / $totalPages', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)),
                        IconButton(
                          onPressed: _page < totalPages - 1 ? () => setState(() => _page++) : null,
                          icon: const Icon(Icons.chevron_right_rounded), color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Task Analytics Tab ────────────────────────────────────────────────────────

class _TaskAnalyticsTab extends StatelessWidget {
  const _TaskAnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: const [
              KpiCard(title: 'Total Tasks', value: '18,420', icon: Icons.task_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'Completed', value: '14,441', icon: Icons.task_alt_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg, subtitle: '78.4% rate'),
              KpiCard(title: 'Missed Tasks', value: '2,210', icon: Icons.cancel_outlined, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg, subtitle: '12.0% rate'),
              KpiCard(title: 'Pending', value: '1,769', icon: Icons.pending_actions_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg, subtitle: '9.6% rate'),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              // Completion trend
              Expanded(
                flex: 2,
                child: ChartCard(
                  title: 'Task Completion Trend',
                  subtitle: 'Monthly completion vs missed rate over 6 months',
                  chart: SizedBox(
                    height: 200,
                    child: LineChart(LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const m = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
                              final i = v.toInt();
                              if (i < 0 || i >= m.length) return const SizedBox();
                              return Text(m[i], style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText));
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [FlSpot(0, 72), FlSpot(1, 74), FlSpot(2, 71), FlSpot(3, 76), FlSpot(4, 78), FlSpot(5, 78)],
                          isCurved: true, color: AppColors.successText, barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: AppColors.successText.withValues(alpha: 0.08)),
                        ),
                        LineChartBarData(
                          spots: const [FlSpot(0, 14), FlSpot(1, 13), FlSpot(2, 15), FlSpot(3, 12), FlSpot(4, 12), FlSpot(5, 12)],
                          isCurved: true, color: AppColors.criticalText, barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: AppColors.criticalText.withValues(alpha: 0.06)),
                        ),
                      ],
                    )),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Task type pie
              Expanded(
                child: ChartCard(
                  title: 'Task Types',
                  subtitle: 'Breakdown by category',
                  chart: SizedBox(
                    height: 200,
                    child: PieChart(PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(value: 35, color: AppColors.primary, title: 'ANC\n35%', titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 50),
                        PieChartSectionData(value: 28, color: AppColors.accent, title: 'PNC\n28%', titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 50),
                        PieChartSectionData(value: 22, color: AppColors.warningText, title: 'Vacc\n22%', titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 50),
                        PieChartSectionData(value: 15, color: AppColors.secondary, title: 'Risk\n15%', titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 50),
                      ],
                    )),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Missed tasks table
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
                Text('Missed Tasks — Risk Correlation',
                    style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                const SizedBox(height: 16),
                // Table header
                Row(
                  children: [
                    _headerCell('Task', 3), _headerCell('Clinician', 2), _headerCell('District', 2), _headerCell('Risk', 2), _headerCell('Overdue', 2),
                  ],
                ),
                const SizedBox(height: 8),
                ...[
                  {'task': 'ANC Visit Reminder', 'clinician': 'Dr. Phiri', 'district': 'Lilongwe', 'risk': 'High', 'days': '3 days'},
                  {'task': 'Postnatal Check', 'clinician': 'Dr. Mwale', 'district': 'Mzuzu', 'risk': 'Medium', 'days': '5 days'},
                  {'task': 'Vaccination Follow-up', 'clinician': 'Dr. Tembo', 'district': 'Mangochi', 'risk': 'Low', 'days': '1 day'},
                  {'task': 'Risk Assessment', 'clinician': 'Dr. Chirwa', 'district': 'Zomba', 'risk': 'High', 'days': '7 days'},
                  {'task': 'ANC Visit Reminder', 'clinician': 'Dr. Banda', 'district': 'Blantyre', 'risk': 'High', 'days': '2 days'},
                ].map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Row(children: [
                            const Icon(Icons.cancel_outlined, size: 14, color: AppColors.criticalText),
                            const SizedBox(width: 8),
                            Expanded(child: _c(t['task']!, bold: true)),
                          ])),
                          Expanded(flex: 2, child: _c(t['clinician']!)),
                          Expanded(flex: 2, child: _c(t['district']!)),
                          Expanded(flex: 2, child: StatusBadge(
                            label: t['risk']!,
                            type: t['risk'] == 'High' ? BadgeType.critical : t['risk'] == 'Medium' ? BadgeType.warning : BadgeType.success,
                          )),
                          Expanded(flex: 2, child: _c(t['days']!, muted: true)),
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

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _headerCell(String label, int flex) => Expanded(
      flex: flex,
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.mutedText, letterSpacing: 0.5)),
    );

Widget _c(String text, {bool bold = false, bool muted = false}) => Text(text,
    style: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
      color: muted ? AppColors.mutedText : AppColors.onSurface,
    ));

class _Drop extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _Drop({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
