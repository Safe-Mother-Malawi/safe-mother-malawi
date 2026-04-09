import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../data/malawi_health_centres.dart';

class NeonatalSignupScreen extends StatefulWidget {
  const NeonatalSignupScreen({super.key});

  @override
  State<NeonatalSignupScreen> createState() => _NeonatalSignupScreenState();
}

class _NeonatalSignupScreenState extends State<NeonatalSignupScreen> {
  int _step = 0; // 0 = mother, 1 = baby, 2 = password

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  // Step 1 – Mother
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _ageCtrl    = TextEditingController();
  String _district  = '';
  String? _healthCentre;

  // Step 2 – Baby
  final _babyNameCtrl = TextEditingController();
  DateTime? _babyDob;
  String _babyGender  = '';
  final _weightCtrl   = TextEditingController();

  // Step 3 – Password
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  String _secQuestion = 'What is the name of your first pet?';
  final _secAnswerCtrl = TextEditingController();

  bool _loading = false;

  static const _districts = [
    'Balaka','Blantyre','Chikwawa','Chiradzulu','Chitipa','Dedza','Dowa',
    'Karonga','Kasungu','Likoma','Lilongwe','Machinga','Mangochi','Mchinji',
    'Mulanje','Mwanza','Mzimba','Neno','Nkhata Bay','Nkhotakota','Nsanje',
    'Ntcheu','Ntchisi','Phalombe','Rumphi','Salima','Thyolo','Zomba',
  ];

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _emailCtrl, _ageCtrl,
        _babyNameCtrl, _weightCtrl, _passwordCtrl, _confirmCtrl, _secAnswerCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 28)),
      lastDate: DateTime.now(),
      helpText: "Baby's Date of Birth",
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1A3A6B))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _babyDob = picked);
  }

  void _snack(String msg, Color c) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: c));

  void _next() {
    GlobalKey<FormState> key;
    if (_step == 0) key = _step1Key;
    else if (_step == 1) key = _step2Key;
    else key = _step3Key;
    if (!key.currentState!.validate()) return;
    if (_step == 1) {
      if (_babyDob == null) { _snack("Please select baby's date of birth.", Colors.red); return; }
      if (_babyGender.isEmpty) { _snack("Please select baby's gender.", Colors.red); return; }
    }
    setState(() => _step++);
  }

  void _back() => setState(() => _step--);

  Future<void> _submit() async {
    if (!_step4Key.currentState!.validate()) return;
    setState(() => _loading = true);
    final user = UserModel(
      email: _emailCtrl.text.trim().isNotEmpty
          ? _emailCtrl.text.trim()
          : _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: 'neonatal',
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      age: _ageCtrl.text.trim(),
      district: _district,
      healthCentre: _healthCentre ?? '',
      babyName: _babyNameCtrl.text.trim(),
      babyDob: _babyDob!.toIso8601String(),
      babyGender: _babyGender,
      babyBirthWeight: _weightCtrl.text.trim(),
      securityQuestion: _secQuestion,
      securityAnswer: _secAnswerCtrl.text.trim().toLowerCase(),
    );
    final ok = await AuthService().register(user);
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      _snack('Account created successfully!', const Color(0xFF1A3A6B));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } else {
      _snack('Phone/email already registered. Try logging in.', Colors.red);
    }
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1A3A6B), width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
    errorStyle: const TextStyle(fontSize: 11, color: Colors.red),
  );

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF1A3A6B);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: color),
          onPressed: _step == 0 ? () => Navigator.pop(context) : _back,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Step indicator ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(children: [
                _StepDot(active: _step == 0, done: _step > 0, label: '1', color: color),
                Expanded(child: Container(height: 2, color: _step > 0 ? color : const Color(0xFFE0E0E0))),
                _StepDot(active: _step == 1, done: _step > 1, label: '2', color: color),
                Expanded(child: Container(height: 2, color: _step > 1 ? color : const Color(0xFFE0E0E0))),
                _StepDot(active: _step == 2, done: _step > 2, label: '3', color: color),
                Expanded(child: Container(height: 2, color: _step > 2 ? color : const Color(0xFFE0E0E0))),
                _StepDot(active: _step == 3, done: false, label: '4', color: color),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Mother's Info", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: _step == 0 ? color : const Color(0xFF9E9E9E))),
                  Text("Baby's Info", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: _step == 1 ? color : const Color(0xFF9E9E9E))),
                  Text("Security", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: _step == 2 ? color : const Color(0xFF9E9E9E))),
                  Text("Password", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: _step == 3 ? color : const Color(0xFF9E9E9E))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _step == 0
                    ? _buildMotherStep()
                    : _step == 1
                        ? _buildBabyStep()
                        : _step == 2
                            ? _buildSecurityStep()
                            : _buildPasswordStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Mother ────────────────────────────────────────────────────────

  Widget _buildMotherStep() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.person_outline, title: "Mother's Information", color: Color(0xFF1A3A6B)),
          const SizedBox(height: 16),
          _Field(label: 'Full Name *', child: TextFormField(
            controller: _nameCtrl,
            decoration: _dec('e.g. Grace Banda'),
            validator: (v) => v!.trim().isEmpty ? 'Full name is required' : null,
          )),
          const SizedBox(height: 14),
          _Field(label: 'Phone Number *', child: TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: _dec('e.g. 0881234567'),
            validator: (v) {
              if (v!.trim().isEmpty) return 'Phone number is required';
              if (v.trim().length < 7) return 'Enter a valid phone number';
              return null;
            },
          )),
          const SizedBox(height: 14),
          _Field(label: 'Email (optional)', child: TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: _dec('e.g. grace@email.com'),
            validator: (v) {
              if (v!.trim().isEmpty) return null;
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
              return null;
            },
          )),
          const SizedBox(height: 14),
          _Field(label: "Mother's Age *", child: TextFormField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            decoration: _dec('e.g. 26'),
            validator: (v) {
              if (v!.trim().isEmpty) return 'Age is required';
              final n = int.tryParse(v.trim());
              if (n == null || n < 10 || n > 60) return 'Enter a valid age (10–60)';
              return null;
            },
          )),
          const SizedBox(height: 14),
          _Field(label: 'District *', child: DropdownButtonFormField<String>(
            value: _district.isEmpty ? null : _district,
            decoration: _dec('Select your district'),
            items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => setState(() {
              _district = v!;
              _healthCentre = null;
            }),
            validator: (v) => v == null ? 'Please select your district' : null,
          )),
          const SizedBox(height: 14),
          _Field(label: 'Health Centre / Zone *', child: DropdownButtonFormField<String>(
            value: _healthCentre,
            decoration: _dec('Select health centre'),
            items: (_district.isNotEmpty
                    ? (kDistrictHealthCentres[_district] ?? [])
                    : <String>[])
                .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                .toList(),
            onChanged: _district.isEmpty
                ? null
                : (v) => setState(() => _healthCentre = v),
            validator: (v) => v == null ? 'Please select a health centre' : null,
          )),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3A6B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Next: Baby's Information",
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account? ',
                  style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
              GestureDetector(
                onTap: () => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false),
                child: const Text('Sign in',
                    style: TextStyle(fontSize: 13, color: Color(0xFF1A3A6B), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Step 2: Baby ──────────────────────────────────────────────────────────

  Widget _buildBabyStep() {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.child_care, title: "Baby's Information", color: Color(0xFF1A3A6B)),
          const SizedBox(height: 16),
          _Field(label: "Baby's Name *", child: TextFormField(
            controller: _babyNameCtrl,
            decoration: _dec('e.g. Baby Banda'),
            validator: (v) => v!.trim().isEmpty ? "Baby's name is required" : null,
          )),
          const SizedBox(height: 14),
          _Field(
            label: 'Date of Birth *',
            child: GestureDetector(
              onTap: _pickDob,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _babyDob == null ? const Color(0xFFE0E0E0) : const Color(0xFF1A3A6B)),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today, size: 18, color: Color(0xFF1A3A6B)),
                  const SizedBox(width: 10),
                  Text(
                    _babyDob == null ? 'Select date of birth' : _fmtDate(_babyDob!),
                    style: TextStyle(
                        fontSize: 14,
                        color: _babyDob == null ? const Color(0xFFBDBDBD) : const Color(0xFF212121)),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Gender *',
            child: Row(
              children: ['Male', 'Female'].map((g) {
                final sel = _babyGender == g;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _babyGender = g),
                    child: Container(
                      margin: EdgeInsets.only(right: g == 'Male' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFF1A3A6B) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: sel ? const Color(0xFF1A3A6B) : const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(g == 'Male' ? '👦' : '👧', style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(g,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: sel ? Colors.white : const Color(0xFF424242))),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          _Field(label: 'Birth Weight (kg) *', child: TextFormField(
            controller: _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('e.g. 3.2'),
            validator: (v) {
              if (v!.trim().isEmpty) return 'Birth weight is required';
              final w = double.tryParse(v.trim());
              if (w == null) return 'Enter a number (e.g. 3.2)';
              if (w < 0.5 || w > 6.0) return 'Valid range: 0.5–6.0 kg';
              return null;
            },
          )),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3A6B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Next: Security Question',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }


  // ── Step 3: Security Question ─────────────────────────────────────────────

  static const _kQuestions = [
    'What is the name of your first pet?',
    "What is your mother's maiden name?",
    'What was the name of your primary school?',
    'What is the name of the town where you were born?',
    'What was the make of your first car?',
  ];

  Widget _buildSecurityStep() {
    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.security_outlined, title: 'Security Question', color: Color(0xFF1A3A6B)),
          const SizedBox(height: 6),
          const Text(
            'This will be used to verify your identity if you forget your password.',
            style: TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.4),
          ),
          const SizedBox(height: 16),
          _Field(
            label: 'Choose a question *',
            child: DropdownButtonFormField<String>(
              value: _secQuestion,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1A3A6B), width: 1.5)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
              ),
              style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
              items: _kQuestions.map((q) => DropdownMenuItem(value: q, child: Text(q, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) { if (v != null) setState(() => _secQuestion = v); },
              validator: (v) => v == null ? 'Please select a question' : null,
            ),
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Your answer *',
            child: TextFormField(
              controller: _secAnswerCtrl,
              decoration: _dec('Type your answer'),
              validator: (v) => v!.trim().isEmpty ? 'Answer is required' : null,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3A6B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Next: Set Password',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Step 4: Password ──────────────────────────────────────────────────────

  Widget _buildPasswordStep() {
    return Form(
      key: _step4Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.lock_outline, title: 'Account Security', color: Color(0xFF1A3A6B)),
          const SizedBox(height: 6),
          const Text(
            'Set a password you will use to log in next time.',
            style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 20),
          _Field(label: 'Password *', child: TextFormField(
            controller: _passwordCtrl,
            obscureText: true,
            decoration: _dec('Minimum 6 characters'),
            validator: (v) => v!.length < 6 ? 'Minimum 6 characters' : null,
          )),
          const SizedBox(height: 14),
          _Field(label: 'Confirm Password *', child: TextFormField(
            controller: _confirmCtrl,
            obscureText: true,
            decoration: _dec('Re-enter your password'),
            validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null,
          )),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3A6B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Create Account',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _SectionHeader({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 20),
    ),
    const SizedBox(width: 10),
    Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
  ]);
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF424242))),
      const SizedBox(height: 6),
      child,
    ],
  );
}

class _StepDot extends StatelessWidget {
  final bool active, done;
  final String label;
  final Color color;
  const _StepDot({required this.active, required this.done, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(
        color: active || done ? color : const Color(0xFFE0E0E0),
        shape: BoxShape.circle),
    child: Center(
      child: done
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : Text(label,
              style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF9E9E9E),
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
    ),
  );
}
