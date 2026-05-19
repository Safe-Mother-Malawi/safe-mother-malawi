import 'package:flutter/material.dart';
import '../../../main_mobile.dart';
import 'auth_service.dart';
import '../screens/login_screen.dart';

/// Logs out the current user and navigates to LoginScreen using the root
/// navigator, clearing the entire stack. Safe to call from any context.
Future<void> performLogout() async {
  await AuthService().logout();
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (_) => false,
  );
}

/// Shows a confirmation dialog then logs out. Pass any valid [BuildContext].
Future<void> confirmAndLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Sign Out',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
      content: const Text('Are you sure you want to sign out?',
          style: TextStyle(fontSize: 14, color: Color(0xFF424242))),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF757575))),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await performLogout();
}
