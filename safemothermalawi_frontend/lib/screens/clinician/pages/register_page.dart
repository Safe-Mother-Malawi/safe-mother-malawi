import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ClinicianRegisterPage extends StatefulWidget {
  const ClinicianRegisterPage({super.key});

  @override
  State<ClinicianRegisterPage> createState() => _ClinicianRegisterPageState();
}

class _ClinicianRegisterPageState extends State<ClinicianRegisterPage> {
  int _tab = 0; // 0 = Prenatal, 1 = Neonatal

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          const Icon(Icons.person_add_outlined, color: AppColors.navy, size: 22),
          const SizedBox(width: 10),
          const Text('Register Patient',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
        ]),
        const SizedBox(height: 6),
        const Text('Fill in the patient details below to register them into the system.',
            style: TextStyle(fontSize: 13, color: AppColors.g400)),
        const SizedBox(height: 24),

        // Tab toggle
        Container(
          decoration: BoxDecoration(
              color: AppColors.g100, borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(4),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _tabBtn(0, Icons.pregnant_woman, 'Prenatal (Pregnant)'),
            const SizedBox(width: 4),
            _tabBtn(1, Icons.child_friendly_outlined, 'Neonatal (Neonatal)'),
          ]),
        ),
        const SizedBox(height: 24),

        // Form card
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.g200)),
          padding: const EdgeInsets.all(28),
          child: _tab == 0 ? const _PrenatalForm() : const _NeonatalForm(),
        ),
      ]),
    );
  }

  Widget _tabBtn(int index, IconData icon, String label) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: selected ? Colors.white : AppColors.g600),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? Colors.white : AppColors.g600)),
        ]),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

const _districts = [
  'Blantyre', 'Chikwawa', 'Chiradzulu', 'Chitipa', 'Dedza', 'Dowa',
  'Karonga', 'Kasungu', 'Likoma', 'Lilongwe', 'Machinga', 'Mangochi',
  'Mchinji', 'Mulanje', 'Mwanza', 'Mzimba', 'Neno', 'Nkhata Bay',
  'Nkhotakota', 'Nsanje', 'Ntcheu', 'Ntchisi', 'Phalombe', 'Rumphi',
  'Salima', 'Thyolo', 'Zomba',
];
Widget _sectionTitle(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(children: [
        Container(width: 3, height: 16, color: AppColors.navy,
            margin: const EdgeInsets.only(right: 10)),
        Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
      ]),
    );

Widget _field(String label, TextEditingController ctrl,
    {bool required = true,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? hint}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800),
        children: required
            ? [const TextSpan(text: ' *', style: TextStyle(color: AppColors.red))]
            : [],
      ),
    ),
    const SizedBox(height: 6),
    TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint ?? 'Enter $label',
        hintStyle: const TextStyle(color: AppColors.g400, fontSize: 13),
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.g200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.g200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.navy, width: 1.5)),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
          : null,
    ),
  ]);
}

Widget _dropdown(String label, String? value, List<String> items,
    void Function(String?) onChanged,
    {bool required = true}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800),
        children: required
            ? [const TextSpan(text: ' *', style: TextStyle(color: AppColors.red))]
            : [],
      ),
    ),
    const SizedBox(height: 6),
    DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.g200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.g200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.navy, width: 1.5)),
      ),
      hint: Text('Select $label',
          style: const TextStyle(color: AppColors.g400, fontSize: 13)),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
          .toList(),
      onChanged: onChanged,
      validator: required ? (v) => v == null ? '$label is required' : null : null,
    ),
  ]);
}

// ── Prenatal Form ─────────────────────────────────────────────────────────────

class _PrenatalForm extends StatefulWidget {
  const _PrenatalForm();
  @override
  State<_PrenatalForm> createState() => _PrenatalFormState();
}

class _PrenatalFormState extends State<_PrenatalForm> {
  final _formKey = GlobalKey<FormState>();
  final _name     = TextEditingController();
  final _age      = TextEditingController();
  final _phone    = TextEditingController();
  final _email    = TextEditingController();
  final _nationality = TextEditingController();
  final _zone     = TextEditingController();
  final _pregMonths = TextEditingController();
  String? _district;
  DateTime? _edd;

