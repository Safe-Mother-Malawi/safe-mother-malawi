import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'screens/neonatal_visits_enhanced_screen.dart';
import 'screens/postnatal_home_screen.dart';
import 'screens/immunization_tracker_screen.dart';
import '../prenatal/widgets/app_drawer.dart';

class PostnatalDashboard extends StatefulWidget {
  const PostnatalDashboard({super.key});

  @override
  State<PostnatalDashboard> createState() => _PostnatalDashboardState();
}

class _PostnatalDashboardState extends State<PostnatalDashboard> {
  int _index = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> get _screens => [
    PostnatalHomeScreen(onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer()),
    NeonatalVisitsEnhancedScreen(onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer()),
    ImmunizationTrackerScreen(onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _PostnatalBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _PostnatalBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _PostnatalBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(color: AppColors.navbarBg.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, label: 'Home', index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.medical_services_outlined, label: 'Neonatal', index: 1, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.vaccines_outlined, label: 'Vaccines', index: 2, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppColors.mobileNavy : AppColors.textMuted, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active ? AppColors.mobileNavy : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
