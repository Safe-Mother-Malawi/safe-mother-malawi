import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class RiskScoringPage extends StatefulWidget {
  const RiskScoringPage({super.key});
  @override
  State<RiskScoringPage> createState() => _RiskScoringPageState();
}

class _RiskScoringPageState extends State<RiskScoringPage> {
  List<Map<String, dynamic>> _assessments = [];
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _selected;
  String _filterRisk   = 'All';
  String _filterStatus = 'All';
  String _search       = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getRiskAssessments();
      if (mounted) {
        setState(() {
          _assessments = data.cast<Map<String, dynamic>>();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<Map<String, dynamic>> get _filtered => _assessments.where((a) {
    final risk   = a['riskLevel']?.toString() ?? '';
    final type   = a['patientType']?.toString() ?? '';
    final name   = a['patientName']?.toString().toLowerCase() ?? '';

    if (_filterRisk != 'All' && risk != _filterRisk) return false;
    if (_filterStatus != 'All' && type.toLowerCase() != _filterStatus.toLowerCase()) return false;
    if (_search.isNotEmpty && !name.contains(_search.toLowerCase())) return false;
    return true;
  }).toList();

  // ── Risk helpers ──────────────────────────────────────────────────────────

  (Color, Color, String) _riskStyle(String level) {
    switch (level) {
      case 'Seek Help Immediately':
        return (AppColors.red, AppColors.redL, 'Critical');
      case 'High Risk':
        return (AppColors.red, AppColors.redL, 'High');
      case 'Moderate Risk':
        return (AppColors.orange, AppColors.orangeL, 'Moderate');
      default:
        return (AppColors.green, AppColors.greenL, 'Low');
    }
  }

  int get _criticalCount => _assessments.where((a) =>
      a['riskLevel'] == 'Seek Help Immediately' || a['riskLevel'] == 'High Risk').length;
  int get _moderateCount => _assessments.where((a) => a['riskLevel'] == 'Moderate Risk').length;
  int get _lowCount      => _assessments.where((a) => a['riskLevel'] == 'Low Risk').length;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_error!, style: const TextStyle(color: AppColors.red)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildSummaryRow(),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: _selected == null ? 1 : 2,
            child: _buildList(),
          ),
          if (_selected != null) ...[
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _buildDetailPanel()),
          ],
        ]),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(children: [
      const Icon(Icons.assessment_outlined, color: AppColors.navy, size: 22),
      const SizedBox(width: 10),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Risk Monitoring',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
        Text('Track and assess patient risk levels in real time.',
            style: TextStyle(fontSize: 13, color: AppColors.g400)),
      ])),
      IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: AppColors.navy, size: 20), tooltip: 'Refresh'),
      const SizedBox(width: 8),
      _chip('All',      isStatus: true),
      const SizedBox(width: 6),
      _chip('Prenatal', isStatus: true),
      const SizedBox(width: 6),
      _chip('Neonatal', isStatus: true),
    ]);
  }

  Widget _chip(String label, {bool isStatus = false}) {
    final selected = isStatus ? _filterStatus == label : _filterRisk == label;
    return GestureDetector(
      onTap: () => setState(() {
        if (isStatus) _filterStatus = label;
        else _filterRisk = selected ? 'All' : label;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.g100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.g600)),
      ),
    );
  }

  // ── Summary cards ─────────────────────────────────────────────────────────

  Widget _buildSummaryRow() {
    return Row(children: [
      Expanded(child: _summaryCard('High / Critical', '$_criticalCount', AppColors.red, AppColors.redL, Icons.warning_amber_rounded)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Moderate Risk', '$_moderateCount', AppColors.orange, AppColors.orangeL, Icons.info_outline)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Low Risk', '$_lowCount', AppColors.green, AppColors.greenL, Icons.check_circle_outline)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Total Assessments', '${_assessments.length}', AppColors.navy, AppColors.navyL, Icons.list_alt_rounded)),
    ]);
  }

  Widget _summaryCard(String label, String value, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.g200)),
      child: Row(children: [
        Container(width: 40, height: 40,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.g400)),
        ]),
      ]),
    );
  }

  // ── Patient list ──────────────────────────────────────────────────────────

  Widget _buildList() {
    final list = _filtered;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.people_outline, color: AppColors.navy, size: 18),
            const SizedBox(width: 8),
            Text('Assessments (${list.length})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search patients...',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.g400),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.g400),
              filled: true, fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.g200),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Column(children: [
              Icon(Icons.assessment_outlined, color: AppColors.g200, size: 40),
              SizedBox(height: 8),
              Text('No risk assessments yet.', style: TextStyle(color: AppColors.g400, fontSize: 13)),
            ])),
          )
        else
          ...list.map((a) => _listItem(a)),
      ]),
    );
  }

  Widget _listItem(Map<String, dynamic> a) {
    final isSelected = _selected?['id'] == a['id'];
    final risk = a['riskLevel']?.toString() ?? 'Low Risk';
    final (riskColor, _, label) = _riskStyle(risk);
    final name = a['patientName']?.toString() ?? '—';
    final type = a['patientType']?.toString() ?? '';
    final score = a['score']?.toString() ?? '0';
    final date = (a['submittedAt'] ?? '').toString();
    final dateShort = date.length >= 10 ? date.substring(0, 10) : date;

    return GestureDetector(
      onTap: () => setState(() => _selected = a),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navyL : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AppColors.g200, width: 0.5)),
        ),
        child: Row(children: [
          Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle)),
          CircleAvatar(radius: 16, backgroundColor: AppColors.navyL,
              child: Text(name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.g800)),
            Text('${type[0].toUpperCase()}${type.substring(1)} · Score $score · $dateShort',
                style: const TextStyle(fontSize: 10, color: AppColors.g400)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(10)),
            child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: riskColor)),
          ),
        ]),
      ),
    );
  }

  // ── Detail panel ──────────────────────────────────────────────────────────

  Widget _buildDetailPanel() {
    final a = _selected!;
    final risk = a['riskLevel']?.toString() ?? 'Low Risk';
    final (color, bg, label) = _riskStyle(risk);
    final name    = a['patientName']?.toString() ?? '—';
    final phone   = a['patientPhone']?.toString() ?? '—';
    final type    = a['patientType']?.toString() ?? '';
    final score   = a['score']?.toString() ?? '0';
    final message = a['message']?.toString() ?? '';
    final date    = (a['submittedAt'] ?? '').toString();
    final dateShort = date.length >= 10 ? date.substring(0, 10) : date;

    // answers map — may contain symptom values
    final answers = a['answers'] as Map<String, dynamic>? ?? {};

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.navyL,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(children: [
            CircleAvatar(radius: 22, backgroundColor: Colors.white,
                child: Text(name.isNotEmpty ? name[0] : '?',
                    style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.g800)),
              Text(phone, style: const TextStyle(fontSize: 12, color: AppColors.g600)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.5))),
              child: Row(children: [
                Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                Text('$label Risk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ]),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _selected = null),
              child: const Icon(Icons.close, size: 18, color: AppColors.g400),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Score + type + date
            _section('Assessment Details', [
              _row(Icons.score_rounded, 'Risk Score', score, valueColor: color),
              _row(Icons.pregnant_woman, 'Patient Type',
                  '${type[0].toUpperCase()}${type.substring(1)}', valueColor: AppColors.navy),
              _row(Icons.calendar_today_rounded, 'Submitted', dateShort, valueColor: AppColors.g800),
            ]),
            const SizedBox(height: 16),

            // Message from the engine
            if (message.isNotEmpty) ...[
              _section('Assessment Message', []),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded, color: color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(message, style: TextStyle(fontSize: 13, color: color))),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            // Answers / symptoms
            if (answers.isNotEmpty) ...[
              _section('Reported Answers', [
                ...answers.entries.map((e) => _row(
                  Icons.check_box_outlined,
                  e.key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
                  e.value.toString(),
                  valueColor: AppColors.g800,
                )),
              ]),
            ],

            if (answers.isEmpty && message.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.greenL, borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Icon(Icons.check_circle_outline, color: AppColors.green, size: 18),
                  SizedBox(width: 10),
                  Text('No additional details recorded.', style: TextStyle(fontSize: 13, color: AppColors.green)),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 14, color: AppColors.navy, margin: const EdgeInsets.only(right: 8)),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800)),
      ]),
      const SizedBox(height: 10),
      ...children,
    ]);
  }

  Widget _row(IconData icon, String label, String value, {Color valueColor = AppColors.g800}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.navy),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g600))),
        if (value.isNotEmpty)
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor)),
      ]),
    );
  }
}
