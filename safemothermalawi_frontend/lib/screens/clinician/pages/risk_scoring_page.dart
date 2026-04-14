import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/animated_pulse_dot.dart';

// ── Data model ────────────────────────────────────────────────────────────────

enum RiskLevel { low, medium, high }

class _Patient {
  final String name;
  final int age;
  final String status; // Prenatal / Neonatal
  final RiskLevel risk;
  final String bp;
  final String pregnancyOrBabyAge;
  final List<String> symptoms;
  final List<String> complications;
  final bool overdueCheckup;

  const _Patient({
    required this.name,
    required this.age,
    required this.status,
    required this.risk,
    required this.bp,
    required this.pregnancyOrBabyAge,
    required this.symptoms,
    required this.complications,
    this.overdueCheckup = false,
  });
}

const _patients = [
  _Patient(
    name: 'Grace Banda', age: 28, status: 'Prenatal', risk: RiskLevel.high,
    bp: '148 / 96 mmHg', pregnancyOrBabyAge: '28 weeks',
    symptoms: ['Severe headache', 'Reduced fetal movement', 'Blurred vision'],
    complications: ['Pre-eclampsia (previous)'],
    overdueCheckup: true,
  ),
  _Patient(
    name: 'Faith Mwale', age: 22, status: 'Prenatal', risk: RiskLevel.high,
    bp: '152 / 98 mmHg', pregnancyOrBabyAge: '34 weeks',
    symptoms: ['Oedema', 'Proteinuria', 'Dizziness'],
    complications: [],
    overdueCheckup: false,
  ),
  _Patient(
    name: 'Mercy Tembo', age: 26, status: 'Neonatal', risk: RiskLevel.medium,
    bp: '118 / 78 mmHg', pregnancyOrBabyAge: 'Baby: 8 days old',
    symptoms: ['Mild fever (37.9°C)', 'Breast tenderness'],
    complications: [],
    overdueCheckup: true,
  ),
  _Patient(
    name: 'Liness Kachali', age: 31, status: 'Prenatal', risk: RiskLevel.medium,
    bp: '126 / 84 mmHg', pregnancyOrBabyAge: '30 weeks',
    symptoms: ['Gestational diabetes', 'Fatigue'],
    complications: ['Gestational diabetes (current)'],
    overdueCheckup: false,
  ),
  _Patient(
    name: 'Rose Phiri', age: 24, status: 'Neonatal', risk: RiskLevel.low,
    bp: '112 / 72 mmHg', pregnancyOrBabyAge: 'Baby: 14 days old',
    symptoms: [],
    complications: [],
    overdueCheckup: false,
  ),
  _Patient(
    name: 'Aisha Tembo', age: 19, status: 'Prenatal', risk: RiskLevel.low,
    bp: '110 / 70 mmHg', pregnancyOrBabyAge: '16 weeks',
    symptoms: ['Mild nausea'],
    complications: [],
    overdueCheckup: false,
  ),
];

// ── Page ──────────────────────────────────────────────────────────────────────

class RiskScoringPage extends StatefulWidget {
  const RiskScoringPage({super.key});

  @override
  State<RiskScoringPage> createState() => _RiskScoringPageState();
}

class _RiskScoringPageState extends State<RiskScoringPage> {
  _Patient? _selected;
  RiskLevel? _filterRisk;
  String _filterStatus = 'All';

  String _search = '';

  List<_Patient> get _filtered => _patients.where((p) {
        if (_filterRisk != null && p.risk != _filterRisk) return false;
        if (_filterStatus != 'All' && p.status != _filterStatus) return false;
        if (_search.isNotEmpty &&
            !p.name.toLowerCase().contains(_search.toLowerCase())) {
          return false;
        }
        return true;
      }).toList();

  @override
  void initState() {
    super.initState();
    _selected = null;
  }

