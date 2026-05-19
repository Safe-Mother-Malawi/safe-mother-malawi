import 'package:flutter/material.dart';

class RiskRecord {
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String role;        // 'prenatal' | 'neonatal'
  final String riskLevel;  // 'Low Risk' | 'Moderate Risk' | 'High Risk...'
  final int    score;
  final String message;
  final DateTime submittedAt;

  RiskRecord({
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.role,
    required this.riskLevel,
    required this.score,
    required this.message,
    required this.submittedAt,
  });

  Color get color {
    if (riskLevel.contains('High') || riskLevel.contains('Immediately')) {
      return const Color(0xFFC62828);
    }
    if (riskLevel.contains('Moderate') || riskLevel.contains('Monitor')) {
      return const Color(0xFFE65100);
    }
    return const Color(0xFF2E7D32);
  }

  String get formattedDate {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${submittedAt.day} ${months[submittedAt.month - 1]} ${submittedAt.year}';
  }

  Map<String, dynamic> toMap() => {
    'patientId':    patientId,
    'patientName':  patientName,
    'patientPhone': patientPhone,
    'role':         role,
    'riskLevel':    riskLevel,
    'score':        score,
    'message':      message,
    'submittedAt':  submittedAt.toIso8601String(),
  };

  factory RiskRecord.fromMap(Map<String, dynamic> m) => RiskRecord(
    patientId:    m['patientId']    as String,
    patientName:  m['patientName']  as String,
    patientPhone: m['patientPhone'] as String,
    role:         m['role']         as String,
    riskLevel:    m['riskLevel']    as String,
    score:        m['score']        as int,
    message:      m['message']      as String,
    submittedAt:  DateTime.parse(m['submittedAt'] as String),
  );
}
