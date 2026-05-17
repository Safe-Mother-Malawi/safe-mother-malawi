import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import 'login_screen.dart';
import '../../../../services/api_service.dart';
import '../../../../utils/validators.dart';
import '../data/fallback_facilities.dart';

const _kDistricts = [
  'Balaka','Blantyre','Chikwawa','Chiradzulu','Chitipa','Dedza',
  'Dowa','Karonga','Kasungu','Likoma','Lilongwe','Machinga',
  'Mangochi','Mchinji','Mulanje','Mwanza','Mzimba','Neno',
  'Nkhata Bay','Nkhotakota','Nsanje','Ntcheu','Ntchisi','Phalombe',
  'Rumphi','Salima','Thyolo','Zomba',
];

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({super.key, required this.role});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Step controller — prenatal has 3 steps, neonatal has 2
  int _step = 0;

  // Step 1 form key
  final _step1Key = GlobalKey<FormState>();
  // Step 2 form key
  final _step2Key = GlobalKey<FormState>();
  // Step 3 form key
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  // ── Step 1: Mother Information ──
  final _nameCtrl         = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _ageCtrl          = TextEditingController();
  final _nationalityCtrl  = TextEditingController();
  final _emailCtrl        = TextEditingController();
  String? _district;
  String? _facilityName;
  List<Map<String, dynamic>> _facilityObjects = [];
  List<String> _facilities = [];
  bool _loadingFacilities = false;

  // ── Step 2: Pregnancy / Baby Details ──
  int _pregMonth = 1;
  int _pregWeek  = 0;
  final _dueDateCtrl  = TextEditingController();
  DateTime? _dueDate;
  final _babyNameCtrl = TextEditingController();
  final _babyDobCtrl  = TextEditingController();

  // ── Step 3: Account Security ──
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  String _secQuestion = 'What is the name of your first pet?';
  final _secAnswerCtrl = TextEditingController();

  bool _loading = false;

  bool get _isPrenatal => widget.role == 'prenatal';
  int  get _totalSteps => _isPrenatal ? 4 : 3;
  int  get _totalWeeks => (_pregMonth * 4) + _pregWeek;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _phoneCtrl, _ageCtrl, _nationalityCtrl,
      _emailCtrl, _dueDateCtrl,
      _babyNameCtrl, _babyDobCtrl, _passwordCtrl, _confirmCtrl, _secAnswerCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _snack(String msg, Color c) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: c));

  Future<void> _loadFacilities(String district) async {
    setState(() { 
      _loadingFacilities = true; 
      _facilities = []; 
      _facilityObjects = []; 
      _facilityName = null; 
    });
    
    try {
      print('Loading facilities for district: $district'); // Debug log
      final data = await ApiService.getFacilitiesByDistrict(district);
      print('Received facilities data: ${data.length} items'); // Debug log
      final objects = data.whereType<Map>().map((f) => Map<String, dynamic>.from(f)).toList();
      
      // Remove duplicates by facility name (keep first occurrence)
      final seen = <String>{};
      final uniqueObjects = objects.where((f) {
        final name = (f['facilityName'] ?? '').toString();
        if (seen.contains(name)) return false;
        seen.add(name);
        return true;
      }).toList();
      
      // Sort: Hospitals first, then Health Centres, then others alphabetically
      const order = ['Hospital', 'Health Centre', 'Clinic', 'Dispensary', 'Health Post'];
      uniqueObjects.sort((a, b) {
        final ta = (a['facilityType'] ?? '').toString();
        final tb = (b['facilityType'] ?? '').toString();
        final ia = order.indexOf(ta) == -1 ? order.length : order.indexOf(ta);
        final ib = order.indexOf(tb) == -1 ? order.length : order.indexOf(tb);
        if (ia != ib) return ia.compareTo(ib);
        return (a['facilityName'] ?? '').toString().compareTo((b['facilityName'] ?? '').toString());
      });
      
      setState(() {
        _facilityObjects = uniqueObjects;
        _facilities = uniqueObjects.map((f) => (f['facilityName'] ?? '').toString()).where((n) => n.isNotEmpty).toList();
        _loadingFacilities = false;
      });
      print('Successfully loaded ${_facilities.length} facilities from API'); // Debug log
    } catch (e) {
      print('Error loading facilities from API: $e'); // Debug log
      print('Loading fallback facilities for district: $district'); // Debug log
      
      // Always use fallback data when API fails
      _loadFallbackFacilities(district);
    }
  }

  void _loadFallbackFacilities(String district) {
    try {
      print('Attempting to load fallback facilities for: $district'); // Debug log
      final fallbackData = FallbackFacilities.getFacilitiesForDistrict(district);
      print('Fallback data loaded: ${fallbackData.length} facilities for $district'); // Debug log
      
      if (fallbackData.isEmpty) {
        print('No fallback facilities found for district: $district'); // Debug log
        setState(() {
          _facilityObjects = [];
          _facilities = [];
          _loadingFacilities = false;
        });
        return;
      }
      
      // Sort fallback data the same way
      const order = ['Hospital', 'Health Centre', 'Clinic', 'Dispensary', 'Health Post'];
      fallbackData.sort((a, b) {
        final ta = (a['facilityType'] ?? '').toString();
        final tb = (b['facilityType'] ?? '').toString();
        final ia = order.indexOf(ta) == -1 ? order.length : order.indexOf(ta);
        final ib = order.indexOf(tb) == -1 ? order.length : order.indexOf(tb);
        if (ia != ib) return ia.compareTo(ib);
        return (a['facilityName'] ?? '').toString().compareTo((b['facilityName'] ?? '').toString());
      });
      
      setState(() {
        _facilityObjects = fallbackData;
        _facilities = fallbackData.map((f) => (f['facilityName'] ?? '').toString()).where((n) => n.isNotEmpty).toList();
        _loadingFacilities = false;
      });
      print('Successfully loaded ${_facilities.length} fallback facilities'); // Debug log
      
      // Debug: Print first few facilities
      if (_facilities.isNotEmpty) {
        print('First few facilities: ${_facilities.take(3).join(', ')}');
      }
    } catch (e) {
      print('Error loading fallback facilities: $e'); // Debug log
      setState(() {
        _facilityObjects = [];
        _facilities = [];
        _loadingFacilities = false;
      });
    }
  }

  GlobalKey<FormState> get _currentKey {
    if (_step == 0) return _step1Key;
    if (_step == 1) return _step2Key;
    if (_step == 2) return _step3Key;
    return _step4Key;
  }

  void _next() {
    if (!_currentKey.currentState!.validate()) return;
    if (_step == 1 && _isPrenatal && _totalWeeks > 40) {
      _snack('Total weeks cannot exceed 40', Colors.red);
      return;
    }
    setState(() => _step++);
  }

  void _back() => setState(() => _step--);

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final p = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 140)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 300)),
      helpText: 'Select Expected Delivery Date',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1A237E))),
        child: child!),
    );
    if (p != null) {
      setState(() {
        _dueDate = p;
        _dueDateCtrl.text =
            '${p.year}-${p.month.toString().padLeft(2, '0')}-${p.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickBabyDob() async {
    final now = DateTime.now();
    final p = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      helpText: "Baby's Date of Birth",
    );
    if (p != null) {
      _babyDobCtrl.text =
          '${p.year}-${p.month.toString().padLeft(2, '0')}-${p.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_step4Key.currentState!.validate()) return;
    setState(() => _loading = true);
    final user = UserModel(
      email: _emailCtrl.text.trim().isNotEmpty
          ? _emailCtrl.text.trim()
          : _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: widget.role,
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      age: _ageCtrl.text.trim(),
      nationality: _nationalityCtrl.text.trim(),
      district: _district ?? '',
      facilityName: _facilityName ?? '',
      pregnancyMonths: _isPrenatal ? _pregMonth.toString() : '',
      pregnancyWeeks:  _isPrenatal ? _pregWeek.toString()  : '',
      expectedDeliveryDate: _isPrenatal ? _dueDateCtrl.text : '',
      babyName: !_isPrenatal ? _babyNameCtrl.text.trim() : '',
      babyDob:  !_isPrenatal ? _babyDobCtrl.text.trim()  : '',
      securityQuestion: _secQuestion,
      securityAnswer: _secAnswerCtrl.text.trim().toLowerCase(),
    );
    final result = await AuthService().register(user);
    setState(() => _loading = false);
    if (!mounted) return;
    if (result['success']) {
      _snack('Account created successfully!', const Color(0xFF1A237E));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false);
    } else {
      _snack(result['error'] ?? 'Registration failed. Please try again.', Colors.red);
    }
  }

  InputDecoration _dd(String h) => InputDecoration(
    hintText: h,
    hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red)),
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: _step == 0 ? () => Navigator.pop(context) : _back,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Step indicator ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepIndicator(current: _step, total: _totalSteps),
            ),
            const SizedBox(height: 8),
            // ── Scrollable form content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (_step == 0) _buildStep1(),
                    if (_step == 1) _buildStep2(),
                    if (_step == 2) _buildStep3(),
                    if (_step == 3) _buildStep4(),
                    const SizedBox(height: 28),
                    // ── Action button ──
                    if (_step < _totalSteps - 1)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Next',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      )
                    else
                      AuthButton(
                          label: 'Sign up',
                          onPressed: _submit,
                          loading: _loading),
                    const SizedBox(height: 20),
                    if (_step == 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ',
                              style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                          GestureDetector(
                            onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (_) => false,
                            ),
                            child: const Text('Sign in',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1A237E),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Mother Information ────────────────────────────────────────────

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SL(n: '1', t: 'Mother Information'),
          const SizedBox(height: 14),
          AuthTextField(
            hint: 'Full Name *',
            controller: _nameCtrl,
            validator: (v) {
              if (v!.trim().isEmpty) return 'Full name is required';
              final trimmed = v.trim();
              final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
              if (parts.length < 2) return 'Full name must include first and last name';
              if (parts.any((p) => RegExp(r'\d').hasMatch(p))) return 'Name cannot contain digits';
              if (parts.any((p) => !RegExp(r"^[a-zA-Z\-']+$").hasMatch(p))) return 'Name can only contain letters, hyphens, and apostrophes';
              return null;
            },
          ),
          const SizedBox(height: 12),
          AuthTextField(
            hint: 'Phone Number *',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v!.trim().isEmpty) return 'Phone number is required';
              if (v.trim().length != 10) return 'Phone must be exactly 10 digits';
              if (!v.trim().startsWith('0')) return 'Phone must start with 0';
              if (!RegExp(r'^[0-9]+$').hasMatch(v.trim())) return 'Phone must contain only digits';
              return null;
            },
          ),
          const SizedBox(height: 12),
          AuthTextField(
            hint: 'Age *',
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v!.trim().isEmpty) return 'Age is required';
              final n = int.tryParse(v.trim());
              if (n == null || n < 10 || n > 60) return 'Enter a valid age (10-60)';
              return null;
            },
          ),
          const SizedBox(height: 12),
          AuthTextField(
            hint: 'Nationality *',
            controller: _nationalityCtrl,
            validator: (v) => v!.trim().isEmpty ? 'Nationality is required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _district,
            decoration: _dd('District *'),
            style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
            hint: const Text('District *',
                style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14)),
            items: _kDistricts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (v) => setState(() {
              _district = v;
              _loadFacilities(v!);
            }),
            validator: (v) => v == null ? 'Please select a district' : null,
          ),
          const SizedBox(height: 12),
          if (_loadingFacilities)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A237E))),
                SizedBox(width: 10),
                Text('Loading facilities...', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
              ]),
            )
          else if (_facilityObjects.isEmpty && _district != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unable to load facilities for this district.',
                    style: const TextStyle(fontSize: 13, color: Color(0xFFD32F2F)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please check your internet connection or try again later.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  ),
                ],
              ),
            )
          else if (_facilityObjects.isNotEmpty)
          DropdownButtonFormField<String>(
            key: ValueKey(_district),
            value: _facilities.contains(_facilityName) ? _facilityName : null,
            decoration: _dd('Health Centre / Zone *'),
            style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
            isExpanded: true,
            hint: Text(
              _district == null ? 'Select district first' : 'Select health facility',
              style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14)),
            items: _facilityObjects.map((f) {
              final name = f['facilityName']?.toString() ?? '';
              final type = f['facilityType']?.toString() ?? '';
              return DropdownMenuItem<String>(
                value: name,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    '$name${type.isNotEmpty ? ' ($type)' : ''}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }).toList(),
            onChanged: (v) => setState(() => _facilityName = v),
            validator: (v) => v == null ? 'Please select a health facility' : null,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            hint: 'Email Address (optional)',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => Validators.validateEmail(v, required: false),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Pregnancy / Baby Details ─────────────────────────────────────

  Widget _buildStep2() {
    if (_isPrenatal) {
      return Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SL(n: '2', t: 'Pregnancy Details'),
            const SizedBox(height: 14),
            const Text('Pregnancy Duration *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF424242))),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _pregMonth,
                  decoration: _dd('Month'),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                  items: List.generate(9, (i) => i + 1)
                      .map((m) => DropdownMenuItem(value: m, child: Text('$m months')))
                      .toList(),
                  onChanged: (v) { if (v != null) setState(() => _pregMonth = v); },
                  validator: (_) => null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _pregWeek,
                  decoration: _dd('Week'),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                  items: List.generate(5, (i) => i)
                      .map((w) => DropdownMenuItem(value: w, child: Text('$w weeks')))
                      .toList(),
                  onChanged: (v) { if (v != null) setState(() => _pregWeek = v); },
                  validator: (v) => (v ?? 0) > 4 ? 'Max 4 weeks' : null,
                ),
              ),
            ]),
            const SizedBox(height: 20),
            const Text('Expected Delivery Date *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF424242))),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDueDate,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dueDateCtrl,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                  decoration: _dd('Tap to select date').copyWith(
                    suffixIcon: const Icon(Icons.calendar_today,
                        color: Color(0xFF1A237E), size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Expected delivery date is required';
                    if (_totalWeeks > 40) return 'Fix duration first (max 40 weeks)';
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Neonatal baby info
      return Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SL(n: '2', t: 'Baby Information'),
            const SizedBox(height: 14),
            AuthTextField(
              hint: "Baby's Name *",
              controller: _babyNameCtrl,
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickBabyDob,
              child: AbsorbPointer(
                child: AuthTextField(
                  hint: "Baby's Date of Birth *",
                  controller: _babyDobCtrl,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }


  // ── Step 3: Security Question ────────────────────────────────────────────

  static const _kQuestions = [
    'What is the name of your first pet?',
    'What is your mother\'s maiden name?',
    'What was the name of your primary school?',
    'What is the name of the town where you were born?',
    'What was the make of your first car?',
  ];

  Widget _buildStep3() {
    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SL(n: '3', t: 'Security Question'),
          const SizedBox(height: 6),
          const Text(
            'This will be used to verify your identity if you forget your password.',
            style: TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.4),
          ),
          const SizedBox(height: 16),
          const Text('Choose a question *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF424242))),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _secQuestion,
            decoration: _dd('Select a question'),
            style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
            items: _kQuestions
                .map((q) => DropdownMenuItem(value: q, child: Text(q, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) { if (v != null) setState(() => _secQuestion = v); },
            validator: (v) => v == null ? 'Please select a question' : null,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            hint: 'Your answer *',
            controller: _secAnswerCtrl,
            validator: (v) => v!.trim().isEmpty ? 'Answer is required' : null,
          ),
        ],
      ),
    );
  }

  // ── Step 4: Account Security ──────────────────────────────────────────────

  Widget _buildStep4() {
    return Form(
      key: _step4Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SL(n: '3', t: 'Account Security'),
          const SizedBox(height: 14),
          AuthTextField(
            hint: 'Password *',
            controller: _passwordCtrl,
            obscure: true,
            validator: (v) => Validators.validatePassword(v),
          ),
          const SizedBox(height: 12),
          AuthTextField(
            hint: 'Confirm Password *',
            controller: _confirmCtrl,
            obscure: true,
            validator: (v) => Validators.validatePasswordConfirmation(v, _passwordCtrl.text),
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total * 2 - 1, (i) {
        if (i.isOdd) {
          // connector line
          final filled = (i ~/ 2) < current;
          return Expanded(
            child: Container(
              height: 2,
              color: filled ? const Color(0xFF1A237E) : const Color(0xFFE0E0E0),
            ),
          );
        }
        final idx = i ~/ 2;
        final done = idx < current;
        final active = idx == current;
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: done || active
                ? const Color(0xFF1A237E)
                : const Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${idx + 1}',
                    style: TextStyle(
                      color: active ? Colors.white : const Color(0xFF9E9E9E),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SL extends StatelessWidget {
  final String n, t;
  const _SL({required this.n, required this.t});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
            color: const Color(0xFF1A237E),
            borderRadius: BorderRadius.circular(6)),
        child: Center(
            child: Text(n,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
      ),
      const SizedBox(width: 10),
      Text(t,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
      const SizedBox(width: 10),
      const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
    ]);
  }
}


