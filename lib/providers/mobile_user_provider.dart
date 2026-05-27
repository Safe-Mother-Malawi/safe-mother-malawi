import 'package:flutter/foundation.dart';
import '../mobile/auth/models/user_model.dart';
import '../mobile/auth/services/auth_service.dart';

/// Reactive state for the currently logged-in mobile user.
/// Wrap your app with ChangeNotifierProvider(create: (_) => MobileUserProvider())
/// then call context.read<MobileUserProvider>().refresh() after profile updates.
class MobileUserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  String get fullName => _user?.fullName ?? '';
  String get role     => _user?.role ?? '';
  String get phone    => _user?.phone ?? '';
  String get email    => _user?.email ?? '';

  /// Load the current user from the backend (uses saved token).
  Future<void> load() async {
    _user = await AuthService().getCurrentUser();
    notifyListeners();
  }

  /// Update the in-memory user and notify listeners — call after profile edits.
  void update(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  /// Clear user on logout.
  void clear() {
    _user = null;
    notifyListeners();
  }
}

