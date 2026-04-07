import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/status_badge.dart';

class SystemUsers extends StatefulWidget {
  const SystemUsers({super.key});

  @override
  State<SystemUsers> createState() => _SystemUsersState();
}

class _SystemUsersState extends State<SystemUsers> {
  final _searchCtrl = TextEditingController();
  String _filterRole = 'All';
  String _filterStatus = 'All';
  bool _showForm = false;

  final List<Map<String, dynamic>> _users = [
    // Admins
    {'name': 'Dr. James Phiri', 'email': 'admin@moh.gov.mw', 'role': 'Admin', 'district': 'National', 'facility': 'MOH HQ', 'status': 'Active', 'lastActive': '1h ago'},
    // DHOs
    {'name': 'Dr. Chisomo Banda', 'email': 'dho.blantyre@moh.gov.mw', 'role': 'DHO', 'district': 'Blantyre', 'facility': 'Blantyre DHO Office', 'status': 'Active', 'lastActive': '2h ago'},
    {'name': 'Dr. Thandiwe Phiri', 'email': 'dho.lilongwe@moh.gov.mw', 'role': 'DHO', 'district': 'Lilongwe', 'facility': 'Lilongwe DHO Office', 'status': 'Active', 'lastActive': '4h ago'},
    {'name': 'Dr. Kondwani Mwale', 'email': 'dho.mzuzu@moh.gov.mw', 'role': 'DHO', 'district': 'Mzuzu', 'facility': 'Mzuzu DHO Office', 'status': 'Inactive', 'lastActive': '15d ago'},
    {'name': 'Dr. Grace Chirwa', 'email': 'dho.zomba@moh.gov.mw', 'role': 'DHO', 'district': 'Zomba', 'facility': 'Zomba DHO Office', 'status': 'Active', 'lastActive': '6h ago'},
    // Clinicians
    {'name': 'Dr. Mphatso Tembo', 'email': 'clinician.mangochi@moh.gov.mw', 'role': 'Clinician', 'district': 'Mangochi', 'facility': 'Mangochi District Hospital', 'status': 'Active', 'lastActive': '3h ago'},
    {'name': 'Dr. Blessings Nyirenda', 'email': 'clinician.kasungu@moh.gov.mw', 'role': 'Clinician', 'district': 'Kasungu', 'facility': 'Kasungu District Hospital', 'status': 'Active', 'lastActive': '5h ago'},
    {'name': 'Dr. Alinafe Kamanga', 'email': 'chw.salima@moh.gov.mw', 'role': 'CHW', 'district': 'Salima', 'facility': 'Salima District Hospital', 'status': 'Active', 'lastActive': '1h ago'},
    {'name': 'Dr. Tadala Msiska', 'email': 'clinician.karonga@moh.gov.mw', 'role': 'Clinician', 'district': 'Karonga', 'facility': 'Karonga District Hospital', 'status': 'Active', 'lastActive': '8h ago'},
    {'name': 'Dr. Chimwemwe Dube', 'email': 'midwife.dedza@moh.gov.mw', 'role': 'Midwife', 'district': 'Dedza', 'facility': 'Dedza District Hospital', 'status': 'Inactive', 'lastActive': '22d ago'},
    {'name': 'Dr. Yankho Phiri', 'email': 'clinician.ntcheu@moh.gov.mw', 'role': 'Clinician', 'district': 'Ntcheu', 'facility': 'Ntcheu District Hospital', 'status': 'Active', 'lastActive': '2h ago'},
    {'name': 'Dr. Tiwonge Banda', 'email': 'clinician.thyolo@moh.gov.mw', 'role': 'Clinician', 'district': 'Thyolo', 'facility': 'Thyolo District Hospital', 'status': 'Active', 'lastActive': '7h ago'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered => _users.where((u) {
        final matchSearch = _searchCtrl.text.isEmpty ||
            u['name'].toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
            u['district'].toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
            u['email'].toLowerCase().contains(_searchCtrl.text.toLowerCase());
        final matchRole = _filterRole == 'All' || u['role'] == _filterRole;
        final matchStatus = _filterStatus == 'All' || u['status'] == _filterStatus;
        return matchSearch && matchRole && matchStatus;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('System Users',
                  style: GoogleFonts.publicSans(
                      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(20)),
                child: Text('Nationwide', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.infoText)),
              ),
              const Spacer(),
              _GradientBtn(
                label: 'Add User',
                icon: Icons.person_add_rounded,
                onTap: () => setState(() => _showForm = !_showForm),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Add form
          if (_showForm) ...[
            _AddUserForm(
              onSubmit: (data) => setState(() {
                _users.add({...data, 'lastActive': 'Just now'});
                _showForm = false;
              }),
              onCancel: () => setState(() => _showForm = false),
            ),
            const SizedBox(height: 20),
          ],

          // Filters
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search by name, district or email...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.mutedText),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ..._roleFilters.map((r) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _Chip(label: r, selected: _filterRole == r, onTap: () => setState(() => _filterRole = r)),
                  )),
              const SizedBox(width: 8),
              _Chip(label: 'Active', selected: _filterStatus == 'Active', onTap: () => setState(() => _filterStatus = _filterStatus == 'Active' ? 'All' : 'Active'), color: AppColors.successText),
              const SizedBox(width: 6),
              _Chip(label: 'Inactive', selected: _filterStatus == 'Inactive', onTap: () => setState(() => _filterStatus = _filterStatus == 'Inactive' ? 'All' : 'Inactive'), color: AppColors.criticalText),
              const Spacer(),
              Text('${filtered.length} users', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
            ],
          ),
          const SizedBox(height: 16),

          // Table fills remaining space
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Header row
                    Container(
                      color: AppColors.pageBg,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                      child: Row(
                        children: [
                          _headerCell('#', 1), _headerCell('Name', 4), _headerCell('Email', 5), _headerCell('Role', 2),
                          _headerCell('District', 3), _headerCell('Status', 2), _headerCell('Last Active', 2), _headerCell('Actions', 3),
                        ],
                      ),
                    ),
                    // Data rows
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text('No users found', style: GoogleFonts.inter(fontSize: 14, color: AppColors.mutedText)))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final u = filtered[index];
                                final isActive = u['status'] == 'Active';
                                return Container(
                                  color: index.isEven ? AppColors.surfaceContainerLowest : AppColors.pageBg.withValues(alpha: 0.4),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 1, child: Text('${index + 1}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                                      Expanded(flex: 4, child: Text(u['name'], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
                                      Expanded(flex: 5, child: Text(u['email'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                                      Expanded(flex: 2, child: _RoleBadge(role: u['role'])),
                                      Expanded(flex: 3, child: Text(u['district'], style: GoogleFonts.inter(fontSize: 13, color: AppColors.bodyText))),
                                      Expanded(flex: 2, child: StatusBadge(label: u['status'], type: isActive ? BadgeType.success : BadgeType.neutral)),
                                      Expanded(flex: 2, child: Text(u['lastActive'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            _ActionBtn(
                                              icon: isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                                              color: isActive ? AppColors.warningText : AppColors.successText,
                                              tooltip: isActive ? 'Deactivate' : 'Activate',
                                              onTap: () => setState(() => u['status'] = isActive ? 'Inactive' : 'Active'),
                                            ),
                                            const SizedBox(width: 4),
                                            _ActionBtn(icon: Icons.edit_outlined, color: AppColors.primary, tooltip: 'Edit', onTap: () {}),
                                            const SizedBox(width: 4),
                                            _ActionBtn(icon: Icons.delete_outline_rounded, color: AppColors.criticalText, tooltip: 'Delete', onTap: () => setState(() => _users.remove(u))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _roleFilters = ['All', 'Admin', 'DHO', 'Clinician', 'Midwife', 'CHW'];

Widget _headerCell(String label, int flex) => Expanded(
      flex: flex,
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText, letterSpacing: 0.5)),
    );

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'Admin': (AppColors.primary, AppColors.infoBg),
      'DHO': (AppColors.tertiary, const Color(0xFFE0F2F1)),
      'Clinician': (AppColors.secondary, AppColors.surfaceContainerLow),
      'Midwife': (AppColors.warningText, AppColors.warningBg),
      'CHW': (AppColors.successText, AppColors.successBg),
    };
    final c = colors[role] ?? (AppColors.mutedText, AppColors.surfaceContainerLow);
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
  final VoidCallback onTap;
  const _GradientBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        ]),
      ),
    );
  }
}

class _AddUserForm extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final VoidCallback onCancel;
  const _AddUserForm({required this.onSubmit, required this.onCancel});

