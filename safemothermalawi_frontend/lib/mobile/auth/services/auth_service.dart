import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const _prefix = 'user_';
  static const _loggedInKey = 'logged_in_email';

  Future<bool> register(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    // Use phone as account key when email is not provided
    final accountId = user.email.isNotEmpty ? user.email : 'phone_${user.phone}';
    final key = '$_prefix$accountId';
    if (prefs.containsKey('${key}_phone')) return false;
    await prefs.setString('${key}_email', user.email);
    await prefs.setString('${key}_accountId', accountId);
    await prefs.setString('${key}_password', user.password);
    await prefs.setString('${key}_role', user.role);
    await prefs.setString('${key}_fullName', user.fullName);
    await prefs.setString('${key}_phone', user.phone);
    await prefs.setString('${key}_lmpDate', user.lmpDate);
    await prefs.setString('${key}_babyName', user.babyName);
    await prefs.setString('${key}_babyDob', user.babyDob);
    await prefs.setString('${key}_age', user.age);
    await prefs.setString('${key}_nationality', user.nationality);
    await prefs.setString('${key}_district', user.district);
    await prefs.setString('${key}_healthCentre', user.healthCentre);
    await prefs.setString('${key}_pregnancyMonths', user.pregnancyMonths);
    await prefs.setString('${key}_pregnancyWeeks', user.pregnancyWeeks);
    await prefs.setString('${key}_expectedDeliveryDate', user.expectedDeliveryDate);
    await prefs.setString('${key}_babyGender', user.babyGender);
    await prefs.setString('${key}_babyBirthWeight', user.babyBirthWeight);
    await prefs.setString('${key}_securityQuestion', user.securityQuestion);
    await prefs.setString('${key}_securityAnswer', user.securityAnswer.toLowerCase().trim());
    return true;
  }

  Future<UserModel?> login(String emailOrPhone, String password) async {
    final prefs = await SharedPreferences.getInstance();
    // Determine account key: email or phone fallback
    final accountId = emailOrPhone.contains('@')
        ? emailOrPhone
        : 'phone_$emailOrPhone';
    final key = '$_prefix$accountId';
    final stored = prefs.getString('${key}_password');
    if (stored == null || stored != password) return null;
    await prefs.setString(_loggedInKey, accountId);
    return _buildUser(prefs, accountId);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getString(_loggedInKey);
    if (accountId == null) return null;
    return _buildUser(prefs, accountId);
  }

  UserModel _buildUser(SharedPreferences prefs, String accountId) {
    final key = '$_prefix$accountId';
    return UserModel(
      email: prefs.getString('${key}_email') ?? accountId,
      password: prefs.getString('${key}_password') ?? '',
      role: prefs.getString('${key}_role') ?? '',
      fullName: prefs.getString('${key}_fullName') ?? '',
      phone: prefs.getString('${key}_phone') ?? '',
      lmpDate: prefs.getString('${key}_lmpDate') ?? '',
      babyName: prefs.getString('${key}_babyName') ?? '',
      babyDob: prefs.getString('${key}_babyDob') ?? '',
      age: prefs.getString('${key}_age') ?? '',
      nationality: prefs.getString('${key}_nationality') ?? '',
      district: prefs.getString('${key}_district') ?? '',
      healthCentre: prefs.getString('${key}_healthCentre') ?? '',
      pregnancyMonths: prefs.getString('${key}_pregnancyMonths') ?? '',
      pregnancyWeeks: prefs.getString('${key}_pregnancyWeeks') ?? '',
      expectedDeliveryDate: prefs.getString('${key}_expectedDeliveryDate') ?? '',
      babyGender: prefs.getString('${key}_babyGender') ?? '',
      babyBirthWeight: prefs.getString('${key}_babyBirthWeight') ?? '',
      securityQuestion: prefs.getString('${key}_securityQuestion') ?? '',
      securityAnswer: prefs.getString('${key}_securityAnswer') ?? '',
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
  }

  /// Returns the security question for a given phone/email, or null if not found.
  Future<String?> getSecurityQuestion(String phoneOrEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = phoneOrEmail.contains('@')
        ? phoneOrEmail
        : 'phone_$phoneOrEmail';
    final key = '$_prefix$accountId';
    if (!prefs.containsKey('${key}_password')) return null;
    return prefs.getString('${key}_securityQuestion');
  }

  /// Verifies the security answer and resets the password.
  /// Returns true on success, false if answer is wrong or account not found.
  Future<bool> resetPassword({
    required String phoneOrEmail,
    required String securityAnswer,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = phoneOrEmail.contains('@')
        ? phoneOrEmail
        : 'phone_$phoneOrEmail';
    final key = '$_prefix$accountId';
    final stored = prefs.getString('${key}_securityAnswer');
    if (stored == null) return false;
    if (stored != securityAnswer.toLowerCase().trim()) return false;
    await prefs.setString('${key}_password', newPassword);
    return true;
  }

  Future<void> seedDemoAccounts() async {
    final prefs = await SharedPreferences.getInstance();

    // ── Demo prenatal account ──────────────────────────────────────────────
    const p1 = 'phone_0881234567';
    final k1 = '$_prefix$p1';
    // Always ensure the seed is present (re-seeds if missing)
    if (prefs.getString('${k1}_password') != 'demo1234') {
      await prefs.setString('${k1}_email', '');
      await prefs.setString('${k1}_accountId', p1);
      await prefs.setString('${k1}_password', 'demo1234');
      await prefs.setString('${k1}_role', 'prenatal');
      await prefs.setString('${k1}_fullName', 'Grace Banda');
      await prefs.setString('${k1}_phone', '0881234567');
      await prefs.setString('${k1}_age', '26');
      await prefs.setString('${k1}_nationality', 'Malawian');
      await prefs.setString('${k1}_district', 'Lilongwe');
      await prefs.setString('${k1}_healthCentre', 'Area 25 Health Centre');
      await prefs.setString('${k1}_pregnancyMonths', '5');
      await prefs.setString('${k1}_pregnancyWeeks', '2');
      await prefs.setString('${k1}_expectedDeliveryDate', '2026-08-10');
      await prefs.setString('${k1}_lmpDate', '');
      await prefs.setString('${k1}_babyName', '');
      await prefs.setString('${k1}_babyDob', '');
      await prefs.setString('${k1}_babyGender', '');
      await prefs.setString('${k1}_babyBirthWeight', '');
    }

    // ── Demo neonatal account ──────────────────────────────────────────────
    const p2 = 'phone_0991234567';
    final k2 = '$_prefix$p2';
    if (prefs.getString('${k2}_password') != 'demo1234') {
      await prefs.setString('${k2}_email', '');
      await prefs.setString('${k2}_accountId', p2);
      await prefs.setString('${k2}_password', 'demo1234');
      await prefs.setString('${k2}_role', 'neonatal');
      await prefs.setString('${k2}_fullName', 'Mercy Phiri');
      await prefs.setString('${k2}_phone', '0991234567');
      await prefs.setString('${k2}_age', '24');
      await prefs.setString('${k2}_nationality', 'Malawian');
      await prefs.setString('${k2}_district', 'Blantyre');
      await prefs.setString('${k2}_healthCentre', 'Ndirande Health Centre');
      await prefs.setString('${k2}_babyName', 'Baby Phiri');
      await prefs.setString('${k2}_babyDob', '2026-03-15T00:00:00.000');
      await prefs.setString('${k2}_babyGender', 'Female');
      await prefs.setString('${k2}_babyBirthWeight', '3.1');
      await prefs.setString('${k2}_lmpDate', '');
      await prefs.setString('${k2}_pregnancyMonths', '');
      await prefs.setString('${k2}_pregnancyWeeks', '');
      await prefs.setString('${k2}_expectedDeliveryDate', '');
    }

    // ── Demo clinician account ─────────────────────────────────────────────
    const p3 = 'clinician@safemothermalawi.app';
    final k3 = '$_prefix$p3';
    if (prefs.getString('${k3}_password') != 'clinic1234') {
      await prefs.setString('${k3}_email', p3);
      await prefs.setString('${k3}_accountId', p3);
      await prefs.setString('${k3}_password', 'clinic1234');
      await prefs.setString('${k3}_role', 'clinician');
      await prefs.setString('${k3}_fullName', 'Dr. Mwale Chirwa');
      await prefs.setString('${k3}_phone', '0771234567');
      await prefs.setString('${k3}_lmpDate', '');
      await prefs.setString('${k3}_babyName', '');
      await prefs.setString('${k3}_babyDob', '');
      await prefs.setString('${k3}_babyGender', '');
      await prefs.setString('${k3}_babyBirthWeight', '');
      await prefs.setString('${k3}_age', '');
      await prefs.setString('${k3}_nationality', '');
      await prefs.setString('${k3}_district', '');
      await prefs.setString('${k3}_healthCentre', '');
      await prefs.setString('${k3}_pregnancyMonths', '');
      await prefs.setString('${k3}_pregnancyWeeks', '');
      await prefs.setString('${k3}_expectedDeliveryDate', '');
      await prefs.setString('${k3}_securityQuestion', '');
      await prefs.setString('${k3}_securityAnswer', '');
    }
  }
}
