import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../auth/services/logout_helper.dart';

class NeonatalSettingsScreen extends StatefulWidget {
  const NeonatalSettingsScreen({super.key});

  @override
  State<NeonatalSettingsScreen> createState() => _NeonatalSettingsScreenState();
}

class _NeonatalSettingsScreenState extends State<NeonatalSettingsScreen> {
  bool _feedingReminders   = true;
  bool _vaccineAlerts      = true;
  bool _sleepReminders     = false;
  bool _dailyTips          = true;
  bool _appointmentAlerts  = true;
  bool _darkMode           = false;
  String _language         = 'English';
  String _units            = 'Metric (kg / cm)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mobilePageBg,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications
            _SectionHeader('NOTIFICATIONS'),
            _SettingsCard(children: [
              _SwitchTile(
                icon: Icons.local_drink_outlined,
                label: 'Feeding Reminders',
                subtitle: 'Remind me every 2–3 hours to feed baby',
                value: _feedingReminders,
                onChanged: (v) => setState(() => _feedingReminders = v),
              ),
              const _Divider(),
              _SwitchTile(
                icon: Icons.vaccines_outlined,
                label: 'Vaccine Alerts',
                subtitle: 'Notify me when a vaccine is due',
                value: _vaccineAlerts,
                onChanged: (v) => setState(() => _vaccineAlerts = v),
              ),
              const _Divider(),
              _SwitchTile(
                icon: Icons.bedtime_outlined,
                label: 'Sleep Reminders',
                subtitle: 'Remind me to log sleep sessions',
                value: _sleepReminders,
                onChanged: (v) => setState(() => _sleepReminders = v),
              ),
              const _Divider(),
              _SwitchTile(
                icon: Icons.lightbulb_outline,
                label: 'Daily Tips',
                subtitle: 'Receive a daily baby care tip',
                value: _dailyTips,
                onChanged: (v) => setState(() => _dailyTips = v),
              ),
              const _Divider(),
              _SwitchTile(
                icon: Icons.event_outlined,
                label: 'Appointment Alerts',
                subtitle: 'Remind me 24 hours before appointments',
                value: _appointmentAlerts,
                onChanged: (v) => setState(() => _appointmentAlerts = v),
              ),
            ]),

            const SizedBox(height: 20),

            // Preferences
            _SectionHeader('PREFERENCES'),
            _SettingsCard(children: [
              _SelectTile(
                icon: Icons.language_outlined,
                label: 'Language',
                value: _language,
                options: const ['English', 'Chichewa'],
                onChanged: (v) => setState(() => _language = v),
              ),
              const _Divider(),
              _SelectTile(
                icon: Icons.straighten_outlined,
                label: 'Units',
                value: _units,
                options: const ['Metric (kg / cm)', 'Imperial (lb / in)'],
                onChanged: (v) => setState(() => _units = v),
              ),
              const _Divider(),
              _SwitchTile(
                icon: Icons.dark_mode_outlined,
                label: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
            ]),

            const SizedBox(height: 20),

            // Privacy & Security
            _SectionHeader('PRIVACY & SECURITY'),
            _SettingsCard(children: [
              _ActionTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () => _showChangePasswordDialog(context),
              ),
              const _Divider(),
              _ActionTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => _showInfoDialog(context, 'Privacy Policy',
                    'Safe Mother Malawi collects only the data necessary to provide maternal and neonatal health services. Your data is stored securely and never shared with third parties without your consent.'),
              ),
              const _Divider(),
              _ActionTile(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () => _showInfoDialog(context, 'Terms of Service',
                    'By using Safe Mother Malawi, you agree to use the app for personal health tracking purposes only. The app does not replace professional medical advice.'),
              ),
            ]),

            const SizedBox(height: 20),

            // About
            _SectionHeader('ABOUT'),
            _SettingsCard(children: [
              _ActionTile(
                icon: Icons.info_outline,
                label: 'App Version',
                trailing: const Text('v1.0.0',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                onTap: () {},
              ),
              const _Divider(),
              _ActionTile(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () => _showInfoDialog(context, 'Help & Support',
                    'For assistance, contact us at support@safemothermalawi.org or call the SafeMother Helpline on 116.'),
              ),
              const _Divider(),
              _ActionTile(
                icon: Icons.star_outline,
                label: 'Rate the App',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 20),

            // Danger zone
            _SectionHeader('ACCOUNT'),
            _SettingsCard(children: [
              _ActionTile(
                icon: Icons.delete_outline,
                label: 'Clear All Data',
                color: AppColors.statusAmber,
                onTap: () => _confirmClearData(context),
              ),
              const _Divider(),
              _ActionTile(
                icon: Icons.logout,
                label: 'Sign Out',
                color: AppColors.statusRed,
                onTap: () => _confirmLogout(context),
              ),
            ]),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(hint: 'Current password', controller: currentCtrl, obscure: true),
            const SizedBox(height: 10),
            _DialogField(hint: 'New password', controller: newCtrl, obscure: true),
            const SizedBox(height: 10),
            _DialogField(hint: 'Confirm new password', controller: confirmCtrl, obscure: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated'), backgroundColor: AppColors.statusGreen),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mobileNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: Text(body,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.mobileNavy)),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Data',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: const Text('This will remove all locally stored data. This action cannot be undone.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusAmber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data cleared'), backgroundColor: AppColors.statusAmber),
      );
    }
  }

  void _confirmLogout(BuildContext context) async {
    await confirmAndLogout(context);
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
    child: Text(label,
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w800,
            color: AppColors.textMuted, letterSpacing: 1.2)),
  );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 56, endIndent: 16, color: AppColors.border);
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.icon, required this.label, this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: AppColors.mobileLightBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.mobileNavy, size: 20),
    ),
    title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    subtitle: subtitle != null
        ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
        : null,
    trailing: Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.mobileNavy,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Widget? trailing;
  const _ActionTile({required this.icon, required this.label, required this.onTap, this.color, this.trailing});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: (color ?? AppColors.mobileNavy).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color ?? AppColors.mobileNavy, size: 20),
    ),
    title: Text(label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color ?? AppColors.textPrimary)),
    trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.textMuted),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _SelectTile({required this.icon, required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: AppColors.mobileLightBg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: AppColors.mobileNavy, size: 20),
    ),
    title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    trailing: DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}

class _DialogField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  const _DialogField({required this.hint, required this.controller, this.obscure = false});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.mobileNavy)),
    ),
  );
}
