import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    debugPrint('📤 POST $_base$path');
    debugPrint('📦 Body: $body');
    final res = await http.post(
      Uri.parse('$_base$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    debugPrint('📥 Response Status: ${res.statusCode}');
    debugPrint('📥 Response Headers: ${res.headers}');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      debugPrint('✅ Success');
    } else {
      debugPrint('❌ Error: ${res.body}');
    }
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

  static Future<Map<String, dynamic>> createFacility(Map<String, dynamic> body) async {
    final data = await instance.post('/health-facilities', body);
    return (data as Map<String, dynamic>?) ?? {};
  }

  static Future<List<String>> getRegions() =>
      instance.get('/health-facilities/regions').then((data) => 
          (data as List<dynamic>).cast<String>());

  static Future<List<String>> getZones(String region) =>
      instance.get('/health-facilities/zones?region=${Uri.encodeComponent(region)}').then((data) => 
          (data as List<dynamic>).cast<String>());

  static Future<List<String>> getDistricts(String zone) =>
      instance.get('/health-facilities/districts?zone=${Uri.encodeComponent(zone)}').then((data) => 
          (data as List<dynamic>).cast<String>());

  static Future<Map<String, dynamic>> getHealthFacilityById(String id) async {
    final data = await instance.get('/health-facilities/$id');
    return (data as Map<String, dynamic>?) ?? {};
  }

  static Future<Map<String, dynamic>> updateHealthFacility(
      String id, Map<String, dynamic> body) async {
    final data = await instance.put('/health-facilities/$id', body);
    return (data as Map<String, dynamic>?) ?? {};
  }

  static Future<void> deleteHealthFacility(String id) =>
      instance.delete('/health-facilities/$id');

  static Future<List<String>> getFacilityTypes() =>
      instance.get('/health-facilities/facility-types').then((data) => 
          (data as List<dynamic>).cast<String>());

  static Future<List<String>> getManagingAuthorities() =>
      instance.get('/health-facilities/managing-authorities').then((data) => 
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

  // ── Health Check History ──────────────────────────────────────────────────

  /// Create a new health check history record
  static Future<Map<String, dynamic>> createHealthCheckHistory(
    Map<String, dynamic> data,
  ) async {
    final result = await instance.post('/health-check-history', data);
    return (result as Map<String, dynamic>?) ?? {};
  }

  /// Save the current user's WHO health-check result to backend history.
  static Future<Map<String, dynamic>> saveHealthCheckResultToHistory({
    required String type,
    required Map<String, dynamic> result,
    required List<Map<String, dynamic>> questions,
    required Map<int, int> answers,
  }) async {
    // Create a map of question IDs to question text for faster lookup
    final questionMap = <dynamic, String>{};
    for (final q in questions) {
      final id = q['id'];
      final text = q['questionText']?.toString() ?? 
                   q['question']?.toString() ?? 
                   q['text']?.toString() ?? '';
      if (text.isNotEmpty) {
        questionMap[id] = text;
      }
    }

    debugPrint('=== SYMPTOM EXTRACTION DEBUG ===');
    debugPrint('Total questions: ${questions.length}');
    debugPrint('Question map size: ${questionMap.length}');
    debugPrint('Total answers: ${answers.length}');
    debugPrint('Questions with YES answers: ${answers.entries.where((e) => e.value == 1).length}');

    final symptoms = <String>[];
    for (final entry in answers.entries) {
      if (entry.value == 1) {
        // Try to find the question text - check multiple key formats
        String? questionText;
        
        // Try direct key match
        if (questionMap.containsKey(entry.key)) {
          questionText = questionMap[entry.key];
        }
        // Try string key match
        else if (questionMap.containsKey(entry.key.toString())) {
          questionText = questionMap[entry.key.toString()];
        }
        // Try int key match
        else {
          final intKey = int.tryParse(entry.key.toString());
          if (intKey != null && questionMap.containsKey(intKey)) {
            questionText = questionMap[intKey];
          }
        }
        
        debugPrint('Answer ID: ${entry.key}, Found: ${questionText != null}, Text: $questionText');
        
        if (questionText != null && questionText.isNotEmpty) {
          symptoms.add(questionText);
        }
      }
    }

    debugPrint('Extracted symptoms: ${symptoms.length}');
    for (final symptom in symptoms) {
      debugPrint('  - $symptom');
    }
    debugPrint('=== END DEBUG ===');

    final maxScore = _numberValue(result['maxScore']);
    final fallbackMaxScore = questions.fold<double>(
      0,
      (total, question) => total + _numberValue(question['weight']),
    );

    final payload = {
      'type': type,
      'riskLevel': _healthCheckRiskLevel(result['riskLevel']),
      'score': _numberValue(result['score']),
      'maxScore': maxScore > 0 ? maxScore : fallbackMaxScore,
      'percentage': _numberValue(result['percentage']),
      'message': result['message']?.toString() ?? '',
      'symptoms': symptoms.isNotEmpty ? symptoms : [],
      'answers': {
        for (final entry in answers.entries) entry.key.toString(): entry.value,
      },
    };

    debugPrint('Payload symptoms: ${payload['symptoms']}');
    return createHealthCheckHistory(payload);
  }

  static double _numberValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _healthCheckRiskLevel(dynamic value) {
    final level = value?.toString().toLowerCase() ?? '';
    if (level.contains('seek')) return 'Seek Help Immediately';
    if (level.contains('high')) return 'High Risk';
    if (level.contains('medium') || level.contains('moderate')) return 'Moderate Risk';
    return 'Low Risk';
  }

  /// Get health check history for the current user
  static Future<Map<String, dynamic>> getMyHealthCheckHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await instance.get(
      '/health-check-history/my-history?limit=$limit&offset=$offset',
    );
    return (data as Map<String, dynamic>?) ?? {};
  }

  /// Get health check history for a specific user (clinician/admin only)
  static Future<Map<String, dynamic>> getUserHealthCheckHistory(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await instance.get(
      '/health-check-history/user/$userId?limit=$limit&offset=$offset',
    );
    return (data as Map<String, dynamic>?) ?? {};
  }

  /// Get the latest health check for a user
  static Future<Map<String, dynamic>> getLatestHealthCheck(String userId) async {
    final data = await instance.get('/health-check-history/user/$userId/latest');
    return (data as Map<String, dynamic>?) ?? {};
  }

  /// Get health check statistics for a user
  static Future<Map<String, dynamic>> getHealthCheckStatistics(String userId) async {
    final data = await instance.get('/health-check-history/user/$userId/statistics');
    return (data as Map<String, dynamic>?) ?? {};
  }

  /// Get a single health check record by ID
  static Future<Map<String, dynamic>> getHealthCheckRecord(String id) async {
    final data = await instance.get('/health-check-history/$id');
    return (data as Map<String, dynamic>?) ?? {};
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

  /// Upload or remove a profile photo
  /// Pass a base64 data URL (e.g., 'data:image/jpeg;base64,...') to upload
  /// Pass null to remove the photo
  /// Returns the new photo URL or null if removed
  static Future<String?> uploadProfilePhoto(String? photoDataUrl) async {
    final token = await instance.getToken();
    if (token == null) throw ApiException(401, 'Not authenticated');

    final response = await http.post(
      Uri.parse('$_base/auth/profile-photo'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'photoDataUrl': photoDataUrl,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(response.statusCode, 'Failed to upload profile photo');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>?;
    return data?['profilePhotoUrl'] as String?;
  }
}

