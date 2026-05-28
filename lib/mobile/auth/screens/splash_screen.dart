import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/mobile_user_provider.dart';
import '../../prenatal/prenatal_dashboard.dart';
import '../../neonatal/neonatal_dashboard.dart';
import '../../clinician/clinician_dashboard.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _navigate();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final authService = AuthService();
    final restoredUser = await authService.restoreSession();
    await authService.seedDemoAccounts();

    if (restoredUser != null) {
      if (!mounted) return;
      context.read<MobileUserProvider>().update(restoredUser);
      final role = restoredUser.role.toLowerCase();
      Widget destination;
      if (role.contains('prenatal')) {
        destination = const PrenatalDashboard();
      } else if (role.contains('neonatal')) {
        destination = const NeonatalDashboard();
      } else {
        destination = const ClinicianDashboard();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: Column(
        children: [
          Expanded(
            child: Center(
              // Clean circular logo — no container, no shadow, no background
              child: Image.asset(
                'assets/logo/LOGO5.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: _LoadingDots(controller: _dotController),
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  final AnimationController controller;
  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.3;
            final t = ((controller.value - delay) % 1.0 + 1.0) % 1.0;
            final opacity = t < 0.5 ? t * 2 : (1.0 - t) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Opacity(
                opacity: opacity.clamp(0.2, 1.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

