import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(
        _isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF121212) : AppColors.pageBg,
    );
  }

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    
    _isDarkMode = isDark;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', isDark);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }
}
