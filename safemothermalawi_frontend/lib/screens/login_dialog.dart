import 'package:flutter/material.dart';
import '../web/admin/admin_overview.dart';
import '../web/dho/dho_overview.dart';
import 'clinician/clinician_layout.dart';
import '../services/api_service.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _resetEmailCtrl = TextEditingController();

  bool _obscure   = true;
  bool _showReset = false;
  bool _loading   = false;
  String? _error;
  String? _resetMessage;

  static const _navy = Color(0xFF0D47A1);
  static const _bg   = Color(0xFFF0F6FF);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _resetEmailCtrl.dispose();
    super.dispose();
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final email    = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final user = await ApiService.login(email, password);
      if (!mounted) return;

      final role = user['role'] as String? ?? '';
      Widget dest;
      if (role == 'admin') {
        dest = const AdminOverview();
      } else if (role == 'dho') {
        dest = const DhoOverview();
      } else if (role == 'clinician') {
        dest = const ClinicianDashboard();
      } else {
        setState(() { _loading = false; _error = 'This portal is for staff only. Use the mobile app.'; });
        return;
      }

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => dest),
        (_) => false,
      );
    } on ApiException catch (e) {
      setState(() { _loading = false; _error = e.message; });
    } catch (_) {
      setState(() { _loading = false; _error = 'Could not connect to server. Is the backend running?'; });
    }
  }

  // ── Forgot password ────────────────────────────────────────────────────────
  Future<void> _submitReset() async {
    final email = _resetEmailCtrl.text.trim().toLowerCase();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }
    setState(() { _loading = true; _error = null; _resetMessage = null; });
    try {
      final res = await ApiService.post(
        '/auth/forgot-password/question',
        {'identifier': email},
        auth: false,
      );
      setState(() {
        _loading = false;
        _resetMessage = 'Security question: ${res['question']}';
      });
    } on ApiException catch (e) {
      setState(() { _loading = false; _error = e.message; });
    } catch (_) {
      setState(() { _loading = false; _error = 'Could not connect to server.'; });
    }
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _showReset ? _buildResetView() : _buildLoginView(),
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
            onPressed: () => setState(() { _showReset = true; _error = null; }),
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

  Widget _buildResetView() {
    return Column(
      key: const ValueKey('reset'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Forgot password'),
        const SizedBox(height: 6),
        const Text("Enter your email and we'll find your security question.",
            style: TextStyle(fontSize: 13, color: Colors.black45)),
        const SizedBox(height: 24),
        TextFormField(
          controller: _resetEmailCtrl,
          onChanged: (_) => setState(() { _error = null; _resetMessage = null; }),
          decoration: _inputDecoration('Email address', Icons.email_outlined),
        ),
        if (_error != null) ...[const SizedBox(height: 10), _buildError(_error!)],
        if (_resetMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(_resetMessage!,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600))),
            ]),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _submitReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Find My Account', style: TextStyle(fontSize: 15)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() { _showReset = false; _error = null; _resetMessage = null; }),
            icon: const Icon(Icons.arrow_back, size: 14, color: _navy),
            label: const Text('Back to Sign In',
                style: TextStyle(fontSize: 13, color: _navy)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: _navy),
        child: const Icon(Icons.local_hospital, color: Colors.white, size: 20),
      ),
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
