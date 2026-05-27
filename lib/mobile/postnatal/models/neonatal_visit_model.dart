/// WHO Neonatal Follow-Up Visit Schedule Model
class NeonatalVisitSchedule {
  final int visitNumber;
  final int dayAfterBirth;
  final String label;
  final String purpose;
  final List<String> checkItems;
  final String riskLevel;

  const NeonatalVisitSchedule({
    required this.visitNumber,
    required this.dayAfterBirth,
    required this.label,
    required this.purpose,
    required this.checkItems,
    this.riskLevel = 'standard',
  });

  /// Get all WHO recommended neonatal follow-up visits
  static List<NeonatalVisitSchedule> getWHOSchedule() {
    return [
      NeonatalVisitSchedule(
        visitNumber: 1,
        dayAfterBirth: 0,
        label: 'Within 24 hours',
        purpose: 'Initial Assessment & Screening',
        checkItems: [
          'Vital signs (temperature, heart rate, breathing)',
          'Physical examination',
          'Umbilical cord assessment',
          'Feeding assessment',
          'Jaundice screening',
          'Birth defects screening',
          'Mother-baby bonding assessment',
          'Counseling on newborn care',
        ],
        riskLevel: 'critical',
      ),
      NeonatalVisitSchedule(
        visitNumber: 2,
        dayAfterBirth: 3,
        label: 'Day 3',
        purpose: 'Early Follow-Up & Jaundice Check',
        checkItems: [
          'Weight measurement',
          'Jaundice assessment (visual & bilirubin if needed)',
          'Feeding assessment',
          'Umbilical cord care',
          'Vital signs',
          'Skin examination',
          'Breastfeeding support',
          'Danger signs counseling',
        ],
        riskLevel: 'high',
      ),
      NeonatalVisitSchedule(
        visitNumber: 3,
        dayAfterBirth: 7,
        label: 'Day 7',
        purpose: 'First Week Check & Immunization',
        checkItems: [
          'Weight measurement',
          'Vital signs',
          'Umbilical cord healing assessment',
          'Feeding assessment',
          'Jaundice follow-up',
          'Skin examination',
          'BCG & OPV 0 immunization',
          'Vitamin K supplementation check',
          'Exclusive breastfeeding counseling',
        ],
        riskLevel: 'high',
      ),
      NeonatalVisitSchedule(
        visitNumber: 4,
        dayAfterBirth: 14,
        label: 'Day 14',
        purpose: 'Two-Week Check & Immunization',
        checkItems: [
          'Weight measurement',
          'Vital signs',
          'General health assessment',
          'Feeding assessment',
          'Umbilical cord healing status',
          'Skin examination',
          'Pentavalent 1 & OPV 1 immunization',
          'Rotavirus vaccine',
          'Pneumococcal vaccine',
          'Danger signs review',
        ],
        riskLevel: 'standard',
      ),
      NeonatalVisitSchedule(
        visitNumber: 5,
        dayAfterBirth: 28,
        label: 'Day 28',
        purpose: 'One-Month Check & Immunization',
        checkItems: [
          'Weight measurement',
          'Length measurement',
          'Head circumference',
          'Vital signs',
          'General health assessment',
          'Feeding assessment',
          'Developmental milestones check',
          'Pentavalent 2 & OPV 2 immunization',
          'Rotavirus vaccine 2',
          'Pneumococcal vaccine 2',
          'Mother postpartum assessment',
          'Family planning counseling',
        ],
        riskLevel: 'standard',
      ),
    ];
  }
}

/// Neonatal Visit Record Model
class NeonatalVisitRecord {
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
  final List<String>? immunizationsGiven;

  NeonatalVisitRecord({
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
    this.immunizationsGiven,
  });

  /// Check if visit is overdue
  bool get isOverdue {
    if (status == 'completed' || status == 'missed') return false;
    return DateTime.now().isAfter(scheduledDate.add(const Duration(days: 3)));
  }

  /// Check if visit is due soon (within 3 days)
  bool get isDueSoon {
    if (status != 'scheduled') return false;
    final daysUntil = scheduledDate.difference(DateTime.now()).inDays;
    return daysUntil >= 0 && daysUntil <= 3;
  }

