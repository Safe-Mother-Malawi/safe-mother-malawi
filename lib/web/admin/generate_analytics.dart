import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class GenerateAnalytics extends StatefulWidget {
  const GenerateAnalytics({super.key});

  @override
  State<GenerateAnalytics> createState() => _GenerateAnalyticsState();
}

class _GenerateAnalyticsState extends State<GenerateAnalytics> {
  final Map<String, bool> _sources = {
    'System Logs': true,
    'Question Responses': false,
    'Task Data': false,
  };

  String _dateRange = 'Last 30 days';
  String _district = 'All Districts';
  String _riskLevel = 'All';
  String _stage = 'All';
  bool _loading = false;
  bool _done = false;
  int _progress = 0;

  Future<void> _generate() async {
    setState(() { _loading = true; _done = false; _progress = 0; });
    try {
      // Simulate progress while fetching
      for (int i = 1; i <= 4; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() => _progress = i * 20);
      }
      // Call real analytics endpoint
      await ApiService.getAnalyticsOverview();
      setState(() => _progress = 100);
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() { _loading = false; _done = true; });
    } catch (e) {
      setState(() { _loading = false; _done = false; _progress = 0; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.criticalText),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Generate Analytics',
              style: GoogleFonts.publicSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headings)),
          const SizedBox(height: 6),
          Text('Select data sources and filters, then fetch insights',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: sources + filters
              Expanded(
                child: Column(
                  children: [
                    // Data sources
                    _Section(
                      title: 'Data Sources',
                      child: Column(
                        children: _sources.entries.map((e) {
                          return _CheckTile(
                            label: e.key,
                            checked: e.value,
                            onChanged: (v) =>
                                setState(() => _sources[e.key] = v!),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Filters
                    _Section(
                      title: 'Filters',
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _FilterDrop(
                            label: 'Date Range',
                            value: _dateRange,
                            items: const [
                              'Today', 'Last 7 days', 'Last 30 days',
                              'Last 3 months', 'Last 6 months', 'Custom'
                            ],
                            onChanged: (v) => setState(() => _dateRange = v!),
                          ),
                          _FilterDrop(
                            label: 'District',
                            value: _district,
                            items: const [
                              'All Districts', 'Blantyre', 'Lilongwe',
                              'Mzuzu', 'Zomba', 'Mangochi', 'Kasungu'
                            ],
                            onChanged: (v) => setState(() => _district = v!),
                          ),
                          _FilterDrop(
                            label: 'Risk Level',
                            value: _riskLevel,
                            items: const ['All', 'Low', 'Medium', 'High'],
                            onChanged: (v) => setState(() => _riskLevel = v!),
                          ),
                          _FilterDrop(
                            label: 'Stage',
                            value: _stage,
                            items: const [
                              'All', 'Pregnant', 'Postnatal', 'Neonatal'
                            ],
                            onChanged: (v) => setState(() => _stage = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right: action + status
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    _Section(
                      title: 'Selected Sources',
                      child: Column(
                        children: _sources.entries
                            .where((e) => e.value)
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          size: 16,
                                          color: AppColors.successText),
                                      const SizedBox(width: 8),
                                      Text(e.key,
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: AppColors.onSurface)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _loading ? null : _generate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: _loading
                                ? null
                                : AppColors.primaryGradient,
                            color: _loading
                                ? AppColors.surfaceContainerHighest
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_loading)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary),
                                )
                              else
                                const Icon(Icons.auto_graph_rounded,
                                    color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                _loading
                                    ? 'Generating...'
                                    : 'Fetch & Generate Insights',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _loading
                                      ? AppColors.mutedText
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (_loading) ...[
                      const SizedBox(height: 16),
                      _Section(
                        title: 'Processing',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progress / 100,
                                backgroundColor:
                                    AppColors.surfaceContainerHighest,
                                color: AppColors.primary,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('$_progress% — Fetching data...',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.mutedText)),
                          ],
                        ),
                      ),
                    ],

                    if (_done) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.successText, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Insights generated. View in Analytics Dashboard.',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.successText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Text(title,
              style: GoogleFonts.publicSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headings)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  final String label;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  const _CheckTile(
      {required this.label, required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: checked,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _FilterDrop extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDrop(
      {required this.label,
      required this.value,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            onChanged: onChanged,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: items
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
