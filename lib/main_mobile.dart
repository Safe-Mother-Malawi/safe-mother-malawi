import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mobile/auth/screens/splash_screen.dart';
import 'mobile/auth/services/auth_service.dart';
import 'providers/theme_provider.dart';
import 'providers/mobile_user_provider.dart';
import 'services/reminder_service.dart';
import 'services/offline_service.dart';

// Global navigator key — used by logout to always reach the root navigator
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await ReminderService.initialize();
  } catch (e) {
    debugPrint('Reminder service initialization failed: $e');
  }
  await OfflineService().initialize();
  await AuthService().restoreSession();
  await AuthService().seedDemoAccounts(); // always sync demo data before app starts
  runApp(const SafeMotherMobileApp());
}

class SafeMotherMobileApp extends StatelessWidget {
  const SafeMotherMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MobileUserProvider()),
        ChangeNotifierProvider.value(value: OfflineService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Safe Mother Malawi',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.theme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

