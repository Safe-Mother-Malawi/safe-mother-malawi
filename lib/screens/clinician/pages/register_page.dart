import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service_web.dart';
import '../../../utils/validators.dart';

class ClinicianRegisterPage extends StatefulWidget {
  /// Called after a patient is successfully registered so the patients
  /// list can refresh automatically.
  final VoidCallback? onPatientRegistered;
  const ClinicianRegisterPage({super.key, this.onPatientRegistered});

  @override
  State<ClinicianRegisterPage> createState() => _ClinicianRegisterPageState();
}

class _ClinicianRegisterPageState extends State<ClinicianRegisterPage> {
  int _tab = 0;
  String _userDistrict = '';
  String _userFacilityName = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    // Try from cached web session first
    final cached = AuthServiceWeb.instance.currentUser;
    if (cached != null) {
      final district     = (cached['district'] as String?) ?? '';
      final facilityName = (cached['facilityName'] as String?) ?? '';
      if (district.isNotEmpty) {
        setState(() { _userDistrict = district; _userFacilityName = facilityName; });
        return;
      }
    }
    // Fallback: fetch from /auth/me
    try {
      await ApiService.instance.loadToken();
      final data = await ApiService.instance.currentUser();
      if (data != null && mounted) {
        setState(() {
          _userDistrict     = (data['district'] as String?) ?? '';
          _userFacilityName = (data['facilityName'] as String?) ?? '';
        });
      }
    } catch (_) {}
  }

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
          if (_userDistrict.isNotEmpty) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.infoBg, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(_userDistrict,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ]),
            ),
            if (_userFacilityName.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.local_hospital_outlined, size: 12, color: Color(0xFF00695C)),
                  const SizedBox(width: 4),
                  Text(_userFacilityName,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF00695C))),
                ]),
              ),
            ],
          ],
        ]),
        const SizedBox(height: 6),
        const Text('Fill in the patient details below to register them into the system.',
            style: TextStyle(fontSize: 13, color: AppColors.g400)),
        const SizedBox(height: 24),

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

        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.g200)),
          padding: const EdgeInsets.all(28),
          child: _tab == 0
              ? _PrenatalForm(
                  onRegistered: widget.onPatientRegistered,
                  lockedDistrict: _userDistrict,
                  lockedFacilityName: _userFacilityName,
                )
              : _NeonatalForm(
                  onRegistered: widget.onPatientRegistered,
                  lockedDistrict: _userDistrict,
                  lockedFacilityName: _userFacilityName,
                ),
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
    String? hint,
    bool numericOnly = false,
    int? minValue,
    int? maxValue,
    String? Function(String?)? customValidator}) {
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
        hintText: hint ?? (minValue != null && maxValue != null
            ? '$minValue – $maxValue'
            : 'Enter $label'),
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
      validator: (v) {
        if (customValidator != null) {
          final customError = customValidator(v);
          if (customError != null) return customError;
        }
        if (required && (v == null || v.trim().isEmpty)) return '$label is required';
        if ((numericOnly || minValue != null) && v != null && v.trim().isNotEmpty) {
          final n = int.tryParse(v.trim());
          if (n == null) return '$label must be a whole number';
          if (minValue != null && n < minValue) return '$label must be at least $minValue';
          if (maxValue != null && n > maxValue) return '$label must be at most $maxValue';
        }
        return null;
      },
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
  final VoidCallback? onRegistered;
  final String lockedDistrict;
  final String lockedFacilityName;
  const _PrenatalForm({this.onRegistered, this.lockedDistrict = '', this.lockedFacilityName = ''});
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
  final _pregMonths = TextEditingController();
  String? _district;
  String? _facilityName;
  String? _urbanRural;
  List<Map<String, dynamic>> _facilities = [];
  bool _loadingFacilities = false;
  DateTime? _edd;

  bool get _districtLocked     => widget.lockedDistrict.isNotEmpty;
  bool get _facilityNameLocked => widget.lockedFacilityName.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.lockedDistrict.isNotEmpty) {
      _district = widget.lockedDistrict;
      // If health centre is also locked, no need to load the dropdown
      if (widget.lockedFacilityName.isNotEmpty) {
        _facilityName = widget.lockedFacilityName;
      } else {
        _loadFacilities(widget.lockedDistrict);
      }
    }
    // Listen to pregnancy months changes to auto-calculate EDD
    _pregMonths.addListener(_calculateEDD);
  }

  @override
  void dispose() {
    _pregMonths.removeListener(_calculateEDD);
    for (final c in [_name, _age, _phone, _email, _nationality, _pregMonths]) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculateEDD() {
    final monthsText = _pregMonths.text.trim();
    if (monthsText.isEmpty) {
      setState(() => _edd = null);
      return;
    }
    final months = int.tryParse(monthsText);
    if (months == null || months < 1 || months > 9) {
      setState(() => _edd = null);
      return;
    }
    // Calculate remaining months until delivery (9 months total)
    final remainingMonths = 9 - months;
    // Add remaining months to today's date
    final calculatedEDD = DateTime.now().add(Duration(days: remainingMonths * 30));
    setState(() => _edd = calculatedEDD);
  }

  Future<void> _loadFacilities(String district) async {
    setState(() { _loadingFacilities = true; _facilities = []; _facilityName = null; _urbanRural = null; });
    try {
      final data = await ApiService.getFacilitiesByDistrict(district);
      setState(() {
        _facilities = data.cast<Map<String, dynamic>>();
        _loadingFacilities = false;
      });
    } catch (_) {
      setState(() { _loadingFacilities = false; });
    }
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

  void _submit() async {
    if (_formKey.currentState!.validate() && _edd != null) {
      try {
        await ApiService.registerPrenatalPatient({
          'fullName': _name.text.trim(),
          'age': _age.text.trim(),
          'phone': _phone.text.trim(),
          'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
          'nationality': _nationality.text.trim(),
          'district': _district,
          'facilityName': _facilityName,
          'urbanRural': _urbanRural,
          'pregnancyMonths': _pregMonths.text.trim(),
          'expectedDeliveryDate': _edd!.toIso8601String(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Prenatal patient "${_name.text}" registered successfully.'),
              backgroundColor: AppColors.green,
            ),
          );
          _formKey.currentState!.reset();
          setState(() {
            if (!_districtLocked) _district = null;
            _edd = null;
            _facilityName = null;
            _urbanRural = null;
            if (!_districtLocked) _facilities = [];
          });
          widget.onRegistered?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: $e'), backgroundColor: AppColors.red),
          );
        }
      }
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
        _twoCol(_field('Full Name', _name, customValidator: _validateFullName), _field('Age', _age, keyboard: TextInputType.number, numericOnly: true)),
        const SizedBox(height: 16),
        _twoCol(_field('Phone Number', _phone, keyboard: TextInputType.phone, customValidator: _validatePhone),
            _field('Email', _email, required: false, hint: 'Optional', 
                   customValidator: (v) => Validators.validateEmail(v, required: false))),
        const SizedBox(height: 16),
        _twoCol(_field('Nationality', _nationality),
            _districtLocked
                ? _lockedDistrictField(_district!)
                : _dropdown('District', _district, _districts, (v) {
                    setState(() => _district = v);
                    if (v != null) _loadFacilities(v);
                  })),
        const SizedBox(height: 16),
        // Facility dropdown — locked if clinician has assigned health centre
        _facilityNameLocked
            ? _lockedFacilityField(widget.lockedFacilityName)
            : _facilityDropdown(),
        const SizedBox(height: 24),
        _sectionTitle('Pregnancy Details'),
        _twoCol(
          _field('Pregnancy Duration (months)', _pregMonths, keyboard: TextInputType.number, numericOnly: true, minValue: 1, maxValue: 9),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Expected Delivery Date *',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
            const SizedBox(height: 6),
            if (_edd == null)
              GestureDetector(
                onTap: _pickEDD,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.g200),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.navy),
                    const SizedBox(width: 10),
                    Text(
                      'Select date',
                      style: TextStyle(fontSize: 13, color: AppColors.g400),
                    ),
                  ]),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.navyL,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.navy.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.navy),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        '${_edd!.day}/${_edd!.month}/${_edd!.year}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.g800),
                      ),
                      const Text(
                        'Auto-calculated from pregnancy duration',
                        style: TextStyle(fontSize: 10, color: AppColors.g600, fontStyle: FontStyle.italic),
                      ),
                    ]),
                  ),
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.green),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 28),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: () {
              _formKey.currentState!.reset();
              setState(() {
                if (!_districtLocked) _district = null;
                _edd = null;
                _facilityName = null;
                _urbanRural = null;
                if (!_districtLocked) _facilities = [];
              });
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

  Widget _facilityDropdown() {
    if (_district == null) {
      return _dropdown('Health Centre / Facility', null, [], (_) {},
          required: true);
    }
    if (_loadingFacilities) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RichText(text: const TextSpan(
          text: 'Health Centre / Facility',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800),
          children: [TextSpan(text: ' *', style: TextStyle(color: AppColors.red))],
        )),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.bg, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.g200)),
          child: const Row(children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy)),
            SizedBox(width: 10),
            Text('Loading facilities...', style: TextStyle(fontSize: 13, color: AppColors.g400)),
          ]),
        ),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Facility selector
      _dropdown(
        'Health Centre / Facility',
        _facilityName,
        _facilities.map((f) => f['facilityName']?.toString() ?? '').where((n) => n.isNotEmpty).toList(),
        (v) {
          final facility = _facilities.firstWhere(
            (f) => f['facilityName'] == v, orElse: () => {});
          setState(() {
            _facilityName = v;
            _urbanRural = facility['urbanRural']?.toString();
          });
        },
        required: true,
      ),
      // Auto-filled Urban/Rural badge
      if (_urbanRural != null && _urbanRural!.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.location_city_outlined, size: 14, color: AppColors.navy),
          const SizedBox(width: 6),
          Text('Area type: ', style: const TextStyle(fontSize: 12, color: AppColors.g600)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.navyL,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_urbanRural!,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navy)),
          ),
        ]),
      ],
    ]);
  }
}

