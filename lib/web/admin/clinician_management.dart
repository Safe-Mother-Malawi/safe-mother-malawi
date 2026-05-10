import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/status_badge.dart';
import '../../../services/api_service.dart';
import '../../../utils/validators.dart';
import '../../../state/user_store.dart';
import 'widgets/password_management_dialog.dart';

// ── Malawi districts ──────────────────────────────────────────────────────────
const _kDistricts = [
  'Blantyre','Chikwawa','Chiradzulu','Chitipa','Dedza','Dowa',
  'Karonga','Kasungu','Likoma','Lilongwe','Machinga','Mangochi',
  'Mchinji','Mulanje','Mwanza','Mzimba','Neno','Nkhata Bay',
  'Nkhotakota','Nsanje','Ntcheu','Ntchisi','Phalombe','Rumphi',
  'Salima','Thyolo','Zomba',
];

const _kRegions = ['Northern', 'Central', 'Southern'];

const _kZones = {
  'Northern': ['Karonga Zone','Mzuzu Zone','Rumphi Zone','Chitipa Zone'],
  'Central':  ['Lilongwe Zone','Kasungu Zone','Salima Zone','Dedza Zone','Dowa Zone'],
  'Southern': ['Blantyre Zone','Zomba Zone','Mangochi Zone','Thyolo Zone','Mulanje Zone','Nsanje Zone'],
};

class ClinicianManagement extends StatefulWidget {
  const ClinicianManagement({super.key});

  @override
  State<ClinicianManagement> createState() => _ClinicianManagementState();
}

class _ClinicianManagementState extends State<ClinicianManagement> {
  final _searchCtrl = TextEditingController();
  String _filterStatus = 'All';
  String _filterFacility = 'All';
  bool _showForm   = false;
  bool _loading    = true;
  String? _error;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _facilities = [];
  Map<String, dynamic>? _editingUser;

