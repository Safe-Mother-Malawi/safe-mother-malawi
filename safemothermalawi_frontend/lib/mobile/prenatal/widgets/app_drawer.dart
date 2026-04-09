import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/help_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/nutrition_screen.dart';
import '../screens/ivr_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE91E8C), Color(0xFFFF80AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 34, color: Colors.white),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Safe Mother', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('Malawi', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(icon: Icons.person_outline, label: 'My Profile', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); }),
                _DrawerItem(icon: Icons.restaurant_menu_outlined, label: 'Nutrition & Health', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionScreen())); }),
                _DrawerItem(icon: Icons.phone_in_talk_outlined, label: 'Emergency Call (IVR)', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const IvrScreen())); }),
                const Divider(indent: 16, endIndent: 16),
                _DrawerItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); }),
                _DrawerItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())); }),
                _DrawerItem(icon: Icons.info_outline, label: 'About', onTap: () { Navigator.pop(context); _showAbout(context); }),
                const Divider(indent: 16, endIndent: 16),
                _DrawerItem(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  color: const Color(0xFFC62828),
                  onTap: () async {
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

          // Version
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Safe Mother Malawi v1.0.0', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFE91E8C), Color(0xFFFF80AB)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Safe Mother Malawi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
            const SizedBox(height: 6),
            const Text('Version 1.0.0', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 12),
            const Text(
              'A maternal health app supporting pregnant mothers in Malawi with pregnancy tracking, health education, and emergency services.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close', style: TextStyle(color: Color(0xFFE91E8C))),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _DrawerItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color ?? const Color(0xFFE91E8C), size: 22),
    title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color ?? const Color(0xFF212121))),
    trailing: color == null ? const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFFBDBDBD)) : null,
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
  );
}
