/// WHO ANC Visit Schedule Model
class ANCVisitSchedule {
  final int visitNumber;
  final int targetWeek;
  final String label;
  final String purpose;
  final List<String> checkItems;
  final String riskLevel;

  const ANCVisitSchedule({
    required this.visitNumber,
    required this.targetWeek,
    required this.label,
    required this.purpose,
    required this.checkItems,
    this.riskLevel = 'standard',
  });

  /// Get all WHO recommended ANC visits
  static List<ANCVisitSchedule> getWHOSchedule() {
    return [
      ANCVisitSchedule(
        visitNumber: 1,
        targetWeek: 12,
        label: '≤12 weeks',
        purpose: 'Registration & Risk Screening',
        checkItems: [
          'Medical history',
          'Physical examination',
          'Blood pressure',
          'Urine test',
          'Blood test',
          'Risk assessment',
          'Counseling on nutrition',
        ],
        riskLevel: 'critical',
      ),
      ANCVisitSchedule(
        visitNumber: 2,
        targetWeek: 20,
        label: '20 weeks',
        purpose: 'Growth Monitoring',
        checkItems: [
          'Weight measurement',
          'Blood pressure',
          'Urine test',
          'Fetal heart rate',
          'Fundal height',
          'Ultrasound (if available)',
          'Counseling on danger signs',
        ],
        riskLevel: 'high',
      ),
      ANCVisitSchedule(
        visitNumber: 3,
        targetWeek: 26,
        label: '26 weeks',
        purpose: 'BP & Fetal Checks',
        checkItems: [
          'Blood pressure',
          'Weight measurement',
          'Urine test',
          'Fetal heart rate',
          'Fundal height',
          'Glucose screening',
          'Anemia assessment',
        ],
        riskLevel: 'high',
      ),
      ANCVisitSchedule(
        visitNumber: 4,
        targetWeek: 30,
        label: '30 weeks',
        purpose: 'Danger Sign Screening',
        checkItems: [
          'Blood pressure',
          'Weight measurement',
          'Urine test',
          'Fetal heart rate',
          'Fundal height',
          'Fetal position assessment',
          'Danger signs review',
        ],
        riskLevel: 'standard',
      ),
      ANCVisitSchedule(
        visitNumber: 5,
        targetWeek: 34,
        label: '34 weeks',
        purpose: 'Birth Planning',
        checkItems: [
          'Blood pressure',
          'Weight measurement',
          'Urine test',
          'Fetal heart rate',
          'Fundal height',
          'Fetal position',
          'Birth plan discussion',
          'Delivery location planning',
        ],
        riskLevel: 'standard',
      ),
      ANCVisitSchedule(
        visitNumber: 6,
        targetWeek: 36,
        label: '36 weeks',
        purpose: 'Delivery Preparation',
        checkItems: [
          'Blood pressure',
          'Weight measurement',
          'Urine test',
          'Fetal heart rate',
          'Fundal height',
          'Fetal position',
          'Pelvic examination',
          'Delivery readiness assessment',
        ],
        riskLevel: 'standard',
      ),
      ANCVisitSchedule(
        visitNumber: 7,
        targetWeek: 38,
        label: '38 weeks',
        purpose: 'Final Review',
        checkItems: [
          'Blood pressure',
          'Weight measurement',
          'Urine test',
          'Fetal heart rate',
          'Fundal height',
          'Fetal position',
          'Final counseling',
          'Labor signs education',
        ],
        riskLevel: 'standard',
      ),
      ANCVisitSchedule(
        visitNumber: 8,
        targetWeek: 40,
        label: '40 weeks',
        purpose: 'Post-Date Assessment',
        checkItems: [
          'Blood pressure',
          'Weight measurement',
          'Urine test',
          'Fetal heart rate',
          'Fundal height',
          'Fetal position',
          'Post-date management plan',
          'Induction discussion if needed',
        ],
        riskLevel: 'critical',
      ),
    ];
  }
}

/// ANC Visit Record Model
class ANCVisitRecord {
  final String id;
  final int visitNumber;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String status; // 'scheduled', 'completed', 'missed', 'rescheduled'
  final String? clinicianName;
  final String? clinicianPhone;
  final Map<String, dynamic>? findings;
  final List<String>? completedChecks;
  final String? notes;
  final bool? riskFlagRaised;
  final String? riskNotes;

