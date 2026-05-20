import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../utils/validators.dart';

/// Secure password management dialog for admins
class PasswordManagementDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onPasswordReset;

  const PasswordManagementDialog({
    super.key,
    required this.user,
    this.onPasswordReset,
  });

  @override
  State<PasswordManagementDialog> createState() => _PasswordManagementDialogState();
}

class _PasswordManagementDialogState extends State<PasswordManagementDialog> {
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _useStrongPassword = true;
  String? _error;
  String? _generatedPassword;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _generateSecurePassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    var password = '';
    
    // Ensure at least one of each required character type
    password += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[(random % 26)];
    password += 'abcdefghijklmnopqrstuvwxyz'[(random % 26)];
    password += '0123456789'[(random % 10)];
    password += '!@#\$%^&*'[(random % 8)];
    
    // Fill remaining characters
    for (int i = 4; i < 12; i++) {
      password += chars[(random * i) % chars.length];
    }
    
    // Shuffle the password
    final shuffled = password.split('')..shuffle();
    _generatedPassword = shuffled.join();
    
    setState(() {
      _newPasswordCtrl.text = _generatedPassword!;
      _confirmPasswordCtrl.text = _generatedPassword!;
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword != null) {
      Clipboard.setData(ClipboardData(text: _generatedPassword!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password copied to clipboard'),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiService.instance.patch('/users/${widget.user['id']}/password', {
        'password': _newPasswordCtrl.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset successfully for ${widget.user['fullName']}'),
            backgroundColor: AppColors.green,
          ),
        );
        widget.onPasswordReset?.call();
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to reset password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.security, color: AppColors.red, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reset User Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.g800,
                          ),
                        ),
                        Text(
                          'User: ${widget.user['fullName']} (${widget.user['role']})',
                          style: const TextStyle(fontSize: 13, color: AppColors.g600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.g400),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Security Warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.red.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.red, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This will immediately change the user\'s password. They will need to use the new password to log in.',
                        style: TextStyle(fontSize: 13, color: AppColors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Password Strength Toggle
              Row(
                children: [
                  Checkbox(
                    value: _useStrongPassword,
                    onChanged: (value) => setState(() => _useStrongPassword = value ?? true),
                    activeColor: AppColors.navy,
                  ),
                  const Text(
                    'Use strong password requirements',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _generateSecurePassword,
                    icon: const Icon(Icons.auto_fix_high, size: 16),
                    label: const Text('Generate Secure'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.navy),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // New Password Field
              TextFormField(
                controller: _newPasswordCtrl,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: _useStrongPassword 
                      ? 'Min. 8 chars with uppercase, lowercase, number, special char'
                      : 'Min. 6 characters',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.navy),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_generatedPassword != null)
                        IconButton(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'Copy to clipboard',
                        ),
                      IconButton(
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                        icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: AppColors.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.g200),
                  ),
                ),
                validator: _useStrongPassword 
                    ? Validators.validatePassword 
                    : Validators.validatePasswordBasic,
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter the new password',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.navy),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18),
                  ),
                  filled: true,
                  fillColor: AppColors.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.g200),
                  ),
                ),
                validator: (value) => Validators.validatePasswordConfirmation(value, _newPasswordCtrl.text),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.g200),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Reset Password'),
                    ),
                  ),
                ],
              ),

              // Password Requirements Info
              if (_useStrongPassword) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Strong Password Requirements:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• At least 8 characters\n• At least one uppercase letter (A-Z)\n• At least one lowercase letter (a-z)\n• At least one number (0-9)\n• At least one special character (!@#\$%^&*)',
                        style: TextStyle(fontSize: 11, color: AppColors.g600),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}