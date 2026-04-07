import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/status_badge.dart';

class ClinicianManagement extends StatefulWidget {
  const ClinicianManagement({super.key});

  @override
  State<ClinicianManagement> createState() => _ClinicianManagementState();
}

class _ClinicianManagementState extends State<ClinicianManagement> {
  final _searchCtrl = TextEditingController();
  String _filterStatus = 'All';
  bool _showForm = false;

  final List<Map<String, dynamic>> _clinicians = [
    {'name': 'Dr. Chisomo Banda', 'district': 'Blantyre', 'facility': 'Queen Elizabeth Central', 'role': 'Clinician', 'status': 'Active', 'lastActive': '2h ago'},
    {'name': 'Dr. Thandiwe Phiri', 'district': 'Lilongwe', 'facility': 'Kamuzu Central', 'role': 'Clinician', 'status': 'Active', 'lastActive': '1d ago'},
    {'name': 'Dr. Kondwani Mwale', 'district': 'Mzuzu', 'facility': 'Mzuzu Central', 'role': 'Clinician', 'status': 'Inactive', 'lastActive': '32d ago'},
    {'name': 'Dr. Grace Chirwa', 'district': 'Zomba', 'facility': 'Zomba Central', 'role': 'Midwife', 'status': 'Active', 'lastActive': '4h ago'},
    {'name': 'Dr. Mphatso Tembo', 'district': 'Mangochi', 'facility': 'Mangochi District', 'role': 'Clinician', 'status': 'Inactive', 'lastActive': '45d ago'},
    {'name': 'Dr. Blessings Nyirenda', 'district': 'Kasungu', 'facility': 'Kasungu District', 'role': 'Clinician', 'status': 'Active', 'lastActive': '6h ago'},
    {'name': 'Dr. Alinafe Kamanga', 'district': 'Salima', 'facility': 'Salima District', 'role': 'CHW', 'status': 'Active', 'lastActive': '3h ago'},
    {'name': 'Dr. Tadala Msiska', 'district': 'Karonga', 'facility': 'Karonga District', 'role': 'Clinician', 'status': 'Active', 'lastActive': '12h ago'},
    {'name': 'Dr. Chimwemwe Dube', 'district': 'Dedza', 'facility': 'Dedza District', 'role': 'Midwife', 'status': 'Inactive', 'lastActive': '20d ago'},
    {'name': 'Dr. Yankho Phiri', 'district': 'Ntcheu', 'facility': 'Ntcheu District', 'role': 'Clinician', 'status': 'Active', 'lastActive': '1h ago'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    return _clinicians.where((c) {
      final matchSearch = _searchCtrl.text.isEmpty ||
          c['name'].toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
          c['district'].toLowerCase().contains(_searchCtrl.text.toLowerCase());
      final matchStatus = _filterStatus == 'All' || c['status'] == _filterStatus;
      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Clinician Management',
                  style: GoogleFonts.publicSans(
                      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
              const Spacer(),
              _GradientButton(
                label: 'Add Clinician',
                icon: Icons.person_add_rounded,
                onTap: () => setState(() => _showForm = !_showForm),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Add form (collapsible)
          if (_showForm) ...[
            _AddClinicianForm(
              onSubmit: (data) => setState(() {
                _clinicians.add({...data, 'lastActive': 'Just now'});
                _showForm = false;
              }),
              onCancel: () => setState(() => _showForm = false),
            ),
            const SizedBox(height: 20),
          ],

          // Filters bar
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search by name or district...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.mutedText),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ..._statusFilters.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: s,
                      selected: _filterStatus == s,
                      onTap: () => setState(() => _filterStatus = s),
                    ),
                  )),
              const Spacer(),
              Text('${_filtered.length} records',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
            ],
          ),
          const SizedBox(height: 16),

          // Table — fills remaining space
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Table header
                    Container(
                      color: AppColors.pageBg,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                      child: Row(
                        children: [
                          _HeaderCell('#', flex: 1),
                          _HeaderCell('Name', flex: 4),
                          _HeaderCell('District', flex: 3),
                          _HeaderCell('Facility', flex: 5),
                          _HeaderCell('Role', flex: 2),
                          _HeaderCell('Status', flex: 2),
                          _HeaderCell('Last Active', flex: 2),
                          _HeaderCell('Actions', flex: 3),
                        ],
                      ),
                    ),
                    // Table rows
                    Expanded(
                      child: _filtered.isEmpty
                          ? Center(
                              child: Text('No clinicians found',
                                  style: GoogleFonts.inter(
                                      fontSize: 14, color: AppColors.mutedText)),
                            )
                          : ListView.builder(
                              itemCount: _filtered.length,
                              itemBuilder: (context, index) {
                                final c = _filtered[index];
                                final isActive = c['status'] == 'Active';
                                return Container(
                                  color: index.isEven
                                      ? AppColors.surfaceContainerLowest
                                      : AppColors.pageBg.withValues(alpha: 0.4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text('${index + 1}',
                                            style: GoogleFonts.inter(
                                                fontSize: 12, color: AppColors.mutedText)),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(c['name'],
                                            style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.onSurface)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(c['district'],
                                            style: GoogleFonts.inter(
                                                fontSize: 13, color: AppColors.bodyText)),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(c['facility'],
                                            style: GoogleFonts.inter(
                                                fontSize: 13, color: AppColors.bodyText)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(c['role'],
                                            style: GoogleFonts.inter(
                                                fontSize: 13, color: AppColors.bodyText)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: StatusBadge(
                                          label: c['status'],
                                          type: isActive
                                              ? BadgeType.success
                                              : BadgeType.neutral,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(c['lastActive'],
                                            style: GoogleFonts.inter(
                                                fontSize: 12, color: AppColors.mutedText)),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            _ActionBtn(
                                              icon: isActive
                                                  ? Icons.pause_circle_outline_rounded
                                                  : Icons.play_circle_outline_rounded,
                                              color: isActive
                                                  ? AppColors.warningText
                                                  : AppColors.successText,
                                              tooltip: isActive ? 'Deactivate' : 'Activate',
                                              onTap: () => setState(() {
                                                c['status'] =
                                                    isActive ? 'Inactive' : 'Active';
                                              }),
                                            ),
                                            const SizedBox(width: 4),
                                            _ActionBtn(
                                              icon: Icons.edit_outlined,
                                              color: AppColors.primary,
                                              tooltip: 'Edit',
                                              onTap: () {},
                                            ),
                                            const SizedBox(width: 4),
                                            _ActionBtn(
                                              icon: Icons.delete_outline_rounded,
                                              color: AppColors.criticalText,
                                              tooltip: 'Delete',
                                              onTap: () => setState(
                                                  () => _clinicians.remove(c)),
                                            ),
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

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
              letterSpacing: 0.5)),
    );
  }
}

const _statusFilters = ['All', 'Active', 'Inactive'];

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.mutedText)),
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
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
            gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _AddClinicianForm extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final VoidCallback onCancel;
  const _AddClinicianForm({required this.onSubmit, required this.onCancel});

  @override
  State<_AddClinicianForm> createState() => _AddClinicianFormState();
}

class _AddClinicianFormState extends State<_AddClinicianForm> {
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _facility = TextEditingController();
  String _district = 'Blantyre';
  String _role = 'Clinician';

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _facility.dispose();
    super.dispose();
  }

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
          Text('Add New Clinician',
              style: GoogleFonts.publicSans(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _FormField(label: 'Full Name', controller: _name, hint: 'Dr. John Doe'),
              _FormField(label: 'Contact', controller: _contact, hint: '+265 999 000 000'),
              _FormField(label: 'Facility', controller: _facility, hint: 'Health facility name'),
              _DropField(
                label: 'District',
                value: _district,
                items: const ['Blantyre', 'Lilongwe', 'Mzuzu', 'Zomba', 'Mangochi', 'Kasungu'],
                onChanged: (v) => setState(() => _district = v!),
              ),
              _DropField(
                label: 'Role',
                value: _role,
                items: const ['Clinician', 'Midwife', 'CHW'],
                onChanged: (v) => setState(() => _role = v!),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _GradientButton(
                label: 'Save Clinician',
                icon: Icons.save_rounded,
                onTap: () => widget.onSubmit({
                  'name': _name.text.isEmpty ? 'New Clinician' : _name.text,
                  'district': _district,
                  'facility': _facility.text.isEmpty ? 'N/A' : _facility.text,
                  'role': _role,
                  'status': 'Active',
                }),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: widget.onCancel,
                child: Text('Cancel',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  const _FormField({required this.label, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppColors.mutedText, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
              filled: true,
              fillColor: AppColors.surfaceContainerHighest,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropField({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppColors.mutedText, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            onChanged: onChanged,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceContainerHighest,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          ),
        ],
      ),
    );
  }
}
