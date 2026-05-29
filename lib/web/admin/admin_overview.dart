import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/app_shell.dart';
import '../shared/sidebar.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/utils/responsive_helper.dart';
import 'system_users.dart';
import 'reports_screen_export.dart';
import 'audit_export_export.dart';
import 'question_insights.dart';
import 'insights_screen.dart';
import 'facilities_management.dart';
import 'system_logs.dart';
import 'broadcast_messages_screen.dart';
import 'admin_dashboard_v2.dart';
import '../../services/api_service.dart';
import '../../services/auth_service_web.dart';
import '../../state/user_store.dart';
import '../../utils/live_data_mixin.dart';

class AdminOverview extends StatefulWidget {
  const AdminOverview({super.key});

  @override
  State<AdminOverview> createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<AdminOverview> {
  String _currentRoute = '/overview';

  @override
  void initState() {
    super.initState();
    UserStore.instance.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    UserStore.instance.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() => setState(() {});

  void _navigate(String route) => setState(() => _currentRoute = route);

  Widget _buildPage() {
    switch (_currentRoute) {
      case '/clinicians':        return const SystemUsers();
      case '/audit-export':      return const AuditExport();
      case '/question-insights': return const QuestionInsights();
      case '/insights':          return const InsightsScreen();
      case '/reports':           return const ReportsScreen();
      case '/facilities':        return const FacilitiesManagementScreen();
      case '/logs':              return const SystemLogs();
      case '/broadcasts':        return const BroadcastMessagesScreen();
      default:                   return const _AdminDashboardV2Body();
    }
  }

  String get _pageTitle {
    const titles = {
      '/overview':          'Overview',
      '/clinicians':        'System Users',
      '/audit-export':      'Audit Export',
      '/question-insights': 'Question Insights',
      '/insights':          'Insights',
      '/reports':           'Reports',
      '/facilities':        'Health Facilities',
      '/logs':              'Audit Logs',
      '/broadcasts':        'Broadcast Messages',
    };
    return titles[_currentRoute] ?? 'Admin Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: UserRole.admin,
      userName: AuthServiceWeb.instance.userName,
      currentRoute: _currentRoute,
      pageTitle: _pageTitle,
      onNavigate: _navigate,
      body: _buildPage(),
    );
  }
}

// ── Admin Dashboard V2 ──────────────────────────────────────────────────────

class _AdminDashboardV2Body extends StatelessWidget {
  const _AdminDashboardV2Body();

  @override
  Widget build(BuildContext context) {
    return const AdminDashboardV2();
  }
}