Widget _twoCol(Widget a, Widget b) {
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: a),
    const SizedBox(width: 16),
    Expanded(child: b),
  ]);
}

/// Read-only district field shown when the clinician/DHO's district is locked
Widget _lockedDistrictField(String district) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    RichText(
      text: const TextSpan(
        text: 'District',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800),
        children: [TextSpan(text: ' *', style: TextStyle(color: AppColors.red))],
      ),
    ),
    const SizedBox(height: 6),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.location_on_rounded, size: 15, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(district,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary))),
        const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.primary),
      ]),
    ),
  ]);
}

/// Read-only health centre field shown when the clinician's facility is locked
Widget _lockedFacilityField(String facilityName) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    RichText(
      text: const TextSpan(
        text: 'Health Centre / Facility',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800),
        children: [TextSpan(text: ' *', style: TextStyle(color: AppColors.red))],
      ),
    ),
    const SizedBox(height: 6),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00695C).withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.local_hospital_outlined, size: 15, color: Color(0xFF00695C)),
        const SizedBox(width: 8),
        Expanded(child: Text(facilityName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF00695C)))),
        const Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF00695C)),
      ]),
    ),
  ]);
}

// ── Neonatal Form ────────────────────────────────────────────────────────────

class _NeonatalForm extends StatefulWidget {
  final VoidCallback? onRegistered;
  final String lockedDistrict;
  final String lockedFacilityName;
  const _NeonatalForm({this.onRegistered, this.lockedDistrict = '', this.lockedFacilityName = ''});
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
  final _bName      = TextEditingController();
  String? _mDistrict;
  String? _mFacilityName;
  String? _mUrbanRural;
  List<Map<String, dynamic>> _facilities = [];
  bool _loadingFacilities = false;
  String? _bGender;
  DateTime? _bDob;

