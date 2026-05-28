import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../prenatal/prenatal_dashboard.dart';
import '../neonatal/neonatal_dashboard.dart';
import '../postnatal/postnatal_dashboard.dart';

/// Centralized Mobile Application
/// Routes users to appropriate module based on their role
class MobileApp extends StatefulWidget {
  const MobileApp({super.key});

  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1A237E)),
        ),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not found. Please log in again.'),
        ),
      );
    }

    // Route to appropriate module based on user role
    return _buildModuleForRole(_user!.role);
  }

  /// Build the appropriate module based on user role
  Widget _buildModuleForRole(String role) {
    switch (role.toLowerCase()) {
      case 'prenatal':
        return const PrenatalDashboard();
      case 'neonatal':
        return const NeonatalDashboard();
      case 'postnatal':
        return const PostnatalDashboard();
      default:
        return Scaffold(
          body: Center(
            child: Text('Unknown role: $role'),
          ),
        );
    }
  }
}
