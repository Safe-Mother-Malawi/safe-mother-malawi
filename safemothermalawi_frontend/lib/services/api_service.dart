import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../state/user_store.dart';

/// Central API service — all HTTP calls go through here.
/// Base URL points to the NestJS backend.
class ApiService {
  /// On web (browser) localhost works fine.
  /// On a physical Android/iOS device, localhost refers to the device itself —
  /// use the PC's LAN IP so the phone can reach the backend over Wi-Fi.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/v1';
    // ngrok tunnel — works from any network (Wi-Fi, mobile data, USB)
    // Update this URL when ngrok restarts (or upgrade to ngrok paid for a stable domain)
    return 'https://wisdom-thermal-gradation.ngrok-free.dev/api/v1';
  }

  // ── Token management ──────────────────────────────────────────────────────

  static String? _accessToken;

  static Future<void> saveTokens(String access, String refresh) async {
    _accessToken = access;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  static Future<String?> getAccessToken() async {
    if (_accessToken != null) return _accessToken;
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    return _accessToken;
  }

  static Future<void> clearTokens() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // ── HTTP helpers ──────────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      // Required to bypass ngrok's browser warning page on free tier
      'ngrok-skip-browser-warning': 'true',
    };
    if (auth) {
      final token = await getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static dynamic _parse(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = body['message'] ?? 'Request failed (${res.statusCode})';
    throw ApiException(msg is List ? (msg as List).join(', ') : msg.toString(), res.statusCode);
  }

  static Future<dynamic> get(String path) async {
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    return _parse(res);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));
    return _parse(res);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));
    return _parse(res);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));
    return _parse(res);
  }

  static Future<void> delete(String path) async {
    final res = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      throw ApiException(body['message']?.toString() ?? 'Delete failed', res.statusCode);
    }
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    final data = await post('/auth/login', {'identifier': identifier, 'password': password}, auth: false);
    await saveTokens(data['tokens']['accessToken'], data['tokens']['refreshToken']);
    final user = data['user'] as Map<String, dynamic>;
    // Save to UserStore so all profile screens can read it immediately
    UserStore.instance.save(user);
    return user;
  }

  /// Register a new prenatal or neonatal patient account.
  /// Returns the created user object on success.
  static Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final data = await post('/auth/register', payload, auth: false);
    // Save tokens so the user is immediately logged in after registration
    if (data['tokens'] != null) {
      await saveTokens(
        data['tokens']['accessToken'],
        data['tokens']['refreshToken'],
      );
    }
    final user = data['user'] as Map<String, dynamic>;
    UserStore.instance.save(user);
    return user;
  }

  static Future<void> logout() async {
    try { await post('/auth/logout', {}); } catch (_) {}
    await clearTokens();
    UserStore.instance.clear();
  }

  static Future<Map<String, dynamic>> getMe() async {
    final user = (await get('/auth/me')) as Map<String, dynamic>;
    // Refresh UserStore with latest server data
    UserStore.instance.save(user);
    return user;
  }

  /// Update the currently logged-in user's own profile.
  static Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) async {
    final updated = (await patch('/auth/me', data)) as Map<String, dynamic>;
    // Persist updated data into UserStore immediately
    UserStore.instance.save(updated);
    return updated;
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAnalyticsOverview() async {
    return (await get('/analytics/overview')) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getSystemAlerts() async {
    return (await get('/analytics/system-alerts')) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getTaskAnalytics() async {
    return (await get('/analytics/task-analytics')) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getRiskDistribution() async {
    return (await get('/analytics/risk-distribution')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getRegistrationTrends() async {
    return (await get('/analytics/registrations')) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAllDistrictStats() async {
    return (await get('/analytics/districts')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getDistrictStats(String district) async {
    return (await get('/analytics/districts/$district')) as Map<String, dynamic>;
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getUsers({String? role, bool? isActive, String? search}) async {
    final params = <String>[];
    if (role != null) params.add('role=$role');
    if (isActive != null) params.add('isActive=$isActive');
    if (search != null && search.isNotEmpty) params.add('search=${Uri.encodeComponent(search)}');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return (await get('/users$query')) as List<dynamic>;
  }

  /// Fetch mobile patient accounts (prenatal + neonatal) — for system users list.
  static Future<List<dynamic>> getPatientUsers({String? role, bool? isActive, String? search}) async {
    final params = <String>[];
    if (role != null) params.add('role=$role');
    if (isActive != null) params.add('isActive=$isActive');
    if (search != null && search.isNotEmpty) params.add('search=${Uri.encodeComponent(search)}');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return (await get('/users/patients$query')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    // Admin creates admin/dho via POST /users/dho
    // DHO creates clinician via POST /users/clinician
    final role = data['role']?.toString().toLowerCase() ?? '';
    final endpoint = (role == 'clinician') ? '/users/clinician' : '/users/dho';

    // Strip 'role' from clinician payload — server enforces it server-side
    // (sending it causes 400 "property role should not exist")
    final payload = Map<String, dynamic>.from(data);
    if (endpoint == '/users/clinician') payload.remove('role');

    return (await post(endpoint, payload)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> data) async {
    return (await patch('/users/$id', data)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> setUserStatus(String id, bool isActive) async {
    return (await patch('/users/$id/status', {'isActive': isActive})) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> resetUserPassword(String id, String password) async {
    return (await patch('/users/$id/password', {'password': password})) as Map<String, dynamic>;
  }

  static Future<void> deleteUser(String id) async {
    await delete('/users/$id');
  }

  // ── Patients ──────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getPrenatalPatients({String? search}) async {
    final q = (search != null && search.isNotEmpty) ? '?search=${Uri.encodeComponent(search)}' : '';
    return (await get('/patients/prenatal$q')) as List<dynamic>;
  }

  static Future<List<dynamic>> getNeonatalPatients({String? search}) async {
    final q = (search != null && search.isNotEmpty) ? '?search=${Uri.encodeComponent(search)}' : '';
    return (await get('/patients/neonatal$q')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createPrenatalPatient(Map<String, dynamic> data) async {
    return (await post('/patients/prenatal', data)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updatePrenatalPatient(String id, Map<String, dynamic> data) async {
    return (await put('/patients/prenatal/$id', data)) as Map<String, dynamic>;
  }

  static Future<void> deletePrenatalPatient(String id) async {
    await delete('/patients/prenatal/$id');
  }

  static Future<Map<String, dynamic>> createNeonatalPatient(Map<String, dynamic> data) async {
    return (await post('/patients/neonatal', data)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateNeonatalPatient(String id, Map<String, dynamic> data) async {
    return (await put('/patients/neonatal/$id', data)) as Map<String, dynamic>;
  }

  static Future<void> deleteNeonatalPatient(String id) async {
    await delete('/patients/neonatal/$id');
  }

  static Future<Map<String, dynamic>> getPatientHistory(String patientId) async {
    return (await get('/patients/prenatal/$patientId/history')) as Map<String, dynamic>;
  }

  // ── Alerts ────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getActiveAlerts() async {
    return (await get('/alerts/active')) as List<dynamic>;
  }

  static Future<List<dynamic>> getAllAlerts() async {
    return (await get('/alerts')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> markAlertAttended(String id) async {
    return (await patch('/alerts/$id/attended', {})) as Map<String, dynamic>;
  }

  // ── Appointments ──────────────────────────────────────────────────────────

  static Future<List<dynamic>> getAppointments({String? date, bool upcoming = false}) async {
    final params = <String>[];
    if (date != null) params.add('date=$date');
    if (upcoming) params.add('upcoming=true');
    final q = params.isEmpty ? '' : '?${params.join('&')}';
    return (await get('/appointments$q')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> data) async {
    return (await post('/appointments', data)) as Map<String, dynamic>;
  }

  // ── Risk assessments ──────────────────────────────────────────────────────

  static Future<List<dynamic>> getHighRiskCases() async {
    return (await get('/analytics/high-risk-cases')) as List<dynamic>;
  }

  static Future<List<dynamic>> getRiskAssessments() async {
    return (await get('/risk-assessments')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> submitRiskAssessment(Map<String, dynamic> data) async {
    return (await post('/risk-assessments', data)) as Map<String, dynamic>;
  }

  // ── Activity logs ─────────────────────────────────────────────────────────

  static Future<List<dynamic>> getActivityLogs({int limit = 100}) async {
    return (await get('/activity-logs?limit=$limit')) as List<dynamic>;
  }

  // ── Reports ───────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getReports({String? district}) async {
    final q = district != null ? '?district=${Uri.encodeComponent(district)}' : '';
    return (await get('/reports$q')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> generateReport(Map<String, dynamic> data) async {
    return (await post('/reports/generate', data)) as Map<String, dynamic>;
  }

  static Future<void> deleteReport(String id) async {
    await delete('/reports/$id');
  }

  /// Returns the raw bytes of the PDF for a given report id.
  static Future<List<int>> downloadReportPdf(String id) async {
    final token = await getAccessToken();
    final res = await http.get(
      Uri.parse('$baseUrl/reports/$id/pdf'),
      headers: {
        'Authorization': 'Bearer ${token ?? ''}',
      },
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return res.bodyBytes;
    throw ApiException('Failed to download report (${res.statusCode})', res.statusCode);
  }

  /// Export audit data — returns raw bytes in the requested format.
  static Future<List<int>> exportData({
    String format = 'CSV',
    String dataType = 'All Data',
    String? district,
    String dateRange = 'Last 30 days',
  }) async {
    final token = await getAccessToken();
    final params = [
      'format=${Uri.encodeComponent(format)}',
      'dataType=${Uri.encodeComponent(dataType)}',
      'dateRange=${Uri.encodeComponent(dateRange)}',
      if (district != null && district != 'All Districts')
        'district=${Uri.encodeComponent(district)}',
    ];
    final res = await http.get(
      Uri.parse('$baseUrl/reports/export?${params.join('&')}'),
      headers: {'Authorization': 'Bearer ${token ?? ''}'},
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return res.bodyBytes;
    throw ApiException('Export failed (${res.statusCode})', res.statusCode);
  }

  // ── Analytics generation ──────────────────────────────────────────────────

  /// Fetches all analytics data in one call for the Generate Analytics screen.
  static Future<Map<String, dynamic>> generateAnalytics({
    String? district,
    String? riskLevel,
  }) async {
    final results = await Future.wait([
      getAnalyticsOverview(),
      getRiskDistribution(),
      getRegistrationTrends(),
      getSystemAlerts(),
      getTaskAnalytics(),
      if (district != null && district != 'All Districts')
        getDistrictStats(district)
      else
        Future.value(<String, dynamic>{}),
    ]);
    return {
      'overview':       results[0],
      'riskDist':       results[1],
      'trends':         results[2],
      'systemAlerts':   results[3],
      'taskAnalytics':  results[4],
      'districtStats':  results[5],
      'generatedAt':    DateTime.now().toIso8601String(),
      'district':       district ?? 'All Districts',
      'riskLevel':      riskLevel ?? 'All',
    };
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  static Future<List<dynamic>> getNotifications() async {
    return (await get('/notifications')) as List<dynamic>;
  }

  static Future<void> markNotificationRead(String id) async {
    await patch('/notifications/$id/read', {});
  }

  static Future<void> markAllNotificationsRead() async {
    await patch('/notifications/mark-all-read', {});
  }

  static Future<void> deleteNotification(String id) async {
    await delete('/notifications/$id');
  }

  // ── Tracking — Feeding ────────────────────────────────────────────────────

  static Future<List<dynamic>> getFeedingLogs(String neonatalPatientId) async {
    return (await get('/tracking/feeding/$neonatalPatientId')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> logFeeding({
    required String neonatalPatientId,
    required String feedType,
    int? volumeMl,
    int? durationMin,
    required String feedTime,
  }) async {
    final body = <String, dynamic>{
      'neonatalPatientId': neonatalPatientId,
      'feedType': feedType,
      'feedTime': feedTime,
    };
    if (volumeMl != null) body['volumeMl'] = volumeMl;
    if (durationMin != null) body['durationMin'] = durationMin;
    return (await post('/tracking/feeding', body)) as Map<String, dynamic>;
  }

  static Future<void> deleteFeedingLog(String id) async {
    await delete('/tracking/feeding/$id');
  }

  // ── Tracking — Sleep ──────────────────────────────────────────────────────

  static Future<List<dynamic>> getSleepLogs(String neonatalPatientId) async {
    return (await get('/tracking/sleep/$neonatalPatientId')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> logSleep({
    required String neonatalPatientId,
    required String sleepType,
    required String startTime,
    required String endTime,
  }) async {
    return (await post('/tracking/sleep', {
      'neonatalPatientId': neonatalPatientId,
      'sleepType': sleepType,
      'startTime': startTime,
      'endTime': endTime,
    })) as Map<String, dynamic>;
  }

  static Future<void> deleteSleepLog(String id) async {
    await delete('/tracking/sleep/$id');
  }

  // ── Tracking — Vaccines ───────────────────────────────────────────────────

  static Future<List<dynamic>> getVaccines(String neonatalPatientId) async {
    return (await get('/tracking/vaccines/$neonatalPatientId')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> markVaccineGiven(String vaccineId) async {
    return (await patch('/tracking/vaccines/$vaccineId/given', {})) as Map<String, dynamic>;
  }

  // ── WHO Health Check ──────────────────────────────────────────────────────

  /// Fetch WHO-based questions auto-detected for the logged-in user's stage.
  static Future<Map<String, dynamic>> getWhoQuestions() async {
    return (await get('/who/questions')) as Map<String, dynamic>;
  }

  /// Submit YES/NO answers and get score + risk level.
  static Future<Map<String, dynamic>> submitWhoAssessment(
      List<Map<String, dynamic>> answers) async {
    return (await post('/who/assessment', {'answers': answers})) as Map<String, dynamic>;
  }

  // ── Health Facilities ─────────────────────────────────────────────────────

  static Future<List<dynamic>> getRegions() async {
    return (await get('/health-facilities/regions')) as List<dynamic>;
  }

  static Future<List<dynamic>> getAllDistricts() async {
    return (await get('/health-facilities/all-districts')) as List<dynamic>;
  }

  static Future<List<dynamic>> getZones(String region) async {
    return (await get('/health-facilities/zones?region=${Uri.encodeComponent(region)}')) as List<dynamic>;
  }

  static Future<List<dynamic>> getDistricts(String zone) async {
    return (await get('/health-facilities/districts?zone=${Uri.encodeComponent(zone)}')) as List<dynamic>;
  }

  static Future<List<dynamic>> getFacilitiesByDistrict(String district) async {
    return (await get('/health-facilities?district=${Uri.encodeComponent(district)}')) as List<dynamic>;
  }

  static Future<Map<String, dynamic>?> lookupFacility(String name) async {
    try {
      return (await get('/health-facilities/lookup?name=${Uri.encodeComponent(name)}')) as Map<String, dynamic>?;
    } catch (_) { return null; }
  }

  static Future<List<dynamic>> getAllFacilities() async {
    return (await get('/health-facilities')) as List<dynamic>;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