  /// Check if visit is upcoming (within 14 days)
  bool get isUpcoming {
    if (status != 'scheduled') return false;
    final daysUntil = scheduledDate.difference(DateTime.now()).inDays;
    return daysUntil > 3 && daysUntil <= 14;
  }

  factory NeonatalVisitRecord.fromJson(Map<String, dynamic> json) {
    return NeonatalVisitRecord(
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
      immunizationsGiven: List<String>.from(json['immunizationsGiven'] as List? ?? []),
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
      'immunizationsGiven': immunizationsGiven,
    };
  }
}

/// Neonatal Visit Tracker
class NeonatalVisitTracker {
  final List<NeonatalVisitRecord> visits;
  final DateTime babyDateOfBirth;

  NeonatalVisitTracker({
    required this.visits,
    required this.babyDateOfBirth,
  });

  /// Get baby age in days
  int get babyAgeDays {
    return DateTime.now().difference(babyDateOfBirth).inDays;
  }

  /// Get baby age in weeks
  int get babyAgeWeeks {
    return (babyAgeDays / 7).floor();
  }

  /// Get baby age in months
  int get babyAgeMonths {
    return (babyAgeDays / 30).floor();
  }

  /// Get formatted baby age string
  String get babyAgeFormatted {
    if (babyAgeDays < 7) {
      return 'Your baby is ${babyAgeDays} day${babyAgeDays == 1 ? '' : 's'} old';
    } else if (babyAgeWeeks < 4) {
      return 'Your baby is ${babyAgeWeeks} week${babyAgeWeeks == 1 ? '' : 's'} old';
    } else {
      return 'Your baby is ${babyAgeMonths} month${babyAgeMonths == 1 ? '' : 's'} old';
    }
  }

  /// Get visit completion percentage
  double get completionPercentage {
    if (visits.isEmpty) return 0;
    final completed = visits.where((v) => v.status == 'completed').length;
    return (completed / visits.length) * 100;
  }

  /// Get next due visit
  NeonatalVisitRecord? get nextDueVisit {
    final scheduled = visits.where((v) => v.status == 'scheduled').toList();
    if (scheduled.isEmpty) return null;
    scheduled.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return scheduled.first;
  }

  /// Get overdue visits
  List<NeonatalVisitRecord> get overdueVisits {
    return visits.where((v) => v.isOverdue).toList();
  }

  /// Get visits due soon
  List<NeonatalVisitRecord> get visitsDueSoon {
    return visits.where((v) => v.isDueSoon).toList();
  }

  /// Get upcoming visits
  List<NeonatalVisitRecord> get upcomingVisits {
    return visits.where((v) => v.isUpcoming).toList();
  }

  /// Get completed visits
  List<NeonatalVisitRecord> get completedVisits {
    return visits.where((v) => v.status == 'completed').toList();
  }

  /// Get missed visits
  List<NeonatalVisitRecord> get missedVisits {
    return visits.where((v) => v.status == 'missed').toList();
  }

  /// Get visits with risk flags
  List<NeonatalVisitRecord> get riskFlaggedVisits {
    return visits.where((v) => v.riskFlagRaised == true).toList();
  }

  /// Get compliance status
  String get complianceStatus {
    final completion = completionPercentage;
    if (completion >= 80) return 'Excellent'; // 4/5 visits
    if (completion >= 60) return 'Good'; // 3/5 visits
    if (completion >= 40) return 'Fair'; // 2/5 visits
    if (completion >= 20) return 'Poor'; // 1/5 visits
    return 'Very Poor';
  }

  /// Get compliance color
  int get complianceColor {
    final completion = completionPercentage;
    if (completion >= 80) return 0xFF4CAF50; // Green
    if (completion >= 60) return 0xFF8BC34A; // Light Green
    if (completion >= 40) return 0xFFFFC107; // Amber
    if (completion >= 20) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  /// Get all immunizations given
  List<String> get allImmunizationsGiven {
    final immunizations = <String>{};
    for (final visit in completedVisits) {
      if (visit.immunizationsGiven != null) {
        immunizations.addAll(visit.immunizationsGiven!);
      }
    }
    return immunizations.toList();
  }
}
