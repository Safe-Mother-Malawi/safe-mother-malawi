import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/reset_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (web-only, no messaging)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  
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
