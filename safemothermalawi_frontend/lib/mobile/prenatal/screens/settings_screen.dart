import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _appointmentReminders = true;
  bool _dailyTips = true;
  bool _babyMilestones = true;
  bool _healthAlerts = true;
  bool _darkMode = false;
  bool _offlineMode = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications
          _SettingsSection(title: 'Notifications', children: [
            _SwitchTile(icon: Icons.event, label: 'Appointment Reminders', subtitle: 'Get reminded before appointments', value: _appointmentReminders, onChanged: (v) => setState(() => _appointmentReminders = v)),
            _SwitchTile(icon: Icons.lightbulb_outline, label: 'Daily Tips', subtitle: 'Receive daily health & nutrition tips', value: _dailyTips, onChanged: (v) => setState(() => _dailyTips = v)),
            _SwitchTile(icon: Icons.star_outline, label: 'Baby Milestones', subtitle: 'Weekly development updates', value: _babyMilestones, onChanged: (v) => setState(() => _babyMilestones = v)),
            _SwitchTile(icon: Icons.warning_amber_outlined, label: 'Health Alerts', subtitle: 'Important health notifications', value: _healthAlerts, onChanged: (v) => setState(() => _healthAlerts = v)),
          ]),
          const SizedBox(height: 16),
          // App
          _SettingsSection(title: 'App Preferences', children: [
            _SwitchTile(icon: Icons.dark_mode_outlined, label: 'Dark Mode', subtitle: 'Switch to dark theme', value: _darkMode, onChanged: (v) => setState(() => _darkMode = v)),
            _SwitchTile(icon: Icons.offline_bolt_outlined, label: 'Offline Mode', subtitle: 'Cache data for offline access', value: _offlineMode, onChanged: (v) => setState(() => _offlineMode = v)),
            _SelectTile(icon: Icons.language, label: 'Language', value: _language, options: const ['English', 'Chichewa', 'Tumbuka'], onChanged: (v) => setState(() => _language = v)),
          ]),
          const SizedBox(height: 16),
          // Privacy
          _SettingsSection(title: 'Privacy & Security', children: [
            _NavTile(icon: Icons.lock_outline, label: 'Change Password', onTap: () {}),
            _NavTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
            _NavTile(icon: Icons.delete_outline, label: 'Delete Account', color: const Color(0xFFC62828), onTap: () => _confirmDelete(context)),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.w700)),
        content: const Text('This will permanently delete your account and all data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF9E9E9E), letterSpacing: 1.0)),
      ),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(
          children: children.asMap().entries.map((e) => Column(children: [
            e.value,
            if (e.key < children.length - 1) const Divider(height: 1, indent: 56),
          ])).toList(),
        ),
      ),
    ],
  );
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.icon, required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Icon(icon, size: 22, color: const Color(0xFFE91E8C)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF212121))),
        Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFFE91E8C)),
    ]),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Icon(icon, size: 22, color: const Color(0xFFE91E8C)),
      const SizedBox(width: 14),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF212121)))),
      DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    ]),
  );
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _NavTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 22, color: color ?? const Color(0xFFE91E8C)),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color ?? const Color(0xFF212121)))),
        Icon(Icons.arrow_forward_ios, size: 14, color: color ?? const Color(0xFF9E9E9E)),
      ]),
    ),
  );
}
