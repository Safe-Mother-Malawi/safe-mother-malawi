import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../widgets/notification_icon.dart';
import 'notifications_screen.dart';
import '../../../services/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/splash_screen.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/validators.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  const SettingsScreen({super.key, this.onOpenDrawer});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ApiService _apiService;
  late AuthService _authService;

  // Notification preferences
  bool _appointmentReminders = true;
  bool _dailyTips = true;
  bool _babyMilestones = true;
  bool _healthAlerts = true;

  // App preferences
  bool _offlineMode = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _apiService = ApiService.instance;
    _authService = AuthService();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        // Load notification preferences
        _appointmentReminders = prefs.getBool('appointmentReminders') ?? true;
        _dailyTips = prefs.getBool('dailyTips') ?? true;
        _babyMilestones = prefs.getBool('babyMilestones') ?? true;
        _healthAlerts = prefs.getBool('healthAlerts') ?? true;
        
        // Load app preferences
        _offlineMode = prefs.getBool('offlineMode') ?? true;
        _selectedLanguage = prefs.getString('appLanguage') ?? 'English';
      });
      
      // Try to load from API as well (don't overwrite local prefs if API is slow)
      try {
        final apiPrefs = await _apiService.getPreferences();
        if (apiPrefs.isNotEmpty && mounted) {
          // Only update if values are different (avoid unnecessary rebuilds)
          final needsUpdate = 
            apiPrefs['appointmentReminders'] != _appointmentReminders ||
            apiPrefs['dailyTips'] != _dailyTips ||
            apiPrefs['babyMilestones'] != _babyMilestones ||
            apiPrefs['healthAlerts'] != _healthAlerts ||
            apiPrefs['offlineMode'] != _offlineMode ||
            apiPrefs['appLanguage'] != _selectedLanguage;
          
          if (needsUpdate) {
            setState(() {
              _appointmentReminders = apiPrefs['appointmentReminders'] ?? _appointmentReminders;
              _dailyTips = apiPrefs['dailyTips'] ?? _dailyTips;
              _babyMilestones = apiPrefs['babyMilestones'] ?? _babyMilestones;
              _healthAlerts = apiPrefs['healthAlerts'] ?? _healthAlerts;
              _offlineMode = apiPrefs['offlineMode'] ?? _offlineMode;
              _selectedLanguage = apiPrefs['appLanguage'] ?? _selectedLanguage;
            });
          }
        }
      } catch (e) {
        debugPrint('Failed to load preferences from API: $e');
        // Silently fail - local prefs are already loaded
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save to local storage
      await prefs.setBool('appointmentReminders', _appointmentReminders);
      await prefs.setBool('dailyTips', _dailyTips);
      await prefs.setBool('babyMilestones', _babyMilestones);
      await prefs.setBool('healthAlerts', _healthAlerts);
      await prefs.setBool('offlineMode', _offlineMode);
      await prefs.setString('appLanguage', _selectedLanguage);
      
      // Save to API
      try {
        await _apiService.savePreferences({
          'appointmentReminders': _appointmentReminders,
          'dailyTips': _dailyTips,
          'babyMilestones': _babyMilestones,
          'healthAlerts': _healthAlerts,
          'offlineMode': _offlineMode,
          'appLanguage': _selectedLanguage,
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to sync preferences to server'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        debugPrint('Failed to save preferences to API: $e');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(
        onPasswordChanged: () {
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<void> _showPrivacyPolicy() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This app collects health information to provide better maternal and neonatal care. '
            'All data is encrypted and stored securely. We do not share your information with third parties without your consent. '
            'For more information, please contact our support team.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. '
          'All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _apiService.deleteAccount();
                await _authService.logout();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting account: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _authService.logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NotificationIcon(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              iconColor: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NOTIFICATIONS SECTION
            _buildSectionHeader('NOTIFICATIONS'),
            _buildToggleSetting(
              icon: Icons.calendar_today,
              title: 'Appointment Reminders',
              subtitle: 'Get reminded before appointments',
              value: _appointmentReminders,
              onChanged: (value) {
                setState(() => _appointmentReminders = value);
                _savePreferences();
              },
            ),
            _buildToggleSetting(
              icon: Icons.lightbulb,
              title: 'Daily Tips',
              subtitle: 'Receive daily health & nutrition tips',
              value: _dailyTips,
              onChanged: (value) {
                setState(() => _dailyTips = value);
                _savePreferences();
              },
            ),
            _buildToggleSetting(
              icon: Icons.star,
              title: 'Baby Milestones',
              subtitle: 'Weekly development updates',
              value: _babyMilestones,
              onChanged: (value) {
                setState(() => _babyMilestones = value);
                _savePreferences();
              },
            ),
            _buildToggleSetting(
              icon: Icons.warning,
              title: 'Health Alerts',
              subtitle: 'Important health notifications',
              value: _healthAlerts,
              onChanged: (value) {
                setState(() => _healthAlerts = value);
                _savePreferences();
              },
            ),
            const SizedBox(height: 24),

            // APP PREFERENCES SECTION
            _buildSectionHeader('APP PREFERENCES'),
            _buildToggleSetting(
              icon: Icons.cloud_off,
              title: 'Offline Mode',
              subtitle: 'Cache data for offline access',
              value: _offlineMode,
              onChanged: (value) {
                setState(() => _offlineMode = value);
                _savePreferences();
              },
            ),
            const SizedBox(height: 24),

            // PRIVACY & SECURITY SECTION
            _buildSectionHeader('PRIVACY & SECURITY'),
            _buildActionSetting(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: _changePassword,
            ),
            _buildActionSetting(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: _showPrivacyPolicy,
            ),
            _buildActionSetting(
              icon: Icons.delete,
              title: 'Delete Account',
              titleColor: Colors.red,
              onTap: _deleteAccount,
            ),
            const SizedBox(height: 24),

            // ACCOUNT SECTION
            _buildSectionHeader('ACCOUNT'),
            _buildActionSetting(
              icon: Icons.logout,
              title: 'Sign Out',
              titleColor: Colors.red,
              onTap: _signOut,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9E9E9E),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildToggleSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E8FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1A237E), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1A237E),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E8FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.language, color: Color(0xFF1A237E), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButton<String>(
                  value: _selectedLanguage.isEmpty ? 'English' : _selectedLanguage,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'English', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedLanguage = value);
                      _savePreferences();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSetting({
    required IconData icon,
    required String title,
    Color titleColor = const Color(0xFF212121),
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E8FF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: titleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: titleColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: titleColor.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Change Password Dialog ────────────────────────────────────────────────────

class _ChangePasswordDialog extends StatefulWidget {
  final VoidCallback? onPasswordChanged;
  const _ChangePasswordDialog({this.onPasswordChanged});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Validate current password
    if (_currentPasswordController.text.isEmpty) {
      setState(() => _passwordError = 'Current password is required');
      return;
    }

    // Validate new password
    final newPasswordError = Validators.validatePassword(_newPasswordController.text);
    if (newPasswordError != null) {
      setState(() => _passwordError = newPasswordError);
      return;
    }

    // Validate password confirmation
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _passwordError = 'Passwords do not match');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Password Change'),
        content: const Text('Are you sure you want to change your password?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Change'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final apiService = ApiService.instance;
      await apiService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onPasswordChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _passwordError = 'Error: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: !_showCurrentPassword,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: Icon(_showCurrentPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: !_showNewPassword,
              onChanged: (_) => setState(() => _passwordError = null),
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
                ),
                helperText: 'Min 6 chars, uppercase, lowercase, number, special char',
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
              ),
              ),
            ),
            if (_passwordError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  _passwordError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Change'),
        ),
      ],
    );
  }
}
