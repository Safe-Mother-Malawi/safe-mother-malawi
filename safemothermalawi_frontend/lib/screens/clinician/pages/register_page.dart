import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../state/user_store.dart';

class ClinicianRegisterPage extends StatefulWidget {
  const ClinicianRegisterPage({super.key});
  @override
  State<ClinicianRegisterPage> createState() => _ClinicianRegisterPageState();
}

class _ClinicianRegisterPageState extends State<ClinicianRegisterPage> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        Container(
          decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(4),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _tabBtn(0, Icons.pregnant_woman, 'Prenatal'),
            const SizedBox(width: 4),
            _tabBtn(1, Icons.child_friendly_outlined, 'Neonatal'),
          ]),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.g200)),
          padding: const EdgeInsets.all(28),
          child: _tab == 0 ? const _PrenatalForm() : const _NeonatalForm(),
        ),
      ]),
    );
  }

  Widget _tabBtn(int index, IconData icon, String label) {
    final sel = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? AppColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: sel ? Colors.white : AppColors.g600),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13,
              fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
              color: sel ? Colors.white : AppColors.g600)),
        ]),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _sectionTitle(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 16, top: 8),
  child: Row(children: [
    Container(width: 3, height: 16, color: AppColors.navy, margin: const EdgeInsets.only(right: 10)),
    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
  ]),
);

Widget _field(String label, TextEditingController ctrl,
    {bool required = true, TextInputType keyboard = TextInputType.text,
    int maxLines = 1, String? hint}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    RichText(text: TextSpan(text: label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800),
        children: required ? [const TextSpan(text: ' *', style: TextStyle(color: AppColors.red))] : [])),
    const SizedBox(height: 6),
    TextFormField(
      controller: ctrl, keyboardType: keyboard, maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint ?? 'Enter $label',
        hintStyle: const TextStyle(color: AppColors.g400, fontSize: 13),
        filled: true, fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.g200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.g200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.navy, width: 1.5)),
      ),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null,
    ),
  ]);
}

Widget _readOnly(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
  const SizedBox(height: 6),
  Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.3))),
    child: Row(children: [
      const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.navy),
      const SizedBox(width: 8),
      Text(value, style: const TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600)),
    ]),
  ),
]);

Widget _cascadeDrop(String label, String? value, List<String> items,
    void Function(String?) onChanged, {bool required = true, bool enabled = true, String? hint}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    RichText(text: TextSpan(text: label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800),
        children: required ? [const TextSpan(text: ' *', style: TextStyle(color: AppColors.red))] : [])),
    const SizedBox(height: 6),
    IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: enabled ? onChanged : null,
          hint: Text(hint ?? 'Select $label', style: const TextStyle(color: AppColors.g400, fontSize: 13)),
          decoration: InputDecoration(
            filled: true, fillColor: AppColors.bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.g200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.g200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.navy, width: 1.5)),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          validator: required ? (v) => v == null ? '$label is required' : null : null,
        ),
      ),
    ),
  ]);
}

Widget _twoCol(Widget a, Widget b) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Expanded(child: a), const SizedBox(width: 16), Expanded(child: b),
]);

// ── Location mixin — shared by both forms ─────────────────────────────────────

