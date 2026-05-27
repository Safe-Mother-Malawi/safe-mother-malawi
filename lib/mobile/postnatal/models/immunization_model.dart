/// Immunization Schedule Model
class ImmunizationSchedule {
  final String vaccineId;
  final String vaccineName;
  final String abbreviation;
  final int ageInDays; // Age when vaccine should be given
  final String ageLabel; // Human-readable age (e.g., "At birth", "Day 7")
  final String purpose;
  final List<String> protectsAgainst;
  final String route; // Oral, Intramuscular, etc.
  final String site; // Injection site
  final bool mandatory; // Is this vaccine mandatory?
  final String? notes;

  const ImmunizationSchedule({
    required this.vaccineId,
    required this.vaccineName,
    required this.abbreviation,
    required this.ageInDays,
    required this.ageLabel,
    required this.purpose,
    required this.protectsAgainst,
    required this.route,
    required this.site,
    this.mandatory = true,
    this.notes,
  });

  /// Get WHO recommended immunization schedule for neonates (0-28 days)
  static List<ImmunizationSchedule> getWHONeonatalSchedule() {
    return [
      // Birth (Day 0)
      ImmunizationSchedule(
        vaccineId: 'bcg',
        vaccineName: 'BCG',
        abbreviation: 'BCG',
        ageInDays: 0,
        ageLabel: 'At birth',
        purpose: 'Protection against tuberculosis',
        protectsAgainst: ['Tuberculosis (TB)'],
        route: 'Intradermal',
        site: 'Left upper arm',
        mandatory: true,
        notes: 'Single dose. Creates a scar at injection site.',
      ),
      ImmunizationSchedule(
        vaccineId: 'opv0',
        vaccineName: 'OPV 0',
        abbreviation: 'OPV 0',
        ageInDays: 0,
        ageLabel: 'At birth',
        purpose: 'First dose of polio vaccine',
        protectsAgainst: ['Poliomyelitis (Polio)'],
        route: 'Oral',
        site: 'Mouth',
        mandatory: true,
        notes: '2 drops given orally. First dose of 3-dose series.',
      ),
      ImmunizationSchedule(
        vaccineId: 'hepb0',
        vaccineName: 'Hepatitis B',
        abbreviation: 'HepB',
        ageInDays: 0,
        ageLabel: 'At birth',
        purpose: 'Protection against Hepatitis B',
        protectsAgainst: ['Hepatitis B'],
        route: 'Intramuscular',
        site: 'Right thigh',
        mandatory: true,
        notes: 'First dose of 3-dose series. Protects against chronic infection.',
      ),
      ImmunizationSchedule(
        vaccineId: 'vitk',
        vaccineName: 'Vitamin K',
        abbreviation: 'Vit K',
        ageInDays: 0,
        ageLabel: 'At birth',
        purpose: 'Prevention of vitamin K deficiency bleeding',
        protectsAgainst: ['Vitamin K deficiency bleeding (VKDB)'],
        route: 'Intramuscular',
        site: 'Right thigh',
        mandatory: true,
        notes: 'Single dose. Prevents bleeding disorders in newborns.',
      ),
      ImmunizationSchedule(
        vaccineId: 'eyeprop',
        vaccineName: 'Eye Prophylaxis',
        abbreviation: 'Eye Prop',
        ageInDays: 0,
        ageLabel: 'At birth',
        purpose: 'Prevention of neonatal conjunctivitis',
        protectsAgainst: ['Neonatal conjunctivitis', 'Ophthalmia neonatorum'],
        route: 'Topical',
        site: 'Both eyes',
        mandatory: true,
        notes: 'Tetracycline or erythromycin ointment applied to both eyes.',
      ),

      // Day 7
      ImmunizationSchedule(
        vaccineId: 'opv1',
        vaccineName: 'OPV 1',
        abbreviation: 'OPV 1',
        ageInDays: 7,
        ageLabel: 'Day 7',
        purpose: 'Second dose of polio vaccine',
        protectsAgainst: ['Poliomyelitis (Polio)'],
        route: 'Oral',
        site: 'Mouth',
        mandatory: true,
        notes: '2 drops given orally. Second dose of 3-dose series.',
      ),

      // Day 14
      ImmunizationSchedule(
        vaccineId: 'penta1',
        vaccineName: 'Pentavalent 1',
        abbreviation: 'Penta 1',
        ageInDays: 14,
        ageLabel: 'Day 14',
        purpose: 'First dose of combined vaccine',
        protectsAgainst: [
          'Diphtheria',
          'Pertussis (Whooping cough)',
          'Tetanus',
          'Hepatitis B',
          'Haemophilus influenzae type b (Hib)'
        ],
        route: 'Intramuscular',
        site: 'Left thigh',
        mandatory: true,
        notes: 'First dose of 3-dose series. Protects against 5 diseases.',
      ),
      ImmunizationSchedule(
        vaccineId: 'opv1_day14',
        vaccineName: 'OPV 1 (Repeat)',
        abbreviation: 'OPV 1',
        ageInDays: 14,
        ageLabel: 'Day 14',
        purpose: 'Repeat dose of polio vaccine',
        protectsAgainst: ['Poliomyelitis (Polio)'],
        route: 'Oral',
        site: 'Mouth',
        mandatory: true,
        notes: '2 drops given orally. Repeat dose for better immunity.',
      ),
      ImmunizationSchedule(
        vaccineId: 'rotavirus1',
        vaccineName: 'Rotavirus 1',
        abbreviation: 'Rota 1',
        ageInDays: 14,
        ageLabel: 'Day 14',
        purpose: 'First dose of rotavirus vaccine',
        protectsAgainst: ['Rotavirus (Severe diarrhea)'],
        route: 'Oral',
        site: 'Mouth',
        mandatory: true,
        notes: 'First dose of 2-dose series. Protects against severe diarrhea.',
      ),
      ImmunizationSchedule(
        vaccineId: 'pneumo1',
        vaccineName: 'Pneumococcal 1',
        abbreviation: 'Pneumo 1',
        ageInDays: 14,
        ageLabel: 'Day 14',
        purpose: 'First dose of pneumococcal vaccine',
        protectsAgainst: ['Pneumococcal disease', 'Meningitis', 'Pneumonia'],
        route: 'Intramuscular',
        site: 'Right thigh',
        mandatory: true,
        notes: 'First dose of 3-dose series. Protects against serious infections.',
      ),

      // Day 28
      ImmunizationSchedule(
        vaccineId: 'penta2',
        vaccineName: 'Pentavalent 2',
        abbreviation: 'Penta 2',
        ageInDays: 28,
        ageLabel: 'Day 28',
        purpose: 'Second dose of combined vaccine',
        protectsAgainst: [
          'Diphtheria',
          'Pertussis (Whooping cough)',
          'Tetanus',
          'Hepatitis B',
          'Haemophilus influenzae type b (Hib)'
        ],
        route: 'Intramuscular',
        site: 'Left thigh',
        mandatory: true,
        notes: 'Second dose of 3-dose series.',
      ),
      ImmunizationSchedule(
        vaccineId: 'opv2',
        vaccineName: 'OPV 2',
        abbreviation: 'OPV 2',
        ageInDays: 28,
        ageLabel: 'Day 28',
        purpose: 'Third dose of polio vaccine',
        protectsAgainst: ['Poliomyelitis (Polio)'],
        route: 'Oral',
        site: 'Mouth',
        mandatory: true,
        notes: '2 drops given orally. Third dose of 3-dose series.',
      ),
      ImmunizationSchedule(
        vaccineId: 'rotavirus2',
        vaccineName: 'Rotavirus 2',
        abbreviation: 'Rota 2',
        ageInDays: 28,
        ageLabel: 'Day 28',
        purpose: 'Second dose of rotavirus vaccine',
        protectsAgainst: ['Rotavirus (Severe diarrhea)'],
        route: 'Oral',
        site: 'Mouth',
        mandatory: true,
        notes: 'Second dose of 2-dose series. Completes rotavirus protection.',
      ),
      ImmunizationSchedule(
        vaccineId: 'pneumo2',
        vaccineName: 'Pneumococcal 2',
        abbreviation: 'Pneumo 2',
        ageInDays: 28,
        ageLabel: 'Day 28',
        purpose: 'Second dose of pneumococcal vaccine',
        protectsAgainst: ['Pneumococcal disease', 'Meningitis', 'Pneumonia'],
        route: 'Intramuscular',
        site: 'Right thigh',
        mandatory: true,
        notes: 'Second dose of 3-dose series.',
      ),
    ];
  }
}

