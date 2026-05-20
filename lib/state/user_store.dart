import 'package:flutter/foundation.dart';
import '../services/auth_service_web.dart';

/// Singleton that exposes the currently logged-in web user's profile.
class UserStore extends ChangeNotifier {
  UserStore._();
  static final UserStore instance = UserStore._();

  /// The district of the currently logged-in DHO/Admin.
  String get district {
    final user = AuthServiceWeb.instance.currentUser;
    return (user?['district'] as String?) ?? '';
  }

  /// Full name of the current user.
  String get fullName => AuthServiceWeb.instance.userName;

  /// Role of the current user.
  String get role => AuthServiceWeb.instance.userRole;

  /// Call after updating the session cache to push a rebuild to all listeners.
  void refresh() => notifyListeners();
}