  @override
  State<_AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends State<_AddUserForm> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _facility = TextEditingController();
  String _district = 'Blantyre';
  String _role = 'Clinician';

  @override
  void dispose() { _name.dispose(); _email.dispose(); _facility.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add New User', style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16, runSpacing: 16,
            children: [
              _Field(label: 'Full Name', ctrl: _name, hint: 'Dr. John Doe'),
              _Field(label: 'Email', ctrl: _email, hint: 'user@moh.gov.mw'),
              _Field(label: 'Facility', ctrl: _facility, hint: 'Health facility name'),
              _Drop(label: 'District', value: _district,
                  items: const ['National','Blantyre','Lilongwe','Mzuzu','Zomba','Mangochi','Kasungu','Salima','Karonga','Dedza','Ntcheu','Thyolo'],
                  onChanged: (v) => setState(() => _district = v!)),
              _Drop(label: 'Role', value: _role,
                  items: const ['Admin','DHO','Clinician','Midwife','CHW'],
                  onChanged: (v) => setState(() => _role = v!)),
            ],
          ),
          const SizedBox(height: 20),
          Row(children: [
            _GradientBtn(label: 'Save User', icon: Icons.save_rounded,
                onTap: () => widget.onSubmit({
                  'name': _name.text.isEmpty ? 'New User' : _name.text,
                  'email': _email.text.isEmpty ? 'user@moh.gov.mw' : _email.text,
                  'role': _role, 'district': _district,
                  'facility': _facility.text.isEmpty ? 'N/A' : _facility.text,
                  'status': 'Active',
                })),
            const SizedBox(width: 12),
            TextButton(onPressed: widget.onCancel,
                child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText))),
          ]),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  const _Field({required this.label, required this.hint, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        TextField(controller: ctrl,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
          decoration: InputDecoration(hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
            filled: true, fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
      ]),
    );
  }
}

class _Drop extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _Drop({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value, onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
          decoration: InputDecoration(filled: true, fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList()),
      ]),
    );
  }
}
