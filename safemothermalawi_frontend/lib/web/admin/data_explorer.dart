import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
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
  String _dateFilter = 'Last 30 days';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
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
          // Header
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
                const SizedBox(width: 16),
                _DropFilter(
                  value: _dateFilter,
                  items: const ['Today', 'Last 7 days', 'Last 30 days', 'Last 3 months', 'All time'],
                  onChanged: (v) => setState(() => _dateFilter = v!),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 16, color: AppColors.primary),
                  label: Text('Export CSV',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tabs + table — fills remaining space
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
                    // Tab bar
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
                        tabs: const [
                          Tab(text: 'System Logs'),
                          Tab(text: 'IVR Interactions'),
                          Tab(text: 'Question Responses'),
                          Tab(text: 'Task Data'),
                        ],
                      ),
                    ),
                    // Tab content fills rest
                    Expanded(
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
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

  const _FullTable({
    required this.columns,
    required this.flexes,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
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
        // Rows
        Expanded(
          child: rows.isEmpty
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

// ── Tab content ──────────────────────────────────────────────────────────────

class _SystemLogsTab extends StatelessWidget {
  final String search;
  const _SystemLogsTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final data = [
      ['2026-03-26 08:12', 'LOGIN', 'Admin', '192.168.1.10', 'Success'],
      ['2026-03-26 08:45', 'CREATE_CLINICIAN', 'Admin', '192.168.1.10', 'Success'],
      ['2026-03-26 09:10', 'DEACTIVATE_USER', 'Admin', '192.168.1.10', 'Success'],
      ['2026-03-26 10:02', 'EXPORT_REPORT', 'DHO Blantyre', '10.0.0.5', 'Success'],
      ['2026-03-26 10:45', 'LOGIN_FAILED', 'Unknown', '203.0.113.5', 'Failed'],
      ['2026-03-26 11:00', 'GENERATE_ANALYTICS', 'Admin', '192.168.1.10', 'Success'],
      ['2026-03-26 11:30', 'UPDATE_RULE', 'Admin', '192.168.1.10', 'Success'],
      ['2026-03-26 12:05', 'DELETE_CLINICIAN', 'Admin', '192.168.1.10', 'Success'],
      ['2026-03-26 12:40', 'LOGIN', 'DHO Mzuzu', '10.0.0.12', 'Success'],
      ['2026-03-26 13:10', 'VIEW_HEATMAP', 'DHO Mzuzu', '10.0.0.12', 'Success'],
    ].where((r) => search.isEmpty || r.any((c) => c.toLowerCase().contains(search.toLowerCase()))).toList();

    return _FullTable(
      columns: const ['#', 'Timestamp', 'Event', 'User', 'IP Address', 'Status'],
      flexes: const [1, 3, 3, 2, 3, 2],
      rows: data.asMap().entries.map((e) => [
        _cell('${e.key + 1}', muted: true),
        _cell(e.value[0]),
        _cell(e.value[1], bold: true),
        _cell(e.value[2]),
        _cell(e.value[3], muted: true),
        StatusBadge(label: e.value[4], type: e.value[4] == 'Success' ? BadgeType.success : BadgeType.critical),
      ]).toList(),
    );
  }
}

class _IvrTab extends StatelessWidget {
  final String search;
  const _IvrTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final data = [
      ['2026-03-26 07:00', '+265 999 111 222', 'Baby Issues', '3m 12s', 'Completed'],
      ['2026-03-26 07:45', '+265 888 333 444', 'Mother Issues', '1m 05s', 'Dropped'],
      ['2026-03-26 08:20', '+265 777 555 666', 'Immunization', '5m 40s', 'Completed'],
      ['2026-03-26 09:00', '+265 666 777 888', 'Feeding Guidance', '2m 18s', 'Completed'],
      ['2026-03-26 09:30', '+265 555 888 999', 'Baby Issues', '4m 02s', 'Completed'],
      ['2026-03-26 10:10', '+265 444 222 111', 'Mother Issues', '0m 45s', 'Dropped'],
      ['2026-03-26 10:55', '+265 333 111 000', 'Immunization', '6m 10s', 'Completed'],
      ['2026-03-26 11:20', '+265 222 000 333', 'Feeding Guidance', '3m 55s', 'Completed'],
    ].where((r) => search.isEmpty || r.any((c) => c.toLowerCase().contains(search.toLowerCase()))).toList();

    return _FullTable(
      columns: const ['#', 'Time', 'Caller', 'Topic', 'Duration', 'Status'],
      flexes: const [1, 3, 3, 3, 2, 2],
      rows: data.asMap().entries.map((e) => [
        _cell('${e.key + 1}', muted: true),
        _cell(e.value[0]),
        _cell(e.value[1]),
        _cell(e.value[2], bold: true),
        _cell(e.value[3]),
        StatusBadge(label: e.value[4], type: e.value[4] == 'Completed' ? BadgeType.success : BadgeType.warning),
      ]).toList(),
    );
  }
}

class _QuestionTab extends StatelessWidget {
  final String search;
  const _QuestionTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final data = [
      ['2026-03-26 06:30', 'Mother (Postnatal)', 'Severe headache', 'High', '7/7'],
      ['2026-03-26 07:10', 'Baby (Newborn)', 'Difficulty breathing', 'High', '7/7'],
      ['2026-03-26 08:00', 'Mother (Postnatal)', 'Mild fatigue', 'Low', '5/7'],
      ['2026-03-26 09:15', 'Baby (Newborn)', 'Normal feeding', 'Low', '7/7'],
      ['2026-03-26 10:00', 'Mother (Postnatal)', 'Swollen feet', 'Medium', '6/7'],
      ['2026-03-26 10:45', 'Baby (Newborn)', 'Reduced movement', 'High', '7/7'],
      ['2026-03-26 11:30', 'Mother (Postnatal)', 'Headache + vision', 'High', '7/7'],
      ['2026-03-26 12:00', 'Baby (Newborn)', 'Normal weight', 'Low', '7/7'],
    ].where((r) => search.isEmpty || r.any((c) => c.toLowerCase().contains(search.toLowerCase()))).toList();

    return _FullTable(
      columns: const ['#', 'Time', 'Category', 'Top Symptom', 'Risk', 'Completion'],
      flexes: const [1, 3, 3, 4, 2, 2],
      rows: data.asMap().entries.map((e) => [
        _cell('${e.key + 1}', muted: true),
        _cell(e.value[0]),
        _cell(e.value[1]),
        _cell(e.value[2], bold: true),
        StatusBadge(
          label: e.value[3],
          type: e.value[3] == 'High' ? BadgeType.critical : e.value[3] == 'Medium' ? BadgeType.warning : BadgeType.success,
        ),
        _cell(e.value[4]),
      ]).toList(),
    );
  }
}

class _TaskTab extends StatelessWidget {
  final String search;
  const _TaskTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final data = [
      ['ANC Visit Reminder', 'Dr. Banda', 'Blantyre', 'Completed', '2026-03-25'],
      ['Postnatal Check', 'Dr. Phiri', 'Lilongwe', 'Missed', '2026-03-24'],
      ['Vaccination Follow-up', 'Dr. Mwale', 'Mzuzu', 'Pending', '2026-03-26'],
      ['Risk Assessment', 'Dr. Chirwa', 'Zomba', 'Completed', '2026-03-25'],
      ['ANC Visit Reminder', 'Dr. Tembo', 'Mangochi', 'Missed', '2026-03-23'],
      ['Postnatal Check', 'Dr. Nyirenda', 'Kasungu', 'Completed', '2026-03-25'],
      ['Vaccination Follow-up', 'Dr. Kamanga', 'Salima', 'Pending', '2026-03-26'],
      ['Risk Assessment', 'Dr. Msiska', 'Karonga', 'Completed', '2026-03-24'],
    ].where((r) => search.isEmpty || r.any((c) => c.toLowerCase().contains(search.toLowerCase()))).toList();

    return _FullTable(
      columns: const ['#', 'Task', 'Assigned To', 'District', 'Status', 'Due Date'],
      flexes: const [1, 4, 3, 3, 2, 3],
      rows: data.asMap().entries.map((e) => [
        _cell('${e.key + 1}', muted: true),
        _cell(e.value[0], bold: true),
        _cell(e.value[1]),
        _cell(e.value[2]),
        StatusBadge(
          label: e.value[3],
          type: e.value[3] == 'Completed' ? BadgeType.success : e.value[3] == 'Missed' ? BadgeType.critical : BadgeType.warning,
        ),
        _cell(e.value[4]),
      ]).toList(),
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

class _DropFilter extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropFilter({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        ),
      ),
    );
  }
}
