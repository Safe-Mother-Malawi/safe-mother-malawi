import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Referral reason enum
enum ReferralReason {
  hypertension,
  bleeding,
  infection,
  fetalDistress,
  prematureLabor,
  placentalIssues,
  neonatalEmergency,
  neonatalInfection,
  lowBirthWeight,
  respiratoryDistress,
  jaundice,
  other,
}

/// Referral status enum
enum ReferralStatus {
  pending,
  accepted,
  inTransit,
  arrived,
  completed,
  rejected,
  cancelled,
}

/// Transport mode enum
enum TransportMode {
  ambulance,
  personalVehicle,
  motorcycle,
  walking,
  other,
}

/// Models for referral feature
class Referral {
  final String id;
  final String referralCode;
  final String patientName;
  final String? patientContact;
  final String? patientAge;
  final String reason;
  final String status;
  final String clinicalSummary;
  final String? urgencyNotes;
  final String referringFacilityId;
  final String receivingFacilityId;
  final String referringClinicianId;
  final String? receivingClinicianId;
  final String? transportMode;
  final String? transportProvider;
  final String? transportContact;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final String? transportNotes;
  final bool acceptedByReceivingFacility;
  final DateTime? acceptedAt;
  final String? rejectionReason;
  final DateTime? rejectedAt;
  final String? treatmentOutcome;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? referringFacility;
  final Map<String, dynamic>? receivingFacility;
  final Map<String, dynamic>? referringClinician;
  final Map<String, dynamic>? receivingClinician;

