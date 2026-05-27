import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import '../widgets/password_strength_indicator.dart';

/// Web email-based forgot password dialog (3 steps):
///   Step 0 — Enter email
///   Step 1 — Enter reset token
///   Step 2 — Set new password
class EmailForgotPasswordDialog extends StatefulWidget {
  const EmailForgotPasswordDialog({super.key});

  @override
  State<EmailForgotPasswordDialog> createState() => _EmailForgotPasswordDialogState();
}

class _EmailForgotPasswordDialogState extends State<EmailForgotPasswordDialog> {
  int _step = 0;

  // Step 0
  final _emailCtrl = TextEditingController();
  // Step 1
  final _tokenCtrl = TextEditingController();
  // Step 2
  final _newPwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _error;
  String? _successMessage;
  String _resetToken = '';

  static const _navy = Color(0xFF0D47A1);
  static const _bg = Color(0xFFF0F6FF);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context, rootNavigator: true).pop();

  // ── Step 0: Request password reset ────────────────────────────────────────
  Future<void> _requestReset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }
    if (!Validators.isValidEmail(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiService.instance.post(
        '/auth/forgot-password/request-reset',
        {'email': email},
      );

      setState(() {
        _loading = false;
        _step = 1;
      });
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error: ${e.message}';
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Could not connect to server. Please check your connection.';
      });
    }
  }

  // ── Step 1: Verify token ──────────────────────────────────────────────────
  Future<void> _verifyToken() async {
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Please enter the reset token from your email.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ApiService.instance.get(
        '/auth/forgot-password/verify-token/$token',
      );
      final isValid = (data['valid'] as bool?) ?? false;

      if (!isValid) {
        setState(() {
          _loading = false;
          _error = 'Invalid or expired token. Please request a new one.';
        });
        return;
      }

      setState(() {
        _loading = false;
        _resetToken = token;
        _step = 2;
      });
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _error = e.statusCode == 400
            ? 'Invalid or expired token. Please request a new one.'
            : 'Error: ${e.message}';
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Could not connect to server.';
      });
    }
  }

  // ── Step 2: Reset password ────────────────────────────────────────────────
  Future<void> _resetPassword() async {
    final passwordError = Validators.validatePassword(_newPwCtrl.text);
    if (passwordError != null) {
      setState(() => _error = passwordError);
      return;
    }
    if (_newPwCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiService.instance.post(
        '/auth/forgot-password/reset-with-token',
        {
          'token': _resetToken,
          'newPassword': _newPwCtrl.text,
          'confirmPassword': _confirmCtrl.text,
        },
      );

      setState(() {
        _loading = false;
        _successMessage = 'Password reset successfully!';
      });

      // Close dialog after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _close();
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _error = 'Reset failed: ${e.message}';
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Could not connect to server.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStepIndicator(),
              const SizedBox(height: 28),
              if (_successMessage != null)
                _buildSuccess()
              else ...[
                if (_step == 0) _buildStep0(),
                if (_step == 1) _buildStep1(),
                if (_step == 2) _buildStep2(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Image.asset('assets/logo/LOGO6.png',
            width: 90, height: 90, fit: BoxFit.contain),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Reset Password',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A1628),
            ),
          ),
        ),
        GestureDetector(
          onTap: _close,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(0, '1'),
        _buildStepLine(0),
        _buildStepCircle(1, '2'),
        _buildStepLine(1),
        _buildStepCircle(2, '3'),
      ],
    );
  }

  Widget _buildStepCircle(int index, String label) {
    final isActive = _step == index;
    final isDone = _step > index;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDone || isActive ? _navy : const Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isDone
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF9E9E9E),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(int index) {
    final isDone = _step > index;
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? _navy : const Color(0xFFE0E0E0),
      ),
    );
  }

  // ── Step 0 UI ─────────────────────────────────────────────────────────────
  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your email',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'We\'ll send you a link to reset your password.',
          style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailCtrl,
          onChanged: (_) => setState(() => _error = null),
          decoration: _inputDecoration('Email address', Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
        ),
        if (_error != null) _buildError(_error!),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _requestReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Send Reset Link', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }

  // ── Step 1 UI ─────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter reset token',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Copy the token from the email link we sent you.',
          style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 20),
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
        TextFormField(
          controller: _tokenCtrl,
          onChanged: (_) => setState(() => _error = null),
          decoration: _inputDecoration('Reset token', Icons.vpn_key_outlined),
        ),
        if (_error != null) _buildError(_error!),
        const SizedBox(height: 24),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() {
                _step = 0;
                _error = null;
              }),
              icon: const Icon(Icons.arrow_back, size: 16, color: _navy),
              label: const Text('Back', style: TextStyle(color: _navy)),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _verifyToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Verify Token', style: TextStyle(fontSize: 15)),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 2 UI ─────────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set new password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Password must be 6-10 characters with uppercase, lowercase, number, and special character.',
          style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _newPwCtrl,
          obscureText: _obscureNew,
          onChanged: (_) => setState(() => _error = null),
          decoration: _inputDecoration('New password', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNew ? Icons.visibility_off : Icons.visibility,
                color: Colors.black38,
                size: 18,
              ),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
        ),
        const SizedBox(height: 12),
        PasswordStrengthIndicator(password: _newPwCtrl.text),
        const SizedBox(height: 14),
        TextFormField(
          controller: _confirmCtrl,
          obscureText: _obscureConfirm,
          onChanged: (_) => setState(() => _error = null),
          decoration: _inputDecoration('Confirm new password', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                color: Colors.black38,
                size: 18,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        if (_error != null) _buildError(_error!),
        const SizedBox(height: 24),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() {
                _step = 1;
                _error = null;
              }),
              icon: const Icon(Icons.arrow_back, size: 16, color: _navy),
              label: const Text('Back', style: TextStyle(color: _navy)),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Reset Password', style: TextStyle(fontSize: 15)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 48),
        ),
        const SizedBox(height: 20),
        Text(
          _successMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildError(String msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(msg, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      prefixIcon: Icon(icon, color: _navy, size: 20),
      filled: true,
      fillColor: _bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

