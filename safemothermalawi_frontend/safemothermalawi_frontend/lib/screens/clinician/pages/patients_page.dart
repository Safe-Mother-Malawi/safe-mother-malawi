import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';

class ClinicianPatientsPage extends StatefulWidget {
  const ClinicianPatientsPage({super.key});

  @override
  State<ClinicianPatientsPage> createState() => _ClinicianPatientsPageState();
}

class _ClinicianPatientsPageState extends State<ClinicianPatientsPage> {
  final _search = TextEditingController();
  String _filter = 'All';
  bool _loading  = true;
  String? _error;

  List<Map<String, dynamic>> _prenatal = [];
  List<Map<String, dynamic>> _neonatal = [];
  Map<String, dynamic>? _selected;
  String? _selectedType; // 'prenatal' | 'neonatal'

  List<Map<String, dynamic>> _riskHistory = [];
  bool _historyLoading = false;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ApiService.instance.get('/patients/prenatal'),
        ApiService.instance.get('/patients/neonatal'),
      ]);
      final prenatalRaw = results[0];
      final neonatalRaw = results[1];
      setState(() {
        _prenatal = (prenatalRaw is List ? prenatalRaw : [])
            .whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _neonatal = (neonatalRaw is List ? neonatalRaw : [])
            .whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _loading  = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadHistory(String patientId, String type) async {
    setState(() { _historyLoading = true; _riskHistory = []; });
    try {
      final results = await Future.wait([
        ApiService.instance.get('/risk-assessments/patient/$patientId'),
      ]);
      final riskData = results[0] is List ? results[0] as List : [];
      setState(() {
        _riskHistory    = riskData.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _historyLoading = false;
      });
    } catch (_) {
      setState(() => _historyLoading = false);
    }
  }

  Future<void> _saveEdit(Map<String, dynamic> updated) async {
    final id   = _selected!['id'] as String;
    final type = _selectedType!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final raw = await ApiService.instance.put(
        '/patients/$type/$id',
        updated,
      );
      final fresh = raw is Map ? Map<String, dynamic>.from(raw) : updated;
      // Update local lists
      setState(() {
        if (type == 'prenatal') {
          final idx = _prenatal.indexWhere((p) => p['id'] == id);
          if (idx != -1) _prenatal[idx] = {..._prenatal[idx], ...fresh, '_type': 'prenatal'};
        } else {
          final idx = _neonatal.indexWhere((p) => p['id'] == id);
          if (idx != -1) _neonatal[idx] = {..._neonatal[idx], ...fresh, '_type': 'neonatal'};
        }
        _selected = {..._selected!, ...fresh};
        _editing  = false;
      });
      messenger.showSnackBar(const SnackBar(
        content: Text('Patient updated successfully.'),
        backgroundColor: AppColors.green,
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Update failed: $e'),
        backgroundColor: AppColors.red,
      ));
    }
  }

  List<Map<String, dynamic>> get _filteredAll {
    final q = _search.text.toLowerCase();
    final result = <Map<String, dynamic>>[];
    if (_filter != 'Neonatal') {
      for (final p in _prenatal) {
        final name = (p['fullName'] ?? '').toString().toLowerCase();
        if (q.isEmpty || name.contains(q)) result.add({...p, '_type': 'prenatal'});
      }
    }
    if (_filter != 'Prenatal') {
      for (final p in _neonatal) {
        final name = (p['motherName'] ?? '').toString().toLowerCase();
        if (q.isEmpty || name.contains(q)) result.add({...p, '_type': 'neonatal'});
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        const Text('Failed to load patients'),
        TextButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Retry')),
      ]));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.people_outline, color: AppColors.navy, size: 22),
          SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Patients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
            Text('View and manage all patients under your care.', style: TextStyle(fontSize: 13, color: AppColors.g400)),
          ]),
        ]),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: _selected == null ? 1 : 2, child: _buildListPanel()),
          if (_selected != null) ...[
            const SizedBox(width: 16),
            Expanded(flex: 3, child: _buildDetailPanel()),
          ],
        ]),
      ]),
    );
  }

  Widget _buildListPanel() {
    final list = _filteredAll;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search patients...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.g400),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.g400),
                filled: true, fillColor: AppColors.bg,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            )),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.g200)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filter,
                  style: const TextStyle(fontSize: 12, color: AppColors.g800),
                  icon: const Icon(Icons.filter_list, size: 16, color: AppColors.navy),
                  items: ['All','Prenatal','Neonatal'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (v) => setState(() { _filter = v!; _selected = null; }),
                ),
              ),
            ),
          ]),
        ),
        const Divider(height: 1, color: AppColors.g200),
        SizedBox(
          height: 480,
          child: list.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(24),
                  child: Text('No patients found.', style: TextStyle(color: AppColors.g400, fontSize: 13))))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final p    = list[i];
                    final type = p['_type'] as String;
                    final name = type == 'prenatal' ? (p['fullName'] ?? 'Unknown') : (p['motherName'] ?? 'Unknown');
                    final sub  = type == 'prenatal'
                        ? 'Prenatal · ${p['pregnancyMonths'] ?? '?'} months'
                        : 'Neonatal · ${p['babyName'] ?? 'Baby'}';
                    final sel  = _selected?['id'] == p['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() { _selected = p; _selectedType = type; });
                        _loadHistory(p['id'] as String, type);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.navyL : Colors.transparent,
                          border: const Border(bottom: BorderSide(color: AppColors.g200, width: 0.5)),
                        ),
                        child: Row(children: [
                          CircleAvatar(radius: 15, backgroundColor: AppColors.navyL,
                              child: Text(name.toString()[0], style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(name.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
                            Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.g400)),
                          ])),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Widget _buildDetailPanel() {
    if (_selected == null) return const SizedBox();
    final p    = _selected!;
    final type = _selectedType ?? 'prenatal';

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            CircleAvatar(radius: 22, backgroundColor: Colors.white,
                child: Text(
                  type == 'prenatal' ? (p['fullName'] ?? 'U').toString()[0] : (p['motherName'] ?? 'U').toString()[0],
                  style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(type == 'prenatal' ? (p['fullName'] ?? '') : (p['motherName'] ?? ''),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.g800)),
              Text(type == 'prenatal' ? 'Prenatal Patient' : 'Neonatal — Mother',
                  style: const TextStyle(fontSize: 12, color: AppColors.g600)),
            ])),
            // Edit toggle
            if (!_editing)
              TextButton.icon(
                onPressed: () => setState(() => _editing = true),
                icon: const Icon(Icons.edit_outlined, size: 15, color: AppColors.navy),
                label: const Text('Edit', style: TextStyle(fontSize: 12, color: AppColors.navy)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() { _selected = null; _selectedType = null; _editing = false; }),
              child: const Icon(Icons.close, size: 18, color: AppColors.g400),
            ),
          ]),
        ),

        // Body — edit form or view
        if (_editing)
          _PatientEditForm(
            patient: p,
            type: type,
            onSave: _saveEdit,
            onCancel: () => setState(() => _editing = false),
          )
        else
          _buildDetailView(p, type),
      ]),
    );
  }

  Widget _buildDetailView(Map<String, dynamic> p, String type) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Contact
          _section('Contact', [
            if (type == 'prenatal') ...[
              _row(Icons.phone, 'Phone', p['phone'] ?? 'N/A'),
              if ((p['email'] ?? '').toString().isNotEmpty) _row(Icons.email_outlined, 'Email', p['email']),
              _row(Icons.flag_outlined, 'Nationality', p['nationality'] ?? 'N/A'),
              _row(Icons.location_on_outlined, 'District', p['district'] ?? 'N/A'),
              _row(Icons.local_hospital_outlined, 'Health Centre', p['facilityName'] ?? 'N/A'),
            ] else ...[
              _row(Icons.phone, 'Mother Phone', p['motherPhone'] ?? 'N/A'),
              _row(Icons.location_on_outlined, 'District', p['district'] ?? 'N/A'),
              _row(Icons.local_hospital_outlined, 'Health Centre', p['facilityName'] ?? 'N/A'),
            ],
          ]),
          const SizedBox(height: 16),

          if (type == 'prenatal') ...[
            _section('Pregnancy', [
              _row(Icons.pregnant_woman, 'Months', '${p['pregnancyMonths'] ?? '?'} months'),
              if (p['expectedDeliveryDate'] != null) _row(Icons.calendar_today_outlined, 'EDD', p['expectedDeliveryDate']),
            ]),
          ] else ...[
            _section('Baby Details', [
              _row(Icons.child_friendly_outlined, 'Baby Name', p['babyName'] ?? 'N/A'),
              _row(Icons.cake_outlined, 'Date of Birth', p['babyDob'] ?? 'N/A'),
              _row(Icons.wc_outlined, 'Gender', p['babyGender'] ?? 'N/A'),
              if (p['babyBirthWeight'] != null) _row(Icons.monitor_weight_outlined, 'Birth Weight', '${p['babyBirthWeight']} kg'),
            ]),
          ],

          const SizedBox(height: 16),

          // Risk history
          _section('Risk History', []),
          const SizedBox(height: 8),
          if (_historyLoading)
            const Center(child: CircularProgressIndicator())
          else if (_riskHistory.isEmpty)
            const Text('No risk assessments recorded.', style: TextStyle(fontSize: 12, color: AppColors.g400))
          else
            ..._riskHistory.take(3).map((r) {
              final level = r['riskLevel'] as String? ?? '';
              final score = r['score']?.toString() ?? '0';
              final date  = (r['submittedAt'] as String? ?? '').substring(0, 10);
              final color = level.contains('Low') ? AppColors.green
                  : level.contains('Moderate') ? AppColors.orange : AppColors.red;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.g200)),
                child: Row(children: [
                  Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(level, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(width: 8),
                  Text('Score: $score', style: const TextStyle(fontSize: 11, color: AppColors.g600)),
                  const Spacer(),
                  Text(date, style: const TextStyle(fontSize: 10, color: AppColors.g400)),
                ]),
              );
            }),

          const SizedBox(height: 16),
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

  Widget _row(IconData icon, String label, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.navy),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(value?.toString() ?? 'N/A', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
      ]),
    );
  }
}

