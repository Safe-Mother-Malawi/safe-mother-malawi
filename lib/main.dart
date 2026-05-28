import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/reset_password_page.dart';
import 'services/notification_sound_service.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background notification received: ${message.notification?.title}');
  
  // Play sound for background notifications
  final soundService = NotificationSoundService();
  final notificationType = message.data['type'] ?? 'default';
  await soundService.playNotificationSound(soundType: notificationType);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (works on all platforms)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Setup Firebase Messaging for mobile
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Request notification permissions
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      print('✅ Firebase Messaging initialized');
    } catch (e) {
      print('⚠️ Firebase Messaging setup skipped (web or error): $e');
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const SafeMotherApp());
}

class SafeMotherApp extends StatefulWidget {
  const SafeMotherApp({super.key});

  @override
  State<SafeMotherApp> createState() => _SafeMotherAppState();
}

class _SafeMotherAppState extends State<SafeMotherApp> {
  final soundService = NotificationSoundService();

  @override
  void initState() {
    super.initState();
    _setupForegroundNotificationHandler();
  }

  void _setupForegroundNotificationHandler() {
    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground notification received: ${message.notification?.title}');
      
      // Play sound for foreground notifications
      final notificationType = message.data['type'] ?? 'default';
      soundService.playNotificationSound(soundType: notificationType);
    });

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Notification tapped: ${message.notification?.title}');
      
      // Play sound when notification is tapped
      final notificationType = message.data['type'] ?? 'default';
      soundService.playNotificationSound(soundType: notificationType);
    });
  }

  @override
  void dispose() {
    soundService.dispose();
    super.dispose();
  }

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