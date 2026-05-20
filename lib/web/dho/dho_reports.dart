import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/status_badge.dart';
import '../shared/utils/report_actions.dart';
import '../../services/api_service.dart';
import '../../state/user_store.dart';

class DhoReports extends StatefulWidget {
  const DhoReports({super.key});
  @override
  State<DhoReports> createState() => _DhoReportsState();
}

class _DhoReportsState extends State<DhoReports> {
  // ── Generate form ─────────────────────────────────────────────────────────
  String _reportType = 'District Summary';
  String _format     = 'PDF';
  bool _generating   = false;

  // ── History ───────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  // DHO's own district (from their profile)
  String get _myDistrict => UserStore.instance.district.isNotEmpty
      ? UserStore.instance.district
      : 'My District';

  static const _reportTypes = [
    'District Summary',
    'Risk Report',
    'IVR Report',
    'Clinician Report',
  ];

  static const _formats = ['PDF', 'CSV', 'Excel'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getReports();
      setState(() {
        _history = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      final report = await ApiService.generateReport({
        'type': _reportType,
        'format': _format,
        'district': _myDistrict,
      });
      setState(() {
        _history.insert(0, report);
        _generating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('Report generated for $_myDistrict'),
          ]),
          backgroundColor: AppColors.successText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    } catch (e) {
      setState(() => _generating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.criticalText,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Page header ───────────────────────────────────────────────────
        Text('Reports',
            style: GoogleFonts.publicSans(
                fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
        const SizedBox(height: 4),
        Text('Generate and manage reports for your district',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
        const SizedBox(height: 24),

        // ── Generate + stats row ──────────────────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Generate card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Generate New Report',
                    style: GoogleFonts.publicSans(
                        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                const SizedBox(height: 6),
                // District badge — locked to DHO's district
                Row(children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('District: ',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
                  Text(_myDistrict,
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Your district',
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.infoText)),
                  ),
                ]),
                const SizedBox(height: 20),
                Wrap(spacing: 16, runSpacing: 16, children: [
                  _ReportDrop(
                    label: 'Report Type',
                    value: _reportType,
                    items: _reportTypes,
                    onChanged: (v) => setState(() => _reportType = v!),
                  ),
                  _ReportDrop(
                    label: 'Format',
                    value: _format,
                    items: _formats,
                    onChanged: (v) => setState(() => _format = v!),
                  ),
                ]),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _generating ? null : _generate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: _generating ? null : AppColors.primaryGradient,
                      color: _generating ? AppColors.surfaceContainerHighest : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (_generating)
                        const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                      else
                        const Icon(Icons.summarize_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        _generating ? 'Generating...' : 'Generate Report',
                        style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: _generating ? AppColors.mutedText : Colors.white,
                        ),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 24),

          // Stats
          SizedBox(width: 220, child: Column(children: [
            _StatCard(
              icon: Icons.description_rounded,
              label: 'My Reports',
              value: '${_history.length}',
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.schedule_rounded,
              label: 'Last Generated',
              value: _history.isNotEmpty
                  ? _history.first['createdAt']?.toString().substring(0, 10) ?? '—'
                  : '—',
            ),
          ])),
        ]),
        const SizedBox(height: 28),

        // ── Report history ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('My Report History',
                  style: GoogleFonts.publicSans(
                      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
              const Spacer(),
            ]),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(children: [
                    const Icon(Icons.description_outlined, size: 40, color: AppColors.mutedText),
                    const SizedBox(height: 8),
                    Text('No reports yet. Generate your first report above.',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
                  ]),
                ),
              )
            else
              ..._history.map((r) => _ReportRow(
                    report: r,
                    onDeleted: () => setState(() => _history.remove(r)),
                  )),
          ]),
        ),
      ]),
    );
  }
}

// ── Shared row widget ─────────────────────────────────────────────────────────

class _ReportRow extends StatefulWidget {
  final Map<String, dynamic> report;
  final VoidCallback onDeleted;
  const _ReportRow({required this.report, required this.onDeleted});
  @override
  State<_ReportRow> createState() => _ReportRowState();
}

class _ReportRowState extends State<_ReportRow> {
  bool _downloading = false;
  bool _opening = false;
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text('Delete Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        content: Text(
          'Delete "${widget.report['name']}"? This cannot be undone.',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await ApiService.deleteReport(widget.report['id']?.toString() ?? '');
      widget.onDeleted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red.shade700,
        ));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = widget.report['format']?.toString() ?? 'PDF';
    final status = widget.report['status']?.toString() ?? 'Ready';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.infoBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(
            format == 'CSV' ? Icons.table_chart_rounded : Icons.picture_as_pdf_rounded,
            size: 18, color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.report['name']?.toString() ?? '—',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
            Text(
              '${widget.report['type']} · ${widget.report['createdAt']?.toString().substring(0, 10) ?? ''}',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText),
            ),
          ]),
        ),
        StatusBadge(label: format, type: BadgeType.info),
        const SizedBox(width: 10),
        StatusBadge(
            label: status,
            type: status == 'Ready' ? BadgeType.success : BadgeType.neutral),
        const SizedBox(width: 4),
        // Open
        Tooltip(
          message: 'Open PDF',
          child: _opening
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  onPressed: () async {
                    setState(() => _opening = true);
                    await openReport(context, widget.report);
                    if (mounted) setState(() => _opening = false);
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
                ),
        ),
        // Download
        Tooltip(
          message: 'Download',
          child: _downloading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  onPressed: () async {
                    setState(() => _downloading = true);
                    await downloadReport(context, widget.report);
                    if (mounted) setState(() => _downloading = false);
                  },
                  icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.primary),
                ),
        ),
        // Delete
        Tooltip(
          message: 'Delete',
          child: _deleting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                ),
        ),
      ]),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _ReportDrop extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _ReportDrop(
      {required this.label,
      required this.value,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 200, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
                letterSpacing: 0.8)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        ),
      ]));
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: GoogleFonts.publicSans(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.headings)),
            Text(label,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText)),
          ]),
        ]),
      );
}
