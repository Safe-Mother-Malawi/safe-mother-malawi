import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';

class RiskScoringPage extends StatefulWidget {
  const RiskScoringPage({super.key});

  @override
  State<RiskScoringPage> createState() => _RiskScoringPageState();
}

class _RiskScoringPageState extends State<RiskScoringPage> {
  List<Map<String, dynamic>> _prenatal = [];
  List<Map<String, dynamic>> _neonatal = [];
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _selected;
  String _selectedType = '';
  String _filterStatus = 'All'; // All | Prenatal | Neonatal
  String _filterRisk   = 'All'; // All | High Risk | Moderate Risk | Low Risk
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.instance.get('/patients/prenatal'),
        ApiService.instance.get('/patients/neonatal'),
      ]);
      setState(() {
        _prenatal = (results[0] as List).cast<Map<String, dynamic>>();
        _neonatal = (results[1] as List).cast<Map<String, dynamic>>();
        _loading  = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // Combine prenatal + neonatal with a _type tag
  List<Map<String, dynamic>> get _all {
    final list = <Map<String, dynamic>>[];
    if (_filterStatus != 'Neonatal') {
      for (final p in _prenatal) list.add({...p, '_type': 'prenatal'});
    }
    if (_filterStatus != 'Prenatal') {
      for (final p in _neonatal) list.add({...p, '_type': 'neonatal'});
    }
    return list;
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _search.toLowerCase();
    return _all.where((p) {
      final name = _patientName(p).toLowerCase();
      if (q.isNotEmpty && !name.contains(q)) return false;
      if (_filterRisk != 'All') {
        // Filter by latest risk assessment level if available
        final risk = (p['latestRiskLevel'] ?? '').toString();
        if (!risk.contains(_filterRisk.split(' ').first)) return false;
      }
      return true;
    }).toList();
  }

  String _patientName(Map<String, dynamic> p) =>
      p['_type'] == 'prenatal'
          ? (p['fullName'] ?? 'Unknown').toString()
          : (p['motherName'] ?? 'Unknown').toString();

  String _patientSub(Map<String, dynamic> p) =>
      p['_type'] == 'prenatal'
          ? 'Prenatal · ${p['pregnancyMonths'] ?? '?'} months'
          : 'Neonatal · ${p['babyName'] ?? 'Baby'}';

  int get _highCount   => _all.where((p) => (p['latestRiskLevel'] ?? '').toString().contains('High')).length;
  int get _medCount    => _all.where((p) => (p['latestRiskLevel'] ?? '').toString().contains('Moderate')).length;
  int get _lowCount    => _all.where((p) => (p['latestRiskLevel'] ?? '').toString().contains('Low')).length;

  Color _riskColor(String? level) {
    if (level == null || level.isEmpty) return AppColors.g400;
    if (level.contains('High') || level.contains('Seek')) return AppColors.red;
    if (level.contains('Moderate')) return AppColors.orange;
    return AppColors.green;
  }

  Color _riskBg(String? level) {
    if (level == null || level.isEmpty) return AppColors.g100;
    if (level.contains('High') || level.contains('Seek')) return AppColors.redL;
    if (level.contains('Moderate')) return AppColors.orangeL;
    return AppColors.greenL;
  }

  String _riskLabel(String? level) {
    if (level == null || level.isEmpty) return 'No data';
    if (level.contains('High') || level.contains('Seek')) return 'High';
    if (level.contains('Moderate')) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: AppColors.red, size: 40),
        const SizedBox(height: 12),
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
            child: _buildPatientList(),
          ),
          if (_selected != null) ...[
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _buildDetailPanel()),
          ],
        ]),
      ]),
    );
  }

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
      const SizedBox(width: 6),
      _chip('All', _filterStatus == 'All', () => setState(() { _filterStatus = 'All'; _selected = null; })),
      const SizedBox(width: 6),
      _chip('Prenatal', _filterStatus == 'Prenatal', () => setState(() { _filterStatus = 'Prenatal'; _selected = null; })),
      const SizedBox(width: 6),
      _chip('Neonatal', _filterStatus == 'Neonatal', () => setState(() { _filterStatus = 'Neonatal'; _selected = null; })),
    ]);
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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

  Widget _buildSummaryRow() {
    return Row(children: [
      Expanded(child: _summaryCard('High Risk', '$_highCount', AppColors.red, AppColors.redL, Icons.warning_amber_rounded)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Medium Risk', '$_medCount', AppColors.orange, AppColors.orangeL, Icons.info_outline)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Low Risk', '$_lowCount', AppColors.green, AppColors.greenL, Icons.check_circle_outline)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Total Patients', '${_all.length}', AppColors.navy, AppColors.navyL, Icons.people_outline)),
    ]);
  }

  Widget _summaryCard(String label, String value, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.g200)),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.g400)),
        ]),
      ]),
    );
  }

  Widget _buildPatientList() {
    final list = _filtered;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.people_outline, color: AppColors.navy, size: 18),
            const SizedBox(width: 8),
            Text('Patients (${list.length})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
            const Spacer(),
            // Risk filter chips
            _riskFilterChip('H', 'High', AppColors.red, AppColors.redL),
            const SizedBox(width: 4),
            _riskFilterChip('M', 'Moderate', AppColors.orange, AppColors.orangeL),
            const SizedBox(width: 4),
            _riskFilterChip('L', 'Low', AppColors.green, AppColors.greenL),
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
          const Padding(padding: EdgeInsets.all(24),
              child: Center(child: Text('No patients found.', style: TextStyle(color: AppColors.g400))))
        else
          ...list.map((p) => _patientListItem(p)),
      ]),
    );
  }

  Widget _riskFilterChip(String short, String level, Color color, Color bg) {
    final selected = _filterRisk.contains(level);
    return GestureDetector(
      onTap: () => setState(() => _filterRisk = selected ? 'All' : level),
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(color: selected ? color : bg, shape: BoxShape.circle),
        child: Center(child: Text(short,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                color: selected ? Colors.white : color))),
      ),
    );
  }

  Widget _patientListItem(Map<String, dynamic> p) {
    final isSelected = _selected?['id'] == p['id'];
    final level = (p['latestRiskLevel'] ?? '').toString();
    final riskColor = _riskColor(level);
    final label = _riskLabel(level);

    return GestureDetector(
      onTap: () {
        setState(() { _selected = p; _selectedType = p['_type'] as String; });
        _loadPatientHistory(p['id'].toString(), p['_type'] as String);
      },
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
              child: Text(_patientName(p)[0],
                  style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_patientName(p), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.g800)),
            Text(_patientSub(p), style: const TextStyle(fontSize: 10, color: AppColors.g400)),
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

  List<Map<String, dynamic>> _riskHistory = [];
  bool _historyLoading = false;

  Future<void> _loadPatientHistory(String id, String type) async {
    setState(() { _historyLoading = true; _riskHistory = []; });
    try {
      final data = await ApiService.instance.get('/risk-assessments/patient/$id');
      if (data is List) {
        setState(() { _riskHistory = data.cast<Map<String, dynamic>>(); _historyLoading = false; });
      } else if (data is Map<String, dynamic>) {
        // Handle case where API returns a single object
        setState(() { _riskHistory = [data]; _historyLoading = false; });
      } else {
        setState(() { _riskHistory = []; _historyLoading = false; });
      }
    } catch (e) {
      print('Error loading patient history: $e');
      setState(() { _riskHistory = []; _historyLoading = false; });
    }
  }

  Widget _buildDetailPanel() {
    if (_selected == null) return const SizedBox.shrink();
    final p     = _selected!;
    final type  = _selectedType;
    final level = (p['latestRiskLevel'] ?? '').toString();
    final color = _riskColor(level);
    final label = _riskLabel(level);

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            CircleAvatar(radius: 22, backgroundColor: Colors.white,
                child: Text(_patientName(p)[0],
                    style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_patientName(p), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.g800)),
              Text(type == 'prenatal' ? 'Prenatal Patient' : 'Neonatal — Mother',
                  style: const TextStyle(fontSize: 12, color: AppColors.g600)),
            ])),
            if (level.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.5))),
                child: Row(children: [
                  Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  Text('$label Risk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                ]),
              ),
            const SizedBox(width: 8),
            GestureDetector(onTap: () => setState(() { _selected = null; _selectedType = ''; }),
                child: const Icon(Icons.close, size: 18, color: AppColors.g400)),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Contact info
            _section('Contact', [
              if (type == 'prenatal') ...[
                _row(Icons.phone, 'Phone', p['phone'] ?? 'N/A'),
                _row(Icons.location_on_outlined, 'District', p['district'] ?? 'N/A'),
                _row(Icons.local_hospital_outlined, 'Health Centre', p['facilityName'] ?? 'N/A'),
              ] else ...[
                _row(Icons.phone, 'Mother Phone', p['motherPhone'] ?? 'N/A'),
                _row(Icons.location_on_outlined, 'District', p['district'] ?? 'N/A'),
                _row(Icons.local_hospital_outlined, 'Health Centre', p['facilityName'] ?? 'N/A'),
              ],
            ]),
            const SizedBox(height: 16),

            if (type == 'prenatal')
              _section('Pregnancy', [
                _row(Icons.pregnant_woman, 'Duration', '${p['pregnancyMonths'] ?? '?'} months'),
                if (p['expectedDeliveryDate'] != null)
                  _row(Icons.calendar_today_outlined, 'EDD', p['expectedDeliveryDate'].toString().substring(0, 10)),
              ])
            else
              _section('Baby Details', [
                _row(Icons.child_friendly_outlined, 'Baby Name', p['babyName'] ?? 'N/A'),
                _row(Icons.cake_outlined, 'Date of Birth', (p['babyDob'] ?? 'N/A').toString().substring(0, 10)),
                _row(Icons.wc_outlined, 'Gender', p['babyGender'] ?? 'N/A'),
              ]),

            const SizedBox(height: 16),

            // Risk assessment history
            _section('Risk Assessment History', []),
            const SizedBox(height: 8),
            if (_historyLoading)
              const Center(child: CircularProgressIndicator())
            else if (_riskHistory.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: AppColors.g400, size: 16),
                  SizedBox(width: 8),
                  Text('No risk assessments recorded yet.', style: TextStyle(fontSize: 12, color: AppColors.g400)),
                ]),
              )
            else
              ..._riskHistory.take(5).map((r) {
                final rl    = (r['riskLevel'] ?? '').toString();
                final score = r['score']?.toString() ?? '0';
                final date  = (r['submittedAt'] ?? r['createdAt'] ?? '').toString();
                final dateStr = date.length >= 10 ? date.substring(0, 10) : date;
                final rc    = _riskColor(rl);
                final rb    = _riskBg(rl);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: rb, borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: rc.withOpacity(0.2))),
                  child: Row(children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: rc, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(rl, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: rc)),
                    const SizedBox(width: 8),
                    Text('Score: $score', style: const TextStyle(fontSize: 11, color: AppColors.g600)),
                    const Spacer(),
                    Text(dateStr, style: const TextStyle(fontSize: 10, color: AppColors.g400)),
                  ]),
                );
              }),
          ]),
        ),
      ]),
      ),
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

  Widget _row(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.navy),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
      ]),
    );
  }
}

