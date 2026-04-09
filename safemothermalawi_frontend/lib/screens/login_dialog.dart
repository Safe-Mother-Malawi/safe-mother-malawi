import 'package:flutter/material.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure       = true;

  static const _navy = Color(0xFF0D47A1);
  static const _bg   = Color(0xFFF0F6FF);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Determine role from email prefix for demo purposes.
  /// Real auth will replace this with a backend role check.
  String _detectRole() {
    final email = _emailCtrl.text.toLowerCase();
    if (email.contains('admin')) return 'admin';
    if (email.contains('dho')) return 'dho';
    return 'admin'; // default
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _navy),
                  child: const Icon(Icons.local_hospital, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Safe Mother Malawi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _navy)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(null),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06), shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: Colors.black54),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              const Text('Sign in to your account',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
              const SizedBox(height: 6),
              const Text('Enter your credentials to continue',
                  style: TextStyle(fontSize: 13, color: Colors.black45)),
              const SizedBox(height: 24),

              // Email
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  hintText: 'Email address',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: const Icon(Icons.email_outlined, color: _navy, size: 20),
                  filled: true, fillColor: _bg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              // Password
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixIcon: const Icon(Icons.lock_outline, color: _navy, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black38, size: 18),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  filled: true, fillColor: _bg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              // Sign in — returns detected role
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_detectRole()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Sign In', style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