// ── Inline edit form ──────────────────────────────────────────────────────────

class _PatientEditForm extends StatefulWidget {
  final Map<String, dynamic> patient;
  final String type;
  final Future<void> Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  const _PatientEditForm({
    required this.patient,
    required this.type,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_PatientEditForm> createState() => _PatientEditFormState();
}

class _PatientEditFormState extends State<_PatientEditForm> {
  final _formKey = GlobalKey<FormState>();
  bool _saving   = false;

  // Prenatal controllers
  final _fullName    = TextEditingController();
  final _age         = TextEditingController();
  final _phone       = TextEditingController();
  final _email       = TextEditingController();
  final _nationality = TextEditingController();
  final _pregMonths  = TextEditingController();

  // Neonatal controllers
  final _motherName      = TextEditingController();
  final _motherAge       = TextEditingController();
  final _motherPhone     = TextEditingController();
  final _motherEmail     = TextEditingController();
  final _babyName        = TextEditingController();
  final _babyBirthWeight = TextEditingController();
  String? _babyGender;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    if (widget.type == 'prenatal') {
      _fullName.text    = p['fullName']?.toString() ?? '';
      _age.text         = p['age']?.toString() ?? '';
      _phone.text       = p['phone']?.toString() ?? '';
      _email.text       = p['email']?.toString() ?? '';
      _nationality.text = p['nationality']?.toString() ?? '';
      _pregMonths.text  = p['pregnancyMonths']?.toString() ?? '';
    } else {
      _motherName.text      = p['motherName']?.toString() ?? '';
      _motherAge.text       = p['motherAge']?.toString() ?? '';
      _motherPhone.text     = p['motherPhone']?.toString() ?? '';
      _motherEmail.text     = p['motherEmail']?.toString() ?? '';
      _babyName.text        = p['babyName']?.toString() ?? '';
      _babyBirthWeight.text = p['babyBirthWeight']?.toString() ?? '';
      _babyGender           = p['babyGender']?.toString();
    }
  }

  @override
  void dispose() {
    for (final c in [_fullName, _age, _phone, _email, _nationality, _pregMonths,
                     _motherName, _motherAge, _motherPhone, _motherEmail,
                     _babyName, _babyBirthWeight]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final Map<String, dynamic> body;
    if (widget.type == 'prenatal') {
      body = {
        'fullName':        _fullName.text.trim(),
        'age':             _age.text.trim(),
        'phone':           _phone.text.trim(),
        'email':           _email.text.trim().isEmpty ? null : _email.text.trim(),
        'nationality':     _nationality.text.trim(),
        'pregnancyMonths': _pregMonths.text.trim(),
      };
    } else {
      body = {
        'motherName':  _motherName.text.trim(),
        'motherAge':   _motherAge.text.trim(),
        'motherPhone': _motherPhone.text.trim(),
        'motherEmail': _motherEmail.text.trim().isEmpty ? null : _motherEmail.text.trim(),
        'babyName':    _babyName.text.trim(),
        'babyGender':  _babyGender,
        if (_babyBirthWeight.text.trim().isNotEmpty)
          'babyBirthWeight': _babyBirthWeight.text.trim(),
      };
    }
    await widget.onSave(body);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (widget.type == 'prenatal') ...[
              _editSection('Mother Information'),
              _editRow('Full Name',   _fullName,   required: true, customValidator: _validateFullName),
              _editRow('Age',         _age,        numeric: true),
              _editRow('Phone',       _phone,      required: true, customValidator: _validatePhone),
              _editRow('Email',       _email,      required: false),
              _editRow('Nationality', _nationality),
              const SizedBox(height: 12),
              _editSection('Pregnancy'),
              _editRow('Pregnancy Duration (months)', _pregMonths, numeric: true),
            ] else ...[
              _editSection('Mother Details'),
              _editRow('Mother Name',  _motherName,  required: true, customValidator: _validateFullName),
              _editRow('Age',          _motherAge,   numeric: true),
              _editRow('Phone',        _motherPhone, required: true, customValidator: _validatePhone),
              _editRow('Email',        _motherEmail, required: false),
              const SizedBox(height: 12),
              _editSection('Baby Details'),
              _editRow('Baby Name',         _babyName),
              _editRow('Birth Weight (kg)', _babyBirthWeight, required: false),
              const SizedBox(height: 8),
              Row(children: [
                const Text('Gender',
                    style: TextStyle(fontSize: 12, color: AppColors.g600, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                ...['Male', 'Female'].map((g) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(g,
                        style: TextStyle(
                            fontSize: 12,
                            color: _babyGender == g ? Colors.white : AppColors.g800)),
                    selected: _babyGender == g,
                    selectedColor: AppColors.navy,
                    onSelected: (_) => setState(() => _babyGender = g),
                  ),
                )),
              ]),
            ],
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(
                onPressed: _saving ? null : widget.onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.g600,
                  side: const BorderSide(color: AppColors.g200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save, size: 15),
                label: Text(_saving ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _editSection(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 4),
    child: Row(children: [
      Container(width: 3, height: 13, color: AppColors.navy,
          margin: const EdgeInsets.only(right: 8)),
      Text(title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800)),
    ]),
  );

  Widget _editRow(String label, TextEditingController ctrl,
      {bool required = true, bool numeric = false, String? Function(String?)? customValidator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 13, color: AppColors.g800),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: const TextStyle(fontSize: 12, color: AppColors.g600),
          filled: true,
          fillColor: AppColors.bg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          if (numeric && v != null && v.trim().isNotEmpty &&
              int.tryParse(v.trim()) == null) {
            return '$label must be a number';
          }
          return null;
        },
      ),
    );
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
