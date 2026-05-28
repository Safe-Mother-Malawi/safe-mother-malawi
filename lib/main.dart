import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/reset_password_page.dart';
import 'services/offline_service.dart';
import 'services/auth_service_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  await OfflineService().initialize();
  await AuthServiceWeb.instance.restoreSession();
  
  runApp(const SafeMotherApp());
}

class SafeMotherApp extends StatefulWidget {
  const SafeMotherApp({super.key});

  @override
  State<SafeMotherApp> createState() => _SafeMotherAppState();
}

class _SafeMotherAppState extends State<SafeMotherApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: OfflineService()),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}