  bool get _districtLocked     => widget.lockedDistrict.isNotEmpty;
  bool get _facilityNameLocked => widget.lockedFacilityName.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.lockedDistrict.isNotEmpty) {
      _mDistrict = widget.lockedDistrict;
      if (widget.lockedFacilityName.isNotEmpty) {
        _mFacilityName = widget.lockedFacilityName;
      } else {
        _loadFacilities(widget.lockedDistrict);
      }
    }
  }

  String get _babyAge {
    if (_bDob == null) return '';
    final days = DateTime.now().difference(_bDob!).inDays;
    if (days < 7) return '$days day${days == 1 ? '' : 's'} old';
    if (days < 30) { final w = (days / 7).floor(); return '$w week${w == 1 ? '' : 's'} old'; }
    final m = (days / 30.44).floor();
    return '$m month${m == 1 ? '' : 's'} old';
  }

  @override
  void dispose() {
    for (final c in [_mName, _mAge, _mPhone, _mEmail, _mNationality, _bName]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFacilities(String district) async {
    setState(() { _loadingFacilities = true; _facilities = []; _mFacilityName = null; _mUrbanRural = null; });
    try {
      final data = await ApiService.getFacilitiesByDistrict(district);
      setState(() { _facilities = data.cast<Map<String, dynamic>>(); _loadingFacilities = false; });
    } catch (_) {
      setState(() => _loadingFacilities = false);
    }
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.navy)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _bDob = picked);
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _bDob != null && _bGender != null) {
      try {
        await ApiService.registerNeonatalPatient({
          'motherName': _mName.text.trim(),
          'motherAge': _mAge.text.trim(),
          'motherPhone': _mPhone.text.trim(),
          'motherEmail': _mEmail.text.trim().isEmpty ? null : _mEmail.text.trim(),
          'nationality': _mNationality.text.trim(),
          'district': _mDistrict,
          'facilityName': _mFacilityName,
          'urbanRural': _mUrbanRural,
          'babyName': _bName.text.trim(),
          'babyGender': _bGender,
          'babyDob': _bDob!.toIso8601String(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Neonatal patient "${_mName.text}" registered successfully.'),
              backgroundColor: AppColors.green,
            ),
          );
          _formKey.currentState!.reset();
          setState(() {
            if (!_districtLocked) _mDistrict = null;
            _bGender = null; _bDob = null;
            _mFacilityName = null; _mUrbanRural = null;
            if (!_districtLocked) _facilities = [];
          });
          widget.onRegistered?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: $e'), backgroundColor: AppColors.red),
          );
        }
      }
    } else {
      final missing = <String>[];
      if (_bDob == null) missing.add('Baby Date of Birth');
      if (_bGender == null) missing.add('Baby Gender');
      if (missing.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill: ${missing.join(', ')}'), backgroundColor: AppColors.red),
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
        _twoCol(_field('Full Name', _mName, customValidator: _validateFullName), _field('Age', _mAge, keyboard: TextInputType.number, numericOnly: true)),
        const SizedBox(height: 16),
        _twoCol(_field('Phone Number', _mPhone, keyboard: TextInputType.phone, customValidator: _validatePhone),
            _field('Email', _mEmail, required: false, hint: 'Optional',
                   customValidator: (v) => Validators.validateEmail(v, required: false))),
        const SizedBox(height: 16),
        _twoCol(_field('Nationality', _mNationality),
            _districtLocked
                ? _lockedDistrictField(_mDistrict!)
                : _dropdown('District', _mDistrict, _districts, (v) {
                    setState(() => _mDistrict = v);
                    if (v != null) _loadFacilities(v);
                  })),
        const SizedBox(height: 16),
        _facilityNameLocked
            ? _lockedFacilityField(widget.lockedFacilityName)
            : _neonatalFacilityDropdown(),
        const SizedBox(height: 24),
        _sectionTitle('Baby Details'),
        _twoCol(_field('Baby Name', _bName),
            _dropdown('Baby Gender', _bGender, ['Male', 'Female'], (v) => setState(() => _bGender = v))),
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
                decoration: BoxDecoration(
                  color: AppColors.bg, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _bDob == null ? AppColors.g200 : AppColors.navy),
                ),
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
              decoration: BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.g200)),
              child: Row(children: [
                const Icon(Icons.child_friendly_outlined, size: 16, color: AppColors.navy),
                const SizedBox(width: 10),
                Text(_bDob == null ? 'Auto-calculated' : _babyAge,
                    style: TextStyle(fontSize: 13, color: _bDob == null ? AppColors.g400 : AppColors.navy,
                        fontWeight: _bDob != null ? FontWeight.w600 : FontWeight.normal)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 28),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: () {
              _formKey.currentState!.reset();
              setState(() {
                if (!_districtLocked) _mDistrict = null;
                _bGender = null; _bDob = null;
                _mFacilityName = null; _mUrbanRural = null;
                if (!_districtLocked) _facilities = [];
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.g600, side: const BorderSide(color: AppColors.g200),
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
              backgroundColor: AppColors.navy, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _neonatalFacilityDropdown() {
    if (_mDistrict == null) {
      return _dropdown('Health Centre / Facility', null, [], (_) {}, required: true);
    }
    if (_loadingFacilities) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RichText(text: const TextSpan(
          text: 'Health Centre / Facility',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800),
          children: [TextSpan(text: ' *', style: TextStyle(color: AppColors.red))],
        )),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.g200)),
          child: const Row(children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy)),
            SizedBox(width: 10),
            Text('Loading facilities...', style: TextStyle(fontSize: 13, color: AppColors.g400)),
          ]),
        ),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _dropdown(
        'Health Centre / Facility',
        _mFacilityName,
        _facilities.map((f) => f['facilityName']?.toString() ?? '').where((n) => n.isNotEmpty).toList(),
        (v) {
          final facility = _facilities.firstWhere((f) => f['facilityName'] == v, orElse: () => {});
          setState(() { _mFacilityName = v; _mUrbanRural = facility['urbanRural']?.toString(); });
        },
        required: true,
      ),
      if (_mUrbanRural != null && _mUrbanRural!.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.location_city_outlined, size: 14, color: AppColors.navy),
          const SizedBox(width: 6),
          const Text('Area type: ', style: TextStyle(fontSize: 12, color: AppColors.g600)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.circular(20)),
            child: Text(_mUrbanRural!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navy)),
          ),
        ]),
      ],
    ]);
  }
}



String? _validateFullName(String? value) {
  if (value == null || value.isEmpty) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'Full name is required';
  final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.length < 2) return 'Full name must include first and last name';
  if (parts.any((p) => RegExp(r'\d').hasMatch(p))) return 'Name cannot contain digits';
  if (parts.any((p) => !RegExp(r"^[a-zA-Z\-']+$").hasMatch(p))) return 'Name can only contain letters, hyphens, and apostrophes';
  return null;
}

String? _validatePhone(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.length != 10) return 'Phone must be exactly 10 digits';
  if (!value.startsWith('0')) return 'Phone must start with 0';
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Phone must contain only digits';
  return null;
}
