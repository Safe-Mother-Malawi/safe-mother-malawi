import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Exception thrown when API calls fail
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Central HTTP client for all backend calls.
/// Base URL: http://41.70.47.173:3000/api/v1
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Use ApiConfig for environment-based URL switching
  static String get _base => ApiConfig.baseUrl;

  /// Exposed for direct URL construction (e.g. blob downloads)
  static String get baseUrl => _base;

  /// Returns the current bearer token (for authenticated fetch calls)
  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  String? _token;

  // ── Token management ──────────────────────────────────────────────────────

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
  }

  Future<void> saveToken(String token, String refreshToken) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  /// Alias used by mobile auth service
  Future<void> clearTokens() => clearToken();

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  // ── Headers ───────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── HTTP helpers ──────────────────────────────────────────────────────────

  Future<dynamic> get(String path) async {
    final res = await http.get(Uri.parse('$_base$path'), headers: _headers);
    return _handle(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$_base$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse('$_base$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$_base$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<void> delete(String path) async {
    final res = await http.delete(Uri.parse('$_base$path'), headers: _headers);
    _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    final msg = _tryParseError(res.body);
    throw ApiException(res.statusCode, msg);
  }

  String _tryParseError(String body) {
    try {
      final j = jsonDecode(body);
      return j['message']?.toString() ?? body;
    } catch (_) {
      return body;
    }
  }

  /// Safely coerce a dynamic API response to a List.
  static List<dynamic> _asList(dynamic d) {
    if (d is List) return d;
    if (d is Map) return (d['data'] as List?) ?? (d['items'] as List?) ?? [];
    return [];
  }

  // ── Auth helpers (used by mobile AuthService) ─────────────────────────────

  Future<dynamic> register(Map<String, dynamic> payload) =>
      post('/auth/register', payload);

  Future<dynamic> login(String emailOrPhone, String password) =>
      post('/auth/login', {'identifier': emailOrPhone, 'password': password});

  Future<Map<String, dynamic>?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return null;
    _token = token;
    try {
      final data = await get('/auth/me');
      return data as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  // ── Reports (static convenience wrappers) ────────────────────────────────

  static Future<List<dynamic>> getReports() =>
      instance.get('/reports').then(_asList);

  static Future<Map<String, dynamic>> generateReport(
      Map<String, dynamic> body) async {
    final data = await instance.post('/reports/generate', body);
    return (data as Map<String, dynamic>?) ?? {};
  }

  static Future<void> deleteReport(String id) =>
      instance.delete('/reports/$id');

  // ── Users (static convenience wrappers) ──────────────────────────────────

  static Future<List<dynamic>> getUsers({String? role}) {
    final path = role != null ? '/users?role=$role' : '/users';
    return instance.get(path).then(_asList);
  }

  static Future<Map<String, dynamic>> createUser(
      Map<String, dynamic> body) async {
    final data = await instance.post('/users', body);
    return (data as Map<String, dynamic>?) ?? {};
  }

  static Future<void> updateUserStatus(String id, String status) =>
      instance.patch('/users/$id/status', {'status': status});

  static Future<void> deleteUser(String id) => instance.delete('/users/$id');

  // ── Activity logs ─────────────────────────────────────────────────────────

  static Future<List<dynamic>> getActivityLogs({int page = 1, int limit = 50}) =>
      instance.get('/activity-logs?page=$page&limit=$limit').then(_asList);

  // ── Analytics ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAnalyticsOverview() async {
    final data = await instance.get('/analytics/overview');
    return (data as Map<String, dynamic>?) ?? {};
  }

  static Future<Map<String, dynamic>> getTaskAnalytics() async {
    final data = await instance.get('/analytics/task-analytics');
    return (data as Map<String, dynamic>?) ?? {};
  }

  static Future<Map<String, dynamic>> getRiskDistribution() async {
    final data = await instance.get('/analytics/risk-distribution');
    // Backend returns List<{riskLevel, count}> — convert to summary map
    final list = data is List ? data : (data is Map ? (data['data'] as List? ?? []) : []);
    if (list.isNotEmpty) {
      int low = 0, medium = 0, high = 0, total = 0;
      for (final item in list) {
        if (item is! Map) continue;
        final level = (item['riskLevel'] ?? '').toString();
        final count = int.tryParse(item['count']?.toString() ?? '0') ?? 0;
        total += count;
        if (level.contains('Low'))           low    += count;
        else if (level.contains('Moderate')) medium += count;
        else if (level.contains('High') || level.contains('Seek')) high += count;
      }
      return {
        'total': total, 'low': low, 'medium': medium, 'high': high,
        'highRisk': high,
        'completionRate': total > 0 ? ((total / (total + 1)) * 100).toStringAsFixed(1) : '—',
        'avgScore': '—',
      };
    }
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  // ── Risk assessments ──────────────────────────────────────────────────────

  static Future<List<dynamic>> getRiskAssessments({int page = 1, int limit = 50}) async {
    final data = await instance.get('/risk-assessments?limit=$limit&offset=${(page - 1) * limit}');
    if (data is Map<String, dynamic>) {
      return (data['assessments'] as List<dynamic>?) ?? [];
    }
    return _asList(data);
  }
      return (data['responses'] as List<dynamic>?) ?? [];
    }
    return _asList(data);
  }

  // ── Appointments ──────────────────────────────────────────────────────────

  static Future<List<dynamic>> getAppointments({String? patientId}) {
    final path = patientId != null ? '/appointments?patientId=$patientId' : '/appointments';
    return instance.get(path).then(_asList);
  }

  static Future<Map<String, dynamic>> createAppointment(
      Map<String, dynamic> body) async {
    final data = await instance.post('/appointments', body);
    return (data as Map<String, dynamic>?) ?? {};
  }

  static Future<Map<String, dynamic>> updateAppointment(
      String id, Map<String, dynamic> body) async {
    final data = await instance.put('/appointments/$id', body);
    return (data as Map<String, dynamic>?) ?? {};
  }

  static Future<void> deleteAppointment(String id) =>
      instance.delete('/appointments/$id');

  // ── Users ─────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getCliniciansByFacility(String facility) =>
      instance.get('/users/clinicians-by-facility?facility=${Uri.encodeComponent(facility)}').then(_asList);

  // ── Alerts ────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getAlerts() =>
      instance.get('/alerts').then(_asList);

  static Future<Map<String, dynamic>> markAlertDone(String id) async {
    final data = await instance.patch('/alerts/$id/attended', {});
    return (data as Map<String, dynamic>?) ?? {};
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  static Future<List<dynamic>> getNotifications() =>
      instance.get('/notifications').then(_asList);

  static Future<void> markNotificationRead(String id) =>
      instance.patch('/notifications/$id/read', {});

  // ── Health facilities ─────────────────────────────────────────────────────

  static Future<List<dynamic>> getHealthFacilities() =>
      instance.get('/health-facilities').then(_asList);

  static Future<List<dynamic>> getFacilitiesByDistrict(String district) =>
      instance.get('/health-facilities?district=${Uri.encodeComponent(district)}').then(_asList);

  static Future<List<String>> getRegions() =>
      instance.get('/health-facilities/regions').then((data) => 
          (data as List<dynamic>).cast<String>());

  static Future<List<String>> getZones(String region) =>
      instance.get('/health-facilities/zones?region=${Uri.encodeComponent(region)}').then((data) => 
          (data as List<dynamic>).cast<String>());

  static Future<List<String>> getDistricts(String zone) =>
      instance.get('/health-facilities/districts?zone=${Uri.encodeComponent(zone)}').then((data) => 
          (data as List<dynamic>).cast<String>());

  // ── Patients ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> registerPrenatalPatient(
      Map<String, dynamic> body) async {
    final data = await instance.post('/patients/prenatal', body);
    return (data as Map<String, dynamic>?) ?? {};
  }

  static Future<Map<String, dynamic>> registerNeonatalPatient(
      Map<String, dynamic> body) async {
    final data = await instance.post('/patients/neonatal', body);
    return (data as Map<String, dynamic>?) ?? {};
  }

  // ── Health Check / Dialogue Service ───────────────────────────────────────

  /// Get health check questions for the current user's stage
  /// Auto-detects stage from user profile (LMP date for prenatal, baby DOB for neonatal)
  static Future<Map<String, dynamic>> getHealthCheckQuestions() async {
    final data = await instance.get('/who/questions');
    return (data as Map<String, dynamic>?) ?? {};
  }

  /// Submit health check answers and get risk assessment
  /// Returns: { stage, score, maxScore, percentage, riskLevel, message, answeredQuestions }
  static Future<Map<String, dynamic>> submitHealthAssessment(
    List<Map<String, dynamic>> answers,
  ) async {
    final data = await instance.post('/who/assessment', {'answers': answers});
    return (data as Map<String, dynamic>?) ?? {};
  }

  /// Get assessment history for the current user
  static Future<List<dynamic>> getAssessmentHistory() async {
    final user = await instance.currentUser();
    if (user == null) return [];
    final patientId = user['id'] as String?;
    if (patientId == null) return [];
    final data = await instance.get('/risk-assessments/patient/$patientId');
    return _asList(data);
  }

  // ── Settings & Account ────────────────────────────────────────────────────

  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await getToken();
    if (token == null) throw ApiException(401, 'Not authenticated');

    final response = await http.post(
      Uri.parse('$_base/auth/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, 'Failed to change password');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    final token = await getToken();
    if (token == null) throw ApiException(401, 'Not authenticated');

    final response = await http.delete(
      Uri.parse('$_base/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, 'Failed to delete account');
    }

    await clearToken();
  }

  /// Save user preferences
  Future<void> savePreferences(Map<String, dynamic> preferences) async {
    final token = await getToken();
    if (token == null) throw ApiException(401, 'Not authenticated');

    final response = await http.put(
      Uri.parse('$_base/users/me/preferences'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(preferences),
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, 'Failed to save preferences');
    }
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getPreferences() async {
    final token = await getToken();
    if (token == null) throw ApiException(401, 'Not authenticated');

    final response = await http.get(
      Uri.parse('$_base/users/me/preferences'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, 'Failed to get preferences');
    }

    return (jsonDecode(response.body) as Map<String, dynamic>?) ?? {};
  }

  /// Submit a support contact form
  Future<void> submitContactForm({
    required String subject,
    required String message,
  }) async {
    final token = await getToken();
    if (token == null) throw ApiException(401, 'Not authenticated');

    final response = await http.post(
      Uri.parse('$_base/support/contact'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'subject': subject,
        'message': message,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(response.statusCode, 'Failed to submit contact form');
    }
  }
}