/// Immunization Record Model
class ImmunizationRecord {
  final String id;
  final String vaccineId;
  final String vaccineName;
  final DateTime scheduledDate;
  final DateTime? administeredDate;
  final String status; // 'pending', 'administered', 'missed', 'contraindicated'
  final String? batchNumber;
  final String? manufacturer;
  final String? site; // Injection site
  final String? route; // Administration route
  final bool? adverseReaction;
  final String? adverseReactionDetails;
  final String? clinicianName;
  final String? clinicianPhone;
  final String? healthFacility;
  final String? notes;

  ImmunizationRecord({
    required this.id,
    required this.vaccineId,
    required this.vaccineName,
    required this.scheduledDate,
    this.administeredDate,
    this.status = 'pending',
    this.batchNumber,
    this.manufacturer,
    this.site,
    this.route,
    this.adverseReaction,
    this.adverseReactionDetails,
    this.clinicianName,
    this.clinicianPhone,
    this.healthFacility,
    this.notes,
  });

  /// Check if vaccine is overdue
  bool get isOverdue {
    if (status == 'administered' || status == 'missed') return false;
    return DateTime.now().isAfter(scheduledDate.add(const Duration(days: 7)));
  }

  /// Check if vaccine is due soon (within 3 days)
  bool get isDueSoon {
    if (status != 'pending') return false;
    final daysUntil = scheduledDate.difference(DateTime.now()).inDays;
    return daysUntil >= 0 && daysUntil <= 3;
  }

