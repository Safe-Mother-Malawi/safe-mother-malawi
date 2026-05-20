import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import '../widgets/password_strength_indicator.dart';

/// Web page for password reset via email link
/// Extracts token from URL query parameter and auto-fills it
class ResetPasswordPage extends StatefulWidget {
  final String? token;

  const ResetPasswordPage({super.key, this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late String _resetToken;
  bool _tokenVerified = false;
  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _error;
  String? _successMessage;

  final _newPwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  static const _navy = Color(0xFF0D47A1);
  static const _bg = Color(0xFFF0F6FF);

  @override
  void initState() {
    super.initState();
    _resetToken = widget.token ?? '';
    if (_resetToken.isNotEmpty) {
      _verifyToken();
    }
  }

  @override
  void dispose() {
    _newPwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// Verify the reset token
  Future<void> _verifyToken() async {
    if (_resetToken.isEmpty) {
      setState(() => _error = 'No reset token provided.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ApiService.instance.get(
        '/auth/forgot-password/verify-token/$_resetToken',
      );
      final isValid = (data['valid'] as bool?) ?? false;

      if (!isValid) {
        setState(() {
          _loading = false;
          _error = 'Invalid or expired token. Please request a new password reset.';
        });
        return;
      }

      setState(() {
        _loading = false;
        _tokenVerified = true;
      });
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _error = e.statusCode == 400
            ? 'Invalid or expired token. Please request a new password reset.'
            : 'Error: ${e.message}';
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Could not connect to server. Please check your connection.';
      });
    }
  }

  /// Reset password with verified token
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

      // Redirect to login after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  if (_successMessage != null)
                    _buildSuccess()
                  else if (!_tokenVerified)
                    _buildVerifying()
                  else
                    _buildResetForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/logo/LOGO6.png',
            width: 100, height: 100, fit: BoxFit.contain),
        const SizedBox(height: 20),
        const Text(
          'Reset Your Password',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A1628),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create a new password for your Safe Mother Malawi account.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifying() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loading)
          Column(
            children: [
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: _navy),
              const SizedBox(height: 20),
              const Text(
                'Verifying your reset link...',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
            ],
          )
        else if (_error != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF5350), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reset Link Invalid',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFD32F2F),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Back to Login', style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password Requirements:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        _buildRequirement('6-10 characters'),
        _buildRequirement('At least one uppercase letter (A-Z)'),
        _buildRequirement('At least one lowercase letter (a-z)'),
        _buildRequirement('At least one number (0-9)'),
        _buildRequirement('At least one special character (!@#\$%^&*)'),
        const SizedBox(height: 24),
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
        const SizedBox(height: 16),
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
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _resetPassword,
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
                : const Text('Reset Password', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 60),
        ),
        const SizedBox(height: 24),
        const Text(
          'Password Reset Successfully!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'You can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
        ),
        const SizedBox(height: 32),
        const Text(
          'Redirecting to login...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.black38),
        ),
      ],
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: _navy, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
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