  @override
  void dispose() {
    for (final c in [_name, _age, _phone, _email, _nationality, _zone, _pregMonths]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickEDD() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 300)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.navy),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _edd = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _edd != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prenatal patient "${_name.text}" registered successfully.'),
          backgroundColor: AppColors.green,
        ),
      );
      _formKey.currentState!.reset();
      setState(() { _district = null; _edd = null; });
    } else if (_edd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an Expected Delivery Date.'),
            backgroundColor: AppColors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Mother Information'),
        _twoCol(_field('Full Name', _name), _field('Age', _age, keyboard: TextInputType.number)),
        const SizedBox(height: 16),
        _twoCol(_field('Phone Number', _phone, keyboard: TextInputType.phone),
            _field('Email', _email, required: false, hint: 'Optional')),
        const SizedBox(height: 16),
        _twoCol(_field('Nationality', _nationality),
            _dropdown('District', _district, _districts, (v) => setState(() => _district = v))),
        const SizedBox(height: 16),
        _field('Health Centre / Zone', _zone),
        const SizedBox(height: 24),
        _sectionTitle('Pregnancy Details'),
        _twoCol(
          _field('Pregnancy Duration (months)', _pregMonths, keyboard: TextInputType.number),
          // EDD date picker
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Expected Delivery Date *',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickEDD,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _edd == null ? AppColors.g200 : AppColors.navy),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.navy),
                  const SizedBox(width: 10),
                  Text(
                    _edd == null
                        ? 'Select date'
                        : '${_edd!.day}/${_edd!.month}/${_edd!.year}',
                    style: TextStyle(
                        fontSize: 13,
                        color: _edd == null ? AppColors.g400 : AppColors.g800),
                  ),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 28),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: () {
              _formKey.currentState!.reset();
              setState(() { _district = null; _edd = null; });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.g600,
              side: const BorderSide(color: AppColors.g200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Register Patient'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ]),
      ]),
    );
  }
}

Widget _twoCol(Widget a, Widget b) {
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: a),
    const SizedBox(width: 16),
    Expanded(child: b),
  ]);
}

// ── Neonatal Form ────────────────────────────────────────────────────────────

class _NeonatalForm extends StatefulWidget {
  const _NeonatalForm();
  @override
  State<_NeonatalForm> createState() => _NeonatalFormState();
}

class _NeonatalFormState extends State<_NeonatalForm> {
  final _formKey    = GlobalKey<FormState>();
  final _mName      = TextEditingController();
  final _mAge       = TextEditingController();
  final _mPhone     = TextEditingController();
  final _mEmail     = TextEditingController();
  final _mNationality = TextEditingController();
  final _mZone      = TextEditingController();
  final _bName      = TextEditingController();
  String? _mDistrict;
  String? _bGender;
  DateTime? _bDob;

  String get _babyAge {
    if (_bDob == null) return '';
    final now = DateTime.now();
    final diff = now.difference(_bDob!);
    final days = diff.inDays;
    if (days < 7) return '$days day${days == 1 ? '' : 's'} old';
    if (days < 30) {
      final weeks = (days / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} old';
    }
    final months = (days / 30.44).floor();
    return '$months month${months == 1 ? '' : 's'} old';
  }

  @override
  void dispose() {
    for (final c in [_mName, _mAge, _mPhone, _mEmail, _mNationality, _mZone, _bName]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.navy),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _bDob = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _bDob != null && _bGender != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Neonatal patient "${_mName.text}" registered successfully.'),
          backgroundColor: AppColors.green,
        ),
      );
      _formKey.currentState!.reset();
      setState(() { _mDistrict = null; _bGender = null; _bDob = null; });
    } else {
      final missing = <String>[];
      if (_bDob == null) missing.add('Baby Date of Birth');
      if (_bGender == null) missing.add('Baby Gender');
      if (missing.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill: ${missing.join(', ')}'),
              backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Mother Details'),
        _twoCol(_field('Full Name', _mName), _field('Age', _mAge, keyboard: TextInputType.number)),
        const SizedBox(height: 16),
        _twoCol(_field('Phone Number', _mPhone, keyboard: TextInputType.phone),
            _field('Email', _mEmail, required: false, hint: 'Optional')),
        const SizedBox(height: 16),
        _twoCol(_field('Nationality', _mNationality),
            _dropdown('District', _mDistrict, _districts, (v) => setState(() => _mDistrict = v))),
        const SizedBox(height: 16),
        _field('Zone', _mZone),
        const SizedBox(height: 24),
        _sectionTitle('Baby Details'),
        _twoCol(_field('Baby Name', _bName),
            _dropdown('Baby Gender', _bGender, ['Male', 'Female'],
                (v) => setState(() => _bGender = v))),
        const SizedBox(height: 16),
        _twoCol(
          // Baby DOB picker
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Baby Date of Birth *',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDob,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _bDob == null ? AppColors.g200 : AppColors.navy),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.navy),
                  const SizedBox(width: 10),
                  Text(
                    _bDob == null
                        ? 'Select date'
                        : '${_bDob!.day}/${_bDob!.month}/${_bDob!.year}',
                    style: TextStyle(
                        fontSize: 13,
                        color: _bDob == null ? AppColors.g400 : AppColors.g800),
                  ),
                ]),
              ),
            ),
          ]),
          // Auto-calculated baby age
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Baby Age',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.navyL,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.g200),
              ),
              child: Row(children: [
                const Icon(Icons.child_friendly_outlined, size: 16, color: AppColors.navy),
                const SizedBox(width: 10),
                Text(
                  _bDob == null ? 'Auto-calculated' : _babyAge,
                  style: TextStyle(
                      fontSize: 13,
                      color: _bDob == null ? AppColors.g400 : AppColors.navy,
                      fontWeight: _bDob != null ? FontWeight.w600 : FontWeight.normal),
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 28),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: () {
              _formKey.currentState!.reset();
              setState(() { _mDistrict = null; _bGender = null; _bDob = null; });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.g600,
              side: const BorderSide(color: AppColors.g200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Register Patient'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ]),
      ]),
    );
  }
}