  @override
  void initState() {
    super.initState();
    _load();
    _loadFacilities();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getUsers(role: 'clinician');
      setState(() { _users = data.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadFacilities() async {
    try {
      final data = await ApiService.getHealthFacilities();
      setState(() { _facilities = data.cast<Map<String, dynamic>>(); });
    } catch (e) {
      // Silently fail - facilities filter will just show "All" option
    }
  }

  List<String> get _facilityOptions {
    final facilities = _users
        .map((u) => u['facilityName']?.toString() ?? u['facility']?.toString() ?? '')
        .where((f) => f.isNotEmpty)
        .toSet()
        .toList();
    facilities.sort();
    return ['All', ...facilities];
  }

  List<Map<String, dynamic>> get _filtered => _users.where((u) {
        final name     = (u['fullName'] ?? '').toString().toLowerCase();
        final district = (u['district'] ?? '').toString().toLowerCase();
        final facility = (u['facilityName'] ?? u['facility'] ?? '').toString();
        final facilityLower = facility.toLowerCase();
        final active   = u['isActive'] == true;
        final q        = _searchCtrl.text.toLowerCase();
        
        final matchSearch = q.isEmpty || name.contains(q) || district.contains(q) || facilityLower.contains(q);
        final matchStatus = _filterStatus == 'All'
            || (_filterStatus == 'Active' && active)
            || (_filterStatus == 'Inactive' && !active);
        final matchFacility = _filterFacility == 'All' || facility == _filterFacility;
        
        return matchSearch && matchStatus && matchFacility;
      }).toList();

  Future<void> _toggleStatus(Map<String, dynamic> u) async {
    final id     = u['id'] as String;
    final active = u['isActive'] == true;
    try {
      await ApiService.instance.patch('/users/$id/status', {'isActive': !active});
      setState(() => u['isActive'] = !active);
    } catch (e) {
      _showErr('Failed to update status: $e');
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> u) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete User'),
        content: Text('Delete "${u['fullName']}"? This cannot be undone.'),
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
    if (confirmed != true) return;
    try {
      await ApiService.instance.delete('/users/${u['id']}');
      setState(() => _users.removeWhere((x) => x['id'] == u['id']));
    } catch (e) {
      _showErr('Failed to delete: $e');
    }
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.criticalText),
    );
  }

  void _showPasswordResetDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => PasswordManagementDialog(
        user: user,
        onPasswordReset: () {
          // Optionally refresh the user list or show success message
          // The dialog already shows success message, so we don't need to do anything here
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: AppColors.criticalText, size: 40),
        const SizedBox(height: 12),
        Text(_error!, style: GoogleFonts.inter(color: AppColors.criticalText)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ]));
    }

    final filtered = _filtered;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Clinician Management',
                style: GoogleFonts.publicSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
            const SizedBox(width: 12),
            Builder(builder: (ctx) {
              final d = UserStore.instance.district;
              if (d.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(20)),
                child: Text(d, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.infoText)),
              );
            }),
            const Spacer(),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: AppColors.primary), tooltip: 'Refresh'),
            const SizedBox(width: 8),
            _GradientBtn(
              label: 'Add Clinician',
              icon: Icons.person_add_rounded,
              onTap: () => setState(() { _showForm = !_showForm; _editingUser = null; }),
            ),
          ]),
          const SizedBox(height: 20),

          if (_showForm) ...[
            _AddClinicianForm(
              onSubmit: (data) async {
                try {
                  final res = await ApiService.instance.post('/auth/register', {...data, 'role': 'clinician'}) as Map<String, dynamic>;
                  final newUser = (res['user'] ?? res) as Map<String, dynamic>;
                  setState(() { 
                    _users.insert(0, newUser); 
                    _showForm = false; 
                  });
                  // Refresh facilities list to include any new facilities
                  _loadFacilities();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('User created successfully'),
                      backgroundColor: AppColors.successText,
                    ));
                  }
                } catch (e) {
                  _showErr('Failed to create user: $e');
                }
              },
              onCancel: () => setState(() => _showForm = false),
            ),
            const SizedBox(height: 20),
          ],

          if (_editingUser != null) ...[
            _EditClinicianForm(
              user: _editingUser!,
              onSubmit: (data) async {
                try {
                  await ApiService.instance.patch('/users/${_editingUser!['id']}', data);
                  setState(() { 
                    _editingUser!.addAll(data); 
                    _editingUser = null; 
                  });
                  // Refresh facilities list in case facility assignments changed
                  _loadFacilities();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('User updated'),
                      backgroundColor: AppColors.successText,
                    ));
                  }
                } catch (e) {
                  _showErr('Failed to update: $e');
                }
              },
              onCancel: () => setState(() => _editingUser = null),
            ),
            const SizedBox(height: 20),
          ],

          // Filters
          Row(children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search by name, district, facility or email...',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.mutedText),
                  filled: true, fillColor: AppColors.surfaceContainerLowest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ..._roleFilters.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _Chip(label: s, selected: _filterStatus == s, onTap: () => setState(() => _filterStatus = s)),
                )),
            const SizedBox(width: 12),
            // Health Facility Filter
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: _filterFacility,
                onChanged: (value) => setState(() => _filterFacility = value ?? 'All'),
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Filter by Facility',
                  labelStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _facilityOptions.map((facility) => DropdownMenuItem<String>(
                  value: facility,
                  child: Text(
                    facility == 'All' ? 'All Facilities' : facility,
                    style: GoogleFonts.inter(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
              ),
            ),
            const Spacer(),
            Text('${filtered.length} users', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
          ]),
          const SizedBox(height: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(children: [
                  Container(
                    color: AppColors.pageBg,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                    child: Row(children: [
                      _hCell('#', 1), _hCell('Name', 4), _hCell('Phone', 3),
                      _hCell('District', 3), _hCell('Facility', 4),
                      _hCell('Status', 2), _hCell('Actions', 3),
                    ]),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(child: Text('No users found', style: GoogleFonts.inter(fontSize: 14, color: AppColors.mutedText)))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final u = filtered[index];
                              final isActive = u['isActive'] == true;
                              final district = (u['district'] ?? '—').toString();
                              return Container(
                                color: index.isEven ? AppColors.surfaceContainerLowest : AppColors.pageBg.withValues(alpha: 0.4),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                child: Row(children: [
                                  Expanded(flex: 1, child: Text('${index + 1}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                                  Expanded(flex: 4, child: Text(u['fullName'] ?? '—', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
                                  Expanded(flex: 3, child: Text(u['phone'] ?? '—', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                                  Expanded(flex: 3, child: Text(district, style: GoogleFonts.inter(fontSize: 13, color: AppColors.bodyText))),
                                  Expanded(flex: 4, child: Text(u['facilityName'] ?? u['facility'] ?? '—', style: GoogleFonts.inter(fontSize: 13, color: AppColors.bodyText))),
                                  Expanded(flex: 2, child: StatusBadge(label: isActive ? 'Active' : 'Inactive', type: isActive ? BadgeType.success : BadgeType.neutral)),
                                  Expanded(flex: 3, child: Row(children: [
                                    _ActionBtn(
                                      icon: isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                                      color: isActive ? AppColors.warningText : AppColors.successText,
                                      tooltip: isActive ? 'Deactivate' : 'Activate',
                                      onTap: () => _toggleStatus(u),
                                    ),
                                    const SizedBox(width: 4),
                                    _ActionBtn(
                                      icon: Icons.lock_reset,
                                      color: AppColors.red,
                                      tooltip: 'Reset Password',
                                      onTap: () => _showPasswordResetDialog(u),
                                    ),
                                    const SizedBox(width: 4),
                                    _ActionBtn(icon: Icons.edit_outlined, color: AppColors.primary, tooltip: 'Edit',
                                        onTap: () => setState(() { _showForm = false; _editingUser = u; })),
                                    const SizedBox(width: 4),
                                    _ActionBtn(icon: Icons.delete_outline_rounded, color: AppColors.criticalText, tooltip: 'Delete',
                                        onTap: () => _deleteUser(u)),
                                  ])),
                                ]),
                              );
                            },
                          ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _roleFilters = ['All', 'Active', 'Inactive'];

Widget _hCell(String label, int flex) => Expanded(
      flex: flex,
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText, letterSpacing: 0.5)),
    );

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'admin':     (AppColors.primary, AppColors.infoBg),
      'dho':       (AppColors.tertiary, const Color(0xFFE0F2F1)),
      'clinician': (AppColors.secondary, AppColors.surfaceContainerLow),
    };
    final c = colors[role.toLowerCase()] ?? (AppColors.mutedText, AppColors.surfaceContainerLow);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.$2, borderRadius: BorderRadius.circular(20)),
      child: Text(role, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: c.$1)),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  const _Chip({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppColors.mutedText)),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(4), child: Icon(icon, size: 18, color: color)),
      ),
    );
  }
}