  ANCVisitRecord({
    required this.id,
    required this.visitNumber,
    required this.scheduledDate,
    this.completedDate,
    this.status = 'scheduled',
    this.clinicianName,
    this.clinicianPhone,
    this.findings,
    this.completedChecks,
    this.notes,
    this.riskFlagRaised,
    this.riskNotes,
  });

  /// Check if visit is overdue
  bool get isOverdue {
    if (status == 'completed' || status == 'missed') return false;
    return DateTime.now().isAfter(scheduledDate.add(const Duration(days: 7)));
  }

  /// Check if visit is due soon (within 7 days)
  bool get isDueSoon {
    if (status != 'scheduled') return false;
    final daysUntil = scheduledDate.difference(DateTime.now()).inDays;
    return daysUntil >= 0 && daysUntil <= 7;
  }

  /// Check if visit is upcoming (within 30 days)
  bool get isUpcoming {
    if (status != 'scheduled') return false;
    final daysUntil = scheduledDate.difference(DateTime.now()).inDays;
    return daysUntil > 7 && daysUntil <= 30;
  }

  factory ANCVisitRecord.fromJson(Map<String, dynamic> json) {
    return ANCVisitRecord(
      id: json['id'] as String? ?? '',
      visitNumber: json['visitNumber'] as int? ?? 0,
      scheduledDate: DateTime.tryParse(json['scheduledDate'] as String? ?? '') ?? DateTime.now(),
      completedDate: json['completedDate'] != null ? DateTime.tryParse(json['completedDate'] as String) : null,
      status: json['status'] as String? ?? 'scheduled',
      clinicianName: json['clinicianName'] as String?,
      clinicianPhone: json['clinicianPhone'] as String?,
      findings: json['findings'] as Map<String, dynamic>?,
      completedChecks: List<String>.from(json['completedChecks'] as List? ?? []),
      notes: json['notes'] as String?,
      riskFlagRaised: json['riskFlagRaised'] as bool?,
      riskNotes: json['riskNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitNumber': visitNumber,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'status': status,
      'clinicianName': clinicianName,
      'clinicianPhone': clinicianPhone,
      'findings': findings,
      'completedChecks': completedChecks,
      'notes': notes,
      'riskFlagRaised': riskFlagRaised,
      'riskNotes': riskNotes,
    };
  }
}

/// ANC Visit Tracker
class ANCVisitTracker {
  final List<ANCVisitRecord> visits;

  ANCVisitTracker({required this.visits});

  /// Get visit completion percentage
  double get completionPercentage {
    if (visits.isEmpty) return 0;
    final completed = visits.where((v) => v.status == 'completed').length;
    return (completed / visits.length) * 100;
  }

  /// Get next due visit
  ANCVisitRecord? get nextDueVisit {
    final scheduled = visits.where((v) => v.status == 'scheduled').toList();
    if (scheduled.isEmpty) return null;
    scheduled.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return scheduled.first;
  }

  /// Get overdue visits
  List<ANCVisitRecord> get overdueVisits {
    return visits.where((v) => v.isOverdue).toList();
  }

  /// Get visits due soon
  List<ANCVisitRecord> get visitsDueSoon {
    return visits.where((v) => v.isDueSoon).toList();
  }

  /// Get upcoming visits
  List<ANCVisitRecord> get upcomingVisits {
    return visits.where((v) => v.isUpcoming).toList();
  }

  /// Get completed visits
  List<ANCVisitRecord> get completedVisits {
    return visits.where((v) => v.status == 'completed').toList();
  }

  /// Get missed visits
  List<ANCVisitRecord> get missedVisits {
    return visits.where((v) => v.status == 'missed').toList();
  }

  /// Get visits with risk flags
  List<ANCVisitRecord> get riskFlaggedVisits {
    return visits.where((v) => v.riskFlagRaised == true).toList();
  }

  /// Get compliance status
  String get complianceStatus {
    final completion = completionPercentage;
    if (completion >= 87.5) return 'Excellent'; // 7/8 visits
    if (completion >= 75) return 'Good'; // 6/8 visits
    if (completion >= 62.5) return 'Fair'; // 5/8 visits
    if (completion >= 50) return 'Poor'; // 4/8 visits
    return 'Very Poor';
  }

  /// Get compliance color
  int get complianceColor {
    final completion = completionPercentage;
    if (completion >= 87.5) return 0xFF4CAF50; // Green
    if (completion >= 75) return 0xFF8BC34A; // Light Green
    if (completion >= 62.5) return 0xFFFFC107; // Amber
    if (completion >= 50) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }
}
