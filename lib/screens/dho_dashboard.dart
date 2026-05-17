import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'splash_screen.dart';

class DhoDashboard extends StatelessWidget {
  final String district;
  const DhoDashboard({super.key, required this.district});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: const Color(0xFF00695C),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const SplashScreen())),
                  child: const Text('Safe Mother MW',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                const Spacer(),
                Text(district,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.white.withOpacity(0.14),
                  child: const Text('DH',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text('DHO Dashboard — $district',
                  style: const TextStyle(fontSize: 24, color: AppColors.g800)),
            ),
          ),
        ],
      ),
    );
  }
}