  @override
  Widget build(BuildContext context) {
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

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(children: [
      const Icon(Icons.assessment_outlined, color: AppColors.navy, size: 22),
      const SizedBox(width: 10),
      const Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Risk Monitoring',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
          Text('Track and assess patient risk levels in real time.',
              style: TextStyle(fontSize: 13, color: AppColors.g400)),
        ]),
      ),
      // Status filter
      _filterChip('All', null, isStatus: true),
      const SizedBox(width: 6),
      _filterChip('Prenatal', null, isStatus: true),
      const SizedBox(width: 6),
      _filterChip('Neonatal', null, isStatus: true),
    ]);
  }

  Widget _filterChip(String label, RiskLevel? risk, {bool isStatus = false}) {
    final selected = isStatus ? _filterStatus == label : _filterRisk == risk;
    return GestureDetector(
      onTap: () => setState(() {
        if (isStatus) {
          _filterStatus = label;
        } else {
          _filterRisk = selected ? null : risk;
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.g100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.g600)),
      ),
    );
  }

  // ── Summary cards ────────────────────────────────────────────────────────────

  Widget _buildSummaryRow() {
    final high   = _patients.where((p) => p.risk == RiskLevel.high).length;
    final medium = _patients.where((p) => p.risk == RiskLevel.medium).length;
    final low    = _patients.where((p) => p.risk == RiskLevel.low).length;
    final overdue = _patients.where((p) => p.overdueCheckup).length;

    return Row(children: [
      Expanded(child: _summaryCard('High Risk', '$high', AppColors.red, AppColors.redL,
          Icons.warning_amber_rounded)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Medium Risk', '$medium', AppColors.orange, AppColors.orangeL,
          Icons.info_outline)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Low Risk', '$low', AppColors.green, AppColors.greenL,
          Icons.check_circle_outline)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Overdue Checkups', '$overdue', AppColors.navy, AppColors.navyL,
          Icons.schedule)),
    ]);
  }

  Widget _summaryCard(String label, String value, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.g200)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.g400)),
        ]),
      ]),
    );
  }

  // ── Patient list ─────────────────────────────────────────────────────────────

  Widget _buildPatientList() {
    final list = _filtered;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.people_outline, color: AppColors.navy, size: 18),
            const SizedBox(width: 8),
            Text('Patients (${list.length})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                    color: AppColors.g800)),
            const Spacer(),
            _riskChip('H', RiskLevel.high, AppColors.red, AppColors.redL),
            const SizedBox(width: 4),
            _riskChip('M', RiskLevel.medium, AppColors.orange, AppColors.orangeL),
            const SizedBox(width: 4),
            _riskChip('L', RiskLevel.low, AppColors.green, AppColors.greenL),
          ]),
        ),
        // Search bar
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
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.g200),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No patients match the filter.',
                style: TextStyle(color: AppColors.g400))),
          )
        else
          ...list.map((p) => _patientListItem(p)),
      ]),
    );
  }

  Widget _riskChip(String label, RiskLevel risk, Color color, Color bg) {
    final selected = _filterRisk == risk;
    return GestureDetector(
      onTap: () => setState(() => _filterRisk = selected ? null : risk),
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
            color: selected ? color : bg,
            shape: BoxShape.circle),
        child: Center(
          child: Text(label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : color)),
        ),
      ),
    );
  }

  Widget _patientListItem(_Patient p) {
    final isSelected = _selected?.name == p.name;
    final (riskColor, _, label) = _riskStyle(p.risk);
    return GestureDetector(
      onTap: () => setState(() => _selected = p),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navyL : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AppColors.g200, width: 0.5)),
        ),
        child: Row(children: [
          // Risk level indicator dot (only colored element)
          Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.navyL,
            child: Text(p.name[0],
                style: const TextStyle(color: AppColors.navy, fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(p.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.g800)),
                if (p.overdueCheckup) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                        color: AppColors.orangeL, borderRadius: BorderRadius.circular(4)),
                    child: const Text('Overdue',
                        style: TextStyle(fontSize: 9, color: AppColors.orange,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ]),
              Text('${p.age} yrs · ${p.status}',
                  style: const TextStyle(fontSize: 10, color: AppColors.g400)),
            ]),
          ),
          // Risk label badge — colored per risk level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.g100, borderRadius: BorderRadius.circular(10)),
            child: Text(label,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                    color: riskColor)),
          ),
        ]),
      ),
    );
  }

  // ── Detail panel ─────────────────────────────────────────────────────────────

  Widget _buildDetailPanel() {
    if (_selected == null) return const SizedBox.shrink();
    final p = _selected!;
    final (color, bg, label) = _riskStyle(p.risk);

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Patient header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.navyL, // consistent for all risk levels
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Text(p.name[0],
                  style: const TextStyle(color: AppColors.navy, fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: AppColors.g800)),
              ]),
            ),
            // Risk badge — only this retains risk color
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.g100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.5))),
              child: Row(children: [
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                Text('$label Risk',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ]),
            ),
            const SizedBox(width: 8),
            // Close button
            GestureDetector(
              onTap: () => setState(() => _selected = null),
              child: const Icon(Icons.close, size: 18, color: AppColors.g400),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _detailSection('Clinical Readings', [
              _detailRow(Icons.favorite_border, 'Blood Pressure', p.bp,
                  valueColor: _bpColor(p.bp)),
              _detailRow(Icons.pregnant_woman, p.status == 'Prenatal' ? 'Pregnancy Duration' : 'Baby Age',
                  p.pregnancyOrBabyAge, valueColor: AppColors.navy),
            ]),
            const SizedBox(height: 16),

            if (p.symptoms.isNotEmpty)
              _detailSection('Reported Symptoms', [
                ...p.symptoms.map((s) => _detailRow(Icons.report_outlined, s, '', valueColor: AppColors.g800)),
              ]),

            if (p.complications.isNotEmpty) ...[
              const SizedBox(height: 16),
              _detailSection('Previous / Current Complications', [
                ...p.complications.map((c) => _detailRow(Icons.medical_information_outlined, c, '', valueColor: AppColors.g800)),
              ]),
            ],

            if (p.symptoms.isEmpty && p.complications.isEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.greenL, borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Icon(Icons.check_circle_outline, color: AppColors.green, size: 18),
                  SizedBox(width: 10),
                  Text('No symptoms or complications reported.',
                      style: TextStyle(fontSize: 13, color: AppColors.green)),
                ]),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _alertBanner(_Patient p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.redL,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (p.risk == RiskLevel.high)
          const Row(children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 16),
            SizedBox(width: 8),
            Text('High-risk patient — immediate attention required.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.red)),
          ]),
        if (p.overdueCheckup) ...[
          if (p.risk == RiskLevel.high) const SizedBox(height: 6),
          const Row(children: [
            Icon(Icons.schedule, color: AppColors.orange, size: 16),
            SizedBox(width: 8),
            Text('Checkup is overdue — please schedule immediately.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.orange)),
          ]),
        ],
      ]),
    );
  }

  Widget _detailSection(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 14, color: AppColors.navy,
            margin: const EdgeInsets.only(right: 8)),
        Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800)),
      ]),
      const SizedBox(height: 10),
      ...children,
    ]);
  }

  Widget _detailRow(IconData icon, String label, String value, {Color valueColor = AppColors.g800}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.navy),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g600)),
        ),
        if (value.isNotEmpty)
          Text(value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor)),
      ]),
    );
  }

  Widget _tagRow(String text, Color color, Color bg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(Icons.circle, size: 7, color: color),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  (Color, Color, String) _riskStyle(RiskLevel r) => switch (r) {
        RiskLevel.high   => (AppColors.red,    AppColors.redL,    'High'),
        RiskLevel.medium => (AppColors.orange,  AppColors.orangeL, 'Medium'),
        RiskLevel.low    => (AppColors.green,   AppColors.greenL,  'Low'),
      };

  Color _bpColor(String bp) {
    final parts = bp.replaceAll(RegExp(r'[^0-9/]'), '').split('/');
    if (parts.length < 2) return AppColors.g800;
    final sys = int.tryParse(parts[0]) ?? 0;
    if (sys >= 140) return AppColors.red;
    if (sys >= 130) return AppColors.orange;
    return AppColors.green;
  }
}
