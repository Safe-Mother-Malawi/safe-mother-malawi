// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../shared/widgets/status_badge.dart';

class AuditExport extends StatefulWidget {
  const AuditExport({super.key});

  @override
  State<AuditExport> createState() => _AuditExportState();
}

class _AuditExportState extends State<AuditExport> {
  String _district  = 'All Districts';
  String _dataType  = 'All Data';
  String _dateRange = 'Last 30 days';
  String _format    = 'CSV';
  bool _exporting   = false;

  List<Map<String, dynamic>> _exports = [];
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
      final data = await ApiService.getReports();
      setState(() {
        _exports = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final district = _district == 'All Districts' ? '' : _district;
      final params = {
        'format':    _format,
        'dataType':  _dataType,
        'dateRange': _dateRange,
        if (district.isNotEmpty) 'district': district,
      };
      final query = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final url   = '${ApiService.baseUrl}/reports/export?$query';
      final token = await ApiService.instance.getToken();

      final request = html.HttpRequest();
      request.open('GET', url);
      if (token != null) request.setRequestHeader('Authorization', 'Bearer $token');
      request.responseType = 'blob';

      request.onLoad.listen((_) {
        if (!mounted) return;
        if (request.status == 200) {
          final blob    = request.response as html.Blob;
          final blobUrl = html.Url.createObjectUrlFromBlob(blob);
          final ext     = _format.toLowerCase() == 'excel' ? 'csv'
                        : _format.toLowerCase() == 'json'  ? 'json'
                        : _format.toLowerCase() == 'pdf'   ? 'pdf'
                        : 'csv';
          final name = '${_dataType.replaceAll(' ', '_')}_export.$ext';
          html.AnchorElement(href: blobUrl)
            ..setAttribute('download', name)
            ..click();
          html.Url.revokeObjectUrl(blobUrl);

          setState(() => _exporting = false);
          messenger.showSnackBar(SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Export downloaded successfully'),
            ]),
            backgroundColor: AppColors.successText,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
        } else {
          setState(() => _exporting = false);
          messenger.showSnackBar(SnackBar(
            content: Text('Export failed: HTTP ${request.status}'),
            backgroundColor: AppColors.criticalText,
          ));
        }
      });

      request.onError.listen((_) {
        if (!mounted) return;
        setState(() => _exporting = false);
        messenger.showSnackBar(const SnackBar(
          content: Text('Export failed: network error'),
          backgroundColor: AppColors.criticalText,
        ));
      });

      request.send();
    } catch (e) {
      setState(() => _exporting = false);
      messenger.showSnackBar(SnackBar(
        content: Text('Export failed: $e'),
        backgroundColor: AppColors.criticalText,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Audit Export',
              style: GoogleFonts.publicSans(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
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
                          style: GoogleFonts.publicSans(
                              fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16, runSpacing: 16,
                        children: [
                          _DropField(
                            label: 'Data Type', value: _dataType,
                            items: const ['All Data', 'User Activity', 'Clinician Data', 'IVR Interactions', 'Health Assessments', 'System Events', 'Login History'],
                            onChanged: (v) => setState(() => _dataType = v!),
                          ),
                          _DropField(
                            label: 'District', value: _district,
                            items: const ['All Districts', 'Blantyre', 'Lilongwe', 'Mzuzu', 'Zomba', 'Mangochi', 'Kasungu', 'Salima', 'Karonga'],
                            onChanged: (v) => setState(() => _district = v!),
                          ),
                          _DropField(
                            label: 'Date Range', value: _dateRange,
                            items: const ['Last 7 days', 'Last 30 days', 'Last 3 months', 'Last 6 months', 'Last year', 'All time'],
                            onChanged: (v) => setState(() => _dateRange = v!),
                          ),
                          _DropField(
                            label: 'Format', value: _format,
                            items: const ['CSV', 'Excel', 'JSON', 'PDF'],
                            onChanged: (v) => setState(() => _format = v!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppColors.infoBg, borderRadius: BorderRadius.circular(10)),
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
                                const SizedBox(width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                              else
                                const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                _exporting ? 'Exporting...' : 'Export Data',
                                style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.w600,
                                    color: _exporting ? AppColors.mutedText : Colors.white),
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
                    _StatCard(icon: Icons.schedule_rounded, label: 'Last Export',
                        value: _exports.isNotEmpty
                            ? (_exports.first['createdAt']?.toString().substring(0, 10) ?? '—')
                            : '—'),
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
                        style: GoogleFonts.publicSans(
                            fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
                    const Spacer(),
                    Text('${_exports.length} records',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
                  ],
                ),
                const SizedBox(height: 16),

                if (_loading)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (_error != null)
                  Center(child: Column(children: [
                    const Icon(Icons.error_outline, color: AppColors.criticalText, size: 36),
                    const SizedBox(height: 8),
                    Text(_error!, style: GoogleFonts.inter(color: AppColors.criticalText)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
                  ]))
                else if (_exports.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Column(children: [
                      const Icon(Icons.folder_open_rounded, size: 40, color: AppColors.mutedText),
                      const SizedBox(height: 8),
                      Text('No exports yet. Generate your first export above.',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
                    ])),
                  )
                else ...[
                  // Header row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.pageBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      _headerCell('Export Name', 4),
                      _headerCell('Type', 2),
                      _headerCell('District', 2),
                      _headerCell('Date', 2),
                      _headerCell('Format', 1),
                      _headerCell('Status', 2),
                      _headerCell('', 1),
                    ]),
                  ),
                  const SizedBox(height: 4),
                  ..._exports.asMap().entries.map((e) {
                    final ex = e.value;
                    final name    = (ex['name'] ?? ex['type'] ?? 'Export').toString();
                    final type    = (ex['type'] ?? '—').toString();
                    final district = (ex['district'] ?? '—').toString();
                    final date    = (ex['createdAt'] ?? '—').toString();
                    final format  = (ex['format'] ?? 'CSV').toString();
                    final status  = (ex['status'] ?? 'Ready').toString();

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        color: e.key.isEven
                            ? AppColors.surfaceContainerLowest
                            : AppColors.pageBg.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(children: [
                        Expanded(flex: 4, child: Row(children: [
                          Icon(
                            format == 'CSV' ? Icons.table_chart_rounded
                                : format == 'PDF' ? Icons.picture_as_pdf_rounded
                                : Icons.grid_on_rounded,
                            size: 16, color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(name,
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                              overflow: TextOverflow.ellipsis)),
                        ])),
                        Expanded(flex: 2, child: Text(type, style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText))),
                        Expanded(flex: 2, child: Text(district, style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText))),
                        Expanded(flex: 2, child: Text(date.length > 10 ? date.substring(0, 10) : date,
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                        Expanded(flex: 1, child: StatusBadge(label: format, type: BadgeType.info)),
                        Expanded(flex: 2, child: StatusBadge(
                          label: status,
                          type: status == 'Ready' ? BadgeType.success : BadgeType.neutral,
                        )),
                        Expanded(flex: 1, child: IconButton(
                          onPressed: () async {
                            final m = ScaffoldMessenger.of(context);
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete Export'),
                                content: Text('Delete "$name"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && ex['id'] != null) {
                              try {
                                await ApiService.deleteReport(ex['id'].toString());
                                if (mounted) setState(() => _exports.remove(ex));
                              } catch (err) {
                                m.showSnackBar(
                                  SnackBar(content: Text('Delete failed: $err'), backgroundColor: AppColors.criticalText),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.criticalText),
                          tooltip: 'Delete',
                        )),
                      ]),
                    );
                  }),
                ],
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
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: AppColors.mutedText, letterSpacing: 0.5)),
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
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                color: AppColors.mutedText, letterSpacing: 0.8)),
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
      ]),
    );
  }
}
