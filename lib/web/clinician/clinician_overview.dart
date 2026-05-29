import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/app_shell.dart';
import '../shared/sidebar.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';
import '../shared/utils/responsive_helper.dart';
import '../../services/api_service.dart';
import '../../services/auth_service_web.dart';
import '../../state/user_store.dart';
import '../../state/notification_store.dart';
import '../../utils/live_data_mixin.dart';
import '../../screens/clinician/pages/dashboard_page.dart';
import '../../screens/clinician/pages/patients_page.dart';
import '../../screens/clinician/pages/alerts_page.dart';
import '../../screens/clinician/pages/register_page.dart';
import '../../screens/clinician/pages/risk_scoring_page.dart';
import '../../screens/clinician/pages/calendar_page.dart';
import '../../screens/clinician/pages/profile_page.dart';
import '../../screens/clinician/pages/referral_page.dart';
import '../../screens/splash_screen.dart';

class ClinicianOverview extends StatefulWidget {
  const ClinicianOverview({super.key});

  @override
  State<ClinicianOverview> createState() => _ClinicianOverviewState();
}

class _ClinicianOverviewState extends State<ClinicianOverview> {
  String _currentRoute = '/overview';
  int _selectedIndex = 0;
  Key _patientsKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    UserStore.instance.addListener(_onUserChanged);
    NotificationStore.instance.addListener(_onNotif);
    NotificationStore.instance.load();
  }

  @override
  void dispose() {
    UserStore.instance.removeListener(_onUserChanged);
    NotificationStore.instance.removeListener(_onNotif);
    NotificationStore.instance.stopAutoRefresh();
    super.dispose();
  }

  void _onUserChanged() => setState(() {});
  void _onNotif() => setState(() {});

  void _navigate(String route) {
    setState(() => _currentRoute = route);
  }

  void _onPatientRegistered() {
    setState(() {
      _patientsKey = UniqueKey();
      _selectedIndex = 1;
    });
  }

  void _selectPage(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return ClinicianDashboardPage(
          onRegisterPatient: () => _selectPage(3),
        );
      case 1:
        return ClinicianPatientsPage(key: _patientsKey);
      case 2:
        return ClinicianAlertsPage(
          onNavigate: (i) => _selectPage(i),
        );
      case 3:
        return ClinicianRegisterPage(
          onPatientRegistered: _onPatientRegistered,
        );
      case 4:
        return const RiskScoringPage();
      case 5:
        return const CalendarPage();
      case 6:
        return const ReferralPage();
      case 7:
        return MyProfilePage(
          onClose: () => _selectPage(0),
        );
      default:
        return ClinicianDashboardPage(
          onRegisterPatient: () => _selectPage(3),
        );
    }
  }

  String get _pageTitle {
    const titles = {
      0: 'Dashboard',
      1: 'Patients',
      2: 'Alerts',
      3: 'Register Patient',
      4: 'Risk Monitoring',
      5: 'Calendar',
      6: 'Referrals',
      7: 'Profile',
    };
    return titles[_selectedIndex] ?? 'Clinician Dashboard';
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.logout, color: AppColors.navy, size: 20),
          SizedBox(width: 8),
          Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        content: const Text('Are you sure you want to log out of the clinician portal?',
            style: TextStyle(fontSize: 13, color: AppColors.g600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.g400)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Custom Sidebar
          Container(
            width: 280,
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
                      Row(children: [
                        Image.asset('assets/logo/LOGO5.png', width: 110, height: 110, fit: BoxFit.contain),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Safe Mother',
                              style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Text('Malawi',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 11,
                              color: AppColors.sidebarMuted,
                              letterSpacing: 1.5)),
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
                    child: Text('Clinician Portal',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.sidebarMuted)),
                  ),
                ),

                const SizedBox(height: 24),

                // Nav items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _sidebarItem(0, Icons.dashboard_rounded, 'Dashboard'),
                      _sidebarItem(1, Icons.people_alt_rounded, 'Patients'),
                      _sidebarItem(2, Icons.notifications_rounded, 'Alerts'),
                      _sidebarItem(3, Icons.person_add_rounded, 'Register Patient'),
                      _sidebarItem(4, Icons.assessment_rounded, 'Risk Monitoring'),
                      _sidebarItem(5, Icons.calendar_today_rounded, 'Calendar'),
                      _sidebarItem(6, Icons.send_rounded, 'Referrals'),
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
                      onTap: _confirmLogout,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(children: [
                          const Icon(Icons.logout_rounded, size: 18, color: Colors.white54),
                          const SizedBox(width: 12),
                          Text('Log Out',
                              style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: Colors.white54)),
                        ]),
                      ),
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text('Ministry of Health\nMalawi',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          color: AppColors.sidebarMuted,
                          height: 1.6)),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 64,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        _pageTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.g800,
                        ),
                      ),
                      const Spacer(),
                      // Notifications
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
                                    child: Column(children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: const BoxDecoration(
                                          color: AppColors.navy,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                        ),
                                        child: Row(children: [
                                          const Icon(Icons.notifications_rounded, color: Colors.white, size: 20),
                                          const SizedBox(width: 10),
                                          const Expanded(
                                              child: Text('Notifications',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold))),
                                          TextButton(
                                            onPressed: () => NotificationStore.instance.markAllRead(),
                                            child: const Text('Mark all read',
                                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                                          ),
                                        ]),
                                      ),
                                      Expanded(child: _NotificationList()),
                                    ]),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.g600, size: 22),
                          ),
                          if (NotificationStore.instance.unreadCount > 0)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                                child: Center(
                                  child: Text('${NotificationStore.instance.unreadCount}',
                                      style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      // Profile
                      GestureDetector(
                        onTap: () => _selectPage(7),
                        child: Row(children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.navy,
                            child: Text(
                              AuthServiceWeb.instance.userName
                                  .trim()
                                  .split(' ')
                                  .where((w) => w.isNotEmpty)
                                  .take(2)
                                  .map((w) => w[0].toUpperCase())
                                  .join(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(AuthServiceWeb.instance.userName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.g800)),
                        ]),
                      ),
                    ],
                  ),
                ),

                // Page Content
                Expanded(
                  child: _buildPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String title) {
    final selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _selectPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(icon, size: 18, color: selected ? Colors.white : AppColors.sidebarMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? Colors.white : AppColors.sidebarText)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Notification list widget ──────────────────────────────────────────────────

class _NotificationList extends StatefulWidget {
  @override
  State<_NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<_NotificationList> {
  @override
  void initState() {
    super.initState();
    NotificationStore.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    NotificationStore.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = NotificationStore.instance.all;
    if (items.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('No notifications.', style: TextStyle(color: Colors.black45)),
      ));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final n = items[i];
        final color = n.type == NotifType.alert
            ? Colors.red
            : n.type == NotifType.appointment
                ? AppColors.navy
                : Colors.green;
        final icon = n.type == NotifType.alert
            ? Icons.warning_amber_rounded
            : n.type == NotifType.appointment
                ? Icons.calendar_today_rounded
                : Icons.info_outline_rounded;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          title: Text(n.title,
              style: TextStyle(fontSize: 13, fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
          subtitle: Text(n.body,
              style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: n.read
              ? null
              : Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          onTap: () => NotificationStore.instance.markRead(n.id),
        );
      },
    );
  }
}
