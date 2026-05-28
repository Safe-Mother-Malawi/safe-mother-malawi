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
  final String pregnancyWeeks; // extra weeks (0–4) on top of months
  final String expectedDeliveryDate;
  final String gravida;
  final String parity;
  final bool previousMiscarriage;
  final bool previousCSection;
  final List<String> existingConditions;
  final String emergencyContact;
  final String emergencyContactPhone;

  // Extended neonatal fields
  final String babyGender; // 'Male' | 'Female'
  final String babyBirthWeight; // in kg e.g. '3.2'
  final String birthLength;
  final String headCircumference;
  final String apgarScore;
  final String gestationalAgeAtBirth;
  final String deliveryMethod;
  final String placeOfBirth;
  final String birthAttendant;
  final String complicationsDuringDelivery;

  // Profile photo
  final String profilePhotoUrl;

  // Password recovery
  final String securityQuestion;
  final String securityAnswer; // stored lowercase-trimmed

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
    this.previousMiscarriage = false,
    this.previousCSection = false,
    this.existingConditions = const [],
    this.emergencyContact = '',
    this.emergencyContactPhone = '',
    this.babyGender = '',
    this.babyBirthWeight = '',
    this.birthLength = '',
    this.headCircumference = '',
    this.apgarScore = '',
    this.gestationalAgeAtBirth = '',
    this.deliveryMethod = '',
    this.placeOfBirth = '',
    this.birthAttendant = '',
    this.complicationsDuringDelivery = '',
    this.securityQuestion = '',
    this.securityAnswer = '',
    this.profilePhotoUrl = '',
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? password,
    String? role,
    String? fullName,
    String? phone,
    String? lmpDate,
    String? babyName,
    String? babyDob,
    String? age,
    String? nationality,
    String? district,
    String? village,
    String? facilityName,
    String? pregnancyMonths,
    String? pregnancyWeeks,
    String? expectedDeliveryDate,
    String? gravida,
    String? parity,
    bool? previousMiscarriage,
    bool? previousCSection,
    List<String>? existingConditions,
    String? emergencyContact,
    String? emergencyContactPhone,
    String? babyGender,
    String? babyBirthWeight,
    String? birthLength,
    String? headCircumference,
    String? apgarScore,
    String? gestationalAgeAtBirth,
    String? deliveryMethod,
    String? placeOfBirth,
    String? birthAttendant,
    String? complicationsDuringDelivery,
    String? securityQuestion,
    String? securityAnswer,
    String? profilePhotoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      lmpDate: lmpDate ?? this.lmpDate,
      babyName: babyName ?? this.babyName,
      babyDob: babyDob ?? this.babyDob,
      age: age ?? this.age,
      nationality: nationality ?? this.nationality,
      district: district ?? this.district,
      village: village ?? this.village,
      facilityName: facilityName ?? this.facilityName,
      pregnancyMonths: pregnancyMonths ?? this.pregnancyMonths,
      pregnancyWeeks: pregnancyWeeks ?? this.pregnancyWeeks,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      gravida: gravida ?? this.gravida,
      parity: parity ?? this.parity,
      previousMiscarriage: previousMiscarriage ?? this.previousMiscarriage,
      previousCSection: previousCSection ?? this.previousCSection,
      existingConditions: existingConditions ?? this.existingConditions,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      babyGender: babyGender ?? this.babyGender,
      babyBirthWeight: babyBirthWeight ?? this.babyBirthWeight,
      birthLength: birthLength ?? this.birthLength,
      headCircumference: headCircumference ?? this.headCircumference,
      apgarScore: apgarScore ?? this.apgarScore,
      gestationalAgeAtBirth:
          gestationalAgeAtBirth ?? this.gestationalAgeAtBirth,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      birthAttendant: birthAttendant ?? this.birthAttendant,
      complicationsDuringDelivery:
          complicationsDuringDelivery ?? this.complicationsDuringDelivery,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      securityAnswer: securityAnswer ?? this.securityAnswer,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  /// Total pregnancy weeks derived from months + extra weeks input.
  int get totalPregnancyWeeks {
    final m = int.tryParse(pregnancyMonths) ?? 0;
    final w = int.tryParse(pregnancyWeeks) ?? 0;
    return (m * 4) + w;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        'fullName': fullName,
        'phone': phone,
        'lmpDate': lmpDate,
        'babyName': babyName,
        'babyDob': babyDob,
        'age': age,
        'nationality': nationality,
        'district': district,
        'village': village,
        'facilityName': facilityName,
        'pregnancyMonths': pregnancyMonths,
        'pregnancyWeeks': pregnancyWeeks,
        'expectedDeliveryDate': expectedDeliveryDate,
        'gravida': gravida,
        'parity': parity,
        'previousMiscarriage': previousMiscarriage,
        'previousCSection': previousCSection,
        'existingConditions': existingConditions,
        'emergencyContact': emergencyContact,
        'emergencyContactPhone': emergencyContactPhone,
        'babyGender': babyGender,
        'babyBirthWeight': babyBirthWeight,
        'birthLength': birthLength,
        'headCircumference': headCircumference,
        'apgarScore': apgarScore,
        'gestationalAgeAtBirth': gestationalAgeAtBirth,
        'deliveryMethod': deliveryMethod,
        'placeOfBirth': placeOfBirth,
        'birthAttendant': birthAttendant,
        'complicationsDuringDelivery': complicationsDuringDelivery,
        'profilePhotoUrl': profilePhotoUrl,
        'securityQuestion': securityQuestion,
        'securityAnswer': securityAnswer,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        password: '',
        role: json['role']?.toString() ?? '',
        fullName:
            json['fullName']?.toString() ?? json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        lmpDate: json['lmpDate']?.toString() ?? '',
        babyName: json['babyName']?.toString() ?? '',
        babyDob: json['babyDob']?.toString() ?? '',
        age: json['age']?.toString() ?? '',
        nationality: json['nationality']?.toString() ?? '',
        district: json['district']?.toString() ?? '',
        village: json['village']?.toString() ?? '',
        facilityName: json['facilityName']?.toString() ?? '',
        pregnancyMonths: json['pregnancyMonths']?.toString() ?? '',
        pregnancyWeeks: json['pregnancyWeeks']?.toString() ?? '',
        expectedDeliveryDate: json['expectedDeliveryDate']?.toString() ?? '',
        gravida: json['gravida']?.toString() ?? '',
        parity: json['parity']?.toString() ?? '',
        previousMiscarriage: json['previousMiscarriage'] == true,
        previousCSection: json['previousCSection'] == true,
        existingConditions: (json['existingConditions'] as List?)
                ?.map((entry) => entry.toString())
                .toList() ??
            const [],
        emergencyContact: json['emergencyContact']?.toString() ?? '',
        emergencyContactPhone: json['emergencyContactPhone']?.toString() ?? '',
        babyGender: json['babyGender']?.toString() ?? '',
        babyBirthWeight: json['babyBirthWeight']?.toString() ?? '',
        birthLength: json['birthLength']?.toString() ?? '',
        headCircumference: json['headCircumference']?.toString() ?? '',
        apgarScore: json['apgarScore']?.toString() ?? '',
        gestationalAgeAtBirth: json['gestationalAgeAtBirth']?.toString() ?? '',
        deliveryMethod: json['deliveryMethod']?.toString() ?? '',
        placeOfBirth: json['placeOfBirth']?.toString() ?? '',
        birthAttendant: json['birthAttendant']?.toString() ?? '',
        complicationsDuringDelivery:
            json['complicationsDuringDelivery']?.toString() ?? '',
        profilePhotoUrl: json['profilePhotoUrl']?.toString() ?? '',
        securityQuestion: json['securityQuestion']?.toString() ?? '',
        securityAnswer: json['securityAnswer']?.toString() ?? '',
      );
}
