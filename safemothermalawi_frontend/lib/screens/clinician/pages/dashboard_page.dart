import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service_web.dart';

class ClinicianDashboardPage extends StatefulWidget {
  final VoidCallback? onRegisterPatient;
  const ClinicianDashboardPage({super.key, this.onRegisterPatient});

  @override
  State<ClinicianDashboardPage> createState() => _ClinicianDashboardPageState();
}

class _ClinicianDashboardPageState extends State<ClinicianDashboardPage> {
  bool _loading = true;
  String? _error;

  int _prenatalCount  = 0;
  int _neonatalCount  = 0;
  int _alertCount     = 0;
  String _userName    = '';

  List<Map<String, dynamic>> _recentPrenatal = [];
  List<Map<String, dynamic>> _todayAppts     = [];

  @override
  void initState() {
    super.initState();
    _userName = AuthServiceWeb.instance.userName;
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ApiService.instance.get('/patients/prenatal').catchError((_) => <dynamic>[]),
        ApiService.instance.get('/patients/neonatal').catchError((_) => <dynamic>[]),
        ApiService.instance.get('/alerts/active').catchError((_) => <dynamic>[]),
        ApiService.instance.get('/appointments?upcoming=true').catchError((_) => <dynamic>[]),
      ]);

      final prenatal = (results[0] is List ? results[0] as List : [])
          .whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      final neonatal = (results[1] is List ? results[1] as List : [])
          .whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      final alerts   = (results[2] is List ? results[2] as List : [])
          .whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      final appts    = (results[3] is List ? results[3] as List : [])
          .whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

      final today = DateTime.now().toIso8601String().substring(0, 10);
      final todayAppts = appts
          .where((a) => (a['date'] as String?)?.startsWith(today) == true)
          .toList();

      if (!mounted) return;
      setState(() {
        _prenatalCount  = prenatal.length;
        _neonatalCount  = neonatal.length;
        _alertCount     = alerts.length;
        _recentPrenatal = prenatal.take(5).toList();
        _todayAppts     = todayAppts.take(5).toList();
        _loading        = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        const Text('Failed to load dashboard'),
        TextButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Retry')),
      ]));
    }

    final now = DateTime.now();
    final dateStr = '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
        const SizedBox(height: 20),

        // Welcome banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome back, $_userName', style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Metric cards
        Row(children: [
          Expanded(child: _metricCard(Icons.people_outline, '${_prenatalCount + _neonatalCount}', 'Active Patients', 'Total', AppColors.navy, AppColors.navyL)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard(Icons.pregnant_woman, '$_prenatalCount', 'Pregnant', 'ANC active', AppColors.navy, AppColors.navyL)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard(Icons.child_friendly_outlined, '$_neonatalCount', 'Neonatal', 'PNC active', AppColors.navy, AppColors.navyL)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard(Icons.notifications_active_outlined, '$_alertCount', 'Alerts', 'Active alerts', AppColors.orange, AppColors.orangeL)),
        ]),
        const SizedBox(height: 20),

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 3, child: _buildRecentPatients()),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildTodayAppointments()),
        ]),
      ]),
    );
  }

  Widget _metricCard(IconData icon, String value, String label, String sub, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      ]),
    );
  }

  Widget _buildRecentPatients() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(children: [
            Icon(Icons.people_outline, color: AppColors.navy, size: 18),
            SizedBox(width: 8),
            Text('Recent Prenatal Patients', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
          ]),
        ),
        const Divider(height: 1, color: AppColors.g200),
        if (_recentPrenatal.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No patients yet.', style: TextStyle(color: AppColors.g400))),
          )
        else
          ..._recentPrenatal.map((p) {
            final name = p['fullName'] as String? ?? 'Unknown';
            final age  = p['age']?.toString() ?? '?';
            final months = p['pregnancyMonths']?.toString() ?? '?';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.g200, width: 0.5))),
              child: Row(children: [
                CircleAvatar(radius: 16, backgroundColor: AppColors.navyL,
                    child: Text(name[0], style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.g800)),
                  Text('$age yrs · $months months pregnant', style: const TextStyle(fontSize: 10, color: AppColors.g400)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Prenatal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navy)),
                ),
              ]),
            );
          }),
      ]),
    );
  }

  Widget _buildTodayAppointments() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined, color: AppColors.navy, size: 18),
            SizedBox(width: 8),
            Text("Today's Appointments", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
          ]),
        ),
        const Divider(height: 1, color: AppColors.g200),
        if (_todayAppts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No appointments today.', style: TextStyle(color: AppColors.g400))),
          )
        else
          ..._todayAppts.map((a) {
            final time  = a['time'] as String? ?? '--:--';
            final title = a['title'] as String? ?? a['patientName'] as String? ?? 'Appointment';
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
          }),
      ]),
    );
  }

  String _weekday(int d) => const ['','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'][d];
  String _month(int m) => const ['','January','February','March','April','May','June','July','August','September','October','November','December'][m];
}
