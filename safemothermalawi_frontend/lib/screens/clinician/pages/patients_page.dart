import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

// ── Data models ───────────────────────────────────────────────────────────────

enum RiskLevel { low, medium, high }

class PrenatalPatient {
  final String name, phone, email, nationality, district, zone;
  final int age;
  final int pregnancyMonths;
  final String edd;
  final RiskLevel risk;
  final String bp;
  final List<String> symptoms;

  const PrenatalPatient({
    required this.name, required this.age, required this.phone,
    required this.email, required this.nationality, required this.district,
    required this.zone, required this.pregnancyMonths, required this.edd,
    required this.risk, required this.bp, required this.symptoms,
  });
}

class NeonatalPatient {
  final String name, phone, email, nationality, district, zone;
  final int age;
  final String babyName, babyDob, babyGender, babyAge;
  final RiskLevel risk;
  final String bp;
  final List<String> symptoms;

  const NeonatalPatient({
    required this.name, required this.age, required this.phone,
    required this.email, required this.nationality, required this.district,
    required this.zone, required this.babyName, required this.babyDob,
    required this.babyGender, required this.babyAge,
    required this.risk, required this.bp, required this.symptoms,
  });
}

// ── Sample data ───────────────────────────────────────────────────────────────

const _prenatal = [
  PrenatalPatient(name: 'Grace Banda',    age: 28, phone: '+265 991 234 567', email: 'grace@mail.com',   nationality: 'Malawian', district: 'Zomba',    zone: 'Zomba Central HC',    pregnancyMonths: 7, edd: '15 Jun 2026', risk: RiskLevel.high,   bp: '148/96',  symptoms: ['Severe headache', 'Reduced fetal movement']),
  PrenatalPatient(name: 'Faith Mwale',    age: 22, phone: '+265 888 345 678', email: '',                 nationality: 'Malawian', district: 'Blantyre', zone: 'Queen Elizabeth HC',  pregnancyMonths: 8, edd: '02 May 2026', risk: RiskLevel.high,   bp: '152/98',  symptoms: ['Oedema', 'Proteinuria']),
  PrenatalPatient(name: 'Liness Kachali', age: 31, phone: '+265 999 456 789', email: 'liness@mail.com', nationality: 'Malawian', district: 'Lilongwe', zone: 'Area 18 HC',          pregnancyMonths: 7, edd: '20 Jun 2026', risk: RiskLevel.medium, bp: '126/84',  symptoms: ['Gestational diabetes', 'Fatigue']),
  PrenatalPatient(name: 'Aisha Tembo',    age: 19, phone: '+265 881 567 890', email: '',                 nationality: 'Malawian', district: 'Mzuzu',    zone: 'Mzuzu City HC',       pregnancyMonths: 4, edd: '10 Sep 2026', risk: RiskLevel.low,    bp: '110/70',  symptoms: ['Mild nausea']),
  PrenatalPatient(name: 'Joyce Mwale',    age: 40, phone: '+265 992 678 901', email: 'joyce@mail.com',  nationality: 'Malawian', district: 'Dedza',    zone: 'Dedza District HC',   pregnancyMonths: 6, edd: '30 Jul 2026', risk: RiskLevel.medium, bp: '125/80',  symptoms: ['Fatigue', 'Back pain']),
];

const _neonatal = [
  NeonatalPatient(name: 'Mercy Tembo',   age: 26, phone: '+265 993 111 222', email: 'mercy@mail.com', nationality: 'Malawian', district: 'Zomba',    zone: 'Zomba Central HC',  babyName: 'Baby Tembo',   babyDob: '18 Mar 2026', babyGender: 'Female', babyAge: '8 days',   risk: RiskLevel.medium, bp: '118/78', symptoms: ['Mild fever 37.9°C', 'Breast tenderness']),
  NeonatalPatient(name: 'Rose Phiri',    age: 24, phone: '+265 994 222 333', email: '',               nationality: 'Malawian', district: 'Blantyre', zone: 'Queen Elizabeth HC', babyName: 'Baby Phiri',   babyDob: '12 Mar 2026', babyGender: 'Male',   babyAge: '14 days',  risk: RiskLevel.low,    bp: '112/72', symptoms: []),
  NeonatalPatient(name: 'Fatima Chirwa', age: 19, phone: '+265 995 333 444', email: '',               nationality: 'Malawian', district: 'Lilongwe', zone: 'Area 18 HC',         babyName: 'Baby Chirwa',  babyDob: '20 Mar 2026', babyGender: 'Female', babyAge: '6 days',   risk: RiskLevel.low,    bp: '115/75', symptoms: []),
];

