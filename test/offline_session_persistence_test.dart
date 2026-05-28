import 'package:flutter_test/flutter_test.dart';
import 'package:safemothermalawi_frontend/mobile/auth/models/user_model.dart';

void main() {
  test('user session serializes and restores correctly', () {
    final user = UserModel(
      id: '123',
      email: 'test@example.com',
      password: 'secret',
      role: 'prenatal',
      fullName: 'Test User',
      phone: '1234567890',
      lmpDate: '2024-01-01',
      babyName: 'Baby',
      babyDob: '2024-06-01',
      age: '26',
      nationality: 'Malawian',
      district: 'Lilongwe',
      village: 'Village',
      facilityName: 'Clinic',
      pregnancyMonths: '6',
      pregnancyWeeks: '26',
      expectedDeliveryDate: '2024-10-01',
      gravida: '1',
      parity: '0',
      previousMiscarriage: false,
      previousCSection: false,
      existingConditions: const ['Hypertension'],
      emergencyContact: 'Contact',
      emergencyContactPhone: '0987654321',
      babyGender: 'Female',
      babyBirthWeight: '3.2',
      birthLength: '50',
      headCircumference: '34',
      apgarScore: '9',
      gestationalAgeAtBirth: '40',
      deliveryMethod: 'Normal',
      placeOfBirth: 'Clinic',
      birthAttendant: 'Midwife',
      complicationsDuringDelivery: 'None',
      profilePhotoUrl: '/uploads/profile-photos/test.jpg',
      securityQuestion: 'Color?',
      securityAnswer: 'Blue',
    );

    final restored = UserModel.fromJson(user.toJson());

    expect(restored.id, user.id);
    expect(restored.email, user.email);
    expect(restored.role, user.role);
    expect(restored.fullName, user.fullName);
    expect(restored.profilePhotoUrl, user.profilePhotoUrl);
    expect(restored.existingConditions, user.existingConditions);
    expect(restored.emergencyContactPhone, user.emergencyContactPhone);
  });
}
