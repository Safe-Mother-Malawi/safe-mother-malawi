import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../shared/app_shell.dart';
import '../shared/sidebar.dart';
import '../shared/widgets/kpi_card.dart';
import '../shared/widgets/chart_card.dart';
import '../shared/widgets/status_badge.dart';
import '../shared/utils/responsive_helper.dart';
import '../admin/clinician_management.dart';
import '../admin/generate_analytics.dart';
import '../admin/analytics_dashboard_v2.dart';
import '../dho/dho_dashboard_v2.dart';
import '../admin/task_analytics.dart';
import '../admin/question_insights.dart';
import '../admin/reports_screen_export.dart';
import 'facilities_view.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service_web.dart';
import '../../../state/user_store.dart';
import '../../../utils/live_data_mixin.dart';

class DhoOverview extends StatefulWidget {
  const DhoOverview({super.key});

  @override
  State<DhoOverview> createState() => _DhoOverviewState();
}

class _DhoOverviewState extends State<DhoOverview> {
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
      case '/clinicians':         return const ClinicianManagement();
      case '/generate-analytics': return const GenerateAnalytics();
      case '/analytics':          return const AnalyticsDashboardV2();
      case '/task-analytics':     return const TaskAnalytics();
      case '/question-insights':  return const QuestionInsights();
      case '/reports':            return const ReportsScreen();
      case '/facilities':         return const DhoFacilitiesView();
      default:                    return const _DhoDashboardV2Body();
    }
  }

  String get _pageTitle {
    const titles = {
      '/overview':          'Overview',
      '/clinicians':        'Clinician Management',
      '/generate-analytics':'Generate Analytics',
      '/analytics':         'Analytics Dashboard',
      '/task-analytics':    'Task Analytics',
      '/question-insights': 'Question Insights',
      '/reports':           'Reports',
      '/facilities':        'Health Facilities',
    };
    return titles[_currentRoute] ?? 'DHO Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: UserRole.dho,
      userName: AuthServiceWeb.instance.userName,
      currentRoute: _currentRoute,
      pageTitle: _pageTitle,
      onNavigate: _navigate,
      body: _buildPage(),
    );
  }
}

class _DhoDashboardV2Body extends StatelessWidget {
  const _DhoDashboardV2Body();

  @override
  Widget build(BuildContext context) {
    return const DhoDashboardV2();
  }
}