// ── Page ──────────────────────────────────────────────────────────────────────

class ClinicianPatientsPage extends StatefulWidget {
  const ClinicianPatientsPage({super.key});
  @override
  State<ClinicianPatientsPage> createState() => _ClinicianPatientsPageState();
}

class _ClinicianPatientsPageState extends State<ClinicianPatientsPage> {
  final _search = TextEditingController();
  String _filter = 'All'; // All | Prenatal | Neonatal
  Object? _selected;

  @override
  void initState() {
    super.initState();
    _selected = null;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // Combined filtered list — all patients, filtered by search + type
  List<Object> get _filteredAll {
    final q = _search.text.toLowerCase();
    final List<Object> result = [];
    for (final p in _prenatal) {
      if (_filter == 'Neonatal') continue;
      if (q.isNotEmpty && !p.name.toLowerCase().contains(q)) continue;
      result.add(p);
    }
    for (final p in _neonatal) {
      if (_filter == 'Prenatal') continue;
      if (q.isNotEmpty && !p.name.toLowerCase().contains(q)) continue;
      result.add(p);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeader(),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: _selected == null ? 1 : 2,
            child: _buildListPanel(),
          ),
          if (_selected != null) ...[
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _buildDetailPanel()),
          ],
        ]),
      ]),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.people_outline, color: AppColors.navy, size: 22),
      const SizedBox(width: 10),
      const Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Patients',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
          Text('View and manage all patients under your care.',
              style: TextStyle(fontSize: 13, color: AppColors.g400)),
        ]),
      ),
    ]);
  }

  // ── List panel ────────────────────────────────────────────────────────────────

  Widget _buildListPanel() {
    final list = _filteredAll;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(children: [
        // Search + dropdown filter row
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
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
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.g200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filter,
                  style: const TextStyle(fontSize: 12, color: AppColors.g800),
                  icon: const Icon(Icons.filter_list, size: 16, color: AppColors.navy),
                  items: ['All', 'Prenatal', 'Neonatal']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setState(() { _filter = v!; _selected = null; }),
                ),
              ),
            ),
          ]),
        ),
        const Divider(height: 1, color: AppColors.g200),
        // Combined list
        SizedBox(
          height: 480,
          child: list.isEmpty
              ? _emptyState()
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final item = list[i];
                    if (item is PrenatalPatient) {
                      final sel = _selected is PrenatalPatient &&
                          (_selected as PrenatalPatient).name == item.name;
                      return _patientTile(
                        name: item.name, age: item.age,
                        sub: 'Prenatal · ${item.pregnancyMonths} months',
                        selected: sel,
                        onTap: () => setState(() => _selected = item),
                      );
                    } else {
                      final p = item as NeonatalPatient;
                      final sel = _selected is NeonatalPatient &&
                          (_selected as NeonatalPatient).name == p.name;
                      return _patientTile(
                        name: p.name, age: p.age,
                        sub: 'Neonatal · ${p.babyAge} old',
                        selected: sel,
                        onTap: () => setState(() => _selected = p),
                      );
                    }
                  },
                ),
        ),
      ]),
    );
  }



  Widget _emptyState() => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No patients match the filter.',
              style: TextStyle(color: AppColors.g400, fontSize: 13)),
        ),
      );

  Widget _patientTile({
    required String name, required int age, required String sub,
    required bool selected, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.navyL : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AppColors.g200, width: 0.5)),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.navyL,
            child: Text(name[0], style: const TextStyle(
                color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.g800)),
            Text('$age yrs · $sub',
                style: const TextStyle(fontSize: 10, color: AppColors.g400)),
          ])),
        ]),
      ),
    );
  }

  // ── Detail panel ──────────────────────────────────────────────────────────────

  Widget _buildDetailPanel() {
    if (_selected == null) {
      return Container(
        height: 400,
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.g200)),
        child: const Center(child: Text('Select a patient to view details.',
            style: TextStyle(color: AppColors.g400))),
      );
    }
    if (_selected is PrenatalPatient) return _prenatalDetail(_selected as PrenatalPatient);
    return _neonatalDetail(_selected as NeonatalPatient);
  }

  Widget _prenatalDetail(PrenatalPatient p) {
    final (color, bg, label) = _riskStyle(p.risk);
    return Container(
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _detailHeader(p.name, p.age, 'Prenatal', color, bg, label, p.risk),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section('Contact Information', [
              _row(Icons.phone, 'Phone', p.phone),
              if (p.email.isNotEmpty) _row(Icons.email_outlined, 'Email', p.email),
              _row(Icons.flag_outlined, 'Nationality', p.nationality),
            ]),
            const SizedBox(height: 16),
            _section('Location', [
              _row(Icons.location_on_outlined, 'District', p.district),
              _row(Icons.local_hospital_outlined, 'Health Centre / Zone', p.zone),
            ]),
            const SizedBox(height: 16),
            _section('Pregnancy Details', [
              _row(Icons.pregnant_woman, 'Pregnancy Duration', '${p.pregnancyMonths} months'),
              _row(Icons.calendar_today_outlined, 'Expected Delivery Date', p.edd),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showHistory(context, p.name, p.symptoms, p.risk),
                icon: const Icon(Icons.history, size: 16),
                label: const Text('View Patient History'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(color: AppColors.navy),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _neonatalDetail(NeonatalPatient p) {
    final (color, bg, label) = _riskStyle(p.risk);
    return Container(
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _detailHeader(p.name, p.age, 'Neonatal', color, bg, label, p.risk),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section('Mother Details', [
              _row(Icons.phone, 'Phone', p.phone),
              if (p.email.isNotEmpty) _row(Icons.email_outlined, 'Email', p.email),
              _row(Icons.flag_outlined, 'Nationality', p.nationality),
              _row(Icons.location_on_outlined, 'District', p.district),
              _row(Icons.place_outlined, 'Zone', p.zone),
            ]),
            const SizedBox(height: 16),
            _section('Baby Details', [
              _row(Icons.child_friendly_outlined, 'Baby Name', p.babyName),
              _row(Icons.cake_outlined, 'Date of Birth', p.babyDob),
              _row(Icons.wc_outlined, 'Gender', p.babyGender),
              _row(Icons.timelapse_outlined, 'Baby Age', p.babyAge),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showHistory(context, p.name, p.symptoms, p.risk),
                icon: const Icon(Icons.history, size: 16),
                label: const Text('View Patient History'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(color: AppColors.navy),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _detailHeader(String name, int age, String status,
      Color riskColor, Color riskBg, String riskLabel, RiskLevel risk) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.navyL, // consistent for all risk levels
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: Text(name[0], style: const TextStyle(
              color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: AppColors.g800)),
          Text('$age years old · $status',
              style: const TextStyle(fontSize: 12, color: AppColors.g600)),
        ])),
        GestureDetector(
          onTap: () => setState(() => _selected = null),
          child: const Icon(Icons.close, size: 18, color: AppColors.g400),
        ),
      ]),
    );
  }

  Widget _alertBanner(String msg, Color color, Color bg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(Icons.warning_amber_rounded, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color))),
      ]),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 14, color: AppColors.navy,
            margin: const EdgeInsets.only(right: 8)),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
            color: AppColors.g800)),
      ]),
      const SizedBox(height: 10),
      ...children,
    ]);
  }

  Widget _row(IconData icon, String label, String value, {Color valueColor = AppColors.g800}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.navy),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g600)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: valueColor)),
      ]),
    );
  }

  Widget _tag(String text, Color color, Color bg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(Icons.circle, size: 6, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _actions() {
    return Row(children: [
      Expanded(child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.assessment_outlined, size: 15),
        label: const Text('Risk Details', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.navy),
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      )),
      const SizedBox(width: 8),
      Expanded(child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.edit_note, size: 15),
        label: const Text('Update', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.g600,
          side: const BorderSide(color: AppColors.g200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      )),
      const SizedBox(width: 8),
      Expanded(child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.schedule, size: 15),
        label: const Text('Schedule', style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      )),
    ]);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  void _showHistory(BuildContext context, String name, List<String> symptoms, RiskLevel risk) {
    final (riskColor, _, riskLabel) = _riskStyle(risk);

    // Per-patient symptom history with risk level and date/time
    final Map<String, List<Map<String, String>>> symptomHistory = {
      'Grace Banda': [
        {'date': '20 Mar 2026', 'time': '10:14 AM', 'risk': 'High',   'symptoms': 'Severe headache, Reduced fetal movement'},
        {'date': '10 Mar 2026', 'time': '09:00 AM', 'risk': 'Medium', 'symptoms': 'Mild headache, Fatigue'},
        {'date': '01 Mar 2026', 'time': '02:30 PM', 'risk': 'Low',    'symptoms': 'Mild nausea'},
      ],
      'Faith Mwale': [
        {'date': '18 Mar 2026', 'time': '11:00 AM', 'risk': 'High',   'symptoms': 'Oedema, Proteinuria, Dizziness'},
        {'date': '05 Mar 2026', 'time': '03:15 PM', 'risk': 'Medium', 'symptoms': 'Swollen feet'},
      ],
      'Mercy Tembo': [
        {'date': '22 Mar 2026', 'time': '08:45 AM', 'risk': 'Medium', 'symptoms': 'Mild fever 37.9°C, Breast tenderness'},
        {'date': '15 Mar 2026', 'time': '10:00 AM', 'risk': 'Low',    'symptoms': 'Fatigue'},
      ],
      'Liness Kachali': [
        {'date': '19 Mar 2026', 'time': '01:00 PM', 'risk': 'Medium', 'symptoms': 'Gestational diabetes, Fatigue'},
        {'date': '10 Mar 2026', 'time': '09:30 AM', 'risk': 'Low',    'symptoms': 'Back pain'},
      ],
      'Aisha Tembo': [
        {'date': '17 Mar 2026', 'time': '11:30 AM', 'risk': 'Low',    'symptoms': 'Mild nausea'},
      ],
      'Joyce Mwale': [
        {'date': '21 Mar 2026', 'time': '02:00 PM', 'risk': 'Medium', 'symptoms': 'Fatigue, Back pain'},
        {'date': '12 Mar 2026', 'time': '10:45 AM', 'risk': 'Low',    'symptoms': 'Mild fatigue'},
      ],
      'Rose Phiri': [
        {'date': '20 Mar 2026', 'time': '09:00 AM', 'risk': 'Low',    'symptoms': 'No symptoms reported'},
      ],
      'Fatima Chirwa': [
        {'date': '22 Mar 2026', 'time': '08:00 AM', 'risk': 'Low',    'symptoms': 'No symptoms reported'},
      ],
    };

    // Per-patient IVR call history
    final Map<String, List<Map<String, String>>> ivrHistory = {
      'Grace Banda':    [{'date': '20 Mar 2026', 'time': '10:10 AM', 'duration': '3 min 22 sec'}, {'date': '15 Mar 2026', 'time': '02:45 PM', 'duration': '1 min 55 sec'}],
      'Faith Mwale':    [{'date': '18 Mar 2026', 'time': '10:55 AM', 'duration': '2 min 10 sec'}],
      'Mercy Tembo':    [{'date': '22 Mar 2026', 'time': '08:40 AM', 'duration': '1 min 30 sec'}, {'date': '15 Mar 2026', 'time': '09:55 AM', 'duration': '2 min 05 sec'}],
      'Liness Kachali': [{'date': '19 Mar 2026', 'time': '12:55 PM', 'duration': '4 min 00 sec'}],
      'Aisha Tembo':    [{'date': '17 Mar 2026', 'time': '11:25 AM', 'duration': '1 min 10 sec'}],
      'Joyce Mwale':    [{'date': '21 Mar 2026', 'time': '01:55 PM', 'duration': '2 min 45 sec'}],
      'Rose Phiri':     [{'date': '20 Mar 2026', 'time': '08:55 AM', 'duration': '0 min 55 sec'}],
      'Fatima Chirwa':  [{'date': '22 Mar 2026', 'time': '07:55 AM', 'duration': '1 min 20 sec'}],
    };

    final patientSymptoms = symptomHistory[name] ?? [];
    final patientCalls    = ivrHistory[name] ?? [];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.navyL,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(children: [
                const Icon(Icons.history, color: AppColors.navy, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('$name — Patient History',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                        color: AppColors.g800))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 18, color: AppColors.g400),
                ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // ── Symptom & Risk History ──────────────────────────────────
                  _historySection('Symptom & Risk History'),
                  const SizedBox(height: 10),
                  if (patientSymptoms.isEmpty)
                    _historyEmpty('No symptom history recorded.')
                  else
                    ...patientSymptoms.map((e) {
                      final rc = e['risk'] == 'High' ? AppColors.red
                          : e['risk'] == 'Medium' ? AppColors.orange : AppColors.green;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.g200)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(width: 7, height: 7,
                                decoration: BoxDecoration(color: rc, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('${e['risk']} Risk',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                                    color: rc)),
                            const Spacer(),
                            Text('${e['date']}  ·  ${e['time']}',
                                style: const TextStyle(fontSize: 10, color: AppColors.g400)),
                          ]),
                          const SizedBox(height: 6),
                          Text(e['symptoms']!,
                              style: const TextStyle(fontSize: 12, color: AppColors.g800)),
                        ]),
                      );
                    }),

                  const SizedBox(height: 20),

                  // ── IVR Call History ────────────────────────────────────────
                  _historySection('IVR Call History'),
                  const SizedBox(height: 10),
                  if (patientCalls.isEmpty)
                    _historyEmpty('No IVR calls recorded.')
                  else
                    ...patientCalls.map((c) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.g200)),
                          child: Row(children: [
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(color: AppColors.navyL,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.phone_in_talk_outlined,
                                  color: AppColors.navy, size: 17),
                            ),
                            const SizedBox(width: 12),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${c['date']}  ·  ${c['time']}',
                                  style: const TextStyle(fontSize: 12,
                                      fontWeight: FontWeight.w600, color: AppColors.g800)),
                              const SizedBox(height: 2),
                              Text('Duration: ${c['duration']}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.g400)),
                            ]),
                          ]),
                        )),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _historySection(String title) {
    return Row(children: [
      Container(width: 3, height: 14, color: AppColors.navy,
          margin: const EdgeInsets.only(right: 8)),
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
          color: AppColors.g800)),
    ]);
  }

  Widget _historyEmpty(String msg) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(msg, style: const TextStyle(fontSize: 12, color: AppColors.g400)),
      );

  (Color, Color, String) _riskStyle(RiskLevel r) => switch (r) {
        RiskLevel.high   => (AppColors.red,    AppColors.redL,    'High'),
        RiskLevel.medium => (AppColors.orange,  AppColors.orangeL, 'Medium'),
        RiskLevel.low    => (AppColors.green,   AppColors.greenL,  'Low'),
      };

  Color _bpColor(String bp) {
    final parts = bp.split('/');
    if (parts.isEmpty) return AppColors.g800;
    final sys = int.tryParse(parts[0].trim()) ?? 0;
    if (sys >= 140) return AppColors.red;
    if (sys >= 130) return AppColors.orange;
    return AppColors.green;
  }
}