class _GradientBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _GradientBtn({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: onTap != null ? AppColors.primaryGradient : null,
          color: onTap == null ? AppColors.surfaceContainerHighest : null,
          borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, color: onTap != null ? Colors.white : AppColors.mutedText, size: 18),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
              color: onTap != null ? Colors.white : AppColors.mutedText)),
        ]),
      ),
    );
  }
}

// ── Add Clinician Form (Admin adds DHO or Admin) ───────────────────────────────────

class _AddClinicianForm extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final VoidCallback onCancel;
  const _AddClinicianForm({required this.onSubmit, required this.onCancel});

  @override
  State<_AddClinicianForm> createState() => _AddClinicianFormState();
}

class _AddClinicianFormState extends State<_AddClinicianForm> {
  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _phone    = TextEditingController();
  final _password = TextEditingController();
  bool _obscure   = true;

  // Facility selection
  List<Map<String, dynamic>> _facilities = [];
  Map<String, dynamic>? _selectedFacility;
  bool _loadingFacilities = false;

  // District is locked to the DHO's own district
  String get _district => UserStore.instance.district;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    if (_district.isEmpty) return;
    setState(() => _loadingFacilities = true);
    try {
      final data = await ApiService.getFacilitiesByDistrict(_district);
      setState(() {
        _facilities = data.cast<Map<String, dynamic>>();
        _loadingFacilities = false;
      });
    } catch (_) {
      setState(() => _loadingFacilities = false);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _phone.dispose(); _password.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _validateFullName(_name.text.trim()) == null &&
      _phone.text.trim().isNotEmpty &&
      _validatePhone(_phone.text.trim()) == null &&
      _password.text.trim().isNotEmpty &&
      Validators.validatePassword(_password.text.trim()) == null &&
      _selectedFacility != null;

  @override
  Widget build(BuildContext context) {
    final facilityName  = _selectedFacility?['facilityName']?.toString() ?? '';
    final urbanRural    = _selectedFacility?['urbanRural']?.toString() ?? '';
    final facilityType  = _selectedFacility?['facilityType']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.person_add_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Add New Clinician',
              style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.location_on_rounded, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text('District: ', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
          Text(_district.isNotEmpty ? _district : 'Not assigned',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ]),
        const SizedBox(height: 20),

        // ── Identity ──────────────────────────────────────────────────────
        _SectionLabel('Clinician Identity'),
        const SizedBox(height: 10),
        Wrap(spacing: 16, runSpacing: 16, children: [
          _TF(label: 'Full Name *', ctrl: _name, hint: 'Dr. Jane Banda',
              onChanged: (_) => setState(() {}), validator: _validateFullName),
          _TF(label: 'Phone Number *', ctrl: _phone, hint: '0999000000',
              keyboard: TextInputType.phone, onChanged: (_) => setState(() {}),
              validator: _validatePhone),
          _TF(label: 'Email (optional)', ctrl: _email, hint: 'clinician@moh.gov.mw',
              keyboard: TextInputType.emailAddress,
              validator: (v) => Validators.validateEmail(v, required: false)),
          _TF(label: 'Password *', ctrl: _password, hint: 'Min. 8 chars with uppercase, lowercase, number, special char',
              obscure: _obscure, onChanged: (_) => setState(() {}),
              validator: Validators.validatePassword,
              suffix: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                    size: 18, color: AppColors.mutedText),
                onPressed: () => setState(() => _obscure = !_obscure),
              )),
        ]),
        const SizedBox(height: 20),

