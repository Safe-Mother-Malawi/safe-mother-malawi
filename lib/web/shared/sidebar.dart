import 'package:flutter/material.dart';

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
  NavItem(label: 'Audit Logs', icon: Icons.history_rounded, route: '/logs',
      allowedRoles: [UserRole.admin]),
  NavItem(label: 'Reports', icon: Icons.summarize_rounded, route: '/reports',
      allowedRoles: [UserRole.admin]),
  NavItem(label: 'Broadcast Messages', icon: Icons.campaign_rounded, route: '/broadcasts',
      allowedRoles: [UserRole.admin]),

  // ── DHO only ──────────────────────────────────────────────────────────────
  NavItem(label: 'Clinician Management', icon: Icons.people_alt_rounded, route: '/clinicians',
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
  final bool isCollapsed;
  final bool isMobile;

  const AppSidebar({
    super.key,
    required this.role,
    required this.currentRoute,
    required this.onNavigate,
    this.isCollapsed = false,
    this.isMobile = false,
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
      'Overview', 'System Users', 'Clinician Management',
      'Analytics Dashboard', 'Generate Analytics', 'Task Analytics',
      'Activity Logs', 'Question Insights', 'Reports', 'Audit Export',
      'Health Facilities', 'Audit Logs', 'Broadcast Messages'
    };

    final sidebarWidth = widget.isCollapsed ? 70.0 : 240.0;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: sidebarWidth,
      height: screenHeight,
      color: AppColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          if (!widget.isCollapsed)
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
                            style: TextStyle(fontFamily: 'Public Sans', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Malawi', style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: AppColors.sidebarMuted, letterSpacing: 1.5)),
                ],
              ),
            )
          else
            // Collapsed brand icon
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Image.asset('assets/logo/LOGO5.png', width: 40, height: 40, fit: BoxFit.contain),
            ),

          // Role chip
          if (!widget.isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  widget.role == UserRole.admin ? 'System Admin' : 'District Health Officer',
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.sidebarMuted),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Nav list - scrollable to ensure all items are accessible
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: widget.isCollapsed ? 8 : 12),
              children: [
                // All flat items for this role
                ..._flatItems
                    .where((i) => i.allowedRoles.contains(widget.role))
                    .where((i) => _flatLabels.contains(i.label))
                    .map((i) => _NavTile(
                          item: i,
                          isActive: widget.currentRoute == i.route,
                          onTap: () => widget.onNavigate(i.route),
                          isCollapsed: widget.isCollapsed,
                        )),

                // Insights group — Admin only
                if (widget.role == UserRole.admin) ...[
                  const SizedBox(height: 8),
                  _GroupHeader(
                    label: 'Insights',
                    icon: Icons.insights_rounded,
                    isOpen: _insightsOpen,
                    isActive: isInsightsActive,
                    onTap: () => setState(() => _insightsOpen = !_insightsOpen),
                    isCollapsed: widget.isCollapsed,
                  ),
                  if (!widget.isCollapsed)
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
                  child: widget.isCollapsed
                      ? const Icon(Icons.logout_rounded, size: 18, color: Colors.white54)
                      : Row(children: [
                          const Icon(Icons.logout_rounded, size: 18, color: Colors.white54),
                          const SizedBox(width: 12),
                          Text('Log Out', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: Colors.white54)),
                        ]),
                ),
              ),
            ),
          ),

          // Footer
          if (!widget.isCollapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text('Ministry of Health\nMalawi',
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 10, color: AppColors.sidebarMuted, height: 1.6)),
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
  final bool isCollapsed;

  const _GroupHeader({
    required this.label,
    required this.icon,
    required this.isOpen,
    required this.isActive,
    required this.onTap,
    this.isCollapsed = false,
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
            child: isCollapsed
                ? Icon(icon, size: 18, color: isActive ? Colors.white : AppColors.sidebarMuted)
                : Row(
                    children: [
                      Icon(icon, size: 18, color: isActive ? Colors.white : AppColors.sidebarMuted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(label,
                            style: TextStyle(fontFamily: 'Roboto', 
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
  final bool isCollapsed;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
    this.isChild = false,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: Tooltip(
          message: isCollapsed ? item.label : '',
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
              child: isCollapsed
                  ? Icon(item.icon, size: 18, color: isActive ? Colors.white : AppColors.sidebarMuted)
                  : Row(
                      children: [
                        if (isChild)
                          Container(width: 4, height: 4, margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(color: isActive ? Colors.white : AppColors.sidebarMuted, shape: BoxShape.circle))
                        else
                          Icon(item.icon, size: 18, color: isActive ? Colors.white : AppColors.sidebarMuted),
                        SizedBox(width: isChild ? 0 : 12),
                        Expanded(
                          child: Text(item.label,
                              style: TextStyle(fontFamily: 'Roboto', 
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

