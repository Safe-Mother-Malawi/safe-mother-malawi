import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'sidebar.dart' show AppSidebar, UserRole;
import 'top_navbar.dart';
import 'widgets/error_boundary.dart';

class AppShell extends StatefulWidget {
  final UserRole role;
  final String userName;
  final String currentRoute;
  final String pageTitle;
  final Widget body;
  final ValueChanged<String> onNavigate;

  const AppShell({
    super.key,
    required this.role,
    required this.userName,
    required this.currentRoute,
    required this.pageTitle,
    required this.body,
    required this.onNavigate,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _sidebarOpen = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Auto-close sidebar on mobile
    if (isMobile && _sidebarOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _sidebarOpen = false);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: isMobile
          ? _buildMobileLayout()
          : isTablet
              ? _buildTabletLayout()
              : _buildDesktopLayout(),
      drawer: isMobile
          ? Drawer(
              child: AppSidebar(
                role: widget.role,
                currentRoute: widget.currentRoute,
                onNavigate: (route) {
                  widget.onNavigate(route);
                  Navigator.pop(context);
                },
                isMobile: true,
              ),
            )
          : null,
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        TopNavbar(
          role: widget.role,
          userName: widget.userName,
          pageTitle: widget.pageTitle,
          isMobile: true,
          onMenuTap: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        Expanded(
          child: ErrorBoundary(child: widget.body),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Collapsible sidebar for tablet
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _sidebarOpen ? 240 : 70,
          child: AppSidebar(
            role: widget.role,
            currentRoute: widget.currentRoute,
            onNavigate: widget.onNavigate,
            isCollapsed: !_sidebarOpen,
            isMobile: false,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              TopNavbar(
                role: widget.role,
                userName: widget.userName,
                pageTitle: widget.pageTitle,
                isMobile: false,
                onMenuTap: () {
                  setState(() => _sidebarOpen = !_sidebarOpen);
                },
              ),
              Expanded(
                child: ErrorBoundary(child: widget.body),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        AppSidebar(
          role: widget.role,
          currentRoute: widget.currentRoute,
          onNavigate: widget.onNavigate,
          isMobile: false,
        ),
        Expanded(
          child: Column(
            children: [
              TopNavbar(
                role: widget.role,
                userName: widget.userName,
                pageTitle: widget.pageTitle,
                isMobile: false,
              ),
              Expanded(
                child: ErrorBoundary(child: widget.body),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

