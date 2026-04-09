import 'package:flutter/material.dart';
import '../auth/services/auth_service.dart';
import '../auth/screens/login_screen.dart';
import 'models/neonatal_data.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/health_screen.dart';
import 'screens/call_screen.dart';
import 'screens/feeding_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/vaccines_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/baby_tracker_screen.dart';

const _kActive = Color(0xFFD81B60);

class NeonatalDashboard extends StatefulWidget {
  const NeonatalDashboard({super.key});
  @override
  State<NeonatalDashboard> createState() => _NeonatalDashboardState();
}

class _NeonatalDashboardState extends State<NeonatalDashboard> {
  int _index = 0;
  NeonatalData? _sharedData;
  String _babyName   = 'Baby';
  String _motherName = 'Mama';

  @override
  void initState() { super.initState(); _loadSharedData(); }

  Future<void> _loadSharedData() async {
    final user = await AuthService().getCurrentUser();
    if (!mounted || user == null) return;
    final babyDob = user.babyDob.isNotEmpty
        ? DateTime.tryParse(user.babyDob) ?? DateTime.now()
        : DateTime.now();
    setState(() {
      _babyName   = user.babyName.isNotEmpty ? user.babyName : 'Baby';
      _motherName = user.fullName.split(' ').first;
      _sharedData = NeonatalData(babyDob: babyDob, babyName: _babyName);
    });
  }

  List<Widget> get _screens => [
    const NeonatalHomeScreen(),
    const ScheduleScreen(),
    NeonatalHealthScreen(data: _sharedData),
    const CallScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _NeoDrawer(babyName: _babyName, motherName: _motherName, data: _sharedData),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _NeoBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _NeoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _NeoBottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.grid_view_rounded,       Icons.grid_view_rounded,      'Today'),
    (Icons.calendar_month_outlined, Icons.calendar_month,         'Schedule'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded,       'Health check'),
    (Icons.phone_outlined,          Icons.phone,                  'Call'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item   = _items[i];
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(active ? item.$2 : item.$1,
                        color: active ? _kActive : const Color(0xFF9E9E9E), size: 26),
                    const SizedBox(height: 4),
                    Text(item.$3,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                          color: active ? _kActive : const Color(0xFF9E9E9E),
                        )),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Side Drawer ───────────────────────────────────────────────────────────────

class _NeoDrawer extends StatelessWidget {
  final String babyName, motherName;
  final NeonatalData? data;
  const _NeoDrawer({required this.babyName, required this.motherName, this.data});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00695C), Color(0xFF00ACC1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.child_care, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 12),
                Text(babyName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Mother: $motherName',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                if (data != null) ...[
                  const SizedBox(height: 4),
                  Text('Day ${data!.ageInDays} · ${data!.stageLabel}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                ],
              ],
            ),
          ),

          // Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // ── Trackers ──────────────────────────────────────────────
                const _DrawerSection('TRACKERS'),
                _DrawerItem(
                  icon: Icons.child_care_outlined,
                  label: 'Baby Tracker',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BabyTrackerScreen(data: data)));
                  },
                ),
                _DrawerItem(
                  icon: Icons.local_drink_outlined,
                  label: 'Feeding Tracker',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const FeedingScreen()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.bedtime_outlined,
                  label: 'Sleep Tracker',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const SleepScreen()));
                  },
                ),
                // ── Health ────────────────────────────────────────────────
                const _DrawerSection('HEALTH'),
                _DrawerItem(
                  icon: Icons.vaccines_outlined,
                  label: 'Vaccine Schedule',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => VaccinesScreen(data: data)));
                  },
                ),
                _DrawerItem(
                  icon: Icons.restaurant_menu_outlined,
                  label: 'Nutrition & Baby Care',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const NeonatalNutritionScreen()));
                  },
                ),
                // ── Account ───────────────────────────────────────────────
                const _DrawerSection('ACCOUNT'),
                _DrawerItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const NeonatalNotificationsScreen()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const NeonatalProfileScreen()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(indent: 16, endIndent: 16),
                _DrawerItem(
                  icon: Icons.logout,
                  label: 'Log out',
                  color: Colors.red,
                  onTap: () async {
                    Navigator.pop(context);
                    await AuthService().logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Helpers ────────────────────────────────────────────────────────────

class _DrawerSection extends StatelessWidget {
  final String label;
  const _DrawerSection(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(label,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFF9E9E9E),
            letterSpacing: 1.2)),
  );
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _DrawerItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF212121);
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c)),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}
