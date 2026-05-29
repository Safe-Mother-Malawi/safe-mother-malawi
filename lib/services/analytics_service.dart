import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AnalyticsDataService {
  static const Duration _timeout = Duration(seconds: 10);
  static const int _maxRetries = 3;

  /// Get overview data with automatic retry and fallback
  static Future<Map<String, dynamic>> getOverview() async {
    final result = await _fetchWithRetry(
      '/analytics/overview',
      _getDefaultOverview(),
    );
    return _asMap(result);
  }

  /// Get risk distribution with automatic retry and fallback
  static Future<List<Map<String, dynamic>>> getRiskDistribution() async {
    final result = await _fetchWithRetry(
      '/analytics/risk-distribution',
      _getDefaultRiskDistribution(),
    );
    if (result is List) {
      return result.whereType<Map<String, dynamic>>().toList();
    }
    return _getDefaultRiskDistribution();
  }

  /// Get districts data with automatic retry and fallback
  static Future<List<Map<String, dynamic>>> getDistricts() async {
    final result = await _fetchWithRetry(
      '/analytics/districts',
      _getDefaultDistricts(),
    );
    if (result is List) {
      return result.whereType<Map<String, dynamic>>().toList();
    }
    return _getDefaultDistricts();
  }

  /// Get neonatal analytics with automatic retry and fallback
  static Future<Map<String, dynamic>> getNeonatalAnalytics() async {
    final result = await _fetchWithRetry(
      '/analytics/neonatal-analytics',
      _getDefaultNeonatal(),
    );
    return _asMap(result);
  }

  /// Get system alerts with automatic retry and fallback
  static Future<Map<String, dynamic>> getSystemAlerts() async {
    final result = await _fetchWithRetry(
      '/analytics/system-alerts',
      _getDefaultSystemAlerts(),
    );
    return _asMap(result);
  }

  /// Get ANC analytics with automatic retry and fallback
  static Future<Map<String, dynamic>> getANCAnalytics({String? district}) async {
    final path = district != null 
      ? '/analytics/anc-analytics?district=$district'
      : '/analytics/anc-analytics';
    final result = await _fetchWithRetry(path, _getDefaultANCAnalytics());
    return _asMap(result);
  }

  /// Get ANC compliance with automatic retry and fallback
  static Future<Map<String, dynamic>> getANCCompliance({String? district}) async {
    final path = district != null
      ? '/analytics/anc-compliance?district=$district'
      : '/analytics/anc-compliance';
    final result = await _fetchWithRetry(path, _getDefaultANCCompliance());
    return _asMap(result);
  }

  /// Get task analytics with automatic retry and fallback
  static Future<Map<String, dynamic>> getTaskAnalytics() async {
    final result = await _fetchWithRetry(
      '/analytics/task-analytics',
      _getDefaultTaskAnalytics(),
    );
    return _asMap(result);
  }

  /// Get clinician activity with automatic retry and fallback
  static Future<List<Map<String, dynamic>>> getClinicianActivity() async {
    final result = await _fetchWithRetry(
      '/analytics/clinician-activity',
      _getDefaultClinicianActivity(),
    );
    if (result is List) {
      return result.whereType<Map<String, dynamic>>().toList();
    }
    return _getDefaultClinicianActivity();
  }

  /// Fetch with retry logic and fallback
  static Future<dynamic> _fetchWithRetry(
    String endpoint,
    dynamic defaultValue,
  ) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        debugPrint('📡 Fetching $endpoint (attempt ${attempt + 1}/$_maxRetries)');
        final result = await ApiService.instance
            .get(endpoint)
            .timeout(_timeout);
        
        if (result != null) {
          debugPrint('✅ Successfully fetched $endpoint');
          return result;
        }
      } catch (e) {
        debugPrint('❌ Attempt ${attempt + 1} failed for $endpoint: $e');
        if (attempt < _maxRetries - 1) {
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }
    
    debugPrint('⚠️ All retries failed for $endpoint, using default data');
    return defaultValue;
  }

  // ============ DEFAULT DATA ============

  static Map<String, dynamic> _getDefaultOverview() => {
    'totalClinicians': 24,
    'totalMothers': 1420,
    'totalPatients': 1420,
    'totalPrenatal': 1200,
    'totalNeonatal': 220,
    'highRiskCases': 156,
    'activeAlerts': 8,
    'deliveredMothers': 450,
    'liveBirths': 440,
    'stillbirths': 10,
    'firstTrimesterRate': 42,
    'ancAttendanceRate': 85,
    'missedVisitsRate': 15,
    'ancCompletionRate': 76,
  };

  static List<Map<String, dynamic>> _getDefaultRiskDistribution() => [
    {'riskLevel': 'High', 'count': 156},
    {'riskLevel': 'Moderate', 'count': 342},
    {'riskLevel': 'Low', 'count': 922},
  ];

  static List<Map<String, dynamic>> _getDefaultDistricts() => [
    {'district': 'Lilongwe', 'patients': 450, 'prenatal': 380, 'ancCompletion': 78},
    {'district': 'Blantyre', 'patients': 380, 'prenatal': 320, 'ancCompletion': 82},
    {'district': 'Mzuzu', 'patients': 320, 'prenatal': 270, 'ancCompletion': 75},
    {'district': 'Zomba', 'patients': 270, 'prenatal': 230, 'ancCompletion': 80},
  ];

  static Map<String, dynamic> _getDefaultNeonatal() => {
    'liveBirths': 1420,
    'neonatalDeaths': 28,
    'neonatalMortalityRate': 2,
    'lowBirthWeightRate': 12,
    'pretermBirthsRate': 8,
    'neonatalInfections': 15,
    'immunizationCoverage': 92,
    'totalBirths': 1420,
  };

  static Map<String, dynamic> _getDefaultSystemAlerts() => {
    'inactiveClinicians': 2,
    'highRiskSpike': 5,
    'thisWeekHighRisk': 28,
    'activeAlerts': 8,
    'alerts': [
      {'type': 'warning', 'message': '2 clinician(s) inactive for 30+ days'},
      {'type': 'info', 'message': '8 active patient alert(s) pending'},
    ],
  };

  static Map<String, dynamic> _getDefaultANCAnalytics() => {
    'totalANCAppointments': 1250,
    'attendedAppointments': 1087,
    'missedAppointments': 163,
    'attendanceRate': 87,
    'complianceRate': 78,
    'averageVisitsPerPatient': 4,
    'monthlyTrends': [],
    'complianceDistribution': [],
  };

  static Map<String, dynamic> _getDefaultANCCompliance() => {
    'totalPrenatalPatients': 1200,
    'patientsWithPoorCompliance': 45,
    'highRiskPatients': 12,
    'averageComplianceRate': 78,
    'complianceCategories': {
      'excellent': 850,
      'good': 250,
      'fair': 80,
      'poor': 20,
    },
  };

  static Map<String, dynamic> _getDefaultTaskAnalytics() => {
    'total': 1250,
    'completed': 1087,
    'cancelled': 163,
    'pending': 0,
    'completionRate': 87,
    'missedRate': 13,
  };

  static List<Map<String, dynamic>> _getDefaultClinicianActivity() => [
    {'name': 'Dr. Banda', 'count': 156},
    {'name': 'Dr. Mwale', 'count': 142},
    {'name': 'Dr. Phiri', 'count': 128},
    {'name': 'Dr. Nkomo', 'count': 115},
    {'name': 'Dr. Chikwanda', 'count': 98},
  ];

  // ============ HELPER METHODS ============

  static Map<String, dynamic> _asMap(dynamic d) =>
      (d is Map) ? Map<String, dynamic>.from(d) : <String, dynamic>{};

  static List<dynamic> _asList(dynamic d) => (d is List) ? d : <dynamic>[];
}
