class UserModel {
  final String id;
  final String email;
  final String password;
  final String role;
  final String fullName;
  final String phone;
  final String lmpDate;
  final String babyName;
  final String babyDob;
  // Extended prenatal fields
  final String age;
  final String nationality;
  final String district;
  final String village;
  final String facilityName;
  final String pregnancyMonths;
  final String pregnancyWeeks;       // extra weeks (0–4) on top of months
  final String expectedDeliveryDate;
  final String gravida;
  final String parity;
  final List<String> existingConditions;
  final String emergencyContact;

  // Extended neonatal fields
  final String babyGender;       // 'Male' | 'Female'
  final String babyBirthWeight;  // in kg e.g. '3.2'
  // Password recovery
  final String securityQuestion;
  final String securityAnswer;   // stored lowercase-trimmed

  UserModel({
    this.id = '',
    required this.email,
    required this.password,
    required this.role,
    required this.fullName,
    required this.phone,
    this.lmpDate = '',
    this.babyName = '',
    this.babyDob = '',
    this.age = '',
    this.nationality = '',
    this.district = '',
    this.village = '',
    this.facilityName = '',
    this.pregnancyMonths = '',
    this.pregnancyWeeks = '',
    this.expectedDeliveryDate = '',
    this.gravida = '',
    this.parity = '',
    this.existingConditions = const [],
    this.emergencyContact = '',
    this.babyGender = '',
    this.babyBirthWeight = '',
    this.securityQuestion = '',
    this.securityAnswer = '',
  });

  /// Total pregnancy weeks derived from months + extra weeks input.
  int get totalPregnancyWeeks {
    final m = int.tryParse(pregnancyMonths) ?? 0;
    final w = int.tryParse(pregnancyWeeks) ?? 0;
    return (m * 4) + w;
  }
}
