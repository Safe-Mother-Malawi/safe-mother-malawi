import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ClinicianDashboardPage extends StatelessWidget {
  const ClinicianDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Page title
        const Text('Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
        const SizedBox(height: 20),
        // Welcome banner
        _buildWelcomeBanner(),
        const SizedBox(height: 20),
        // Metric cards
        _buildMetricsRow(),
        const SizedBox(height: 20),
        // Bottom two columns
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 3, child: _buildRecentPatients()),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildTodayAppointments()),
        ]),
      ]),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Welcome back, Dr. Rachel',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const Text('Clinician Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.calendar_today, color: Colors.white54, size: 12),
              const SizedBox(width: 4),
              const Text('Monday, 24 March 2026',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('1 critical alert',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ]),
          ]),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add, size: 16),
          label: const Text('Register Patient', style: TextStyle(fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.navy,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
      ]),
    );
  }

  Widget _buildMetricsRow() {
    return Row(children: [
      Expanded(child: _metricCard(Icons.people_outline, '6', 'Active Patients', 'This week',
          AppColors.navy, AppColors.navyL)),
      const SizedBox(width: 12),
      Expanded(child: _metricCard(Icons.pregnant_woman, '5', 'Pregnant', 'ANC active',
          const Color(0xFF7B1FA2), const Color(0xFFF3E5F5))),
      const SizedBox(width: 12),
      Expanded(child: _metricCard(Icons.child_friendly_outlined, '1', 'Postnatal', 'PNC active',
          AppColors.green, AppColors.greenL)),
      const SizedBox(width: 12),
      Expanded(child: _metricCard(Icons.warning_amber_outlined, '1', 'High Risk', 'Needs attention',
          AppColors.amber, AppColors.amberL)),
      const SizedBox(width: 12),
      Expanded(child: _metricCard(Icons.notifications_active_outlined, '2', 'Alerts', 'Active alerts',
          AppColors.red, AppColors.redL)),
    ]);
  }

  Widget _metricCard(IconData icon, String value, String label, String sub,
      Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, color: color, size: 20),
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ]),
        const SizedBox(height: 12),
        Text(value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color, height: 1)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.g400)),
      ]),
    );
  }

  Widget _buildRecentPatients() {
    final patients = [
      ('Grace Banda',  '28 yrs · G2P1 · BP: 110/70',  'Stable',   AppColors.green,  AppColors.greenL),
      ('Mary Phiri',   '35 yrs · G3P2 · BP: 140/90',  'Monitor',  AppColors.amber,  AppColors.amberL),
      ('Aisha Tembo',  '22 yrs · G1P0 · BP: 160/100', 'Critical', AppColors.red,    AppColors.redL),
      ('Fatima Chirwa','19 yrs · G1P0 · BP: 115/75',  'Stable',   AppColors.green,  AppColors.greenL),
      ('Joyce Mwale',  '40 yrs · G5P4 · BP: 125/80',  'Due Soon', AppColors.navy,   AppColors.navyL),
    ];

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.people_outline, color: AppColors.navy, size: 18),
            const SizedBox(width: 8),
            const Text('Recent Patients',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
          ]),
        ),
        const Divider(height: 1, color: AppColors.g200),
        ...patients.map((p) => _patientRow(p.$1, p.$2, p.$3, p.$4, p.$5)),
      ]),
    );
  }

  Widget _patientRow(String name, String sub, String status, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.g200, width: 0.5))),
      child: Row(children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.navyL,
          child: Text(name[0],
              style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.g800)),
            Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.g400)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
          child: Text(status,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ),
      ]),
    );
  }

  Widget _buildTodayAppointments() {
    final appts = [
      ('09:00 AM', 'Grace Banda — Antenatal'),
      ('10:30 AM', 'Mary Phiri — Ultrasound'),
      ('12:00 PM', 'Fatima Chirwa — First Visit'),
      ('02:00 PM', 'Joyce Mwale — Labour Assess.'),
      ('03:30 PM', 'Ruth Gondwe — Counselling'),
    ];

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.navy, size: 18),
            const SizedBox(width: 8),
            const Text("Today's Appointments",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.g800)),
          ]),
        ),
        const Divider(height: 1, color: AppColors.g200),
        ...appts.asMap().entries.map((e) => _appointmentRow(e.value.$1, e.value.$2, e.key)),
      ]),
    );
  }

  Widget _appointmentRow(String time, String title, int index) {
    final colors = [AppColors.navy, AppColors.amber, AppColors.green, AppColors.navy, AppColors.rose];
    final color = colors[index % colors.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.g200, width: 0.5))),
      child: Row(children: [
        Text(time,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.g600)),
        const SizedBox(width: 12),
        Container(width: 3, height: 32, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title,
              style: const TextStyle(fontSize: 12, color: AppColors.g800)),
        ),
      ]),
    );
  }
}