mixin _LocationMixin<T extends StatefulWidget> on State<T> {
  // District is always the clinician's own district
  String get _myDistrict => UserStore.instance.district.isNotEmpty
      ? UserStore.instance.district
      : 'My District';

  String? _zone;
  String? _facilityName;
  String? _facilityType;
  String? _urbanRural;

  List<String> _zones      = [];
  List<Map<String, dynamic>> _facilities = [];
  bool _loadingZones       = false;
  bool _loadingFacilities  = false;

  Future<void> loadZones() async {
    setState(() { _loadingZones = true; _zones = []; _zone = null; _facilityName = null; });
    try {
      // Get zones for the clinician's district by querying facilities
      final data = await ApiService.getFacilitiesByDistrict(_myDistrict);
      final facilities = data.cast<Map<String, dynamic>>();
      final zoneSet = <String>{};
      for (final f in facilities) {
        final z = f['zone']?.toString();
        if (z != null && z.isNotEmpty) zoneSet.add(z);
      }
      if (mounted) setState(() { _zones = zoneSet.toList()..sort(); _loadingZones = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingZones = false);
    }
  }

  Future<void> onZoneChanged(String? zone) async {
    setState(() { _zone = zone; _facilityName = null; _facilityType = null; _urbanRural = null; _facilities = []; });
    if (zone == null) return;
    setState(() => _loadingFacilities = true);
    try {
      final data = await ApiService.getFacilitiesByDistrict(_myDistrict);
      final all = data.cast<Map<String, dynamic>>();
      final filtered = all.where((f) => f['zone']?.toString() == zone).toList();
      if (mounted) setState(() { _facilities = filtered; _loadingFacilities = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingFacilities = false);
    }
  }

  Future<void> onFacilitySelected(String? name) async {
    if (name == null) return;
    setState(() { _facilityName = name; _facilityType = null; _urbanRural = null; });
    final f = await ApiService.lookupFacility(name);
    if (f != null && mounted) {
      setState(() {
        _facilityType = f['facilityType']?.toString();
        _urbanRural   = f['urbanRural']?.toString();
      });
    }
  }

  List<Widget> buildLocationFields() => [
    _readOnly('District', _myDistrict),
    const SizedBox(height: 16),
    _loadingZones
        ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        : _cascadeDrop('Zone', _zone, _zones, onZoneChanged,
            hint: _zones.isEmpty ? 'Loading zones...' : 'Select zone'),
    const SizedBox(height: 16),
    _loadingFacilities
        ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        : _cascadeDrop('Health Facility', _facilityName,
            _facilities.map((f) => f['facilityName']?.toString() ?? '').toList(),
            onFacilitySelected,
            enabled: _zone != null,
            hint: _zone == null ? 'Select zone first' : 'Select facility'),
    if (_facilityType != null) ...[
      const SizedBox(height: 16),
      _twoCol(
        _readOnly('Facility Type', _facilityType!),
        _readOnly('Urban / Rural', _urbanRural ?? '—'),
      ),
    ],
  ];
}

// ── Prenatal Form ─────────────────────────────────────────────────────────────

class _PrenatalForm extends StatefulWidget {
  const _PrenatalForm();
  @override
  State<_PrenatalForm> createState() => _PrenatalFormState();
}

class _PrenatalFormState extends State<_PrenatalForm> with _LocationMixin {
  final _formKey     = GlobalKey<FormState>();
  final _name        = TextEditingController();
  final _age         = TextEditingController();
  final _phone       = TextEditingController();
  final _email       = TextEditingController();
  final _nationality = TextEditingController();
  final _pregMonths  = TextEditingController();
  DateTime? _edd;
  bool _saving = false;

  @override
  void initState() { super.initState(); loadZones(); }

  @override
  void dispose() {
    for (final c in [_name, _age, _phone, _email, _nationality, _pregMonths]) c.dispose();
    super.dispose();
  }

  Future<void> _pickEDD() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 300)),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.navy)), child: child!),
    );
    if (picked != null) setState(() => _edd = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_edd == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select an Expected Delivery Date.'), backgroundColor: AppColors.red));
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.createPrenatalPatient({
        'fullName':            _name.text.trim(),
        'age':                 _age.text.trim(),
        'phone':               _phone.text.trim(),
        'email':               _email.text.trim(),
        'nationality':         _nationality.text.trim(),
        'district':            _myDistrict,
        'healthCentre':        _facilityName ?? '',
        'pregnancyMonths':     _pregMonths.text.trim(),
        'expectedDeliveryDate': '${_edd!.year}-${_edd!.month.toString().padLeft(2,'0')}-${_edd!.day.toString().padLeft(2,'0')}',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Prenatal patient "${_name.text}" registered successfully.'),
          backgroundColor: AppColors.green));
        _formKey.currentState!.reset();
        setState(() { _edd = null; _zone = null; _facilityName = null; _facilityType = null; _urbanRural = null; _facilities = []; });
        loadZones();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
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
        _field('Nationality', _nationality),
        const SizedBox(height: 24),
        _sectionTitle('Location'),
        ...buildLocationFields(),
        const SizedBox(height: 24),
        _sectionTitle('Pregnancy Details'),
        _twoCol(
          _field('Pregnancy Duration (months)', _pregMonths, keyboard: TextInputType.number),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Expected Delivery Date *',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickEDD,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _edd == null ? AppColors.g200 : AppColors.navy)),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.navy),
                  const SizedBox(width: 10),
                  Text(_edd == null ? 'Select date' : '${_edd!.day}/${_edd!.month}/${_edd!.year}',
                      style: TextStyle(fontSize: 13, color: _edd == null ? AppColors.g400 : AppColors.g800)),
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
              setState(() { _edd = null; _zone = null; _facilityName = null; _facilityType = null; _urbanRural = null; _facilities = []; });
              loadZones();
            },
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.g600,
                side: const BorderSide(color: AppColors.g200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Clear'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check, size: 16),
            label: Text(_saving ? 'Registering...' : 'Register Patient'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
          ),
        ]),
      ]),
    );
  }
}

