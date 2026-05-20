import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../screens/splash_screen.dart';
import '../../services/auth_service_web.dart';

enum UserRole { admin, dho, clinician }

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  final List<UserRole> allowedRoles;

  const NavItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.allowedRoles,
  });
}

// Flat nav items
const List<NavItem> _flatItems = [
  // Admin + DHO shared
  NavItem(label: 'Overview', icon: Icons.dashboard_rounded, route: '/overview',
      allowedRoles: [UserRole.admin, UserRole.dho]),

  // ── Admin only ────────────────────────────────────────────────────────────
  NavItem(label: 'System Users', icon: Icons.manage_accounts_rounded, route: '/clinicians',
      allowedRoles: [UserRole.admin]),
  NavItem(label: 'Health Facilities', icon: Icons.local_hospital_rounded, route: '/facilities',
      allowedRoles: [UserRole.admin]),
  NavItem(label: 'SMS Management', icon: Icons.sms_rounded, route: '/sms',
      allowedRoles: [UserRole.admin]),
  NavItem(label: 'Audit Logs', icon: Icons.history_rounded, route: '/logs',
      allowedRoles: [UserRole.admin]),
  NavItem(label: 'Reports', icon: Icons.summarize_rounded, route: '/reports',
      allowedRoles: [UserRole.admin]),

  // ── DHO only ──────────────────────────────────────────────────────────────
  NavItem(label: 'Clinician Management', icon: Icons.people_alt_rounded, route: '/clinicians',
      allowedRoles: [UserRole.dho]),
  NavItem(label: 'Data Source', icon: Icons.storage_rounded, route: '/data-explorer',
      allowedRoles: [UserRole.dho]),
  NavItem(label: 'Analytics Dashboard', icon: Icons.bar_chart_rounded, route: '/analytics',
      allowedRoles: [UserRole.dho]),
  NavItem(label: 'Generate Analytics', icon: Icons.auto_graph_rounded, route: '/generate-analytics',
      allowedRoles: [UserRole.dho]),
  NavItem(label: 'Task Analytics', icon: Icons.task_alt_rounded, route: '/task-analytics',
      allowedRoles: [UserRole.dho]),
  NavItem(label: 'Question Insights', icon: Icons.quiz_rounded, route: '/question-insights',
      allowedRoles: [UserRole.dho]),
  NavItem(label: 'Reports', icon: Icons.summarize_rounded, route: '/reports',
      allowedRoles: [UserRole.dho]),
];

// Insights group — Admin only (Question only)
const _insightsChildren = [
  NavItem(label: 'Question Insights', icon: Icons.quiz_rounded, route: '/question-insights',
      allowedRoles: [UserRole.admin]),
];

class AppSidebar extends StatefulWidget {
  final UserRole role;
  final String currentRoute;
  final ValueChanged<String> onNavigate;

  const AppSidebar({
    super.key,
    required this.role,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _insightsOpen = true;

  @override
  Widget build(BuildContext context) {
    final isInsightsActive = widget.currentRoute == '/question-insights' ||
        widget.currentRoute == '/insights';

    const _flatLabels = {
      'Overview', 'System Users', 'Clinician Management', 'Data Source',
      'Analytics Dashboard', 'Generate Analytics', 'Task Analytics',
      'Activity Logs', 'Question Insights', 'Reports', 'Audit Export',
      'Health Facilities', 'SMS Management', 'Audit Logs'
    };

    return Container(
      width: 240,
      color: AppColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Container(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/logo/LOGO5.png', width: 110, height: 110, fit: BoxFit.contain),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Safe Mother',
                          style: GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Malawi', style: GoogleFonts.inter(fontSize: 11, color: AppColors.sidebarMuted, letterSpacing: 1.5)),
              ],
            ),
          ),

          // Role chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                widget.role == UserRole.admin ? 'System Admin' : 'District Health Officer',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.sidebarMuted),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Nav list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // All flat items for this role
                ..._flatItems
                    .where((i) => i.allowedRoles.contains(widget.role))
                    .where((i) => _flatLabels.contains(i.label))
                    .map((i) => _NavTile(
                          item: i,
                          isActive: widget.currentRoute == i.route,
                          onTap: () => widget.onNavigate(i.route),
                        )),

                // Insights group — Admin only
                if (widget.role == UserRole.admin) ...[
                  _GroupHeader(
                    label: 'Insights',
                    icon: Icons.insights_rounded,
                    isOpen: _insightsOpen,
                    isActive: isInsightsActive,
                    onTap: () => setState(() => _insightsOpen = !_insightsOpen),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _insightsOpen
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        children: _insightsChildren
                            .map((c) => _NavTile(
                                  item: c,
                                  isActive: widget.currentRoute == c.route,
                                  onTap: () => widget.onNavigate(c.route),
                                  isChild: true,
                                ))
                            .toList(),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _confirmLogout(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(children: [
                    const Icon(Icons.logout_rounded, size: 18, color: Colors.white54),
                    const SizedBox(width: 12),
                    Text('Log Out', style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
                  ]),
                ),
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text('Ministry of Health\nMalawi',
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.sidebarMuted, height: 1.6)),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isOpen;
  final bool isActive;
  final VoidCallback onTap;

  const _GroupHeader({
    required this.label,
    required this.icon,
    required this.isOpen,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive && !isOpen ? AppColors.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: isActive ? Colors.white : AppColors.sidebarMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : AppColors.sidebarText,
                      )),
                ),
                Icon(
                  isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 16,
                  color: AppColors.sidebarMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final bool isChild;

  const _NavTile({required this.item, required this.isActive, required this.onTap, this.isChild = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: isChild ? 10 : 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                if (isChild)
                  Container(width: 4, height: 4, margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(color: isActive ? Colors.white : AppColors.sidebarMuted, shape: BoxShape.circle))
                else
                  Icon(item.icon, size: 18, color: isActive ? Colors.white : AppColors.sidebarMuted),
                SizedBox(width: isChild ? 0 : 12),
                Expanded(
                  child: Text(item.label,
                      style: GoogleFonts.inter(
                        fontSize: isChild ? 12 : 13,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? Colors.white : AppColors.sidebarText,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Row(children: [
        Icon(Icons.logout_rounded, color: Color(0xFF0D47A1), size: 20),
        SizedBox(width: 8),
        Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
      content: const Text('Are you sure you want to log out?',
          style: TextStyle(fontSize: 13, color: Colors.black54)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.black45)),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await AuthServiceWeb.instance.logout();
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (_) => false,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text('Log Out'),
        ),
      ],
    ),
  );
}
