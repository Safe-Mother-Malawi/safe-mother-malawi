import 'package:flutter/material.dart';
import '../web/admin/admin_overview.dart';
import '../web/dho/dho_overview.dart';
import 'clinician/clinician_layout.dart';
import '../services/auth_service_web.dart';
import '../services/api_service.dart';
import 'email_forgot_password_dialog.dart';
import '../utils/validators.dart';
import '../state/notification_store.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure      = true;
  bool _loading      = false;
  String? _error;

  static const _navy = Color(0xFF0D47A1);
  static const _bg   = Color(0xFFF0F6FF);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final role = await AuthServiceWeb.instance.login(email, password);

      if (!mounted) return;

      // Web portal only allows CLINICIAN, DHO, and ADMIN
      // Block PRENATAL and NEONATAL users
      if (role == 'prenatal' || role == 'neonatal') {
        // Logout the user immediately
        await AuthServiceWeb.instance.logout();
        
        setState(() {
          _loading = false;
          _error = 'This web portal is for healthcare workers only. '
                   '${role.toUpperCase()} users should use the mobile app.';
        });
        return;
      }

      Widget dest;
      if (role == 'admin') {
        dest = const AdminOverview();
      } else if (role == 'dho') {
        dest = const DhoOverview();
      } else if (role == 'clinician') {
        dest = const ClinicianDashboard();
      } else {
        // Unknown role
        await AuthServiceWeb.instance.logout();
        setState(() {
          _loading = false;
          _error = 'Invalid user role. This portal is for Admin, DHO, and Clinician accounts only.';
        });
        return;
      }

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => dest),
        (_) => false,
      );
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _error = e.statusCode == 401
            ? 'Invalid email or password.'
            : 'Login failed: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Could not connect to server. Please check your connection.';
      });
    }
  }

  // ── Forgot password ────────────────────────────────────────────────────────
  void _openForgotPassword() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EmailForgotPasswordDialog(),
    );
  }

  void _close() => Navigator.of(context, rootNavigator: true).pop();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: SingleChildScrollView(
            child: _buildLoginView(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    return Column(
      key: const ValueKey('login'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Sign in to your account'),
        const SizedBox(height: 6),
        const Text('Enter your credentials to continue',
            style: TextStyle(fontSize: 13, color: Colors.black45)),
        const SizedBox(height: 24),

        TextFormField(
          controller: _emailCtrl,
          onChanged: (_) => setState(() => _error = null),
          decoration: _inputDecoration('Email address', Icons.email_outlined),
          validator: Validators.validateEmailOrPhone,
        ),
        const SizedBox(height: 14),

        TextFormField(
          controller: _passwordCtrl,
          obscureText: _obscure,
          onChanged: (_) => setState(() => _error = null),
          onFieldSubmitted: (_) => _submit(),
          decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black38, size: 18),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),

        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _openForgotPassword,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Forgot password?',
                style: TextStyle(fontSize: 13, color: _navy, fontWeight: FontWeight.w500)),
          ),
        ),

        if (_error != null) _buildError(_error!),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Sign In', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Row(children: [
      Image.asset('assets/logo/LOGO6.png', width: 110, height: 110, fit: BoxFit.contain),
      const SizedBox(width: 10),
      Expanded(child: Text(title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
              color: Color(0xFF0A1628)))),
      GestureDetector(
        onTap: _close,
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.06), shape: BoxShape.circle),
          child: const Icon(Icons.close, size: 16, color: Colors.black54),
        ),
      ),
    ]);
  }

  Widget _buildError(String msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 15),
        const SizedBox(width: 6),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.red, fontSize: 13))),
      ]),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      prefixIcon: Icon(icon, color: _navy, size: 20),
      filled: true, fillColor: _bg,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }
}

