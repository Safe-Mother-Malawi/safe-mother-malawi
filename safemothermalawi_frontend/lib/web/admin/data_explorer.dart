import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/data_table_widget.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data Source',
              style: GoogleFonts.publicSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headings)),
          const SizedBox(height: 6),
          Text('Direct access to system data tables',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          // Filters bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 24,
                    offset: Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search records...',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.mutedText),
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 18, color: AppColors.mutedText),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _DropFilter(
                  value: _dateFilter,
                  items: const [
                    'Today', 'Last 7 days', 'Last 30 days', 'Last 3 months', 'All time'
                  ],
                  onChanged: (v) => setState(() => _dateFilter = v!),
                ),
                const Spacer(),
                _ExportBtn(label: 'Export CSV', icon: Icons.download_rounded),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tabs
          Container(
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
              children: [
                TabBar(
                  controller: _tabCtrl,
                  labelStyle: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle:
                      GoogleFonts.inter(fontSize: 13),
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
                SizedBox(
                  height: 420,
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
        ],
      ),
    );
  }
}

class _SystemLogsTab extends StatelessWidget {
  final String search;
  const _SystemLogsTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['2026-03-26 08:12', 'LOGIN', 'Admin', 'Success'],
      ['2026-03-26 08:45', 'CREATE_CLINICIAN', 'Admin', 'Success'],
      ['2026-03-26 09:10', 'DEACTIVATE_USER', 'Admin', 'Success'],
      ['2026-03-26 10:02', 'EXPORT_REPORT', 'DHO Blantyre', 'Success'],
      ['2026-03-26 11:30', 'LOGIN_FAILED', 'Unknown', 'Failed'],
    ].where((r) => search.isEmpty || r.any((c) => c.toLowerCase().contains(search.toLowerCase()))).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppDataTable(
        showIndex: true,
        columns: const ['Timestamp', 'Event', 'User', 'Status'],
        rows: rows.map((r) => [
          Text(r[0], style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
          Text(r[1], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
          Text(r[2], style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
          StatusBadge(label: r[3], type: r[3] == 'Success' ? BadgeType.success : BadgeType.critical),
        ]).toList(),
      ),
    );
  }
}

class _IvrTab extends StatelessWidget {
  final String search;
  const _IvrTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['2026-03-26 07:00', '+265 999 111 222', 'Baby Issues', '3m 12s', 'Completed'],
      ['2026-03-26 07:45', '+265 888 333 444', 'Mother Issues', '1m 05s', 'Dropped'],
      ['2026-03-26 08:20', '+265 777 555 666', 'Immunization', '5m 40s', 'Completed'],
      ['2026-03-26 09:00', '+265 666 777 888', 'Feeding Guidance', '2m 18s', 'Completed'],
    ].where((r) => search.isEmpty || r.any((c) => c.toLowerCase().contains(search.toLowerCase()))).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppDataTable(
        showIndex: true,
        columns: const ['Time', 'Caller', 'Topic', 'Duration', 'Status'],
        rows: rows.map((r) => [
          Text(r[0], style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
          Text(r[1], style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
          Text(r[2], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
          Text(r[3], style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
          StatusBadge(label: r[4], type: r[4] == 'Completed' ? BadgeType.success : BadgeType.warning),
        ]).toList(),
      ),
    );
  }
}

class _QuestionTab extends StatelessWidget {
  final String search;
  const _QuestionTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['2026-03-26 06:30', 'Mother (Postnatal)', 'Severe headache', 'High', '7/7'],
      ['2026-03-26 07:10', 'Baby (Newborn)', 'Difficulty breathing', 'High', '7/7'],
      ['2026-03-26 08:00', 'Mother (Postnatal)', 'Mild fatigue', 'Low', '5/7'],
      ['2026-03-26 09:15', 'Baby (Newborn)', 'Normal feeding', 'Low', '7/7'],
    ].where((r) => search.isEmpty || r.any((c) => c.toLowerCase().contains(search.toLowerCase()))).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppDataTable(
        showIndex: true,
        columns: const ['Time', 'Category', 'Top Symptom', 'Risk', 'Completion'],
        rows: rows.map((r) => [
          Text(r[0], style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
          Text(r[1], style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
          Text(r[2], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
          StatusBadge(label: r[3], type: r[3] == 'High' ? BadgeType.critical : r[3] == 'Medium' ? BadgeType.warning : BadgeType.success),
          Text(r[4], style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
        ]).toList(),
      ),
    );
  }
}

class _TaskTab extends StatelessWidget {
  final String search;
  const _TaskTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['ANC Visit Reminder', 'Dr. Banda', 'Blantyre', 'Completed', '2026-03-25'],
      ['Postnatal Check', 'Nurse Phiri', 'Lilongwe', 'Missed', '2026-03-24'],
      ['Vaccination Follow-up', 'Dr. Mwale', 'Mzuzu', 'Pending', '2026-03-26'],
      ['Risk Assessment', 'Nurse Chirwa', 'Zomba', 'Completed', '2026-03-25'],
    ].where((r) => search.isEmpty || r.any((c) => c.toLowerCase().contains(search.toLowerCase()))).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppDataTable(
        showIndex: true,
        columns: const ['Task', 'Assigned To', 'District', 'Status', 'Due Date'],
        rows: rows.map((r) => [
          Text(r[0], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
          Text(r[1], style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
          Text(r[2], style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
          StatusBadge(
            label: r[3],
            type: r[3] == 'Completed' ? BadgeType.success : r[3] == 'Missed' ? BadgeType.critical : BadgeType.warning,
          ),
          Text(r[4], style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText)),
        ]).toList(),
      ),
    );
  }
}

class _DropFilter extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropFilter(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
        ),
      ),
    );
  }
}

class _ExportBtn extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ExportBtn({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
