import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../state/user_store.dart';
import 'pages/dashboard_page.dart';
import 'pages/patients_page.dart';
import 'pages/alerts_page.dart';
import 'pages/register_page.dart';
import 'pages/consult_page.dart';
import 'pages/risk_scoring_page.dart';
import 'pages/calendar_page.dart';
import 'pages/profile_page.dart';
import '../splash_screen.dart';

class ClinicianDashboard extends StatefulWidget {
  const ClinicianDashboard({super.key});

  @override
  State<ClinicianDashboard> createState() => _ClinicianDashboardState();
}

class _ClinicianDashboardState extends State<ClinicianDashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      ClinicianDashboardPage(onRegisterPatient: () => setState(() => _selectedIndex = 3)),
      const ClinicianPatientsPage(),
      ClinicianAlertsPage(onNavigate: (i) => setState(() => _selectedIndex = i)),
      const ClinicianRegisterPage(),
      const ClinicianConsultPage(),
      const RiskScoringPage(),
      const CalendarPage(),
      MyProfilePage(onClose: () => setState(() => _selectedIndex = 0)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(children: [
        _buildSidebar(),
        Expanded(
          child: Column(children: [
            _buildTopBar(),
            Expanded(child: _pages[_selectedIndex]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 52,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _selectedIndex = 7),
          child: const Icon(Icons.person_outline, color: AppColors.g600, size: 22),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _selectedIndex = 7),
          child: Text(UserStore.instance.fullName.isNotEmpty ? UserStore.instance.fullName : 'My Profile',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.g800)),
        ),
      ]),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 200,
      color: AppColors.navy,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.local_hospital, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text('Safe Mother MW',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
            const SizedBox(height: 4),
            const Text('Clinician Portal',
                style: TextStyle(color: Colors.white54, fontSize: 10)),
          ]),
        ),
        const SizedBox(height: 8),
        _sidebarLabel('OVERVIEW'),
        _sidebarItem(0, Icons.dashboard_outlined, 'Dashboard'),
        _sidebarItem(1, Icons.people_outline, 'Patients'),
        _sidebarItem(2, Icons.notifications_outlined, 'Alerts'),
        const SizedBox(height: 8),
        _sidebarLabel('CLINICAL'),
        _sidebarItem(3, Icons.person_add_outlined, 'Register Patient'),
        _sidebarItem(4, Icons.favorite_border, 'Health Data'),
        _sidebarItem(5, Icons.assessment_outlined, 'Risk Monitoring'),
        _sidebarItem(6, Icons.calendar_today_outlined, 'Calendar'),
        const Spacer(),
        const Divider(color: Colors.white12, height: 1),
        _sidebarItem(7, Icons.account_circle_outlined, 'My Profile'),
        InkWell(
          onTap: _confirmLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(children: [
              Icon(Icons.logout, size: 18, color: Colors.white54),
              SizedBox(width: 10),
              Text('Logout', style: TextStyle(fontSize: 13, color: Colors.white54)),
            ]),
          ),
        ),
        const SizedBox(height: 8),
      ]),
    );
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

  Widget _sidebarLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6, top: 4),
      child: Text(label,
          style: const TextStyle(
              fontSize: 9, fontWeight: FontWeight.bold,
              color: Colors.white38, letterSpacing: 1.2)),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String title, {String? badge}) {
    final selected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(children: [
          Icon(icon, size: 17, color: selected ? Colors.white : Colors.white60),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : Colors.white60,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          if (badge != null) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.red, borderRadius: BorderRadius.circular(10)),
              child: Text(badge,
                  style: const TextStyle(color: Colors.white, fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
      ),
    );
  }
}
