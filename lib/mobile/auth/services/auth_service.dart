import '../models/user_model.dart';
import '../../../services/api_service.dart';

/// Mobile auth service — delegates to the real backend API.
class AuthService {
  /// Register a new user via the backend.
  Future<bool> register(UserModel user) async {
    try {
      final payload = <String, dynamic>{
        'email': user.email.isNotEmpty ? user.email : null,
        'phone': user.phone,
        'password': user.password,
        'role': user.role,
        'fullName': user.fullName,
        'age': user.age,
        'nationality': user.nationality,
        'district': user.district,
        'facilityName': user.facilityName,
        'lmpDate': user.lmpDate.isNotEmpty ? user.lmpDate : null,
        'pregnancyMonths': user.pregnancyMonths.isNotEmpty ? user.pregnancyMonths : null,
        'pregnancyWeeks': user.pregnancyWeeks.isNotEmpty ? user.pregnancyWeeks : null,
        'expectedDeliveryDate': user.expectedDeliveryDate.isNotEmpty ? user.expectedDeliveryDate : null,
        'babyName': user.babyName.isNotEmpty ? user.babyName : null,
        'babyDob': user.babyDob.isNotEmpty ? user.babyDob : null,
        'babyGender': user.babyGender.isNotEmpty ? user.babyGender : null,
        'babyBirthWeight': user.babyBirthWeight.isNotEmpty ? user.babyBirthWeight : null,
        'securityQuestion': user.securityQuestion.isNotEmpty ? user.securityQuestion : null,
        'securityAnswer': user.securityAnswer.isNotEmpty ? user.securityAnswer : null,
      }..removeWhere((_, v) => v == null);

      final data = await ApiService.instance.register(payload);
      // Save tokens so the user is immediately authenticated after registration
      final tokens = data?['tokens'] as Map<String, dynamic>?;
      if (tokens != null) {
        await ApiService.instance.saveToken(
          tokens['accessToken'] as String,
          tokens['refreshToken'] as String,
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Login via the backend. Returns a [UserModel] on success, null on failure.
  Future<UserModel?> login(String emailOrPhone, String password) async {
    try {
      final data = await ApiService.instance.login(emailOrPhone, password);
      // Save tokens so subsequent API calls are authenticated
      final tokens = data['tokens'] as Map<String, dynamic>?;
      if (tokens != null) {
        await ApiService.instance.saveToken(
          tokens['accessToken'] as String,
          tokens['refreshToken'] as String,
        );
      }
      final user = data['user'] as Map<String, dynamic>?;
      if (user == null) return null;
      return _userFromMap(user);
    } catch (_) {
      return null;
    }
  }

  /// Returns the currently logged-in user from the backend (uses saved token).
  Future<UserModel?> getCurrentUser() async {
    // Ensure token is loaded from storage before making the request
    await ApiService.instance.loadToken();
    if (!ApiService.instance.isLoggedIn) return null;
    final data = await ApiService.instance.currentUser();
    if (data == null) return null;
    return _userFromMap(data);
  }

  /// Logout — clears tokens and cached user data.
  Future<void> logout() async {
    await ApiService.instance.clearTokens();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  UserModel _userFromMap(Map<String, dynamic> m) {
    return UserModel(
      id: (m['id']?.toString()) ?? (m['_id']?.toString()) ?? '',
      email: (m['email'] as String?) ?? '',
      password: '',
      role: (m['role'] as String?) ?? '',
      fullName: (m['fullName'] as String?) ?? (m['name'] as String?) ?? '',
      phone: (m['phone'] as String?) ?? '',
      lmpDate: (m['lmpDate'] as String?) ?? '',
      babyName: (m['babyName'] as String?) ?? '',
      babyDob: (m['babyDob'] as String?) ?? '',
      age: (m['age']?.toString()) ?? '',
      nationality: (m['nationality'] as String?) ?? '',
      district: (m['district'] as String?) ?? '',
      facilityName: (m['facilityName'] as String?) ?? '',
      pregnancyMonths: (m['pregnancyMonths']?.toString()) ?? '',
      pregnancyWeeks: (m['pregnancyWeeks']?.toString()) ?? '',
      expectedDeliveryDate: (m['expectedDeliveryDate'] as String?) ?? '',
      babyGender: (m['babyGender'] as String?) ?? '',
      babyBirthWeight: (m['babyBirthWeight']?.toString()) ?? '',
      securityQuestion: (m['securityQuestion'] as String?) ?? '',
      securityAnswer: (m['securityAnswer'] as String?) ?? '',
    );
  }

  /// Returns the security question for a given phone/email, or null if not found.
  Future<String?> getSecurityQuestion(String phoneOrEmail) async {
    try {
      final data = await ApiService.instance.post(
        '/auth/forgot-password/question',
        {'identifier': phoneOrEmail},
      );
      return data['question'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Resets password via backend security question verification.
  Future<bool> resetPassword({
    required String phoneOrEmail,
    required String securityAnswer,
    required String newPassword,
  }) async {
    try {
      await ApiService.instance.post(
        '/auth/forgot-password/reset',
        {
          'identifier': phoneOrEmail,
          'securityAnswer': securityAnswer,
          'newPassword': newPassword,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Request password reset via email (email-based flow).
  /// Returns true if request was successful (neutral response).
  Future<bool> requestPasswordReset(String email) async {
    try {
      await ApiService.instance.post(
        '/auth/forgot-password/request-reset',
        {'email': email},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Verify a password reset token.
  /// Returns true if token is valid, false otherwise.
  Future<bool> verifyResetToken(String token) async {
    try {
      final data = await ApiService.instance.get(
        '/auth/forgot-password/verify-token/$token',
      );
      return (data['valid'] as bool?) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Reset password using a token (email-based flow).
  /// Returns true on success, false on failure.
  Future<bool> resetPasswordWithToken({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await ApiService.instance.post(
        '/auth/forgot-password/reset-with-token',
        {
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// No-op: demo accounts are no longer needed with real backend.
  Future<void> seedDemoAccounts() async {}
}

