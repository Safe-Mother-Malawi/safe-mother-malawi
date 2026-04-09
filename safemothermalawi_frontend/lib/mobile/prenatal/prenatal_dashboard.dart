import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/diagnostic_screen.dart';
import 'screens/ivr_screen.dart';

class PrenatalDashboard extends StatefulWidget {
  const PrenatalDashboard({super.key});

  @override
  State<PrenatalDashboard> createState() => _PrenatalDashboardState();
}

class _PrenatalDashboardState extends State<PrenatalDashboard> {
  int _index = 0;

  final _screens = const [
    PrenatalHomeScreen(),
    AppointmentsScreen(),
    DiagnosticScreen(),
    IvrScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _PinkBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _PinkBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _PinkBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF80AB).withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.grid_view_rounded, label: 'Today', index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.calendar_month_outlined, label: 'Schedule', index: 1, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.favorite_border, label: 'Health check', index: 2, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.phone_outlined, label: 'Call', index: 3, current: currentIndex, onTap: onTap),
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
            Icon(icon, color: active ? const Color(0xFFE91E8C) : const Color(0xFF9E9E9E), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active ? const Color(0xFFE91E8C) : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
