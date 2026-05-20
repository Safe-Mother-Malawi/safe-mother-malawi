import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
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
              style: TextStyle(fontFamily: 'Public Sans', 
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 4),
          Text('System audit trail and clinician task performance',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
            ),
            child: TabBar(
              controller: _tab,
              labelStyle: TextStyle(fontFamily: 'Roboto', fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontFamily: 'Roboto', fontSize: 14),
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

  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getActivityLogs(limit: 200);
      setState(() {
        _logs = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered => _logs.where((l) {
        final matchSearch = _searchCtrl.text.isEmpty ||
            l.values.any((v) => v.toString().toLowerCase().contains(_searchCtrl.text.toLowerCase()));
        final event = (l['action'] ?? l['event'] ?? '').toString();
        final role = (l['user']?['role'] ?? l['role'] ?? '').toString();
        final matchEvent = _eventFilter == 'All' || event == _eventFilter;
        final matchRole = _roleFilter == 'All' || role == _roleFilter;
        return matchSearch && matchEvent && matchRole;
      }).toList();

  Set<String> get _eventOptions {
    final events = _logs.map((l) => (l['action'] ?? l['event'] ?? '').toString()).toSet();
    return {'All', ...events};
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: AppColors.criticalText, size: 40),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(fontFamily: 'Roboto', color: AppColors.criticalText)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]));
    }

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
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    hintStyle: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.mutedText),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _Drop(
                label: 'Event',
                value: _eventFilter,
                items: _eventOptions.toList(),
                onChanged: (v) => setState(() { _eventFilter = v!; _page = 0; }),
              ),
              const SizedBox(width: 12),
              _Drop(
                label: 'Role',
                value: _roleFilter,
                items: const ['All', 'admin', 'dho', 'clinician'],
                onChanged: (v) => setState(() { _roleFilter = v!; _page = 0; }),
              ),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 16),

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
                  Container(
                    color: AppColors.pageBg,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        _headerCell('#', 1), _headerCell('Timestamp', 3), _headerCell('Event', 3),
                        _headerCell('User', 4), _headerCell('Role', 2), _headerCell('Status', 2),
                      ],
                    ),
                  ),
                  Expanded(
                    child: pageData.isEmpty
                        ? Center(child: Text('No logs found', style: TextStyle(fontFamily: 'Roboto', color: AppColors.mutedText)))
                        : ListView.builder(
                            itemCount: pageData.length,
                            itemBuilder: (context, i) {
                              final log = pageData[i];
                              final idx = _page * _perPage + i + 1;
                              final event = (log['action'] ?? log['event'] ?? '—').toString();
                              final user = (log['user']?['email'] ?? log['user'] ?? '—').toString();
                              final role = (log['user']?['role'] ?? log['role'] ?? '—').toString();
                              final status = (log['status'] ?? 'Success').toString();
                              final time = (log['createdAt'] ?? log['timestamp'] ?? '—').toString();
                              return Container(
                                color: i.isEven ? AppColors.surfaceContainerLowest : AppColors.pageBg.withOpacity(0.4),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(flex: 1, child: _c('$idx', muted: true)),
                                    Expanded(flex: 3, child: _c(time)),
                                    Expanded(flex: 3, child: _c(event, bold: true)),
                                    Expanded(flex: 4, child: _c(user)),
                                    Expanded(flex: 2, child: _c(role)),
                                    Expanded(flex: 2, child: StatusBadge(
                                      label: status,
                                      type: status == 'Success' ? BadgeType.success : BadgeType.critical,
                                    )),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    color: AppColors.pageBg,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${filtered.length} records', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.mutedText)),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _page > 0 ? () => setState(() => _page--) : null,
                          icon: const Icon(Icons.chevron_left_rounded), color: AppColors.primary,
                        ),
                        Text('${_page + 1} / $totalPages', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface)),
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

class _TaskAnalyticsTab extends StatefulWidget {
  const _TaskAnalyticsTab();
  @override
  State<_TaskAnalyticsTab> createState() => _TaskAnalyticsTabState();
}

class _TaskAnalyticsTabState extends State<_TaskAnalyticsTab> {
  Map<String, dynamic> _data = {};
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
      final data = await ApiService.getTaskAnalytics();
      setState(() { _data = data; _loading = false; });
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
        Text(_error!, style: TextStyle(fontFamily: 'Roboto', color: AppColors.criticalText)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]));
    }

    final total     = (_data['total'] ?? _data['totalTasks'] ?? 0).toString();
    final completed = (_data['completed'] ?? _data['completedTasks'] ?? 0).toString();
    final missed    = (_data['missed'] ?? _data['missedTasks'] ?? 0).toString();
    final pending   = (_data['pending'] ?? _data['pendingTasks'] ?? 0).toString();

    final completionRate = _data['completionRate'] ?? _data['completionRatePercent'] ?? '—';
    final missedRate     = _data['missedRate'] ?? _data['missedRatePercent'] ?? '—';
    final pendingRate    = _data['pendingRate'] ?? _data['pendingRatePercent'] ?? '—';

    final missedList = (_data['missedTasksList'] ?? _data['recentMissed'] ?? []) as List;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              KpiCard(title: 'Total Tasks', value: total, icon: Icons.task_rounded, iconColor: AppColors.primary, iconBg: AppColors.infoBg),
              KpiCard(title: 'Completed', value: completed, icon: Icons.task_alt_rounded, iconColor: AppColors.successText, iconBg: AppColors.successBg, subtitle: '$completionRate%'),
              KpiCard(title: 'Missed Tasks', value: missed, icon: Icons.cancel_outlined, iconColor: AppColors.criticalText, iconBg: AppColors.criticalBg, subtitle: '$missedRate%'),
              KpiCard(title: 'Pending', value: pending, icon: Icons.pending_actions_rounded, iconColor: AppColors.warningText, iconBg: AppColors.warningBg, subtitle: '$pendingRate%'),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: ChartCard(
                  title: 'Task Completion Trend',
                  subtitle: 'Monthly completion vs missed rate',
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
                              return Text(m[i], style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: AppColors.mutedText));
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _buildTrendSpots(_data['completionTrend']),
                          isCurved: true, color: AppColors.successText, barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: AppColors.successText.withOpacity(0.08)),
                        ),
                        LineChartBarData(
                          spots: _buildTrendSpots(_data['missedTrend']),
                          isCurved: true, color: AppColors.criticalText, barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: AppColors.criticalText.withOpacity(0.06)),
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
                  subtitle: 'Breakdown by category',
                  chart: SizedBox(
                    height: 200,
                    child: PieChart(PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      sections: _buildPieSections(_data['taskTypes']),
                    )),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (missedList.isNotEmpty)
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
                      style: TextStyle(fontFamily: 'Public Sans', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                  const SizedBox(height: 16),
                  Row(children: [
                    _headerCell('Task', 3), _headerCell('Clinician', 2),
                    _headerCell('District', 2), _headerCell('Risk', 2), _headerCell('Overdue', 2),
                  ]),
                  const SizedBox(height: 8),
                  ...missedList.map((t) {
                    final task = t as Map<String, dynamic>;
                    final risk = (task['riskLevel'] ?? task['risk'] ?? 'Low').toString();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Row(children: [
                            const Icon(Icons.cancel_outlined, size: 14, color: AppColors.criticalText),
                            const SizedBox(width: 8),
                            Expanded(child: _c((task['title'] ?? task['task'] ?? '—').toString(), bold: true)),
                          ])),
                          Expanded(flex: 2, child: _c((task['clinician']?['fullName'] ?? task['clinician'] ?? '—').toString())),
                          Expanded(flex: 2, child: _c((task['district'] ?? '—').toString())),
                          Expanded(flex: 2, child: StatusBadge(
                            label: risk,
                            type: risk == 'High' ? BadgeType.critical : risk == 'Medium' ? BadgeType.warning : BadgeType.success,
                          )),
                          Expanded(flex: 2, child: _c((task['overdueDays'] != null ? '${task['overdueDays']} days' : '—'), muted: true)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<FlSpot> _buildTrendSpots(dynamic trend) {
    if (trend is List && trend.isNotEmpty) {
      return trend.asMap().entries.map((e) {
        final val = (e.value is num) ? (e.value as num).toDouble() : 0.0;
        return FlSpot(e.key.toDouble(), val);
      }).toList();
    }
    return const [FlSpot(0, 70), FlSpot(1, 72), FlSpot(2, 74), FlSpot(3, 76), FlSpot(4, 77), FlSpot(5, 78)];
  }

  List<PieChartSectionData> _buildPieSections(dynamic types) {
    final colors = [AppColors.primary, AppColors.accent, AppColors.warningText, AppColors.secondary];
    if (types is Map) {
      final entries = types.entries.toList();
      return entries.asMap().entries.map((e) {
        final color = colors[e.key % colors.length];
        final label = e.value.key.toString();
        final val = (e.value.value as num).toDouble();
        return PieChartSectionData(
          value: val, color: color,
          title: '$label\n${val.toStringAsFixed(0)}%',
          titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
          radius: 50,
        );
      }).toList();
    }
    return [
      PieChartSectionData(value: 35, color: AppColors.primary, title: 'ANC\n35%', titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 50),
      PieChartSectionData(value: 28, color: AppColors.accent, title: 'PNC\n28%', titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 50),
      PieChartSectionData(value: 22, color: AppColors.warningText, title: 'Vacc\n22%', titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 50),
      PieChartSectionData(value: 15, color: AppColors.secondary, title: 'Risk\n15%', titleStyle: TextStyle(fontFamily: 'Roboto', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white), radius: 50),
    ];
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _headerCell(String label, int flex) => Expanded(
      flex: flex,
      child: Text(label,
          style: TextStyle(fontFamily: 'Roboto', 
              fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.mutedText, letterSpacing: 0.5)),
    );

Widget _c(String text, {bool bold = false, bool muted = false}) => Text(text,
    style: TextStyle(fontFamily: 'Roboto', 
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
        Text('$label: ', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.mutedText)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              onChanged: onChanged,
              style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

