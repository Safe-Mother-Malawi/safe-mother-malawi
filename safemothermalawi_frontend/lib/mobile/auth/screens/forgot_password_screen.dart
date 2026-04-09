import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import 'login_screen.dart';

/// 3-step self-service password reset:
///   Step 0 — Enter phone / email
///   Step 1 — Answer security question
///   Step 2 — Set new password
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0;

  // Step 0
  final _identCtrl   = TextEditingController();
  // Step 1
  String _question   = '';
  final _answerCtrl  = TextEditingController();
  // Step 2
  final _newPwCtrl   = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _identCtrl.dispose();
    _answerCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));

  // ── Step 0: look up account ───────────────────────────────────────────────
  Future<void> _lookupAccount() async {
    final id = _identCtrl.text.trim();
    if (id.isEmpty) { _snack('Enter your phone number or email', Colors.red); return; }
    setState(() => _loading = true);
    final q = await AuthService().getSecurityQuestion(id);
    setState(() => _loading = false);
    if (q == null || q.isEmpty) {
      _snack('No account found for that phone / email', Colors.red);
      return;
    }
    setState(() { _question = q; _step = 1; });
  }

  // ── Step 1: verify answer ─────────────────────────────────────────────────
  Future<void> _verifyAnswer() async {
    if (_answerCtrl.text.trim().isEmpty) {
      _snack('Please enter your answer', Colors.red);
      return;
    }
    // We don't call resetPassword yet — just advance to step 2.
    // The actual reset happens at step 2 so the answer is verified atomically.
    setState(() => _step = 2);
  }

  // ── Step 2: reset password ────────────────────────────────────────────────
  Future<void> _resetPassword() async {
    if (_newPwCtrl.text.length < 6) {
      _snack('Password must be at least 6 characters', Colors.red);
      return;
    }
    if (_newPwCtrl.text != _confirmCtrl.text) {
      _snack('Passwords do not match', Colors.red);
      return;
    }
    setState(() => _loading = true);
    final ok = await AuthService().resetPassword(
      phoneOrEmail: _identCtrl.text.trim(),
      securityAnswer: _answerCtrl.text.trim(),
      newPassword: _newPwCtrl.text,
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      _snack('Password reset successfully!', const Color(0xFF1A237E));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } else {
      // Answer was wrong — go back to step 1
      _snack('Incorrect answer. Please try again.', Colors.red);
      setState(() => _step = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: _step == 0
              ? () => Navigator.pop(context)
              : () => setState(() => _step--),
        ),
        title: const Text('Reset Password',
            style: TextStyle(
                color: Color(0xFF1A237E),
                fontSize: 17,
                fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Step indicator
              _StepBar(current: _step),
              const SizedBox(height: 32),

              if (_step == 0) _buildStep0(),
              if (_step == 1) _buildStep1(),
              if (_step == 2) _buildStep2(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 0 UI ─────────────────────────────────────────────────────────────
  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Find your account',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
        const SizedBox(height: 6),
        const Text('Enter the phone number or email you registered with.',
            style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4)),
        const SizedBox(height: 24),
        AuthTextField(
          hint: 'Phone number or email *',
          controller: _identCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        AuthButton(label: 'Continue', onPressed: _lookupAccount, loading: _loading),
      ],
    );
  }

  // ── Step 1 UI ─────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Security question',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
        const SizedBox(height: 6),
        const Text('Answer the question you set during registration.',
            style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4)),
        const SizedBox(height: 24),
        // Question display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.help_outline, color: Color(0xFF1A237E), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_question,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A237E),
                        height: 1.4)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AuthTextField(
          hint: 'Your answer *',
          controller: _answerCtrl,
        ),
        const SizedBox(height: 24),
        AuthButton(label: 'Verify', onPressed: _verifyAnswer, loading: _loading),
      ],
    );
  }

  // ── Step 2 UI ─────────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Set new password',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
        const SizedBox(height: 6),
        const Text('Choose a strong password you will remember.',
            style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4)),
        const SizedBox(height: 24),
        AuthTextField(
          hint: 'New password *',
          controller: _newPwCtrl,
          obscure: true,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          hint: 'Confirm new password *',
          controller: _confirmCtrl,
          obscure: true,
        ),
        const SizedBox(height: 24),
        AuthButton(label: 'Reset Password', onPressed: _resetPassword, loading: _loading),
      ],
    );
  }
}

// ── Step Bar ──────────────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int current;
  const _StepBar({required this.current});

  @override
  Widget build(BuildContext context) {
    const labels = ['Find account', 'Verify', 'New password'];
    return Row(
      children: List.generate(5, (i) {
        if (i.isOdd) {
          final filled = (i ~/ 2) < current;
          return Expanded(
            child: Container(
              height: 2,
              color: filled ? const Color(0xFF1A237E) : const Color(0xFFE0E0E0),
            ),
          );
        }
        final idx    = i ~/ 2;
        final done   = idx < current;
        final active = idx == current;
        return Column(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: done || active ? const Color(0xFF1A237E) : const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 15)
                    : Text('${idx + 1}',
                        style: TextStyle(
                            color: active ? Colors.white : const Color(0xFF9E9E9E),
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 4),
            Text(labels[idx],
                style: TextStyle(
                    fontSize: 9,
                    color: active ? const Color(0xFF1A237E) : const Color(0xFF9E9E9E),
                    fontWeight: active ? FontWeight.w700 : FontWeight.normal)),
          ],
        );
      }),
    );
  }
}
