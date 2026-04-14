import 'package:flutter/material.dart';
import '../web/admin/admin_overview.dart';
import '../web/dho/dho_overview.dart';
import 'clinician/clinician_layout.dart';

/// Web portal credentials.
/// Admin     → admin@safemothermalawi.app      / admin1234
/// DHO       → dho@safemothermalawi.app        / dho12345
/// Clinician → clinician@safemothermalawi.app  / clinic1234
const _credentials = {
  'admin@safemothermalawi.app':     ('admin1234',  'admin'),
  'dho@safemothermalawi.app':       ('dho12345',   'dho'),
  'clinician@safemothermalawi.app': ('clinic1234', 'clinician'),
};

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _resetEmailCtrl = TextEditingController();

  bool _obscure      = true;
  bool _showReset    = false;   // toggles between login and forgot-password view
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
  void _submit() {
    final email    = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;
    final entry    = _credentials[email];

    if (entry == null || entry.$1 != password) {
      setState(() => _error = 'Invalid email or password.');
      return;
    }

    Widget dest;
    if (entry.$2 == 'admin') {
      dest = const AdminOverview();
    } else if (entry.$2 == 'dho') {
      dest = const DhoOverview();
    } else {
      dest = const ClinicianDashboard();
    }

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => dest),
      (_) => false,
    );
  }

  // ── Forgot password ────────────────────────────────────────────────────────
  void _submitReset() {
    final email = _resetEmailCtrl.text.trim().toLowerCase();
    final entry = _credentials[email];
    setState(() {
      if (entry == null) {
        _resetMessage = null;
        _error = 'No account found for that email.';
      } else {
        _error = null;
        _resetMessage = 'Your password is: ${entry.$1}';
      }
    });
  }

  // ── Close button ───────────────────────────────────────────────────────────
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

  // ── Login view ─────────────────────────────────────────────────────────────
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

        // Email
        TextFormField(
          controller: _emailCtrl,
          onChanged: (_) => setState(() => _error = null),
          decoration: _inputDecoration('Email address', Icons.email_outlined),
        ),
        const SizedBox(height: 14),

        // Password
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

        // Forgot password link
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

        // Sign in button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign In', style: TextStyle(fontSize: 15)),
          ),
        ),

        const SizedBox(height: 16),
        Center(
          child: Text(
            'Admin: admin@safemothermalawi.app\nDHO: dho@safemothermalawi.app\nClinician: clinician@safemothermalawi.app',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black38, height: 1.6),
          ),
        ),
      ],
    );
  }

  // ── Forgot password view ───────────────────────────────────────────────────
  Widget _buildResetView() {
    return Column(
      key: const ValueKey('reset'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Forgot password'),
        const SizedBox(height: 6),
        const Text('Enter your email and we\'ll retrieve your password.',
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
              Expanded(
                child: Text(_resetMessage!,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ],

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Retrieve Password', style: TextStyle(fontSize: 15)),
          ),
        ),

        const SizedBox(height: 12),

        // Back to login
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

  // ── Shared helpers ─────────────────────────────────────────────────────────
  Widget _buildHeader(String title) {
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: _navy),
        child: const Icon(Icons.local_hospital, color: Colors.white, size: 20),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                color: Color(0xFF0A1628))),
      ),
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
        Text(msg, style: const TextStyle(color: Colors.red, fontSize: 13)),
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