  /// Check if vaccine is upcoming (within 14 days)
  bool get isUpcoming {
    if (status != 'pending') return false;
    final daysUntil = scheduledDate.difference(DateTime.now()).inDays;
    return daysUntil > 3 && daysUntil <= 14;
  }

  factory ImmunizationRecord.fromJson(Map<String, dynamic> json) {
    return ImmunizationRecord(
      id: json['id'] as String? ?? '',
      vaccineId: json['vaccineId'] as String? ?? '',
      vaccineName: json['vaccineName'] as String? ?? '',
      scheduledDate: DateTime.tryParse(json['scheduledDate'] as String? ?? '') ?? DateTime.now(),
      administeredDate: json['administeredDate'] != null ? DateTime.tryParse(json['administeredDate'] as String) : null,
      status: json['status'] as String? ?? 'pending',
      batchNumber: json['batchNumber'] as String?,
      manufacturer: json['manufacturer'] as String?,
      site: json['site'] as String?,
      route: json['route'] as String?,
      adverseReaction: json['adverseReaction'] as bool?,
      adverseReactionDetails: json['adverseReactionDetails'] as String?,
      clinicianName: json['clinicianName'] as String?,
      clinicianPhone: json['clinicianPhone'] as String?,
      healthFacility: json['healthFacility'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccineId': vaccineId,
      'vaccineName': vaccineName,
      'scheduledDate': scheduledDate.toIso8601String(),
      'administeredDate': administeredDate?.toIso8601String(),
      'status': status,
      'batchNumber': batchNumber,
      'manufacturer': manufacturer,
      'site': site,
      'route': route,
      'adverseReaction': adverseReaction,
      'adverseReactionDetails': adverseReactionDetails,
      'clinicianName': clinicianName,
      'clinicianPhone': clinicianPhone,
      'healthFacility': healthFacility,
      'notes': notes,
    };
  }
}

/// Immunization Tracker
class ImmunizationTracker {
  final List<ImmunizationRecord> records;
  final DateTime babyDateOfBirth;