  Referral({
    required this.id,
    required this.referralCode,
    required this.patientName,
    this.patientContact,
    this.patientAge,
    required this.reason,
    required this.status,
    required this.clinicalSummary,
    this.urgencyNotes,
    required this.referringFacilityId,
    required this.receivingFacilityId,
    required this.referringClinicianId,
    this.receivingClinicianId,
    this.transportMode,
    this.transportProvider,
    this.transportContact,
    this.departureTime,
    this.arrivalTime,
    this.transportNotes,
    this.acceptedByReceivingFacility = false,
    this.acceptedAt,
    this.rejectionReason,
    this.rejectedAt,
    this.treatmentOutcome,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
    this.referringFacility,
    this.receivingFacility,
    this.referringClinician,
    this.receivingClinician,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as String,
      referralCode: json['referralCode'] as String,
      patientName: json['patientName'] as String,
      patientContact: json['patientContact'] as String?,
      patientAge: json['patientAge'] as String?,
      reason: json['reason'] as String,
      status: json['status'] as String,
      clinicalSummary: json['clinicalSummary'] as String,
      urgencyNotes: json['urgencyNotes'] as String?,
      referringFacilityId: json['referringFacilityId'] as String,
      receivingFacilityId: json['receivingFacilityId'] as String,
      referringClinicianId: json['referringClinicianId'] as String,
      receivingClinicianId: json['receivingClinicianId'] as String?,
      transportMode: json['transportMode'] as String?,
      transportProvider: json['transportProvider'] as String?,
      transportContact: json['transportContact'] as String?,
      departureTime: json['departureTime'] != null
          ? DateTime.parse(json['departureTime'] as String)
          : null,
      arrivalTime: json['arrivalTime'] != null
          ? DateTime.parse(json['arrivalTime'] as String)
          : null,
      transportNotes: json['transportNotes'] as String?,
      acceptedByReceivingFacility: json['acceptedByReceivingFacility'] as bool? ?? false,
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'] as String)
          : null,
      treatmentOutcome: json['treatmentOutcome'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      referringFacility: json['referringFacility'] as Map<String, dynamic>?,
      receivingFacility: json['receivingFacility'] as Map<String, dynamic>?,
      referringClinician: json['referringClinician'] as Map<String, dynamic>?,
      receivingClinician: json['receivingClinician'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'referralCode': referralCode,
    'patientName': patientName,
    'patientContact': patientContact,
    'patientAge': patientAge,
    'reason': reason,
    'status': status,
    'clinicalSummary': clinicalSummary,
    'urgencyNotes': urgencyNotes,
    'referringFacilityId': referringFacilityId,
    'receivingFacilityId': receivingFacilityId,
    'referringClinicianId': referringClinicianId,
    'receivingClinicianId': receivingClinicianId,
    'transportMode': transportMode,
    'transportProvider': transportProvider,
    'transportContact': transportContact,
    'departureTime': departureTime?.toIso8601String(),
    'arrivalTime': arrivalTime?.toIso8601String(),
    'transportNotes': transportNotes,
    'acceptedByReceivingFacility': acceptedByReceivingFacility,
    'acceptedAt': acceptedAt?.toIso8601String(),
    'rejectionReason': rejectionReason,
    'rejectedAt': rejectedAt?.toIso8601String(),
    'treatmentOutcome': treatmentOutcome,
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'referringFacility': referringFacility,
    'receivingFacility': receivingFacility,
    'referringClinician': referringClinician,
    'receivingClinician': receivingClinician,
  };
}

class CreateReferralRequest {
  final String patientName;
  final String? patientContact;
  final String? patientAge;
  final String reason;
  final String referringFacilityId;
  final String receivingFacilityId;
  final String clinicalSummary;
  final String? urgencyNotes;
  final String? transportMode;

  CreateReferralRequest({
    required this.patientName,
    this.patientContact,
    this.patientAge,
    required this.reason,
    required this.referringFacilityId,
    required this.receivingFacilityId,
    required this.clinicalSummary,
    this.urgencyNotes,
    this.transportMode,
  });

  Map<String, dynamic> toJson() => {
    'patientName': patientName,
    'patientContact': patientContact,
    'patientAge': patientAge,
    'reason': reason,
    'referringFacilityId': referringFacilityId,
    'receivingFacilityId': receivingFacilityId,
    'clinicalSummary': clinicalSummary,
    'urgencyNotes': urgencyNotes,
    'transportMode': transportMode,
  };
}

/// Service for managing referrals
class ReferralService {
  ReferralService._();
  static final ReferralService instance = ReferralService._();

  static const String _endpoint = '/referrals';

  /// Create a new referral
  Future<Referral> createReferral(CreateReferralRequest request) async {
    try {
      final token = await ApiService.instance.getToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}$_endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        return Referral.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all referrals
  Future<List<Referral>> getAllReferrals() async {
    try {
      final token = await ApiService.instance.getToken();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}$_endpoint'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Referral.fromJson(json)).toList();
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get referrals by facility
  Future<List<Referral>> getReferralsByFacility(
    String facilityId, {
    String type = 'receiving',
  }) async {
    try {
      final token = await ApiService.instance.getToken();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}$_endpoint/facility/$facilityId?type=$type'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Referral.fromJson(json)).toList();
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get referral by ID
  Future<Referral> getReferralById(String id) async {
    try {
      final token = await ApiService.instance.getToken();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}$_endpoint/$id'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Referral.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get referral by code
  Future<Referral> getReferralByCode(String code) async {
    try {
      final token = await ApiService.instance.getToken();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}$_endpoint/code/$code'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Referral.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Accept a referral
  Future<Referral> acceptReferral(String id) async {
    try {
      final token = await ApiService.instance.getToken();
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}$_endpoint/$id/accept'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Referral.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reject a referral
  Future<Referral> rejectReferral(String id, String rejectionReason) async {
    try {
      final token = await ApiService.instance.getToken();
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}$_endpoint/$id/reject'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'rejectionReason': rejectionReason}),
      );

      if (response.statusCode == 200) {
        return Referral.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update transport status
  Future<Referral> updateTransportStatus(
    String id,
    String status, {
    DateTime? timestamp,
  }) async {
    try {
      final token = await ApiService.instance.getToken();
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}$_endpoint/$id/transport'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
          if (timestamp != null) 'timestamp': timestamp.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return Referral.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Complete a referral
  Future<Referral> completeReferral(String id, String treatmentOutcome) async {
    try {
      final token = await ApiService.instance.getToken();
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}$_endpoint/$id/complete'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'treatmentOutcome': treatmentOutcome}),
      );

      if (response.statusCode == 200) {
        return Referral.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel a referral
  Future<Referral> cancelReferral(String id) async {
    try {
      final token = await ApiService.instance.getToken();
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}$_endpoint/$id/cancel'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Referral.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } catch (e) {
      rethrow;
    }
  }
}
