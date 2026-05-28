import 'package:flutter/material.dart';
import '../../../services/offline_api_service.dart';
import '../../auth/services/auth_service.dart';
import '../../../theme/app_colors.dart';

class PregnancyRegistrationScreen extends StatefulWidget {
  final VoidCallback? onRegistrationComplete;

  const PregnancyRegistrationScreen({
    super.key,
    this.onRegistrationComplete,
  });

  @override
  State<PregnancyRegistrationScreen> createState() =>
      _PregnancyRegistrationScreenState();
}

class _PregnancyRegistrationScreenState
    extends State<PregnancyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _fullNameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _nationalityCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _villageCtrl;
  late TextEditingController _facilityCtrl;
  late TextEditingController _gravidaCtrl;
  late TextEditingController _parityCtrl;
  late TextEditingController _emergencyContactCtrl;
  late TextEditingController _emergencyPhoneCtrl;

  // State
  DateTime? _selectedLmpDate;
  bool _previousMiscarriage = false;
  bool _previousCSection = false;
  Set<String> _selectedConditions = {};
  bool _isLoading = false;
  int _currentStep = 0;
  String? _errorMessage;

  final List<String> _conditions = ['Hypertension', 'Diabetes', 'HIV', 'Asthma'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _fullNameCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _nationalityCtrl = TextEditingController();
    _districtCtrl = TextEditingController();
    _villageCtrl = TextEditingController();
    _facilityCtrl = TextEditingController();
    _gravidaCtrl = TextEditingController();
    _parityCtrl = TextEditingController();
    _emergencyContactCtrl = TextEditingController();
    _emergencyPhoneCtrl = TextEditingController();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          _fullNameCtrl.text = user.fullName;
          _phoneCtrl.text = user.phone;
          _ageCtrl.text = user.age;
          _nationalityCtrl.text = user.nationality;
          _districtCtrl.text = user.district;
          _villageCtrl.text = user.village;
          _facilityCtrl.text = user.facilityName;
          _gravidaCtrl.text = user.gravida;
          _parityCtrl.text = user.parity;
          _previousMiscarriage = user.previousMiscarriage;
          _previousCSection = user.previousCSection;
          _selectedConditions = Set.from(user.existingConditions);
          _emergencyContactCtrl.text = user.emergencyContact;
          _emergencyPhoneCtrl.text = user.emergencyContactPhone;
          if (user.lmpDate.isNotEmpty) {
            _selectedLmpDate = DateTime.tryParse(user.lmpDate);
          }
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _selectLmpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedLmpDate ??
          DateTime.now().subtract(const Duration(days: 70)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now(),
      helpText: 'Select Last Menstrual Period (LMP)',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && mounted) {
      setState(() => _selectedLmpDate = picked);
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLmpDate == null) {
      setState(() => _errorMessage = 'Please select LMP date');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gravida = int.parse(_gravidaCtrl.text);
      final parity = int.parse(_parityCtrl.text);

      if (parity > gravida) {
        throw Exception('Parity cannot exceed gravida');
      }

      final result = await OfflineApiService().post('/patients/prenatal', {
        'fullName': _fullNameCtrl.text,
        'age': _ageCtrl.text,
        'phone': _phoneCtrl.text,
        'nationality': _nationalityCtrl.text,
        'district': _districtCtrl.text,
        'village': _villageCtrl.text,
        'facilityName': _facilityCtrl.text,
        'lmpDate': _selectedLmpDate!.toIso8601String().split('T')[0],
        'gravida': gravida,
        'parity': parity,
        'previousMiscarriage': _previousMiscarriage,
        'previousCSection': _previousCSection,
        'existingConditions': _selectedConditions.toList(),
        'emergencyContact': _emergencyContactCtrl.text,
        'emergencyContactPhone': _emergencyPhoneCtrl.text,
      });

      if (mounted) {
        final queued = result is Map && result['queued'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(queued
                ? 'Pregnancy registration saved locally and will sync when online.'
                : 'Pregnancy registered successfully!'),
            backgroundColor: queued ? Colors.orange : Colors.green,
          ),
        );
        widget.onRegistrationComplete?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    _nationalityCtrl.dispose();
    _districtCtrl.dispose();
    _villageCtrl.dispose();
    _facilityCtrl.dispose();
    _gravidaCtrl.dispose();
    _parityCtrl.dispose();
    _emergencyContactCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Registration'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              _submitRegistration();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: [
            // Step 1: Basic Information
            Step(
              title: const Text('Basic Information'),
              isActive: _currentStep >= 0,
              content: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fullNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Full Name *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Full name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageCtrl,
                      decoration: InputDecoration(
                        labelText: 'Age *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Age is required';
                        final age = int.tryParse(v!);
                        if (age == null || age < 15 || age > 50) {
                          return 'Age must be between 15 and 50';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: InputDecoration(
                        labelText: 'Phone Number *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Phone number is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nationalityCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nationality',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.public),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _districtCtrl,
                      decoration: InputDecoration(
                        labelText: 'District *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'District is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _villageCtrl,
                      decoration: InputDecoration(
                        labelText: 'Village',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.home),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _facilityCtrl,
                      decoration: InputDecoration(
                        labelText: 'Health Facility *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.local_hospital),
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Health facility is required' : null,
                    ),
                  ],
                ),
              ),
            ),

            // Step 2: Pregnancy Information
            Step(
              title: const Text('Pregnancy Information'),
              isActive: _currentStep >= 1,
              content: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: ListTile(
                      title: const Text('Last Menstrual Period (LMP) *'),
                      subtitle: Text(
                        _selectedLmpDate != null
                            ? _selectedLmpDate!.toLocal().toString().split(' ')[0]
                            : 'Tap to select date',
                        style: const TextStyle(fontSize: 14),
                      ),
                      onTap: _selectLmpDate,
                      trailing: const Icon(Icons.calendar_today,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _gravidaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Number of Pregnancies (Gravida) *',
                      hintText: 'Total pregnancies including current',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.pregnant_woman),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Gravida is required';
                      if (int.tryParse(v!) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _parityCtrl,
                    decoration: InputDecoration(
                      labelText: 'Number of Live Births (Parity) *',
                      hintText: 'Previous live births only',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.child_care),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Parity is required';
                      if (int.tryParse(v!) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Previous Miscarriage'),
                    value: _previousMiscarriage,
                    onChanged: (v) =>
                        setState(() => _previousMiscarriage = v ?? false),
                    activeColor: AppColors.primary,
                  ),
                  CheckboxListTile(
                    title: const Text('Previous C-Section'),
                    value: _previousCSection,
                    onChanged: (v) =>
                        setState(() => _previousCSection = v ?? false),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            // Step 3: Existing Conditions
            Step(
              title: const Text('Existing Conditions'),
              isActive: _currentStep >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Do you have any of these conditions?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ..._conditions.map((condition) {
                    return CheckboxListTile(
                      title: Text(condition),
                      value: _selectedConditions.contains(condition),
                      onChanged: (v) {
                        setState(() {
                          if (v ?? false) {
                            _selectedConditions.add(condition);
                          } else {
                            _selectedConditions.remove(condition);
                          }
                        });
                      },
                      activeColor: AppColors.primary,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'These conditions help us provide personalized care recommendations.',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Step 4: Emergency Contact
            Step(
              title: const Text('Emergency Contact'),
              isActive: _currentStep >= 3,
              content: Column(
                children: [
                  TextFormField(
                    controller: _emergencyContactCtrl,
                    decoration: InputDecoration(
                      labelText: 'Contact Name *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person_add),
                    ),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Contact name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyPhoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Contact Phone *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Contact phone is required' : null,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'We will contact this person in case of emergency.',
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isLoading
          ? const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            )
          : null,
    );
  }
}