        // ── Facility ──────────────────────────────────────────────────────
        _SectionLabel('Health Facility Assignment'),
        const SizedBox(height: 10),
        if (_loadingFacilities)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 10),
              Text('Loading facilities...'),
            ]),
          )
        else if (_facilities.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warningText),
              const SizedBox(width: 8),
              Text('No facilities found for $_district district.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.warningText)),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _loadFacilities,
                child: Text('Retry', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
              ),
            ]),
          )
        else ...[
          SizedBox(
            width: 460,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SELECT FACILITY *',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.mutedText, letterSpacing: 0.8)),
              const SizedBox(height: 6),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedFacility,
                hint: Text('Choose a facility in $_district',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
                onChanged: (v) => setState(() => _selectedFacility = v),
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                decoration: InputDecoration(
                  filled: true, fillColor: AppColors.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: _facilities.map((f) {
                  final name = f['facilityName']?.toString() ?? '—';
                  final type = f['facilityType']?.toString() ?? '';
                  final ur   = f['urbanRural']?.toString() ?? '';
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: f,
                    child: Text('$name${type.isNotEmpty ? ' ($type)' : ''}${ur.isNotEmpty ? ' · $ur' : ''}',
                        style: GoogleFonts.inter(fontSize: 13)),
                  );
                }).toList(),
              ),
            ]),
          ),
          // Auto-filled read-only fields
          if (_selectedFacility != null) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 16, runSpacing: 12, children: [
              _ReadOnly(label: 'Facility Name', value: facilityName),
              _ReadOnly(label: 'Urban / Rural', value: urbanRural),
              _ReadOnly(label: 'Facility Type', value: facilityType),
              _ReadOnly(label: 'District', value: _district),
            ]),
          ],
        ],
        const SizedBox(height: 24),

        Row(children: [
          _GradientBtn(
            label: 'Save Clinician',
            icon: Icons.save_rounded,
            onTap: _valid ? () => widget.onSubmit({
              'fullName':    _name.text.trim(),
              'phone':       _phone.text.trim(),
              'email':       _email.text.trim().isEmpty ? null : _email.text.trim(),
              'password':    _password.text.trim(),
              'district':    _district,
              'facilityName': facilityName,
              'urbanRural':  urbanRural,
              'facilityType': facilityType,
            }) : null,
          ),
          const SizedBox(width: 12),
          TextButton(onPressed: widget.onCancel,
              child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText))),
        ]),
      ]),
    );
  }
}

// ── Edit Clinician Form ────────────────────────────────────────────────────────────

class _EditClinicianForm extends StatefulWidget {
  final Map<String, dynamic> user;
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final VoidCallback onCancel;
  const _EditClinicianForm({required this.user, required this.onSubmit, required this.onCancel});

  @override
  State<_EditClinicianForm> createState() => _EditClinicianFormState();
}

