import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/status_badge.dart';

class AuditExport extends StatefulWidget {
  const AuditExport({super.key});

  @override
  State<AuditExport> createState() => _AuditExportState();
}

class _AuditExportState extends State<AuditExport> {
  String _district = 'All Districts';
  String _dataType = 'All Data';
  String _dateRange = 'Last 30 days';
  String _format = 'CSV';
  bool _exporting = false;

  final List<Map<String, String>> _exports = [
    {'name': 'Full System Audit — March 2026', 'type': 'Full Audit', 'district': 'National', 'date': '2026-03-25', 'format': 'CSV', 'size': '4.2 MB', 'status': 'Ready'},
    {'name': 'User Activity — Q1 2026', 'type': 'User Activity', 'district': 'National', 'date': '2026-03-20', 'format': 'CSV', 'size': '1.8 MB', 'status': 'Ready'},
    {'name': 'Clinician Data — Blantyre', 'type': 'Clinician Data', 'district': 'Blantyre', 'date': '2026-03-15', 'format': 'Excel', 'size': '890 KB', 'status': 'Ready'},
    {'name': 'IVR Interactions — Feb 2026', 'type': 'IVR Data', 'district': 'National', 'date': '2026-02-28', 'format': 'CSV', 'size': '2.1 MB', 'status': 'Ready'},
    {'name': 'Health Assessments — Q4 2025', 'type': 'Assessment Data', 'district': 'National', 'date': '2025-12-31', 'format': 'CSV', 'size': '5.6 MB', 'status': 'Archived'},
  ];

  Future<void> _export() async {
    setState(() => _exporting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _exporting = false;
      _exports.insert(0, {
        'name': '$_dataType — ${DateTime.now().toString().substring(0, 10)}',
        'type': _dataType,
        'district': _district,
        'date': DateTime.now().toString().substring(0, 10),
        'format': _format,
        'size': 'Calculating...',
        'status': 'Ready',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Audit Export',
              style: GoogleFonts.publicSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 4),
          Text('Export system data for auditing and compliance purposes',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Export config
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
                      Text('Configure Export',
                          style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16, runSpacing: 16,
                        children: [
                          _DropField(label: 'Data Type', value: _dataType,
                              items: const ['All Data', 'User Activity', 'Clinician Data', 'IVR Interactions', 'Health Assessments', 'System Events', 'Login History'],
                              onChanged: (v) => setState(() => _dataType = v!)),
                          _DropField(label: 'District', value: _district,
                              items: const ['All Districts', 'Blantyre', 'Lilongwe', 'Mzuzu', 'Zomba', 'Mangochi', 'Kasungu', 'Salima', 'Karonga'],
                              onChanged: (v) => setState(() => _district = v!)),
                          _DropField(label: 'Date Range', value: _dateRange,
                              items: const ['Last 7 days', 'Last 30 days', 'Last 3 months', 'Last 6 months', 'Last year', 'All time'],
                              onChanged: (v) => setState(() => _dateRange = v!)),
                          _DropField(label: 'Format', value: _format,
                              items: const ['CSV', 'Excel', 'JSON', 'PDF'],
                              onChanged: (v) => setState(() => _format = v!)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Info banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.infoText),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Exports are logged for compliance. All data exports are traceable to your admin account.',
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.infoText),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: _exporting ? null : _export,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: _exporting ? null : AppColors.primaryGradient,
                            color: _exporting ? AppColors.surfaceContainerHighest : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_exporting)
                                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                              else
                                const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                _exporting ? 'Exporting...' : 'Export Data',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _exporting ? AppColors.mutedText : Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Quick stats
              SizedBox(
                width: 220,
                child: Column(
                  children: [
                    _StatCard(icon: Icons.folder_zip_rounded, label: 'Total Exports', value: '${_exports.length}'),
                    const SizedBox(height: 12),
                    _StatCard(icon: Icons.storage_rounded, label: 'Total Data Size', value: '14.6 MB'),
                    const SizedBox(height: 12),
                    _StatCard(icon: Icons.schedule_rounded, label: 'Last Export', value: 'Today'),
                    const SizedBox(height: 12),
                    _StatCard(icon: Icons.verified_user_rounded, label: 'Compliance', value: '100%'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Export history
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
                Row(
                  children: [
                    Text('Export History',
                        style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                    const Spacer(),
                    Text('${_exports.length} records',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
                  ],
                ),
                const SizedBox(height: 16),
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.pageBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      _headerCell('Export Name', 4),
                      _headerCell('Type', 2),
                      _headerCell('District', 2),
                      _headerCell('Date', 2),
                      _headerCell('Format', 1),
                      _headerCell('Size', 2),
                      _headerCell('Status', 2),
                      _headerCell('', 1),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                ..._exports.asMap().entries.map((e) {
                  final ex = e.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: e.key.isEven ? AppColors.surfaceContainerLowest : AppColors.pageBg.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 4, child: Row(children: [
                          Icon(ex['format'] == 'CSV' ? Icons.table_chart_rounded : ex['format'] == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.grid_on_rounded,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ex['name']!, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface), overflow: TextOverflow.ellipsis)),
                        ])),
                        Expanded(flex: 2, child: Text(ex['type']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText))),
                        Expanded(flex: 2, child: Text(ex['district']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText))),
                        Expanded(flex: 2, child: Text(ex['date']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                        Expanded(flex: 1, child: StatusBadge(label: ex['format']!, type: BadgeType.info)),
                        Expanded(flex: 2, child: Text(ex['size']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                        Expanded(flex: 2, child: StatusBadge(label: ex['status']!, type: ex['status'] == 'Ready' ? BadgeType.success : BadgeType.neutral)),
                        Expanded(flex: 1, child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.download_rounded, size: 16, color: AppColors.primary),
                          tooltip: 'Download',
                        )),
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
}

Widget _headerCell(String label, int flex) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText, letterSpacing: 0.5)),
      ),
    );

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(value, style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.headings)),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText)),
        ]),
      ]),
    );
  }
}

class _DropField extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropField({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value, onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
          decoration: InputDecoration(
            filled: true, fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList()),
      ]),
    );
  }
}
