import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service_web.dart';
import '../../../utils/validators.dart';

class MyProfilePage extends StatefulWidget {
  final VoidCallback? onClose;
  const MyProfilePage({super.key, this.onClose});
  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _editing  = false;
  bool _loading  = true;
  bool _saving   = false;
  String? _error;

  Map<String, dynamic> _profile = {};

  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _facilityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _districtCtrl, _facilityCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!forceRefresh) {
        final cached = AuthServiceWeb.instance.currentUser;
        if (cached != null && cached.isNotEmpty) {
          _applyProfile(cached);
          setState(() => _loading = false);
          return;
        }
      }
      await ApiService.instance.loadToken();
      final raw = await ApiService.instance.get('/auth/me');
      final data = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      if (data.isNotEmpty) {
        AuthServiceWeb.instance.updateCurrentUser(data);
        _applyProfile(data);
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _applyProfile(Map<String, dynamic> data) {
    _profile = data;
    _nameCtrl.text     = (data['fullName']    ?? '').toString();
    _emailCtrl.text    = (data['email']       ?? '').toString();
    _phoneCtrl.text    = (data['phone']       ?? '').toString();
    _districtCtrl.text = (data['district']    ?? '').toString();
    _facilityCtrl.text = (data['facilityName'] ?? data['facility'] ?? '').toString();
  }

  /// DHO and clinician cannot change email (used for login), district, or
  /// health facility — those are assigned/managed by the admin.
  bool get _isAdminAssignedRole {
    final role = (_profile['role'] ?? '').toString().toLowerCase();
    return role == 'dho' || role == 'clinician';
  }

  Future<void> _save() async {
    final nameError = Validators.validateFullName(_nameCtrl.text.trim());
    if (nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(nameError),
        backgroundColor: AppColors.red,
      ));
      return;
    }
    final phoneError = Validators.validatePhone(_phoneCtrl.text.trim());
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(phoneError),
        backgroundColor: AppColors.red,
      ));
      return;
    }
    final emailError = Validators.validateEmail(_emailCtrl.text.trim(), required: false);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(emailError),
        backgroundColor: AppColors.red,
      ));
      return;
    }

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Never send district/healthCentre/email for dho/clinician — admin-assigned only
      final body = <String, dynamic>{
        'fullName': _nameCtrl.text.trim(),
        'phone':    _phoneCtrl.text.trim(),
        if (!_isAdminAssignedRole) 'email':        _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        if (!_isAdminAssignedRole) 'district':     _districtCtrl.text.trim(),
        if (!_isAdminAssignedRole) 'facilityName': _facilityCtrl.text.trim(),
      };

      // 1. Persist to backend
      await ApiService.instance.patch('/auth/me', body);

      // 2. Re-fetch the authoritative profile from the backend
      final fresh = await ApiService.instance.get('/auth/me');
      final updated = fresh is Map ? Map<String, dynamic>.from(fresh) : body;

      // 3. Update in-memory session cache so top bar name etc. refresh
      AuthServiceWeb.instance.updateCurrentUser(updated);

      // 4. Apply to local controllers
      _applyProfile(updated);

      setState(() { _editing = false; _saving = false; });
      messenger.showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text('Profile updated successfully.'),
        ]),
        backgroundColor: AppColors.navy,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
    } catch (e) {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(
        content: Text('Update failed: $e'),
        backgroundColor: AppColors.red,
      ));
    }
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
        ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
      ]));
    }

    final role     = (_profile['role'] ?? 'clinician').toString();
    final initials = _nameCtrl.text.isNotEmpty
        ? _nameCtrl.text.trim().split(' ')
            .where((w) => w.isNotEmpty).take(2)
            .map((w) => w[0]).join().toUpperCase()
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

            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: Text(initials,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_nameCtrl.text,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(role.toUpperCase(),
                      style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 0.8)),
                  if (_districtCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 11, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(_districtCtrl.text,
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ]),
                  ],
                  if (_facilityCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(_facilityCtrl.text,
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
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

            // Personal Information
            _sectionHeader('Personal Information'),
            _field('Full Name',     _nameCtrl,  Icons.person_outline, validator: Validators.validateFullName),
            // Email is the login credential for DHO/clinician — not editable
            if (_isAdminAssignedRole)
              _adminAssignedField(
                label: 'Email Address',
                value: _emailCtrl.text,
                icon: Icons.email_outlined,
                hint: 'Email is your login credential and cannot be changed',
              )
            else
              _field('Email Address', _emailCtrl, Icons.email_outlined, 
                     validator: (v) => Validators.validateEmail(v, required: false)),
            _field('Phone Number',  _phoneCtrl, Icons.phone_outlined, validator: Validators.validatePhone),
            const SizedBox(height: 12),

            // Work Details
            _sectionHeader('Work Details'),
            _readOnlyField('Role', role.toUpperCase(), Icons.badge_outlined),

            // District — always read-only for DHO and clinician
            if (_isAdminAssignedRole) ...[
              _adminAssignedField(
                label: 'District',
                value: _districtCtrl.text,
                icon: Icons.location_on_outlined,
                hint: role.toLowerCase() == 'dho'
                    ? 'Your district is assigned by the system admin'
                    : 'Assigned by your DHO / admin',
              ),
              _adminAssignedField(
                label: 'Health Facility',
                value: _facilityCtrl.text,
                icon: Icons.local_hospital_outlined,
                hint: role.toLowerCase() == 'dho'
                    ? 'DHOs oversee all facilities in their district'
                    : 'Assigned by your DHO / admin',
              ),
            ] else ...[
              _field('Health Facility', _facilityCtrl, Icons.local_hospital_outlined),
              _field('District',        _districtCtrl, Icons.location_on_outlined),
            ],

            const SizedBox(height: 80),
          ]),
        ),
      ),

      // Sticky bottom bar
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.g200)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(children: [
          if (_editing) ...[
            OutlinedButton(
              onPressed: _saving ? null : () => setState(() { _editing = false; _loadProfile(forceRefresh: true); }),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.g600, side: const BorderSide(color: AppColors.g200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save, size: 16),
                label: Text(_saving ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
                ),
              ),
            ),
          ] else
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _editing = true),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
                ),
              ),
            ),
        ]),
      ),
    ]);
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 3, height: 14, color: AppColors.navy, margin: const EdgeInsets.only(right: 8)),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800)),
      ]),
    );
  }

  /// Editable in edit mode, read-only in view mode.
  Widget _field(String label, TextEditingController ctrl, IconData icon, {String? Function(String?)? validator}) {
    if (!_editing) {
      return _viewRow(label, ctrl.text, icon);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
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
        if (validator != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Builder(
              builder: (context) {
                final error = validator(ctrl.text);
                if (error == null) return const SizedBox();
                return Text(error,
                    style: const TextStyle(fontSize: 10, color: AppColors.red, fontWeight: FontWeight.w500));
              },
            ),
          ),
      ]),
    );
  }

  /// Always read-only — value set by admin. Shows lock icon + hint tooltip.
  Widget _adminAssignedField({
    required String label,
    required String value,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.g200),
      ),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.g400),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g600)),
        const Spacer(),
        Text(
          value.isEmpty ? '—' : value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: hint,
          child: const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.g400),
        ),
      ]),
    );
  }

  /// Plain read-only row (for role, etc.).
  Widget _readOnlyField(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.navy),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g600)),
        const Spacer(),
        Row(children: [
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
          const SizedBox(width: 4),
          const Icon(Icons.lock_outline_rounded, size: 11, color: AppColors.g400),
        ]),
      ]),
    );
  }

  Widget _viewRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, size: 15, color: AppColors.navy),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g600)),
        const Spacer(),
        Text(value.isEmpty ? '—' : value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
      ]),
    );
  }
}
