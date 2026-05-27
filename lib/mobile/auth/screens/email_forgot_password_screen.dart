import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../../utils/validators.dart';
import '../../../widgets/password_strength_indicator.dart';
import 'login_screen.dart';

/// Email-based password reset flow (3 steps):
///   Step 0 — Enter email
///   Step 1 — Enter reset token (from email link)
///   Step 2 — Set new password
class EmailForgotPasswordScreen extends StatefulWidget {
  final String? initialToken;

  const EmailForgotPasswordScreen({super.key, this.initialToken});

  @override
  State<EmailForgotPasswordScreen> createState() => _EmailForgotPasswordScreenState();
}

class _EmailForgotPasswordScreenState extends State<EmailForgotPasswordScreen> {
  late int _step;

  // Step 0
  final _emailCtrl = TextEditingController();
  // Step 1
  final _tokenCtrl = TextEditingController();
  // Step 2
  final _newPwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  String _resetToken = '';

  @override
  void initState() {
    super.initState();
    // If token is provided (from deep link), skip to step 2
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      _step = 2;
      _resetToken = widget.initialToken!;
    } else {
      _step = 0;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));

  // ── Step 0: Request password reset ────────────────────────────────────────
  Future<void> _requestReset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _snack('Please enter your email', Colors.red);
      return;
    }
    if (!Validators.isValidEmail(email)) {
      _snack('Please enter a valid email', Colors.red);
      return;
    }

    setState(() => _loading = true);
    final ok = await AuthService().requestPasswordReset(email);
    setState(() => _loading = false);

    if (!mounted) return;
    if (ok) {
      _snack('Check your email for reset instructions', const Color(0xFF1A237E));
      // Show step 1 to enter token
      setState(() => _step = 1);
    } else {
      _snack('Failed to send reset email. Please try again.', Colors.red);
    }
  }

  // ── Step 1: Verify token ──────────────────────────────────────────────────
  Future<void> _verifyToken() async {
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      _snack('Please enter the reset token from your email', Colors.red);
      return;
    }

    setState(() => _loading = true);
    final isValid = await AuthService().verifyResetToken(token);
    setState(() => _loading = false);

    if (!mounted) return;
    if (isValid) {
      setState(() {
        _resetToken = token;
        _step = 2;
      });
    } else {
      _snack('Invalid or expired token. Please request a new one.', Colors.red);
    }
  }

  // ── Step 2: Reset password ────────────────────────────────────────────────
  Future<void> _resetPassword() async {
    final passwordError = Validators.validatePassword(_newPwCtrl.text);
    if (passwordError != null) {
      _snack(passwordError, Colors.red);
      return;
    }
    if (_newPwCtrl.text != _confirmCtrl.text) {
      _snack('Passwords do not match', Colors.red);
      return;
    }

    setState(() => _loading = true);
    final ok = await AuthService().resetPasswordWithToken(
      token: _resetToken,
      newPassword: _newPwCtrl.text,
      confirmPassword: _confirmCtrl.text,
    );
    setState(() => _loading = false);

    if (!mounted) return;
    if (ok) {
      _snack('Password reset successfully! Please login.', const Color(0xFF1A237E));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } else {
      _snack('Failed to reset password. Please try again.', Colors.red);
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
        const Text('Enter your email',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
        const SizedBox(height: 6),
        const Text('We\'ll send you a link to reset your password.',
            style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4)),
        const SizedBox(height: 24),
        AuthTextField(
          hint: 'Email address *',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        AuthButton(label: 'Send Reset Link', onPressed: _requestReset, loading: _loading),
      ],
    );
  }

  // ── Step 1 UI ─────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter reset token',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
        const SizedBox(height: 6),
        const Text('Copy the token from the email link we sent you.',
            style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4)),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFB74D), width: 1),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Color(0xFFF57C00), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'The link in your email contains the token. You can also paste it here.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFF57C00),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AuthTextField(
          hint: 'Reset token *',
          controller: _tokenCtrl,
        ),
        const SizedBox(height: 24),
        AuthButton(label: 'Verify Token', onPressed: _verifyToken, loading: _loading),
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
        const Text('Password must be 6-10 characters with uppercase, lowercase, number, and special character.',
            style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4)),
        const SizedBox(height: 24),
        AuthTextField(
          hint: 'New password *',
          controller: _newPwCtrl,
          obscure: true,
        ),
        const SizedBox(height: 12),
        PasswordStrengthIndicator(password: _newPwCtrl.text),
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
    const labels = ['Email', 'Token', 'New password'];
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
        final idx = i ~/ 2;
        final done = idx < current;
        final active = idx == current;
        return Column(
          children: [
            Container(
              width: 30,
              height: 30,
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

