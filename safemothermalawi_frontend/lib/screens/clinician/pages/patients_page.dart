import 'package:flutter/material.dart';
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
  Map<String, dynamic>? _selected;
  String _selectedType = '';

  List<Map<String, dynamic>> _prenatal = [];
  List<Map<String, dynamic>> _neonatal = [];
  List<dynamic> _history = [];
  bool _loading = true;
  bool _historyLoading = false;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getPrenatalPatients(),
        ApiService.getNeonatalPatients(),
      ]);
      setState(() {
        _prenatal = results[0].cast<Map<String, dynamic>>();
        _neonatal = results[1].cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _loadHistory(String patientId) async {
    setState(() { _historyLoading = true; _history = []; });
    try {
      final data = await ApiService.getPatientHistory(patientId);
      setState(() { _history = (data['riskHistory'] as List?) ?? []; _historyLoading = false; });
    } catch (_) { setState(() => _historyLoading = false); }
  }

  List<Map<String, dynamic>> get _filteredAll {
    final q = _search.text.toLowerCase();
    final result = <Map<String, dynamic>>[];
    if (_filter != 'Neonatal') {
      for (final p in _prenatal) {
        if (q.isNotEmpty && !(p['fullName'] ?? '').toLowerCase().contains(q)) continue;
        result.add({...p, '_type': 'prenatal'});
      }
    }
    if (_filter != 'Prenatal') {
      for (final p in _neonatal) {
        if (q.isNotEmpty && !(p['motherName'] ?? '').toLowerCase().contains(q)) continue;
        result.add({...p, '_type': 'neonatal'});
      }
    }
    return result;
  }

  // â”€â”€ Delete â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _confirmDelete(Map<String, dynamic> p) async {
    final isPrenatal = p['_type'] == 'prenatal';
    final name = isPrenatal ? (p['fullName'] ?? '') : (p['motherName'] ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text('Delete Patient', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        content: Text('Delete "$name"? This cannot be undone.',
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      if (isPrenatal) {
        await ApiService.deletePrenatalPatient(p['id']);
        setState(() { _prenatal.removeWhere((x) => x['id'] == p['id']); if (_selected?['id'] == p['id']) _selected = null; });
      } else {
        await ApiService.deleteNeonatalPatient(p['id']);
        setState(() { _neonatal.removeWhere((x) => x['id'] == p['id']); if (_selected?['id'] == p['id']) _selected = null; });
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$name" deleted.'), backgroundColor: AppColors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  // â”€â”€ Edit â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showEditDialog(Map<String, dynamic> p) {
    final isPrenatal = p['_type'] == 'prenatal';
    if (isPrenatal) {
      _showEditPrenatal(p);
    } else {
      _showEditNeonatal(p);
    }
  }

  void _showEditPrenatal(Map<String, dynamic> p) {
    final nameCtrl  = TextEditingController(text: p['fullName'] ?? '');
    final phoneCtrl = TextEditingController(text: p['phone'] ?? '');
    final emailCtrl = TextEditingController(text: p['email'] ?? '');
    final monthsCtrl = TextEditingController(text: p['pregnancyMonths'] ?? '');
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.edit_outlined, color: AppColors.navy, size: 20),
          SizedBox(width: 8),
          Text('Edit Prenatal Patient', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
        content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
          _editField('Full Name', nameCtrl),
          const SizedBox(height: 12),
          _editField('Phone', phoneCtrl, keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _editField('Email', emailCtrl, keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _editField('Pregnancy Months', monthsCtrl, keyboard: TextInputType.number),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: saving ? null : () async {
              setS(() => saving = true);
              try {
                final updated = await ApiService.updatePrenatalPatient(p['id'], {
                  'fullName': nameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'pregnancyMonths': monthsCtrl.text.trim(),
                });
                setState(() {
                  final idx = _prenatal.indexWhere((x) => x['id'] == p['id']);
                  if (idx != -1) _prenatal[idx] = updated;
                  if (_selected?['id'] == p['id']) _selected = {...updated, '_type': 'prenatal'};
                });
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient updated.'), backgroundColor: AppColors.green));
              } catch (e) {
                setS(() => saving = false);
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white, elevation: 0),
            child: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save'),
          ),
        ],
      )),
    );
  }

  void _showEditNeonatal(Map<String, dynamic> p) {
    final mNameCtrl  = TextEditingController(text: p['motherName'] ?? '');
    final mPhoneCtrl = TextEditingController(text: p['motherPhone'] ?? '');
    final bNameCtrl  = TextEditingController(text: p['babyName'] ?? '');
    final bWeightCtrl = TextEditingController(text: p['babyBirthWeight'] ?? '');
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.edit_outlined, color: AppColors.navy, size: 20),
          SizedBox(width: 8),
          Text('Edit Neonatal Patient', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
        content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
          _editField('Mother Name', mNameCtrl),
          const SizedBox(height: 12),
          _editField('Mother Phone', mPhoneCtrl, keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _editField('Baby Name', bNameCtrl),
          const SizedBox(height: 12),
          _editField('Birth Weight (kg)', bWeightCtrl, keyboard: TextInputType.number),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: saving ? null : () async {
              setS(() => saving = true);
              try {
                final updated = await ApiService.updateNeonatalPatient(p['id'], {
                  'motherName': mNameCtrl.text.trim(),
                  'motherPhone': mPhoneCtrl.text.trim(),
                  'babyName': bNameCtrl.text.trim(),
                  'babyBirthWeight': bWeightCtrl.text.trim(),
                });
                setState(() {
                  final idx = _neonatal.indexWhere((x) => x['id'] == p['id']);
                  if (idx != -1) _neonatal[idx] = updated;
                  if (_selected?['id'] == p['id']) _selected = {...updated, '_type': 'neonatal'};
                });
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient updated.'), backgroundColor: AppColors.green));
              } catch (e) {
                setS(() => saving = false);
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white, elevation: 0),
            child: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save'),
          ),
        ],
      )),
    );
  }

  Widget _editField(String label, TextEditingController ctrl, {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: ctrl, keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true, fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.g200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.g200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.navy, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeader(),
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

  Widget _buildHeader() => Row(children: [
    const Icon(Icons.people_outline, color: AppColors.navy, size: 22), const SizedBox(width: 10),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Patients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
      Text('View and manage all patients under your care.', style: TextStyle(fontSize: 13, color: AppColors.g400)),
    ])),
    IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: AppColors.navy, size: 20), tooltip: 'Refresh'),
  ]);

  Widget _buildListPanel() {
    final list = _filteredAll;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 8), child: Row(children: [
          Expanded(child: TextField(controller: _search, onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: 'Search patients...', hintStyle: const TextStyle(fontSize: 12, color: AppColors.g400),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.g400),
              filled: true, fillColor: AppColors.bg, contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)))),
          const SizedBox(width: 10),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.g200)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: _filter, style: const TextStyle(fontSize: 12, color: AppColors.g800),
              icon: const Icon(Icons.filter_list, size: 16, color: AppColors.navy),
              items: ['All','Prenatal','Neonatal'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (v) => setState(() { _filter = v!; _selected = null; })))),
        ])),
        const Divider(height: 1, color: AppColors.g200),
        SizedBox(height: 480, child: list.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.people_outline, color: AppColors.g200, size: 40),
                SizedBox(height: 8),
                Text('No patients found.', style: TextStyle(color: AppColors.g400, fontSize: 13)),
              ])))
          : ListView.builder(itemCount: list.length, itemBuilder: (_, i) {
            final p = list[i];
            final isPrenatal = p['_type'] == 'prenatal';
            final name = isPrenatal ? (p['fullName'] ?? '') : (p['motherName'] ?? '');
            final sub  = isPrenatal
                ? 'Prenatal Â· ${p['pregnancyMonths'] ?? '?'} months'
                : 'Neonatal Â· Baby: ${p['babyName'] ?? 'â€”'}';
            final sel = _selected?['id'] == p['id'];
            return GestureDetector(
              onTap: () { setState(() { _selected = p; _selectedType = p['_type']; }); _loadHistory(p['id']); },
              child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(color: sel ? AppColors.navyL : Colors.transparent,
                    border: const Border(bottom: BorderSide(color: AppColors.g200, width: 0.5))),
                child: Row(children: [
                  CircleAvatar(radius: 15, backgroundColor: AppColors.navyL,
                      child: Text(name.isNotEmpty ? name[0] : '?',
                          style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
                    Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.g400)),
                  ])),
                  // Edit button
                  GestureDetector(
                    onTap: () => _showEditDialog(p),
                    child: const Padding(padding: EdgeInsets.all(4),
                        child: Icon(Icons.edit_outlined, size: 15, color: AppColors.navy)),
                  ),
                  const SizedBox(width: 4),
                  // Delete button
                  GestureDetector(
                    onTap: () => _confirmDelete(p),
                    child: const Padding(padding: EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline_rounded, size: 15, color: Colors.red)),
                  ),
                ])),
            );
          })),
      ]),
    );
  }

  Widget _buildDetailPanel() {
    if (_selected == null) return const SizedBox();
    final p = _selected!;
    final isPrenatal = _selectedType == 'prenatal';

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            CircleAvatar(radius: 22, backgroundColor: Colors.white,
                child: Text(isPrenatal ? (p['fullName'] ?? '?')[0] : (p['motherName'] ?? '?')[0],
                    style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isPrenatal ? (p['fullName'] ?? 'â€”') : (p['motherName'] ?? 'â€”'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.g800)),
              Text(isPrenatal ? 'Prenatal' : 'Neonatal Â· Baby: ${p['babyName'] ?? 'â€”'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.g600)),
            ])),
            // Edit
            IconButton(
              onPressed: () => _showEditDialog(p),
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.navy),
              tooltip: 'Edit',
            ),
            // Delete
            IconButton(
              onPressed: () => _confirmDelete(p),
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              tooltip: 'Delete',
            ),
            GestureDetector(onTap: () => setState(() { _selected = null; _history = []; }),
                child: const Icon(Icons.close, size: 18, color: AppColors.g400)),
          ])),

        Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (isPrenatal) ...[
            _section('Contact Information', [
              _row(Icons.phone, 'Phone', p['phone'] ?? 'â€”'),
              if ((p['email'] ?? '').isNotEmpty) _row(Icons.email_outlined, 'Email', p['email']),
              if ((p['nationality'] ?? '').isNotEmpty) _row(Icons.flag_outlined, 'Nationality', p['nationality']),
            ]),
            const SizedBox(height: 16),
            _section('Location', [
              _row(Icons.location_on_outlined, 'District', p['district'] ?? 'â€”'),
              _row(Icons.local_hospital_outlined, 'Health Centre', p['healthCentre'] ?? 'â€”'),
            ]),
            const SizedBox(height: 16),
            _section('Pregnancy Details', [
              _row(Icons.pregnant_woman, 'Duration', '${p['pregnancyMonths'] ?? '?'} months ${p['pregnancyWeeks'] ?? ''} weeks'),
              if ((p['expectedDeliveryDate'] ?? '').isNotEmpty)
                _row(Icons.calendar_today_outlined, 'Expected Delivery', p['expectedDeliveryDate']),
            ]),
          ] else ...[
            _section('Mother Details', [
              _row(Icons.phone, 'Phone', p['motherPhone'] ?? 'â€”'),
              if ((p['motherEmail'] ?? '').isNotEmpty) _row(Icons.email_outlined, 'Email', p['motherEmail']),
              _row(Icons.location_on_outlined, 'District', p['district'] ?? 'â€”'),
              _row(Icons.local_hospital_outlined, 'Health Centre', p['healthCentre'] ?? 'â€”'),
            ]),
            const SizedBox(height: 16),
            _section('Baby Details', [
              _row(Icons.child_friendly_outlined, 'Baby Name', p['babyName'] ?? 'â€”'),
              _row(Icons.cake_outlined, 'Date of Birth', p['babyDob'] ?? 'â€”'),
              if ((p['babyGender'] ?? '').isNotEmpty) _row(Icons.wc_outlined, 'Gender', p['babyGender']),
              if ((p['babyBirthWeight'] ?? '').isNotEmpty) _row(Icons.monitor_weight_outlined, 'Birth Weight', '${p['babyBirthWeight']} kg'),
            ]),
          ],
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => _showHistory(context),
            icon: const Icon(Icons.history, size: 16),
            label: const Text('View Patient History'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.navy), padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          )),
        ])),
      ]),
    );
  }

  void _showHistory(BuildContext context) {
    showDialog(context: context, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(children: [
              const Icon(Icons.history, color: AppColors.navy, size: 20), const SizedBox(width: 10),
              const Expanded(child: Text('Patient History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.g800))),
              GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, size: 18, color: AppColors.g400)),
            ])),
          Expanded(child: _historyLoading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(24),
                  child: Text('No risk history recorded yet.', style: TextStyle(color: AppColors.g400))))
              : ListView.builder(padding: const EdgeInsets.all(20), itemCount: _history.length, itemBuilder: (_, i) {
                final h = _history[i] as Map<String, dynamic>;
                final level = h['riskLevel']?.toString() ?? '';
                final rc = level.contains('High') || level.contains('Seek') ? AppColors.red
                    : level.contains('Moderate') ? AppColors.orange : AppColors.green;
                return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.g200)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 7, height: 7, decoration: BoxDecoration(color: rc, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(level, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: rc)),
                      const Spacer(),
                      Text(h['submittedAt']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 10, color: AppColors.g400)),
                    ]),
                    const SizedBox(height: 6),
                    Text('Score: ${h['score']} Â· ${h['message'] ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.g800)),
                  ]));
              })),
        ])),
    ));
  }

  Widget _section(String title, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Container(width: 3, height: 14, color: AppColors.navy, margin: const EdgeInsets.only(right: 8)),
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800))]),
    const SizedBox(height: 10), ...children,
  ]);

  Widget _row(IconData icon, String label, String? value) => Container(
    margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
    child: Row(children: [
      Icon(icon, size: 15, color: AppColors.navy), const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g600)),
      const Spacer(),
      Text(value ?? 'â€”', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
    ]));
}


