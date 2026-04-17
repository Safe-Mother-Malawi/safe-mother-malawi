import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'sidebar.dart';
import 'top_navbar.dart';

class AppShell extends StatelessWidget {
  final UserRole role;
  final String userName;
  final String currentRoute;
  final String pageTitle;
  final Widget body;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  const AppShell({
    super.key,
    required this.role,
    required this.userName,
    required this.currentRoute,
    required this.pageTitle,
    required this.body,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Row(
        children: [
          AppSidebar(
            role: role,
            currentRoute: currentRoute,
            onNavigate: onNavigate,
          ),
          Expanded(
            child: Column(
              children: [
                TopNavbar(
                  role: role,
                  userName: userName,
                  pageTitle: pageTitle,
                  onLogout: onLogout,
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