  ImmunizationTracker({
    required this.records,
    required this.babyDateOfBirth,
  });

  /// Get immunization completion percentage
  double get completionPercentage {
    if (records.isEmpty) return 0;
    final administered = records.where((r) => r.status == 'administered').length;
    return (administered / records.length) * 100;
  }

  /// Get next due vaccine
  ImmunizationRecord? get nextDueVaccine {
    final pending = records.where((r) => r.status == 'pending').toList();
    if (pending.isEmpty) return null;
    pending.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return pending.first;
  }

  /// Get overdue vaccines
  List<ImmunizationRecord> get overdueVaccines {
    return records.where((r) => r.isOverdue).toList();
  }

  /// Get vaccines due soon
  List<ImmunizationRecord> get vaccinesDueSoon {
    return records.where((r) => r.isDueSoon).toList();
  }

  /// Get upcoming vaccines
  List<ImmunizationRecord> get upcomingVaccines {
    return records.where((r) => r.isUpcoming).toList();
  }

  /// Get administered vaccines
  List<ImmunizationRecord> get administeredVaccines {
    return records.where((r) => r.status == 'administered').toList();
  }

  /// Get missed vaccines
  List<ImmunizationRecord> get missedVaccines {
    return records.where((r) => r.status == 'missed').toList();
  }

  /// Get vaccines with adverse reactions
  List<ImmunizationRecord> get vaccinesWithAdverseReactions {
    return records.where((r) => r.adverseReaction == true).toList();
  }

  /// Get immunization status
  String get immunizationStatus {
    final completion = completionPercentage;
    if (completion >= 90) return 'Excellent'; // 11/12 vaccines
    if (completion >= 75) return 'Good'; // 9/12 vaccines
    if (completion >= 60) return 'Fair'; // 7/12 vaccines
    if (completion >= 40) return 'Poor'; // 5/12 vaccines
    return 'Very Poor';
  }

  /// Get immunization status color
  int get immunizationStatusColor {
    final completion = completionPercentage;
    if (completion >= 90) return 0xFF4CAF50; // Green
    if (completion >= 75) return 0xFF8BC34A; // Light Green
    if (completion >= 60) return 0xFFFFC107; // Amber
    if (completion >= 40) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  /// Get vaccines by age group
  Map<String, List<ImmunizationRecord>> getVaccinesByAgeGroup() {
    final grouped = <String, List<ImmunizationRecord>>{};
    
    for (final record in records) {
      final schedule = ImmunizationSchedule.getWHONeonatalSchedule()
          .firstWhere((s) => s.vaccineId == record.vaccineId, orElse: () => ImmunizationSchedule.getWHONeonatalSchedule().first);
      
      if (!grouped.containsKey(schedule.ageLabel)) {
        grouped[schedule.ageLabel] = [];
      }
      grouped[schedule.ageLabel]!.add(record);
    }
    
    return grouped;
  }

  /// Get vaccines due at specific age
  List<ImmunizationRecord> getVaccinesDueAtAge(int ageInDays) {
    return records.where((r) {
      final schedule = ImmunizationSchedule.getWHONeonatalSchedule()
          .firstWhere((s) => s.vaccineId == r.vaccineId, orElse: () => ImmunizationSchedule.getWHONeonatalSchedule().first);
      return schedule.ageInDays == ageInDays;
    }).toList();
  }
}