class _EditClinicianFormState extends State<_EditClinicianForm> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late String _region;
  late String _zone;
  late String _district;

  List<Map<String, dynamic>> _facilities = [];
  Map<String, dynamic>? _selectedFacility;
  bool _loadingFacilities = false;

  @override
  void initState() {
    super.initState();
    _name     = TextEditingController(text: widget.user['fullName'] ?? '');
    _email    = TextEditingController(text: widget.user['email'] ?? '');
    _phone    = TextEditingController(text: widget.user['phone'] ?? '');
    _region   = widget.user['region'] ?? 'Southern';
    _zone     = widget.user['zone'] ?? (_kZones[_region]?.first ?? 'Blantyre Zone');
    _district = widget.user['district'] ?? 'Blantyre';
    _loadFacilities(_district, preselect: widget.user['facilityName']?.toString() ?? widget.user['facility']?.toString());
  }

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _phone.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities(String district, {String? preselect}) async {
    setState(() { _loadingFacilities = true; _facilities = []; _selectedFacility = null; });
    try {
      final data = await ApiService.getFacilitiesByDistrict(district);
      final list = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      Map<String, dynamic>? pre;
      if (preselect != null && preselect.isNotEmpty) {
        pre = list.firstWhere(
          (f) => f['facilityName']?.toString().toLowerCase() == preselect.toLowerCase(),
          orElse: () => <String, dynamic>{},
        );
        if ((pre as Map).isEmpty) pre = null;
      }
      setState(() {
        _facilities = list;
        _selectedFacility = pre;
        _loadingFacilities = false;
      });
    } catch (_) {
      setState(() => _loadingFacilities = false);
    }
  }

  List<String> get _zonesForRegion => _kZones[_region] ?? [];

  @override
  Widget build(BuildContext context) {
    final role = (widget.user['role'] ?? 'dho').toString();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1.5),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.edit_rounded, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Text('Edit ${role.toUpperCase()} User',
              style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
        ]),
        const SizedBox(height: 20),

        _SectionLabel('Identity'),
        const SizedBox(height: 10),
        Wrap(spacing: 16, runSpacing: 16, children: [
          _TF(label: 'Full Name', ctrl: _name, hint: 'Dr. Jane Banda', validator: _validateFullName),
          _TF(label: 'Phone', ctrl: _phone, hint: '0999000000', keyboard: TextInputType.phone,
              onChanged: (_) => setState(() {}), validator: _validatePhone),
          _TF(label: 'Email', ctrl: _email, hint: 'user@moh.gov.mw', keyboard: TextInputType.emailAddress,
              validator: (v) => Validators.validateEmail(v, required: false)),
        ]),
        const SizedBox(height: 20),

        _SectionLabel('Location Assignment'),
        const SizedBox(height: 10),
        Wrap(spacing: 16, runSpacing: 16, children: [
          _DD(label: 'Region', value: _region, items: _kRegions,
              onChanged: (v) => setState(() {
                _region = v!;
                _zone = _kZones[_region]!.first;
              })),
          _DD(label: 'Zone', value: _zone, items: _zonesForRegion,
              onChanged: (v) => setState(() => _zone = v!)),
          _DD(label: 'District', value: _district, items: _kDistricts,
              onChanged: (v) => setState(() => _district = v!)),
        ]),
        const SizedBox(height: 24),

        Row(children: [
          _GradientBtn(
            label: 'Save Changes',
            icon: Icons.save_rounded,
            onTap: () => widget.onSubmit({
              'fullName': _name.text.trim(),
              'phone':    _phone.text.trim(),
              'email':    _email.text.trim().isEmpty ? null : _email.text.trim(),
              'region':   _region,
              'zone':     _zone,
              'district': _district,
            }),
          ),
          const SizedBox(width: 12),
          TextButton(onPressed: widget.onCancel,
              child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText))),
        ]),
      ]),
    );
  }
}

// ── Shared form widgets ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 14, color: AppColors.primary, margin: const EdgeInsets.only(right: 8)),
    Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.headings, letterSpacing: 0.3)),
  ]);
}

class _RoleToggle extends StatelessWidget {
  final String label, value, selected;
  final IconData icon;
  final VoidCallback onTap;
  const _RoleToggle({required this.label, required this.value, required this.selected, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceContainerHighest),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.mutedText),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.bodyText)),
        ]),
      ),
    );
  }
}

class _TF extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final TextInputType keyboard;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final String? Function(String?)? validator;
  const _TF({required this.label, required this.ctrl, required this.hint,
      this.keyboard = TextInputType.text, this.obscure = false, this.onChanged, this.suffix, this.validator});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          obscureText: obscure,
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
            filled: true, fillColor: AppColors.surfaceContainerHighest,
            suffixIcon: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        if (validator != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Builder(
              builder: (context) {
                final error = validator!(ctrl.text);
                if (error == null) return const SizedBox();
                return Text(error,
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.red, fontWeight: FontWeight.w500));
              },
            ),
          ),
      ]),
    );
  }
}

class _DD extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DD({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
          decoration: InputDecoration(
            filled: true, fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        ),
      ]),
    );
  }
}

class _ReadOnly extends StatelessWidget {
  final String label, value;
  const _ReadOnly({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                color: AppColors.mutedText, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.infoBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(child: Text(
              value.isNotEmpty ? value : '—',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary,
                  fontWeight: FontWeight.w500),
            )),
          ]),
        ),
      ]),
    );
  }
}
String? _validateFullName(String? value) {
  return Validators.validateFullName(value);
}

String? _validatePhone(String? value) {
  return Validators.validatePhone(value);
}
