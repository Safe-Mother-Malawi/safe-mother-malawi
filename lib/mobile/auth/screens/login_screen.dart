import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/app_logo.dart';
import 'role_selection_screen.dart';
import 'email_forgot_password_screen.dart';
import '../../prenatal/prenatal_dashboard.dart';
import '../../neonatal/neonatal_dashboard.dart';
import '../../clinician/clinician_dashboard.dart';
import '../../../providers/mobile_user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _identCtrl    = TextEditingController(); // phone or email
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _identCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final user = await AuthService().login(
      _identCtrl.text.trim(),
      _passwordCtrl.text,
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (user != null) {
      // Populate reactive provider so any widget can read the current user
      context.read<MobileUserProvider>().update(user);

      // Mobile app only allows PRENATAL and NEONATAL users
      if (user.role == 'prenatal') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PrenatalDashboard()),
          (_) => false,
        );
      } else if (user.role == 'neonatal') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const NeonatalDashboard()),
          (_) => false,
        );
      } else if (user.role == 'clinician') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ClinicianDashboard()),
          (_) => false,
        );
      } else {
        // Block DHO, ADMIN roles — web portal only
        await AuthService().logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user.role.toUpperCase()} accounts use the web portal at safemothermalawi.vercel.app',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect phone/email or password.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmailForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Center(child: AppLogo(size: 220)),
                const SizedBox(height: 32),
                const Text(
                  'Login to your Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Use your phone number or email and password',
                  style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  hint: 'Phone Number or Email *',
                  controller: _identCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Phone number or email is required' : null,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  hint: 'Password *',
                  controller: _passwordCtrl,
                  obscure: true,
                  validator: (v) =>
                      v!.isEmpty ? 'Password is required' : null,
                ),
                const SizedBox(height: 10),
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _forgotPassword,
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1A237E),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AuthButton(
                    label: 'Sign in', onPressed: _login, loading: _loading),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ",
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF757575))),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RoleSelectionScreen()),
                      ),
                      child: const Text('Sign up',
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
      ),
    );
  }
}
