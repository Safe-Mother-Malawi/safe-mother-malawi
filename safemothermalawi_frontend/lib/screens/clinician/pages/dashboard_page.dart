import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';

class ClinicianDashboardPage extends StatefulWidget {
  final VoidCallback? onRegisterPatient;
  const ClinicianDashboardPage({super.key, this.onRegisterPatient});
  @override
  State<ClinicianDashboardPage> createState() => _ClinicianDashboardPageState();
}

class _ClinicianDashboardPageState extends State<ClinicianDashboardPage> {
  List<dynamic> _prenatal = [];
  List<dynamic> _neonatal = [];
  List<dynamic> _alerts   = [];
  List<dynamic> _todayAppts = [];
  bool _loading = true;
  String? _me;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final results = await Future.wait([
        ApiService.getPrenatalPatients(),
        ApiService.getNeonatalPatients(),
        ApiService.getActiveAlerts(),
        ApiService.getAppointments(date: today),
        ApiService.getMe(),
      ]);
      setState(() {
        _prenatal   = results[0] as List<dynamic>;
        _neonatal   = results[1] as List<dynamic>;
        _alerts     = results[2] as List<dynamic>;
        _todayAppts = results[3] as List<dynamic>;
        _me = (results[4] as Map<String, dynamic>)['fullName']?.toString() ?? 'Clinician';
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final recentPatients = [..._prenatal, ..._neonatal].take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
        const SizedBox(height: 20),
        _buildWelcomeBanner(),
        const SizedBox(height: 20),
        _buildMetricsRow(),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 3, child: _buildRecentPatients(recentPatients)),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildTodayAppointments()),
        ]),
      ]),
    );
  }

  Widget _buildWelcomeBanner() {
    final now = DateTime.now();
    final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 24)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome back, $_me', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const Text('Clinician Dashboard', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today, color: Colors.white54, size: 12),
            const SizedBox(width: 4),
            Text(dateStr, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        ])),
        ElevatedButton.icon(
          onPressed: widget.onRegisterPatient,
          icon: const Icon(Icons.person_add, size: 16),
          label: const Text('Register Patient', style: TextStyle(fontSize: 13)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
        ),
      ]),
    );
  }

  Widget _buildMetricsRow() {
    return Row(children: [
      Expanded(child: _metricCard(Icons.people_outline, '${_prenatal.length + _neonatal.length}', 'Active Patients', 'Total', AppColors.navy, AppColors.navyL)),
      const SizedBox(width: 12),
      Expanded(child: _metricCard(Icons.pregnant_woman, '${_prenatal.length}', 'Prenatal', 'ANC active', AppColors.navy, AppColors.navyL)),
      const SizedBox(width: 12),
      Expanded(child: _metricCard(Icons.child_friendly_outlined, '${_neonatal.length}', 'Neonatal', 'PNC active', AppColors.navy, AppColors.navyL)),
      const SizedBox(width: 12),
      Expanded(child: _metricCard(Icons.notifications_active_outlined, '${_alerts.length}', 'Alerts', 'Active alerts', AppColors.orange, AppColors.orangeL)),
    ]);
  }

  Widget _metricCard(IconData icon, String value, String label, String sub, Color color, Color bgColor) {
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, color: color, size: 20),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ]),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color, height: 1)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.g400)),
      ]));
  }

  Widget _buildRecentPatients(List<dynamic> patients) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          const Icon(Icons.people_outline, color: AppColors.navy, size: 18),
          const SizedBox(width: 8),
          const Text('Recent Patients', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
        ])),
        const Divider(height: 1, color: AppColors.g200),
        if (patients.isEmpty)
          const Padding(padding: EdgeInsets.all(24),
              child: Text('No patients registered yet.', style: TextStyle(color: AppColors.g400, fontSize: 13)))
        else
          ...patients.map((p) {
            final isPrenatal = p['fullName'] != null;
            final name = isPrenatal ? (p['fullName'] ?? '') : (p['motherName'] ?? '');
            final sub  = isPrenatal
                ? 'Prenatal · ${p['district'] ?? '—'}'
                : 'Neonatal · Baby: ${p['babyName'] ?? '—'}';
            return _patientRow(name.toString(), sub, 'Registered', AppColors.green, AppColors.greenL);
          }),
      ]),
    );
  }

  Widget _patientRow(String name, String sub, String status, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.g200, width: 0.5))),
      child: Row(children: [
        CircleAvatar(radius: 16, backgroundColor: AppColors.navyL,
            child: Text(name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.g800)),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.g400)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color))),
      ]),
    );
  }

  Widget _buildTodayAppointments() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          const Icon(Icons.calendar_today_outlined, color: AppColors.navy, size: 18),
          const SizedBox(width: 8),
          const Text("Today's Appointments", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
        ])),
        const Divider(height: 1, color: AppColors.g200),
        if (_todayAppts.isEmpty)
          const Padding(padding: EdgeInsets.all(24),
              child: Text('No appointments today.', style: TextStyle(color: AppColors.g400, fontSize: 13)))
        else
          ..._todayAppts.take(5).map((a) => _appointmentRow(
            a['time']?.toString() ?? '—',
            '${a['patientName']} — ${a['title']}',
          )),
      ]),
    );
  }

  Widget _appointmentRow(String time, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.g200, width: 0.5))),
      child: Row(children: [
        Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.g600)),
        const SizedBox(width: 12),
        Container(width: 3, height: 32, color: AppColors.navy),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 12, color: AppColors.g800))),
      ]),
    );
  }
}
