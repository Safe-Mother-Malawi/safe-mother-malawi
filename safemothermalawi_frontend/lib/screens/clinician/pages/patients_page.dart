import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/animated_pulse_dot.dart';

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

class PostnatalPatient {
  final String name, phone, email, nationality, district, zone;
  final int age;
  final String babyName, babyDob, babyGender, babyAge;
  final RiskLevel risk;
  final String bp;
  final List<String> symptoms;

  const PostnatalPatient({
    required this.name, required this.age, required this.phone,
    required this.email, required this.nationality, required this.district,
    required this.zone, required this.babyName, required this.babyDob,
    required this.babyGender, required this.babyAge,
    required this.risk, required this.bp, required this.symptoms,
  });
}

// ── Sample data ───────────────────────────────────────────────────────────────

const _prenatal = [
  PrenatalPatient(name: 'Grace Banda',    age: 28, phone: '+265 991 234 567', email: 'grace@mail.com',   nationality: 'Malawian', district: 'Zomba',    zone: 'Zomba Central HC', pregnancyMonths: 7, edd: '15 Jun 2026', risk: RiskLevel.high,   bp: '148/96',  symptoms: ['Severe headache', 'Reduced fetal movement']),
  PrenatalPatient(name: 'Faith Mwale',    age: 22, phone: '+265 888 345 678', email: '',                 nationality: 'Malawian', district: 'Blantyre', zone: 'Queen Elizabeth HC', pregnancyMonths: 8, edd: '02 May 2026', risk: RiskLevel.high,   bp: '152/98',  symptoms: ['Oedema', 'Proteinuria']),
  PrenatalPatient(name: 'Liness Kachali', age: 31, phone: '+265 999 456 789', email: 'liness@mail.com', nationality: 'Malawian', district: 'Lilongwe', zone: 'Area 18 HC',        pregnancyMonths: 7, edd: '20 Jun 2026', risk: RiskLevel.medium, bp: '126/84',  symptoms: ['Gestational diabetes', 'Fatigue']),
  PrenatalPatient(name: 'Aisha Tembo',    age: 19, phone: '+265 881 567 890', email: '',                 nationality: 'Malawian', district: 'Mzuzu',    zone: 'Mzuzu City HC',    pregnancyMonths: 4, edd: '10 Sep 2026', risk: RiskLevel.low,    bp: '110/70',  symptoms: ['Mild nausea']),
  PrenatalPatient(name: 'Joyce Mwale',    age: 40, phone: '+265 992 678 901', email: 'joyce@mail.com',  nationality: 'Malawian', district: 'Dedza',    zone: 'Dedza District HC', pregnancyMonths: 6, edd: '30 Jul 2026', risk: RiskLevel.medium, bp: '125/80',  symptoms: ['Fatigue', 'Back pain']),
];

const _postnatal = [
  PostnatalPatient(name: 'Mercy Tembo',   age: 26, phone: '+265 993 111 222', email: 'mercy@mail.com', nationality: 'Malawian', district: 'Zomba',    zone: 'Zomba Central HC',  babyName: 'Baby Tembo',   babyDob: '18 Mar 2026', babyGender: 'Female', babyAge: '8 days',   risk: RiskLevel.medium, bp: '118/78', symptoms: ['Mild fever 37.9°C', 'Breast tenderness']),
  PostnatalPatient(name: 'Rose Phiri',    age: 24, phone: '+265 994 222 333', email: '',               nationality: 'Malawian', district: 'Blantyre', zone: 'Queen Elizabeth HC', babyName: 'Baby Phiri',   babyDob: '12 Mar 2026', babyGender: 'Male',   babyAge: '14 days',  risk: RiskLevel.low,    bp: '112/72', symptoms: []),
  PostnatalPatient(name: 'Fatima Chirwa', age: 19, phone: '+265 995 333 444', email: '',               nationality: 'Malawian', district: 'Lilongwe', zone: 'Area 18 HC',         babyName: 'Baby Chirwa',  babyDob: '20 Mar 2026', babyGender: 'Female', babyAge: '6 days',   risk: RiskLevel.low,    bp: '115/75', symptoms: []),
];

// ── Page ──────────────────────────────────────────────────────────────────────

class ClinicianPatientsPage extends StatefulWidget {
  const ClinicianPatientsPage({super.key});
  @override
  State<ClinicianPatientsPage> createState() => _ClinicianPatientsPageState();
}

