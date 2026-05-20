import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/reset_password_page.dart';

void main() {
  runApp(const SafeMotherApp());
}

class SafeMotherApp extends StatelessWidget {
  const SafeMotherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Mother Malawi — Staff Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.pageBg,
      ),
      home: const SplashScreen(),
      routes: {
        '/reset-password': (context) {
          final token = Uri.base.queryParameters['token'];
          return ResetPasswordPage(token: token);
        },
      },
    );
  }
}

