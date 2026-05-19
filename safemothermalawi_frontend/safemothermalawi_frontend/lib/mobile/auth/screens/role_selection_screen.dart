import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import 'signup_screen.dart';
import 'neonatal_signup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Centered logo
              Center(
                child: AppLogo(size: 180, darkBackground: false),
              ),
              const SizedBox(height: 28),
              const Text(
                'Select your role',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the role that best describes you to get a personalized experience.',
                style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 32),
              _RoleCard(
                title: 'Prenatal',
                subtitle: 'For expectant mothers during pregnancy',
                icon: Icons.pregnant_woman,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupScreen(role: 'prenatal')),
                ),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'Neonatal',
                subtitle: 'For mothers with newborn babies',
                icon: Icons.child_care,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NeonatalSignupScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF757575))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }
}