class _ClinicianPatientsPageState extends State<ClinicianPatientsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _search = TextEditingController();
  RiskLevel? _riskFilter;
  String? _districtFilter;
  Object? _selected; // PrenatalPatient | PostnatalPatient

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    _selected = null;
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _search.dispose();
    super.dispose();
  }

  List<PrenatalPatient> get _filteredPrenatal => _prenatal.where((p) {
        if (_riskFilter != null && p.risk != _riskFilter) return false;
        if (_districtFilter != null && p.district != _districtFilter) return false;
        if (_search.text.isNotEmpty &&
            !p.name.toLowerCase().contains(_search.text.toLowerCase())) return false;
        return true;
      }).toList();

  List<PostnatalPatient> get _filteredPostnatal => _postnatal.where((p) {
        if (_riskFilter != null && p.risk != _riskFilter) return false;
        if (_districtFilter != null && p.district != _districtFilter) return false;
        if (_search.text.isNotEmpty &&
            !p.name.toLowerCase().contains(_search.text.toLowerCase())) return false;
        return true;
      }).toList();

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
    final allDistricts = {
      ..._prenatal.map((p) => p.district),
      ..._postnatal.map((p) => p.district),
    }.toList()..sort();

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.people_outline, color: AppColors.navy, size: 22),
      const SizedBox(width: 10),
      const Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('My Patients',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
          Text('View and manage all patients under your care.',
              style: TextStyle(fontSize: 13, color: AppColors.g400)),
        ]),
      ),
      // Risk filter
      _chip('All Risk', null, isRisk: true),
      const SizedBox(width: 6),
      _chip('High', RiskLevel.high, isRisk: true),
      const SizedBox(width: 6),
      _chip('Medium', RiskLevel.medium, isRisk: true),
      const SizedBox(width: 6),
      _chip('Low', RiskLevel.low, isRisk: true),
      const SizedBox(width: 12),
      // District filter
      DropdownButton<String>(
        value: _districtFilter,
        hint: const Text('District', style: TextStyle(fontSize: 12, color: AppColors.g600)),
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 12, color: AppColors.g800),
        items: [
          const DropdownMenuItem(value: null, child: Text('All Districts')),
          ...allDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))),
        ],
        onChanged: (v) => setState(() => _districtFilter = v),
      ),
    ]);
  }

  Widget _chip(String label, RiskLevel? risk, {bool isRisk = false}) {
    final selected = isRisk
        ? (risk == null ? _riskFilter == null : _riskFilter == risk)
        : false;
    Color color = AppColors.navy;
    if (risk == RiskLevel.high) color = AppColors.red;
    if (risk == RiskLevel.medium) color = AppColors.amber;
    if (risk == RiskLevel.low) color = AppColors.green;

    return GestureDetector(
      onTap: () => setState(() => _riskFilter = (selected && risk != null) ? null : risk),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.g100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.g600)),
      ),
    );
  }

  // ── List panel ────────────────────────────────────────────────────────────────

  Widget _buildListPanel() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(children: [
        // Search
        Padding(
          padding: const EdgeInsets.all(12),
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
        // Tabs
        Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.g200))),
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppColors.navy,
            unselectedLabelColor: AppColors.g400,
            indicatorColor: AppColors.navy,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Prenatal (${_filteredPrenatal.length})'),
              Tab(text: 'Postnatal (${_filteredPostnatal.length})'),
            ],
          ),
        ),
        SizedBox(
          height: 480,
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _prenatalList(),
              _postnatalList(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _prenatalList() {
    final list = _filteredPrenatal;
    if (list.isEmpty) return _emptyState();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final p = list[i];
        final sel = _selected is PrenatalPatient && (_selected as PrenatalPatient).name == p.name;
        return _patientTile(
          name: p.name, age: p.age, sub: '${p.pregnancyMonths} months · ${p.district}',
          risk: p.risk, selected: sel,
          onTap: () => setState(() => _selected = p),
        );
      },
    );
  }

  Widget _postnatalList() {
    final list = _filteredPostnatal;
    if (list.isEmpty) return _emptyState();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final p = list[i];
        final sel = _selected is PostnatalPatient && (_selected as PostnatalPatient).name == p.name;
        return _patientTile(
          name: p.name, age: p.age, sub: '${p.babyAge} old · ${p.district}',
          risk: p.risk, selected: sel,
          onTap: () => setState(() => _selected = p),
        );
      },
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
    required RiskLevel risk, required bool selected, required VoidCallback onTap,
  }) {
    final (color, bg, label) = _riskStyle(risk);
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
          if (risk == RiskLevel.high)
            Padding(padding: const EdgeInsets.only(right: 6),
                child: AnimatedPulseDot(color: AppColors.red, size: 6)),
          CircleAvatar(radius: 15, backgroundColor: bg,
              child: Text(name[0], style: TextStyle(color: color, fontSize: 11,
                  fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.g800)),
            Text('$age yrs · $sub',
                style: const TextStyle(fontSize: 10, color: AppColors.g400)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                color: color)),
          ),
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
    return _postnatalDetail(_selected as PostnatalPatient);
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
            if (p.risk == RiskLevel.high) _alertBanner('High-risk patient — immediate attention required.', AppColors.red, AppColors.redL),
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
              _row(Icons.favorite_border, 'Blood Pressure', p.bp,
                  valueColor: _bpColor(p.bp)),
            ]),
            if (p.symptoms.isNotEmpty) ...[
              const SizedBox(height: 16),
              _section('Reported Symptoms',
                  p.symptoms.map((s) => _tag(s, AppColors.amber, AppColors.amberL)).toList()),
            ],
            const SizedBox(height: 20),
            _actions(),
          ]),
        ),
      ]),
    );
  }

  Widget _postnatalDetail(PostnatalPatient p) {
    final (color, bg, label) = _riskStyle(p.risk);
    return Container(
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _detailHeader(p.name, p.age, 'Postnatal', color, bg, label, p.risk),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (p.risk == RiskLevel.medium || p.risk == RiskLevel.high)
              _alertBanner('Patient requires close monitoring.', AppColors.amber, AppColors.amberL),
            _section('Mother Contact', [
              _row(Icons.phone, 'Phone', p.phone),
              if (p.email.isNotEmpty) _row(Icons.email_outlined, 'Email', p.email),
              _row(Icons.flag_outlined, 'Nationality', p.nationality),
              _row(Icons.location_on_outlined, 'District', p.district),
              _row(Icons.place_outlined, 'Zone', p.zone),
              _row(Icons.favorite_border, 'Blood Pressure', p.bp,
                  valueColor: _bpColor(p.bp)),
            ]),
            const SizedBox(height: 16),
            _section('Baby Details', [
              _row(Icons.child_friendly_outlined, 'Baby Name', p.babyName),
              _row(Icons.cake_outlined, 'Date of Birth', p.babyDob),
              _row(Icons.wc_outlined, 'Gender', p.babyGender),
              _row(Icons.timelapse_outlined, 'Baby Age', p.babyAge),
            ]),
            if (p.symptoms.isNotEmpty) ...[
              const SizedBox(height: 16),
              _section('Reported Symptoms',
                  p.symptoms.map((s) => _tag(s, AppColors.amber, AppColors.amberL)).toList()),
            ],
            const SizedBox(height: 20),
            _actions(),
          ]),
        ),
      ]),
    );
  }

  Widget _detailHeader(String name, int age, String status,
      Color color, Color bg, String label, RiskLevel risk) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: risk == RiskLevel.high ? AppColors.redL : AppColors.navyL,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(children: [
        CircleAvatar(radius: 22, backgroundColor: bg,
            child: Text(name[0], style: TextStyle(color: color, fontSize: 16,
                fontWeight: FontWeight.bold))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: AppColors.g800)),
          Text('$age years old · $status',
              style: const TextStyle(fontSize: 12, color: AppColors.g600)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4))),
          child: Row(children: [
            if (risk == RiskLevel.high)
              Padding(padding: const EdgeInsets.only(right: 6),
                  child: AnimatedPulseDot(color: color, size: 7)),
            Text('$label Risk', style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.bold, color: color)),
          ]),
        ),
        const SizedBox(width: 8),
        // Close detail panel
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

  (Color, Color, String) _riskStyle(RiskLevel r) => switch (r) {
        RiskLevel.high   => (AppColors.red,   AppColors.redL,   'High'),
        RiskLevel.medium => (AppColors.amber,  AppColors.amberL, 'Medium'),
        RiskLevel.low    => (AppColors.green,  AppColors.greenL, 'Low'),
      };

  Color _bpColor(String bp) {
    final parts = bp.split('/');
    if (parts.isEmpty) return AppColors.g800;
    final sys = int.tryParse(parts[0].trim()) ?? 0;
    if (sys >= 140) return AppColors.red;
    if (sys >= 130) return AppColors.amber;
    return AppColors.green;
  }
}
