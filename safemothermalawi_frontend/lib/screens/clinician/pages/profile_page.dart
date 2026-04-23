import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';
import '../../../state/user_store.dart';
import '../../../services/api_service.dart';

class MyProfilePage extends StatefulWidget {
  final VoidCallback? onClose;
  const MyProfilePage({super.key, this.onClose});
  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _editing = false;
  bool _loading = true;
  Uint8List? _photoBytes;

  // Controllers — populated from UserStore after login
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _facilityCtrl;
  late final TextEditingController _districtCtrl;

  @override
  void initState() {
    super.initState();
    final u = UserStore.instance.user ?? {};
    _nameCtrl     = TextEditingController(text: u['fullName']?.toString()     ?? '');
    _emailCtrl    = TextEditingController(text: u['email']?.toString()        ?? '');
    _phoneCtrl    = TextEditingController(text: u['phone']?.toString()        ?? '');
    _roleCtrl     = TextEditingController(text: _fmtRole(u['role']?.toString() ?? ''));
    _facilityCtrl = TextEditingController(text: u['healthCentre']?.toString() ?? u['facility']?.toString() ?? '');
    _districtCtrl = TextEditingController(text: u['district']?.toString()     ?? '');

    UserStore.instance.addListener(_onUserUpdate);
    _refresh();
  }

  @override
  void dispose() {
    UserStore.instance.removeListener(_onUserUpdate);
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _roleCtrl, _facilityCtrl, _districtCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onUserUpdate() {
    if (!mounted) return;
    final u = UserStore.instance.user ?? {};
    setState(() {
      _nameCtrl.text     = u['fullName']?.toString()     ?? _nameCtrl.text;
      _emailCtrl.text    = u['email']?.toString()        ?? _emailCtrl.text;
      _phoneCtrl.text    = u['phone']?.toString()        ?? _phoneCtrl.text;
      _roleCtrl.text     = _fmtRole(u['role']?.toString() ?? '');
      _facilityCtrl.text = u['healthCentre']?.toString() ?? u['facility']?.toString() ?? _facilityCtrl.text;
      _districtCtrl.text = u['district']?.toString()     ?? _districtCtrl.text;
    });
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      await ApiService.getMe(); // updates UserStore → triggers _onUserUpdate
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  String _fmtRole(String role) {
    switch (role) {
      case 'clinician': return 'Clinician';
      case 'admin':     return 'System Admin';
      case 'dho':       return 'District Health Officer';
      default:          return role.isNotEmpty ? role[0].toUpperCase() + role.substring(1) : '—';
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  Future<void> _save() async {
    final userId = UserStore.instance.id;
    if (userId.isEmpty) return;

    setState(() => _editing = false);

    try {
      final updated = await ApiService.updateMe({
        'fullName':     _nameCtrl.text.trim(),
        'email':        _emailCtrl.text.trim(),
        'phone':        _phoneCtrl.text.trim(),
        'district':     _districtCtrl.text.trim(),
        'healthCentre': _facilityCtrl.text.trim(),
      });

      // Persist updated data into UserStore so all screens reflect the change
      UserStore.instance.save(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text('Profile updated successfully.'),
        ]),
        backgroundColor: const Color(0xFF1A3A5C),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _editing = true); // re-open edit mode on failure
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _editing = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to update profile. Check your connection.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (widget.onClose != null) ...[
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close, size: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Hero card ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                GestureDetector(
                  onTap: _editing ? _pickPhoto : null,
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                      child: _photoBytes == null
                          ? Text(initials, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
                          : null,
                    ),
                    if (_editing)
                      Positioned(bottom: 0, right: 0,
                        child: Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: AppColors.navy, size: 13),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (_loading)
                    const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  else
                    Text(_nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Loading...',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(_roleCtrl.text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(_facilityCtrl.text, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.greenL, borderRadius: BorderRadius.circular(16)),
                  child: const Text('Active',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.green)),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Personal Information ─────────────────────────────────────────
            _sectionHeader('Personal Information'),
            _field('Full Name',     _nameCtrl,  Icons.person_outline),
            _field('Email Address', _emailCtrl, Icons.email_outlined),
            _field('Phone Number',  _phoneCtrl, Icons.phone_outlined),
            const SizedBox(height: 12),

            // ── Work Details ─────────────────────────────────────────────────
            _sectionHeader('Work Details'),
            _field('Role',           _roleCtrl,     Icons.badge_outlined),
            _field('Health Facility',_facilityCtrl, Icons.local_hospital_outlined),
            _field('District',       _districtCtrl, Icons.location_on_outlined),
            const SizedBox(height: 80),
          ]),
        ),
      ),

      // ── Sticky bottom bar ────────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.g200)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(children: [
          if (_editing) ...[
            OutlinedButton(
              onPressed: () => setState(() => _editing = false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.g600,
                side: const BorderSide(color: AppColors.g200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save, size: 16),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            )),
          ] else
            Expanded(child: ElevatedButton.icon(
              onPressed: () => setState(() => _editing = true),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            )),
        ]),
      ),
    ]);
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Container(width: 3, height: 14, color: AppColors.navy, margin: const EdgeInsets.only(right: 8)),
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800)),
    ]),
  );

  Widget _field(String label, TextEditingController ctrl, IconData icon) {
    if (!_editing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(icon, size: 15, color: AppColors.navy),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g600)),
          const Spacer(),
          Text(ctrl.text.isNotEmpty ? ctrl.text : '—',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: AppColors.g600),
          prefixIcon: Icon(icon, size: 16, color: AppColors.navy),
          filled: true, fillColor: AppColors.bg,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.g200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.g200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.navy, width: 1.5)),
        ),
      ),
    );
  }
}
