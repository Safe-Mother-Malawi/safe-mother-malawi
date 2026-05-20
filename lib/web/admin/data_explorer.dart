import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../../services/auth_service_web.dart';
import '../shared/widgets/status_badge.dart';

class DataExplorer extends StatefulWidget {
  const DataExplorer({super.key});

  @override
  State<DataExplorer> createState() => _DataExplorerState();
}

class _DataExplorerState extends State<DataExplorer>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final isAdmin = AuthServiceWeb.instance.userRole.toLowerCase() == 'admin';
    _tabCtrl = TabController(length: isAdmin ? 4 : 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data Source',
              style: GoogleFonts.publicSans(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 4),
          Text('Direct access to system data tables',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 20),

          // Filters bar
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
                  width: 260,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search records...',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.mutedText),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tabs + table
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
                      color: AppColors.surfaceContainerLowest,
                      child: TabBar(
                        controller: _tabCtrl,
                        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.mutedText,
                        indicatorColor: AppColors.primary,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          if (AuthServiceWeb.instance.userRole.toLowerCase() == 'admin')
                            const Tab(text: 'System Logs'),
                          const Tab(text: 'IVR Interactions'),
                          const Tab(text: 'Question Responses'),
                          const Tab(text: 'Task Data'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          if (AuthServiceWeb.instance.userRole.toLowerCase() == 'admin')
                            _SystemLogsTab(search: _searchCtrl.text),
                          _IvrTab(search: _searchCtrl.text),
                          _QuestionTab(search: _searchCtrl.text),
                          _TaskTab(search: _searchCtrl.text),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared table widget ──────────────────────────────────────────────────────

class _FullTable extends StatelessWidget {
  final List<String> columns;
  final List<int> flexes;
  final List<List<Widget>> rows;
  final bool loading;
  final String? error;
  final VoidCallback? onRetry;

  const _FullTable({
    required this.columns,
    required this.flexes,
    required this.rows,
    this.loading = false,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.pageBg,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              for (int i = 0; i < columns.length; i++)
                Expanded(
                  flex: flexes[i],
                  child: Text(columns[i],
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedText,
                          letterSpacing: 0.5)),
                ),
            ],
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.error_outline, color: AppColors.criticalText, size: 36),
                        const SizedBox(height: 8),
                        Text(error!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.criticalText)),
                        if (onRetry != null) ...[
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
                        ],
                      ]),
                    )
                  : rows.isEmpty
                      ? Center(
                          child: Text('No records found',
                              style: GoogleFonts.inter(fontSize: 14, color: AppColors.mutedText)))
                      : ListView.builder(
                          itemCount: rows.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: index.isEven
                                  ? AppColors.surfaceContainerLowest
                                  : AppColors.pageBg.withValues(alpha: 0.4),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                              child: Row(
                                children: [
                                  for (int i = 0; i < rows[index].length; i++)
                                    Expanded(flex: flexes[i], child: rows[index][i]),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

// ── System Logs Tab ──────────────────────────────────────────────────────────

class _SystemLogsTab extends StatefulWidget {
  final String search;
  const _SystemLogsTab({required this.search});
  @override
  State<_SystemLogsTab> createState() => _SystemLogsTabState();
}

class _SystemLogsTabState extends State<_SystemLogsTab> {
  List<dynamic> _data = [];
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
      final data = await ApiService.getActivityLogs(limit: 100);
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _data.where((r) {
      if (widget.search.isEmpty) return true;
      final s = widget.search.toLowerCase();
      return r.toString().toLowerCase().contains(s);
    }).toList();

    return _FullTable(
      loading: _loading,
      error: _error,
      onRetry: _load,
      columns: const ['#', 'Timestamp', 'Event', 'User', 'IP Address', 'Status'],
      flexes: const [1, 3, 3, 4, 3, 2],
      rows: filtered.asMap().entries.map((e) {
        final r = e.value as Map<String, dynamic>;
        final status = (r['status'] ?? 'Success').toString();
        return [
          _cell('${e.key + 1}', muted: true),
          _cell((r['createdAt'] ?? r['timestamp'] ?? '—').toString()),
          _cell((r['action'] ?? r['event'] ?? '—').toString(), bold: true),
          _cell((r['user']?['email'] ?? r['user'] ?? '—').toString()),
          _cell((r['ipAddress'] ?? r['ip'] ?? '—').toString(), muted: true),
          StatusBadge(
            label: status,
            type: status == 'Success' ? BadgeType.success : BadgeType.critical,
          ),
        ];
      }).toList(),
    );
  }
}

// ── IVR Tab ──────────────────────────────────────────────────────────────────

class _IvrTab extends StatefulWidget {
  final String search;
  const _IvrTab({required this.search});
  @override
  State<_IvrTab> createState() => _IvrTabState();
}

class _IvrTabState extends State<_IvrTab> {
  List<dynamic> _data = [];
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
      final data = await ApiService.getRiskAssessments(limit: 100);
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _data.where((r) {
      if (widget.search.isEmpty) return true;
      return r.toString().toLowerCase().contains(widget.search.toLowerCase());
    }).toList();

    return _FullTable(
      loading: _loading,
      error: _error,
      onRetry: _load,
      columns: const ['#', 'Time', 'Caller', 'Topic', 'Duration', 'Status'],
      flexes: const [1, 3, 3, 3, 2, 2],
      rows: filtered.asMap().entries.map((e) {
        final r = e.value as Map<String, dynamic>;
        final status = (r['status'] ?? r['callStatus'] ?? 'Completed').toString();
        final duration = r['duration'] != null ? '${r['duration']}s' : '—';
        return [
          _cell('${e.key + 1}', muted: true),
          _cell((r['createdAt'] ?? r['startTime'] ?? '—').toString()),
          _cell((r['callerPhone'] ?? r['caller'] ?? '—').toString()),
          _cell((r['topic'] ?? r['category'] ?? '—').toString(), bold: true),
          _cell(duration),
          StatusBadge(
            label: status,
            type: status == 'Completed' ? BadgeType.success : BadgeType.warning,
          ),
        ];
      }).toList(),
    );
  }
}

// ── Question Responses Tab ───────────────────────────────────────────────────

class _QuestionTab extends StatefulWidget {
  final String search;
  const _QuestionTab({required this.search});
  @override
  State<_QuestionTab> createState() => _QuestionTabState();
}

class _QuestionTabState extends State<_QuestionTab> {
  List<dynamic> _data = [];
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
      final data = await ApiService.getRiskAssessments(limit: 100);
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _data.where((r) {
      if (widget.search.isEmpty) return true;
      return r.toString().toLowerCase().contains(widget.search.toLowerCase());
    }).toList();

    return _FullTable(
      loading: _loading,
      error: _error,
      onRetry: _load,
      columns: const ['#', 'Time', 'Category', 'Top Symptom', 'Risk', 'Score'],
      flexes: const [1, 3, 3, 4, 2, 2],
      rows: filtered.asMap().entries.map((e) {
        final r = e.value as Map<String, dynamic>;
        final risk = (r['riskLevel'] ?? r['risk'] ?? 'Low').toString();
        final category = (r['patientType'] ?? r['category'] ?? '—').toString();
        final symptom = (r['topSymptom'] ?? r['primarySymptom'] ?? '—').toString();
        final score = (r['score'] ?? r['riskScore'] ?? '—').toString();
        return [
          _cell('${e.key + 1}', muted: true),
          _cell((r['createdAt'] ?? '—').toString()),
          _cell(category),
          _cell(symptom, bold: true),
          StatusBadge(
            label: risk,
            type: risk == 'High' ? BadgeType.critical
                : risk == 'Medium' ? BadgeType.warning
                : BadgeType.success,
          ),
          _cell(score),
        ];
      }).toList(),
    );
  }
}

