import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_colors.dart';
import 'mobile/auth/screens/splash_screen.dart';
import 'mobile/auth/screens/login_screen.dart';

// Global navigator key — used by logout to always reach the root navigator
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const SafeMotherMobileApp());
}

class SafeMotherMobileApp extends StatelessWidget {
  const SafeMotherMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Safe Mother Malawi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}
