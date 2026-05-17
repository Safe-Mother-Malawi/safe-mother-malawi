import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../shared/widgets/status_badge.dart';
import '../../../services/api_service.dart';
import '../../../utils/validators.dart';
import 'widgets/password_management_dialog.dart';

class SystemUsers extends StatefulWidget {
  const SystemUsers({super.key});

  @override
  State<SystemUsers> createState() => _SystemUsersState();
}

class _SystemUsersState extends State<SystemUsers> {
  final _searchCtrl = TextEditingController();
  String _filterRole   = 'All';
  String _filterStatus = 'All';
  bool _showForm   = false;
  bool _loading    = true;
  String? _error;

  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _editingUser;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Load all user types for admin dashboard
      final staffData = await ApiService.instance.get('/users') as List<dynamic>;
      final patientData = await ApiService.instance.get('/users/patients') as List<dynamic>;
      
      setState(() {
        _users = [
          ...staffData.cast<Map<String, dynamic>>(),
          ...patientData.cast<Map<String, dynamic>>(),
        ];
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered => _users.where((u) {
        final name     = (u['fullName'] ?? '').toString().toLowerCase();
        final email    = (u['email'] ?? '').toString().toLowerCase();
        final district = (u['district'] ?? '').toString().toLowerCase();
        final role     = (u['role'] ?? '').toString();
        final active   = u['isActive'] == true;
        final q        = _searchCtrl.text.toLowerCase();

        final matchSearch = q.isEmpty || name.contains(q) || email.contains(q) || district.contains(q);
        final matchRole   = _filterRole == 'All' || role.toLowerCase() == _filterRole.toLowerCase();
        final matchStatus = _filterStatus == 'All'
            || (_filterStatus == 'Active' && active)
            || (_filterStatus == 'Inactive' && !active);
        return matchSearch && matchRole && matchStatus;
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

  void _showUserDetails(Map<String, dynamic> u) {
    final role = (u['role'] ?? '').toString().toLowerCase();
    final isMobileUser = ['prenatal', 'neonatal'].contains(role);
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(
              isMobileUser 
                ? (role == 'prenatal' ? Icons.pregnant_woman : Icons.child_care)
                : Icons.person,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('${u['fullName']} Details')),
          ],
        ),
        content: SizedBox(
          width: isMobileUser ? 500 : 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                _SectionHeader('Basic Information'),
                _DetailRow('Full Name', u['fullName'] ?? '—'),
                _DetailRow('Role', (u['role'] ?? '').toString().toUpperCase()),
                _DetailRow('Phone', u['phone'] ?? '—'),
                _DetailRow('Email', u['email'] ?? '—'),
                _DetailRow('Age', u['age'] ?? '—'),
                _DetailRow('Nationality', u['nationality'] ?? '—'),
                
                const SizedBox(height: 16),
                
                // Location Information
                _SectionHeader('Location'),
                _DetailRow('Region', u['region'] ?? '—'),
                _DetailRow('Zone', u['zone'] ?? '—'),
                _DetailRow('District', u['district'] ?? '—'),
                _DetailRow('Health Facility', u['facilityName'] ?? u['facility'] ?? '—'),
                
                if (isMobileUser) ...[
                  const SizedBox(height: 16),
                  
                  // Prenatal-specific information
                  if (role == 'prenatal') ...[
                    _SectionHeader('Pregnancy Information'),
                    _DetailRow('Pregnancy Months', u['pregnancyMonths'] ?? '—'),
                    _DetailRow('Pregnancy Weeks', u['pregnancyWeeks'] ?? '—'),
                    _DetailRow('Expected Delivery Date', u['expectedDeliveryDate'] ?? '—'),
                    _DetailRow('Last Menstrual Period', u['lmpDate'] ?? '—'),
                  ],
                  
                  // Neonatal-specific information
                  if (role == 'neonatal') ...[
                    _SectionHeader('Baby Information'),
                    _DetailRow('Baby Name', u['babyName'] ?? '—'),
                    _DetailRow('Baby Date of Birth', u['babyDob'] ?? '—'),
                    _DetailRow('Baby Gender', u['babyGender'] ?? '—'),
                    _DetailRow('Birth Weight', u['babyBirthWeight'] ?? '—'),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Preferences
                  if (u['preferences'] != null) ...[
                    _SectionHeader('App Preferences'),
                    _buildPreferencesSection(u['preferences']),
                  ],
                ],
                
                const SizedBox(height: 16),
                
                // Account Status
                _SectionHeader('Account Status'),
                _DetailRow('Status', u['isActive'] == true ? 'Active' : 'Inactive'),
                _DetailRow('Last Active', u['lastActiveAt'] != null 
                  ? DateTime.parse(u['lastActiveAt']).toString().split('.')[0]
                  : 'Never'),
                _DetailRow('Registered', u['createdAt'] != null 
                  ? DateTime.parse(u['createdAt']).toString().split('.')[0]
                  : '—'),
              ],
            ),
          ),
        ),
        actions: [
          if (isMobileUser) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showEditMobileUserDialog(u);
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _deleteMobileUser(u);
              },
              icon: const Icon(Icons.delete, size: 16, color: AppColors.criticalText),
              label: Text('Delete', style: TextStyle(color: AppColors.criticalText)),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.criticalText),
    );
  }

  Widget _SectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            color: AppColors.primary,
            margin: const EdgeInsets.only(right: 8),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.headings,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(Map<String, dynamic> preferences) {
    final prefs = [
      ('Appointment Reminders', preferences['appointmentReminders']),
      ('Daily Tips', preferences['dailyTips']),
      ('Baby Milestones', preferences['babyMilestones']),
      ('Health Alerts', preferences['healthAlerts']),
      ('Dark Mode', preferences['darkMode']),
      ('Offline Mode', preferences['offlineMode']),
      ('App Language', preferences['appLanguage']),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: prefs.map((pref) {
        final value = pref.$2;
        String displayValue;
        if (value is bool) {
          displayValue = value ? 'Enabled' : 'Disabled';
        } else if (value is String) {
          displayValue = value;
        } else {
          displayValue = '—';
        }
        return _DetailRow(pref.$1, displayValue);
      }).toList(),
    );
  }

  Future<void> _deleteMobileUser(Map<String, dynamic> u) async {
    final role = (u['role'] ?? '').toString().toLowerCase();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.criticalText, size: 20),
            const SizedBox(width: 8),
            const Text('Delete Mobile User'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this ${role} user?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.criticalText.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.criticalText.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User: ${u['fullName']}',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  Text('Phone: ${u['phone']}'),
                  Text('District: ${u['district'] ?? '—'}'),
                  if (role == 'prenatal' && u['expectedDeliveryDate'] != null)
                    Text('Expected Delivery: ${u['expectedDeliveryDate']}'),
                  if (role == 'neonatal' && u['babyName'] != null)
                    Text('Baby: ${u['babyName']}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone. All user data, appointments, and preferences will be permanently deleted.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.criticalText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalText,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Delete User'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      await ApiService.instance.delete('/users/${u['id']}');
      setState(() => _users.removeWhere((x) => x['id'] == u['id']));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${role.toUpperCase()} user deleted successfully'),
            backgroundColor: AppColors.successText,
          ),
        );
      }
    } catch (e) {
      _showErr('Failed to delete user: $e');
    }
  }

  void _showEditMobileUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => _EditMobileUserDialog(
        user: user,
        onUserUpdated: (updatedUser) {
          setState(() {
            final index = _users.indexWhere((u) => u['id'] == updatedUser['id']);
            if (index != -1) {
              _users[index] = updatedUser;
            }
          });
        },
      ),
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
            Text('System Users',
                style: GoogleFonts.publicSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(20)),
              child: Text('DHOs & Admins',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.infoText)),
            ),
            const Spacer(),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: AppColors.primary), tooltip: 'Refresh'),
            const SizedBox(width: 8),
            _GradientBtn(
              label: 'Add User',
              icon: Icons.person_add_rounded,
              onTap: () => setState(() { _showForm = !_showForm; _editingUser = null; }),
            ),
          ]),
          const SizedBox(height: 20),

          if (_showForm) ...[
            _AddUserForm(
              onSubmit: (data) async {
                try {
                  final created = await ApiService.instance.post('/users/dho', data) as Map<String, dynamic>;
                  final newUser = (created['user'] ?? created) as Map<String, dynamic>;
                  setState(() { _users.insert(0, newUser); _showForm = false; });
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
            _EditUserForm(
              user: _editingUser!,
              onSubmit: (data) async {
                try {
                  await ApiService.instance.patch('/users/${_editingUser!['id']}', data);
                  setState(() { _editingUser!.addAll(data); _editingUser = null; });
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
                  hintText: 'Search by name, district or email...',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.mutedText),
                  filled: true, fillColor: AppColors.surfaceContainerLowest,
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
            _Chip(label: 'Active', selected: _filterStatus == 'Active',
                onTap: () => setState(() => _filterStatus = _filterStatus == 'Active' ? 'All' : 'Active'),
                color: AppColors.successText),
            const SizedBox(width: 6),
            _Chip(label: 'Inactive', selected: _filterStatus == 'Inactive',
                onTap: () => setState(() => _filterStatus = _filterStatus == 'Inactive' ? 'All' : 'Inactive'),
                color: AppColors.criticalText),
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
                      _hCell('#', 1), _hCell('Name', 4), _hCell('Email / Phone', 4),
                      _hCell('Role', 2), _hCell('Region', 2), _hCell('Zone', 2), _hCell('District', 2),
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
                              final role = (u['role'] ?? '').toString();
                              final contact = (u['email'] ?? u['phone'] ?? '—').toString();
                              final region = (u['region'] ?? '—').toString();
                              final zone = (u['zone'] ?? '—').toString();
                              final district = (u['district'] ?? '—').toString();
                              return Container(
                                color: index.isEven ? AppColors.surfaceContainerLowest : AppColors.pageBg.withValues(alpha: 0.4),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                child: Row(children: [
                                  Expanded(flex: 1, child: Text('${index + 1}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                                  Expanded(flex: 4, child: Text(u['fullName'] ?? '—', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
                                  Expanded(flex: 4, child: Text(contact, style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                                  Expanded(flex: 2, child: _RoleBadge(role: role)),
                                  Expanded(flex: 2, child: Text(region, style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                                  Expanded(flex: 2, child: Text(zone, style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText))),
                                  Expanded(flex: 2, child: Text(district, style: GoogleFonts.inter(fontSize: 13, color: AppColors.bodyText))),
                                  Expanded(flex: 2, child: StatusBadge(label: isActive ? 'Active' : 'Inactive', type: isActive ? BadgeType.success : BadgeType.neutral)),
                                  Expanded(flex: 3, child: Row(children: [
                                    // All users can be activated/deactivated
                                    _ActionBtn(
                                      icon: isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                                      color: isActive ? AppColors.warningText : AppColors.successText,
                                      tooltip: isActive ? 'Deactivate' : 'Activate',
                                      onTap: () => _toggleStatus(u),
                                    ),
                                    const SizedBox(width: 4),
                                    
                                    // Staff users (admin, dho, clinician) - full management
                                    if (['admin', 'dho', 'clinician'].contains(role.toLowerCase())) ...[
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
                                    ] 
                                    // Mobile users (prenatal/neonatal) - enhanced management
                                    else if (['prenatal', 'neonatal'].contains(role.toLowerCase())) ...[
                                      _ActionBtn(
                                        icon: Icons.visibility_outlined,
                                        color: AppColors.primary,
                                        tooltip: 'View Details',
                                        onTap: () => _showUserDetails(u),
                                      ),
                                      const SizedBox(width: 4),
                                      _ActionBtn(
                                        icon: Icons.edit_outlined,
                                        color: AppColors.accent,
                                        tooltip: 'Edit Mobile User',
                                        onTap: () => _showEditMobileUserDialog(u),
                                      ),
                                      const SizedBox(width: 4),
                                      _ActionBtn(
                                        icon: Icons.delete_outline_rounded,
                                        color: AppColors.criticalText,
                                        tooltip: 'Delete Mobile User',
                                        onTap: () => _deleteMobileUser(u),
                                      ),
                                    ]
                                    // Other users - view only
                                    else ...[
                                      _ActionBtn(
                                        icon: Icons.visibility_outlined,
                                        color: AppColors.primary,
                                        tooltip: 'View Details',
                                        onTap: () => _showUserDetails(u),
                                      ),
                                    ],
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

const _roleFilters = ['All', 'Admin', 'DHO', 'Clinician', 'Prenatal', 'Neonatal'];

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
      'prenatal':  (const Color(0xFF9C27B0), const Color(0xFFF3E5F5)), // Purple for prenatal
      'neonatal':  (const Color(0xFF4CAF50), const Color(0xFFE8F5E8)), // Green for neonatal
    };
    final c = colors[role.toLowerCase()] ?? (AppColors.mutedText, AppColors.surfaceContainerLow);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.$2, borderRadius: BorderRadius.circular(20)),
      child: Text(
        role.toUpperCase(), 
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: c.$1)
      ),
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

// ── Add User Form (Admin adds DHO or Admin) ───────────────────────────────────

class _AddUserForm extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final VoidCallback onCancel;
  const _AddUserForm({required this.onSubmit, required this.onCancel});

  @override
  State<_AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends State<_AddUserForm> {
  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _phone    = TextEditingController();
  final _password = TextEditingController();
  String _role     = 'dho';
  String? _region;
  String? _zone;
  String? _district;
  bool _obscure    = true;

  List<String> _regions = [];
  List<String> _zones = [];
  List<String> _districts = [];
  bool _loadingRegions = true;
  bool _loadingZones = false;
  bool _loadingDistricts = false;
  
  String? _regionError;
  String? _zoneError;
  String? _districtError;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() => _loadingRegions = true);
    try {
      final regions = await ApiService.getRegions();
      print('DEBUG: Loaded regions: $regions');
      setState(() {
        _regions = regions;
        _region = regions.isNotEmpty ? regions.first : null;
        _regionError = null;
        _loadingRegions = false;
      });
      if (_region != null) {
        _loadZones(_region!);
      }
    } catch (e) {
      print('DEBUG: Error loading regions: $e');
      setState(() {
        _loadingRegions = false;
        _regionError = 'Failed to load regions: ${e.toString().split('\n').first}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading regions: $e'), 
            backgroundColor: AppColors.criticalText,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _loadZones(String region) async {
    setState(() {
      _loadingZones = true;
      _zoneError = null;
    });
    try {
      final zones = await ApiService.getZones(region);
      print('DEBUG: Loaded zones for region "$region": $zones');
      setState(() {
        _zones = zones;
        _zone = zones.isNotEmpty ? zones.first : null;
        _loadingZones = false;
      });
      if (_zone != null) {
        _loadDistricts(_zone!);
      }
    } catch (e) {
      print('DEBUG: Error loading zones: $e');
      setState(() {
        _loadingZones = false;
        _zoneError = 'Failed to load zones: ${e.toString()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading zones: $e'), 
            backgroundColor: AppColors.criticalText,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _loadDistricts(String zone) async {
    setState(() {
      _loadingDistricts = true;
      _districtError = null;
    });
    try {
      final districts = await ApiService.getDistricts(zone);
      print('DEBUG: Loaded districts for zone "$zone": $districts');
      setState(() {
        _districts = districts;
        _district = districts.isNotEmpty ? districts.first : null;
        _loadingDistricts = false;
      });
    } catch (e) {
      print('DEBUG: Error loading districts: $e');
      setState(() {
        _loadingDistricts = false;
        _districtError = 'Failed to load districts: ${e.toString()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading districts: $e'), 
            backgroundColor: AppColors.criticalText,
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
      (_role == 'admin' || (_region != null && _zone != null && _district != null));

  String? _validateLocationSelection() {
    if (_role == 'admin') return null; // Admins don't need location
    if (_region == null) return 'Region is required';
    if (_zone == null) return 'Zone is required';
    if (_district == null) return 'District is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final locationError = _validateLocationSelection();
    
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
          Text('Add New User',
              style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.headings)),
        ]),
        const SizedBox(height: 6),
        Text('Creates a DHO or Admin account. Clinicians are managed by DHOs.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
        const SizedBox(height: 20),

        // Role selector
        _SectionLabel('Account Type'),
        const SizedBox(height: 8),
        Row(children: [
          _RoleToggle(label: 'DHO', value: 'dho', selected: _role, icon: Icons.admin_panel_settings_rounded,
              onTap: () => setState(() => _role = 'dho')),
          const SizedBox(width: 12),
          _RoleToggle(label: 'Admin', value: 'admin', selected: _role, icon: Icons.manage_accounts_rounded,
              onTap: () => setState(() => _role = 'admin')),
        ]),
        const SizedBox(height: 20),

        // Identity fields
        _SectionLabel('Identity'),
        const SizedBox(height: 10),
        Wrap(spacing: 16, runSpacing: 16, children: [
          _TF(label: 'Full Name *', ctrl: _name, hint: 'Dr. Jane Banda',
              onChanged: (_) => setState(() {}), validator: _validateFullName),
          _TF(label: 'Phone Number *', ctrl: _phone, hint: '0999000000',
              keyboard: TextInputType.phone, onChanged: (_) => setState(() {}),
              validator: _validatePhone),
          _TF(label: 'Email (optional)', ctrl: _email, hint: 'user@moh.gov.mw',
              keyboard: TextInputType.emailAddress,
              validator: (v) => Validators.validateEmail(v, required: false)),
          _TF(label: 'Password *', ctrl: _password, hint: 'Min. 8 chars with uppercase, lowercase, number, special char',
              obscure: _obscure, onChanged: (_) => setState(() {}),
              validator: Validators.validatePassword,
              suffix: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.mutedText),
                onPressed: () => setState(() => _obscure = !_obscure),
              )),
        ]),
        const SizedBox(height: 20),

        // Location fields
        _SectionLabel('Location Assignment'),
        const SizedBox(height: 6),
        if (_role == 'admin')
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.infoText.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.infoText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Admins oversee the entire system. Location fields are not applicable.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.infoText, fontWeight: FontWeight.w500),
                ),
              ),
            ]),
          )
        else
          Text('Select region first, then zone, then district from the filtered options.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
        const SizedBox(height: 10),
        Wrap(spacing: 16, runSpacing: 16, children: [
          _CascadingDD(
            label: 'Region', 
            value: _region, 
            items: _regions,
            loading: _loadingRegions,
            isRequired: _role == 'dho',
            enabled: _role == 'dho',
            errorText: _regionError,
            onChanged: (v) {
              if (_role != 'dho') return;
              setState(() {
                _region = v;
                _zone = null;
                _district = null;
                _zones.clear();
                _districts.clear();
                _regionError = null;
              });
              if (v != null) _loadZones(v);
            },
          ),
          _CascadingDD(
            label: 'Zone', 
            value: _zone, 
            items: _zones,
            loading: _loadingZones,
            enabled: _role == 'dho' && _region != null,
            isRequired: _role == 'dho',
            errorText: _zoneError,
            onChanged: (v) {
              if (_role != 'dho') return;
              setState(() {
                _zone = v;
                _district = null;
                _districts.clear();
                _zoneError = null;
              });
              if (v != null) _loadDistricts(v);
            },
          ),
          _CascadingDD(
            label: 'District', 
            value: _district, 
            items: _districts,
            loading: _loadingDistricts,
            enabled: _role == 'dho' && _zone != null,
            isRequired: _role == 'dho',
            errorText: _districtError,
            onChanged: (v) {
              if (_role != 'dho') return;
              setState(() {
                _district = v;
                _districtError = null;
              });
            },
          ),
        ]),
        
        if (locationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.criticalText.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.criticalText.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.criticalText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationError,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.criticalText, fontWeight: FontWeight.w500),
                  ),
                ),
              ]),
            ),
          ),
        
        const SizedBox(height: 24),

        Row(children: [
          _GradientBtn(
            label: 'Create User',
            icon: Icons.save_rounded,
            onTap: _valid && locationError == null ? () => widget.onSubmit({
              'fullName': _name.text.trim(),
              'phone':    _phone.text.trim(),
              'email':    _email.text.trim().isEmpty ? null : _email.text.trim(),
              'password': _password.text.trim(),
              'role':     _role,
              'region':   _region!,
              'zone':     _zone!,
              'district': _district!,
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

// ── Edit User Form ────────────────────────────────────────────────────────────

class _EditUserForm extends StatefulWidget {
  final Map<String, dynamic> user;
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final VoidCallback onCancel;
  const _EditUserForm({required this.user, required this.onSubmit, required this.onCancel});

  @override
  State<_EditUserForm> createState() => _EditUserFormState();
}

class _EditUserFormState extends State<_EditUserForm> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  String? _region;
  String? _zone;
  String? _district;

  List<String> _regions = [];
  List<String> _zones = [];
  List<String> _districts = [];
  bool _loadingRegions = true;
  bool _loadingZones = false;
  bool _loadingDistricts = false;
  
  String? _regionError;
  String? _zoneError;
  String? _districtError;

  @override
  void initState() {
    super.initState();
    _name     = TextEditingController(text: widget.user['fullName'] ?? '');
    _email    = TextEditingController(text: widget.user['email'] ?? '');
    _phone    = TextEditingController(text: widget.user['phone'] ?? '');
    _region   = widget.user['region'];
    _zone     = widget.user['zone'];
    _district = widget.user['district'];
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() => _loadingRegions = true);
    try {
      final regions = await ApiService.getRegions();
      setState(() {
        _regions = regions;
        _regionError = null;
        _loadingRegions = false;
      });
      if (_region != null) {
        _loadZones(_region!);
      }
    } catch (e) {
      setState(() {
        _loadingRegions = false;
        _regionError = 'Failed to load regions';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load regions: $e'), 
            backgroundColor: AppColors.criticalText,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _loadZones(String region) async {
    setState(() {
      _loadingZones = true;
      _zoneError = null;
    });
    try {
      final zones = await ApiService.getZones(region);
      setState(() {
        _zones = zones;
        _loadingZones = false;
      });
      if (_zone != null) {
        _loadDistricts(_zone!);
      }
    } catch (e) {
      setState(() {
        _loadingZones = false;
        _zoneError = 'Failed to load zones';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load zones: $e'), 
            backgroundColor: AppColors.criticalText,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _loadDistricts(String zone) async {
    setState(() {
      _loadingDistricts = true;
      _districtError = null;
    });
    try {
      final districts = await ApiService.getDistricts(zone);
      setState(() {
        _districts = districts;
        _loadingDistricts = false;
      });
    } catch (e) {
      setState(() {
        _loadingDistricts = false;
        _districtError = 'Failed to load districts';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load districts: $e'), 
            backgroundColor: AppColors.criticalText,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _phone.dispose();
    super.dispose();
  }

  String? _validateLocationSelection() {
    final role = (widget.user['role'] ?? 'dho').toString();
    if (role == 'admin') return null; // Admins don't need location
    if (_region == null) return 'Region is required';
    if (_zone == null) return 'Zone is required';
    if (_district == null) return 'District is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final role = (widget.user['role'] ?? 'dho').toString();
    final locationError = _validateLocationSelection();
    
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
              validator: _validatePhone),
          _TF(label: 'Email', ctrl: _email, hint: 'user@moh.gov.mw', keyboard: TextInputType.emailAddress,
              validator: (v) => Validators.validateEmail(v, required: false)),
        ]),
        const SizedBox(height: 20),

        _SectionLabel('Location Assignment'),
        const SizedBox(height: 6),
        if (role == 'admin')
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.infoText.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.infoText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Admins oversee the entire system. Location fields are not applicable.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.infoText, fontWeight: FontWeight.w500),
                ),
              ),
            ]),
          )
        else
          Text('Select region first, then zone, then district from the filtered options.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText)),
        const SizedBox(height: 10),
        Wrap(spacing: 16, runSpacing: 16, children: [
          _CascadingDD(
            label: 'Region', 
            value: _region, 
            items: _regions,
            loading: _loadingRegions,
            enabled: role == 'dho',
            errorText: _regionError,
            onChanged: (v) {
              if (role != 'dho') return;
              setState(() {
                _region = v;
                _zone = null;
                _district = null;
                _zones.clear();
                _districts.clear();
                _regionError = null;
              });
              if (v != null) _loadZones(v);
            },
          ),
          _CascadingDD(
            label: 'Zone', 
            value: _zone, 
            items: _zones,
            loading: _loadingZones,
            enabled: role == 'dho' && _region != null,
            errorText: _zoneError,
            onChanged: (v) {
              if (role != 'dho') return;
              setState(() {
                _zone = v;
                _district = null;
                _districts.clear();
                _zoneError = null;
              });
              if (v != null) _loadDistricts(v);
            },
          ),
          _CascadingDD(
            label: 'District', 
            value: _district, 
            items: _districts,
            loading: _loadingDistricts,
            enabled: role == 'dho' && _zone != null,
            errorText: _districtError,
            onChanged: (v) {
              if (role != 'dho') return;
              setState(() {
                _district = v;
                _districtError = null;
              });
            },
          ),
        ]),
        
        if (locationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.criticalText.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.criticalText.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.criticalText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationError,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.criticalText, fontWeight: FontWeight.w500),
                  ),
                ),
              ]),
            ),
          ),
        
        const SizedBox(height: 24),

        Row(children: [
          _GradientBtn(
            label: 'Save Changes',
            icon: Icons.save_rounded,
            onTap: locationError == null ? () => widget.onSubmit({
              'fullName': _name.text.trim(),
              'phone':    _phone.text.trim(),
              'email':    _email.text.trim().isEmpty ? null : _email.text.trim(),
              'region':   _region,
              'zone':     _zone,
              'district': _district,
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

String? _validateFullName(String? value) {
  return Validators.validateFullName(value);
}

String? _validatePhone(String? value) {
  return Validators.validatePhone(value);
}

class _CascadingDD extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool loading;
  final bool enabled;
  final String? errorText;
  final bool isRequired;
  
  const _CascadingDD({
    required this.label, 
    required this.value, 
    required this.items, 
    required this.onChanged,
    this.loading = false,
    this.enabled = true,
    this.errorText,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final isSelected = value != null && value!.isNotEmpty;
    
    return SizedBox(
      width: 220,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText, letterSpacing: 0.8)),
          if (isRequired)
            Text(' *', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.criticalText)),
        ]),
        const SizedBox(height: 6),
        Stack(
          children: [
            DropdownButtonFormField<String>(
              value: items.contains(value) ? value : null,
              onChanged: enabled && !loading ? onChanged : null,
              style: GoogleFonts.inter(fontSize: 13, color: enabled ? AppColors.onSurface : AppColors.mutedText),
              decoration: InputDecoration(
                filled: true, 
                fillColor: enabled ? AppColors.surfaceContainerHighest : AppColors.surfaceContainerLow,
                hintText: loading ? 'Loading...' : (items.isEmpty ? 'No options available' : 'Select ${label.toLowerCase()}'),
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), 
                  borderSide: BorderSide(
                    color: hasError ? AppColors.criticalText : Colors.transparent,
                    width: hasError ? 1.5 : 0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: hasError ? AppColors.criticalText : AppColors.primary, 
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            ),
            if (loading)
              Positioned(
                right: 12,
                top: 12,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            if (!enabled && !loading)
              Positioned(
                right: 12,
                top: 12,
                child: Icon(Icons.lock_outline, size: 16, color: AppColors.mutedText),
              ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errorText!, 
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.criticalText, fontWeight: FontWeight.w500)),
          ),
        if (!enabled && !loading)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Select ${label.toLowerCase()} first', 
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText, fontStyle: FontStyle.italic)),
          ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit Mobile User Dialog ───────────────────────────────────────────────────

class _EditMobileUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final ValueChanged<Map<String, dynamic>> onUserUpdated;
  
  const _EditMobileUserDialog({
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<_EditMobileUserDialog> createState() => _EditMobileUserDialogState();
}

class _EditMobileUserDialogState extends State<_EditMobileUserDialog> {
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _age;
  late final TextEditingController _nationality;
  late final TextEditingController _district;
  late final TextEditingController _facilityName;
  
  // Prenatal fields
  late final TextEditingController _pregnancyMonths;
  late final TextEditingController _pregnancyWeeks;
  late final TextEditingController _expectedDeliveryDate;
  late final TextEditingController _lmpDate;
  
  // Neonatal fields
  late final TextEditingController _babyName;
  late final TextEditingController _babyDob;
  late final TextEditingController _babyGender;
  late final TextEditingController _babyBirthWeight;
  
  bool _loading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    final user = widget.user;
    
    // Basic fields
    _fullName = TextEditingController(text: user['fullName'] ?? '');
    _phone = TextEditingController(text: user['phone'] ?? '');
    _email = TextEditingController(text: user['email'] ?? '');
    _age = TextEditingController(text: user['age'] ?? '');
    _nationality = TextEditingController(text: user['nationality'] ?? '');
    _district = TextEditingController(text: user['district'] ?? '');
    _facilityName = TextEditingController(text: user['facilityName'] ?? user['facility'] ?? '');
    
    // Prenatal fields
    _pregnancyMonths = TextEditingController(text: user['pregnancyMonths'] ?? '');
    _pregnancyWeeks = TextEditingController(text: user['pregnancyWeeks'] ?? '');
    _expectedDeliveryDate = TextEditingController(text: user['expectedDeliveryDate'] ?? '');
    _lmpDate = TextEditingController(text: user['lmpDate'] ?? '');
    
    // Neonatal fields
    _babyName = TextEditingController(text: user['babyName'] ?? '');
    _babyDob = TextEditingController(text: user['babyDob'] ?? '');
    _babyGender = TextEditingController(text: user['babyGender'] ?? '');
    _babyBirthWeight = TextEditingController(text: user['babyBirthWeight'] ?? '');
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _age.dispose();
    _nationality.dispose();
    _district.dispose();
    _facilityName.dispose();
    _pregnancyMonths.dispose();
    _pregnancyWeeks.dispose();
    _expectedDeliveryDate.dispose();
    _lmpDate.dispose();
    _babyName.dispose();
    _babyDob.dispose();
    _babyGender.dispose();
    _babyBirthWeight.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() { _loading = true; _error = null; });
    
    try {
      final role = (widget.user['role'] ?? '').toString().toLowerCase();
      final updateData = <String, dynamic>{
        'fullName': _fullName.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
        'age': _age.text.trim().isEmpty ? null : _age.text.trim(),
        'nationality': _nationality.text.trim().isEmpty ? null : _nationality.text.trim(),
        'district': _district.text.trim().isEmpty ? null : _district.text.trim(),
        'facilityName': _facilityName.text.trim().isEmpty ? null : _facilityName.text.trim(),
      };
      
      // Add role-specific fields
      if (role == 'prenatal') {
        updateData.addAll({
          'pregnancyMonths': _pregnancyMonths.text.trim().isEmpty ? null : _pregnancyMonths.text.trim(),
          'pregnancyWeeks': _pregnancyWeeks.text.trim().isEmpty ? null : _pregnancyWeeks.text.trim(),
          'expectedDeliveryDate': _expectedDeliveryDate.text.trim().isEmpty ? null : _expectedDeliveryDate.text.trim(),
          'lmpDate': _lmpDate.text.trim().isEmpty ? null : _lmpDate.text.trim(),
        });
      } else if (role == 'neonatal') {
        updateData.addAll({
          'babyName': _babyName.text.trim().isEmpty ? null : _babyName.text.trim(),
          'babyDob': _babyDob.text.trim().isEmpty ? null : _babyDob.text.trim(),
          'babyGender': _babyGender.text.trim().isEmpty ? null : _babyGender.text.trim(),
          'babyBirthWeight': _babyBirthWeight.text.trim().isEmpty ? null : _babyBirthWeight.text.trim(),
        });
      }
      
      // Update user via API
      await ApiService.instance.patch('/users/${widget.user['id']}', updateData);
      
      // Update local user object
      final updatedUser = Map<String, dynamic>.from(widget.user);
      updatedUser.addAll(updateData);
      
      widget.onUserUpdated(updatedUser);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${role.toUpperCase()} user updated successfully'),
            backgroundColor: AppColors.successText,
          ),
        );
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = (widget.user['role'] ?? '').toString().toLowerCase();
    final isPrenatal = role == 'prenatal';
    final isNeonatal = role == 'neonatal';
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(
        children: [
          Icon(
            isPrenatal ? Icons.pregnant_woman : Icons.child_care,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text('Edit ${role.toUpperCase()} User'),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.criticalText.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.criticalText.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: AppColors.criticalText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.criticalText),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Basic Information
              _SectionLabel('Basic Information'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _EditField('Full Name *', _fullName, 'Enter full name'),
                  _EditField('Phone *', _phone, 'Enter phone number', TextInputType.phone),
                  _EditField('Email', _email, 'Enter email address', TextInputType.emailAddress),
                  _EditField('Age', _age, 'Enter age', TextInputType.number),
                  _EditField('Nationality', _nationality, 'Enter nationality'),
                  _EditField('District', _district, 'Enter district'),
                  _EditField('Health Facility', _facilityName, 'Enter health facility name'),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Role-specific fields
              if (isPrenatal) ...[
                _SectionLabel('Pregnancy Information'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _EditField('Pregnancy Months', _pregnancyMonths, 'e.g., 7', TextInputType.number),
                    _EditField('Pregnancy Weeks', _pregnancyWeeks, 'e.g., 28', TextInputType.number),
                    _EditField('Expected Delivery Date', _expectedDeliveryDate, 'YYYY-MM-DD'),
                    _EditField('Last Menstrual Period', _lmpDate, 'YYYY-MM-DD'),
                  ],
                ),
              ],
              
              if (isNeonatal) ...[
                _SectionLabel('Baby Information'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _EditField('Baby Name', _babyName, 'Enter baby name'),
                    _EditField('Baby Date of Birth', _babyDob, 'YYYY-MM-DD'),
                    _EditField('Baby Gender', _babyGender, 'Male/Female/Other'),
                    _EditField('Birth Weight (kg)', _babyBirthWeight, 'e.g., 3.2', TextInputType.numberWithOptions(decimal: true)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  
  const _EditField(
    this.label,
    this.controller,
    this.hint, [
    this.keyboardType = TextInputType.text,
  ]);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
              filled: true,
              fillColor: AppColors.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}