// ── Task Data Tab ────────────────────────────────────────────────────────────

class _TaskTab extends StatefulWidget {
  final String search;
  const _TaskTab({required this.search});
  @override
  State<_TaskTab> createState() => _TaskTabState();
}

class _TaskTabState extends State<_TaskTab> {
  List<dynamic> _data = [];
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
      final data = await ApiService.getAppointments();
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _data.where((r) {
      if (widget.search.isEmpty) return true;
      return r.toString().toLowerCase().contains(widget.search.toLowerCase());
    }).toList();

    return _FullTable(
      loading: _loading,
      error: _error,
      onRetry: _load,
      columns: const ['#', 'Task', 'Assigned To', 'District', 'Status', 'Due Date'],
      flexes: const [1, 4, 3, 3, 2, 3],
      rows: filtered.asMap().entries.map((e) {
        final r = e.value as Map<String, dynamic>;
        final status = (r['status'] ?? 'Pending').toString();
        final assignee = r['clinician']?['fullName'] ?? r['assignedTo'] ?? '—';
        final district = r['clinician']?['district'] ?? r['district'] ?? '—';
        return [
          _cell('${e.key + 1}', muted: true),
          _cell((r['title'] ?? r['type'] ?? '—').toString(), bold: true),
          _cell(assignee.toString()),
          _cell(district.toString()),
          StatusBadge(
            label: status,
            type: status == 'Completed' ? BadgeType.success
                : status == 'Missed' ? BadgeType.critical
                : BadgeType.warning,
          ),
          _cell((r['scheduledDate'] ?? r['dueDate'] ?? '—').toString()),
        ];
      }).toList(),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _cell(String text, {bool bold = false, bool muted = false}) {
  return Text(text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
        color: muted ? AppColors.mutedText : AppColors.onSurface,
      ));
}
