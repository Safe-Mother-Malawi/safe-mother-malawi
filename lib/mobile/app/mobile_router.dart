import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../prenatal/prenatal_dashboard.dart';
import '../neonatal/neonatal_dashboard.dart';
import '../postnatal/postnatal_dashboard.dart';

/// Centralized Mobile Router
/// Handles navigation between different modules
class MobileRouter {
  static const String prenatalHome = '/prenatal';
  static const String neonatalHome = '/neonatal';
  static const String postnatalHome = '/postnatal';

  /// Get the home route for a user based on their role
  static String getHomeRoute(String role) {
    switch (role.toLowerCase()) {
      case 'prenatal':
        return prenatalHome;
      case 'neonatal':
        return neonatalHome;
      case 'postnatal':
        return postnatalHome;
      default:
        return prenatalHome;
    }
  }

  /// Get the home widget for a user based on their role
  static Widget getHomeWidget(String role) {
    switch (role.toLowerCase()) {
      case 'prenatal':
        return const PrenatalDashboard();
      case 'neonatal':
        return const NeonatalDashboard();
      case 'postnatal':
        return const PostnatalDashboard();
      default:
        return const PrenatalDashboard();
    }
  }

  /// Build named routes for the mobile app
  static Map<String, WidgetBuilder> buildRoutes() {
    return {
      prenatalHome: (_) => const PrenatalDashboard(),
      neonatalHome: (_) => const NeonatalDashboard(),
      postnatalHome: (_) => const PostnatalDashboard(),
    };
  }

  /// Navigate to module based on role
  static Future<void> navigateToModule(
    BuildContext context,
    String role, {
    bool replace = false,
  }) async {
    final route = getHomeRoute(role);
    final widget = getHomeWidget(role);

    if (replace) {
      Navigator.of(context).pushReplacementNamed(route);
    } else {
      Navigator.of(context).pushNamed(route);
    }
  }
}
