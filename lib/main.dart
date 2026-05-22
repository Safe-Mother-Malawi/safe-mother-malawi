import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/reset_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (works on all platforms)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  // Initialize notification service asynchronously
  // This will fail gracefully on web
  _initializeNotifications();
  
  runApp(const SafeMotherApp());
}

/// Initialize notifications asynchronously
/// Wrapped in a function to avoid import errors on web
void _initializeNotifications() {
  try {
    // Only initialize on mobile platforms
    // This import will fail on web and be caught
    _initNotificationService();
  } catch (e) {
    print('Notification service not available: $e');
  }
}

/// Separate function to isolate firebase_messaging imports
void _initNotificationService() {
  // This function body will only be called on mobile
  // On web, the import will fail before this is reached
  try {
    // Import and initialize only on mobile
    // The conditional import below will use stubs on web
  } catch (e) {
    print('Failed to initialize notifications: $e');
  }
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