// ── Neonatal Form ─────────────────────────────────────────────────────────────

class _NeonatalForm extends StatefulWidget {
  const _NeonatalForm();
  @override
  State<_NeonatalForm> createState() => _NeonatalFormState();
}

class _NeonatalFormState extends State<_NeonatalForm> with _LocationMixin {
  final _formKey      = GlobalKey<FormState>();
  final _mName        = TextEditingController();
  final _mAge         = TextEditingController();
  final _mPhone       = TextEditingController();
  final _mEmail       = TextEditingController();
  final _mNationality = TextEditingController();
  final _bName        = TextEditingController();
  final _bWeight      = TextEditingController();
  String? _bGender;
  DateTime? _bDob;
  bool _saving = false;

  String get _babyAge {
    if (_bDob == null) return '';
    final days = DateTime.now().difference(_bDob!).inDays;
    if (days < 7) return '$days day${days == 1 ? '' : 's'} old';
    if (days < 30) { final w = (days / 7).floor(); return '$w week${w == 1 ? '' : 's'} old'; }
    final m = (days / 30.44).floor(); return '$m month${m == 1 ? '' : 's'} old';
  }

  @override
  void initState() { super.initState(); loadZones(); }

  @override
  void dispose() {
    for (final c in [_mName, _mAge, _mPhone, _mEmail, _mNationality, _bName, _bWeight]) c.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.navy)), child: child!),
    );
    if (picked != null) setState(() => _bDob = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_bDob == null || _bGender == null) {
      final missing = [if (_bDob == null) 'Baby Date of Birth', if (_bGender == null) 'Baby Gender'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please fill: ${missing.join(', ')}'), backgroundColor: AppColors.red));
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.createNeonatalPatient({
        'motherName':     _mName.text.trim(),
        'motherAge':      _mAge.text.trim(),
        'motherPhone':    _mPhone.text.trim(),
        'motherEmail':    _mEmail.text.trim(),
        'nationality': _mNationality.text.trim(),
        'district':       _myDistrict,
        'healthCentre':   _facilityName ?? '',
        'babyName':       _bName.text.trim(),
        'babyGender':     _bGender!,
        'babyDob':        '${_bDob!.year}-${_bDob!.month.toString().padLeft(2,'0')}-${_bDob!.day.toString().padLeft(2,'0')}',
        'babyBirthWeight': _bWeight.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Neonatal patient "${_mName.text}" registered successfully.'),
          backgroundColor: AppColors.green));
        _formKey.currentState!.reset();
        setState(() { _bGender = null; _bDob = null; _zone = null; _facilityName = null; _facilityType = null; _urbanRural = null; _facilities = []; });
        loadZones();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
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
        _field('Nationality', _mNationality),
        const SizedBox(height: 24),
        _sectionTitle('Location'),
        ...buildLocationFields(),
        const SizedBox(height: 24),
        _sectionTitle('Baby Details'),
        _twoCol(_field('Baby Name', _bName),
            _cascadeDrop('Baby Gender', _bGender, ['Male', 'Female'], (v) => setState(() => _bGender = v))),
        const SizedBox(height: 16),
        _twoCol(
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Baby Date of Birth *',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDob,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _bDob == null ? AppColors.g200 : AppColors.navy)),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.navy),
                  const SizedBox(width: 10),
                  Text(_bDob == null ? 'Select date' : '${_bDob!.day}/${_bDob!.month}/${_bDob!.year}',
                      style: TextStyle(fontSize: 13, color: _bDob == null ? AppColors.g400 : AppColors.g800)),
                ]),
              ),
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Baby Age', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.g200)),
              child: Row(children: [
                const Icon(Icons.child_friendly_outlined, size: 16, color: AppColors.navy),
                const SizedBox(width: 10),
                Text(_bDob == null ? 'Auto-calculated' : _babyAge,
                    style: TextStyle(fontSize: 13,
                        color: _bDob == null ? AppColors.g400 : AppColors.navy,
                        fontWeight: _bDob != null ? FontWeight.w600 : FontWeight.normal)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _field('Birth Weight (kg)', _bWeight, required: false, keyboard: TextInputType.number, hint: 'e.g. 3.2'),
        const SizedBox(height: 28),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: () {
              _formKey.currentState!.reset();
              setState(() { _bGender = null; _bDob = null; _zone = null; _facilityName = null; _facilityType = null; _urbanRural = null; _facilities = []; });
              loadZones();
            },
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.g600,
                side: const BorderSide(color: AppColors.g200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Clear'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check, size: 16),
            label: Text(_saving ? 'Registering...' : 'Register Patient'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
          ),
        ]),
      ]),
    );
  }
}
