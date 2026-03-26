import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/animated_pulse_dot.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

enum AlertSeverity { critical, high }

class PatientAlert {
  final String id;
  final String patientName;
  final String status; // Prenatal / Postnatal
  final String contact;
  final String reason;
  final String detail;
  final String timeAgo;
  final AlertSeverity severity;
  bool dismissed;

  PatientAlert({
    required this.id, required this.patientName, required this.status,
    required this.contact, required this.reason, required this.detail,
    required this.timeAgo, required this.severity, this.dismissed = false,
  });
}

// ── Seed data (sorted: critical first, then high) ─────────────────────────────

final List<PatientAlert> _alertData = [
  PatientAlert(id: '1', patientName: 'Grace Banda',  status: 'Prenatal',  contact: '+265 991 234 567', reason: 'BP 148/96 — Severe hypertension',       detail: 'Severe headache, reduced fetal movement. Week 28. Immediate review required.',  timeAgo: '12 min ago',  severity: AlertSeverity.critical),
  PatientAlert(id: '2', patientName: 'Faith Mwale',  status: 'Prenatal',  contact: '+265 888 345 678', reason: 'BP 152/98 — Pre-eclampsia risk',         detail: 'Oedema and proteinuria detected. Week 34. Urgent assessment needed.',           timeAgo: '35 min ago',  severity: AlertSeverity.critical),
  PatientAlert(id: '3', patientName: 'Mercy Tembo',  status: 'Postnatal', contact: '+265 993 111 222', reason: 'Fever 37.9°C — Postnatal infection risk', detail: 'Day 8 postnatal. Breast tenderness and mild fever. Overdue checkup.',           timeAgo: '1 hr ago',    severity: AlertSeverity.high),
  PatientAlert(id: '4', patientName: 'Liness Kachali', status: 'Prenatal', contact: '+265 999 456 789', reason: 'Gestational diabetes — overdue review',  detail: 'Week 30. Blood sugar levels not reviewed in 2 weeks. Follow-up required.',     timeAgo: '2 hrs ago',   severity: AlertSeverity.high),
];

// ── Page ──────────────────────────────────────────────────────────────────────

class ClinicianAlertsPage extends StatefulWidget {
  const ClinicianAlertsPage({super.key});
  @override
  State<ClinicianAlertsPage> createState() => _ClinicianAlertsPageState();
}

class _ClinicianAlertsPageState extends State<ClinicianAlertsPage> {
  late List<PatientAlert> _alerts;
  String _filter = 'All'; // All | Critical | High | Prenatal | Postnatal
  String? _expandedId;

  @override
  void initState() {
    super.initState();
    _alerts = List.from(_alertData);
  }

  List<PatientAlert> get _filtered => _alerts.where((a) {
        if (a.dismissed) return false;
        if (_filter == 'Critical') return a.severity == AlertSeverity.critical;
        if (_filter == 'High') return a.severity == AlertSeverity.high;
        if (_filter == 'Prenatal') return a.status == 'Prenatal';
        if (_filter == 'Postnatal') return a.status == 'Postnatal';
        return true;
      }).toList();

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(children: [
            Icon(Icons.phone_disabled, color: AppColors.red, size: 20),
            SizedBox(width: 8),
            Text('Cannot Place Call', style: TextStyle(fontSize: 15)),
          ]),
          content: Text('Your device cannot make phone calls directly.\nPlease dial $number manually.',
              style: const TextStyle(fontSize: 13, color: AppColors.g600)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: AppColors.navy))),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final criticalCount = _alerts.where((a) => !a.dismissed && a.severity == AlertSeverity.critical).length;
    final highCount     = _alerts.where((a) => !a.dismissed && a.severity == AlertSeverity.high).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeader(criticalCount, highCount),
        const SizedBox(height: 20),
        _buildSummaryRow(criticalCount, highCount),
        const SizedBox(height: 20),
        _buildFilterRow(),
        const SizedBox(height: 16),
        if (list.isEmpty) _emptyState()
        else ...list.map((a) => _alertCard(a)),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader(int critical, int high) {
    return Row(children: [
      Stack(children: [
        const Icon(Icons.notifications_active_outlined, color: AppColors.red, size: 24),
        if (critical > 0)
          Positioned(right: 0, top: 0,
              child: Container(width: 9, height: 9,
                  decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle))),
      ]),
      const SizedBox(width: 10),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('High Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
            color: AppColors.g800)),
        Text('Critical and high-priority patient notifications.',
            style: TextStyle(fontSize: 13, color: AppColors.g400)),
      ])),
      // Refresh button
      OutlinedButton.icon(
        onPressed: () => setState(() {}),
        icon: const Icon(Icons.refresh, size: 15),
        label: const Text('Refresh', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.navy),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ]);
  }

  // ── Summary ───────────────────────────────────────────────────────────────────

  Widget _buildSummaryRow(int critical, int high) {
    return Row(children: [
      Expanded(child: _summaryCard('Critical', '$critical', AppColors.red, AppColors.redL,
          Icons.warning_rounded)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('High Priority', '$high', AppColors.amber, AppColors.amberL,
          Icons.info_outline)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Total Active', '${critical + high}', AppColors.navy,
          AppColors.navyL, Icons.notifications_outlined)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Dismissed', '${_alerts.where((a) => a.dismissed).length}',
          AppColors.g400, AppColors.g100, Icons.check_circle_outline)),
    ]);
  }

  Widget _summaryCard(String label, String value, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.g200)),
      child: Row(children: [
        Container(width: 38, height: 38,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.g400)),
        ]),
      ]),
    );
  }

  // ── Filter row ────────────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return Row(children: [
      const Text('Filter:', style: TextStyle(fontSize: 12, color: AppColors.g400)),
      const SizedBox(width: 10),
      for (final f in ['All', 'Critical', 'High', 'Prenatal', 'Postnatal']) ...[
        _filterChip(f),
        const SizedBox(width: 6),
      ],
    ]);
  }

  Widget _filterChip(String label) {
    final sel = _filter == label;
    Color color = AppColors.navy;
    if (label == 'Critical') color = AppColors.red;
    if (label == 'High') color = AppColors.amber;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? color : AppColors.g100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: sel ? Colors.white : AppColors.g600)),
      ),
    );
  }

  // ── Alert card ────────────────────────────────────────────────────────────────

  Widget _alertCard(PatientAlert a) {
    final isCritical = a.severity == AlertSeverity.critical;
    final color      = isCritical ? AppColors.red : AppColors.amber;
    final bg         = isCritical ? AppColors.redL : AppColors.amberL;
    final expanded   = _expandedId == a.id;

    return GestureDetector(
      onTap: () => setState(() => _expandedId = expanded ? null : a.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Main row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg.withOpacity(0.5),
              borderRadius: expanded
                  ? const BorderRadius.vertical(top: Radius.circular(12))
                  : BorderRadius.circular(12),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Pulsing dot
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 10),
                child: AnimatedPulseDot(color: color, size: 9),
              ),
              // Avatar
              CircleAvatar(radius: 18, backgroundColor: bg,
                  child: Text(a.patientName[0],
                      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              // Info
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(a.patientName, style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.bold, color: AppColors.g800)),
                  const SizedBox(width: 8),
                  _badge(isCritical ? 'CRITICAL' : 'HIGH', color, bg),
                  const SizedBox(width: 6),
                  _badge(a.status,
                      a.status == 'Prenatal' ? AppColors.navy : AppColors.rose,
                      a.status == 'Prenatal' ? AppColors.navyL : AppColors.roseL),
                ]),
                const SizedBox(height: 4),
                Text(a.reason, style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: color)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.access_time, size: 11, color: AppColors.g400),
                  const SizedBox(width: 4),
                  Text(a.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.g400)),
                  const SizedBox(width: 12),
                  const Icon(Icons.phone_outlined, size: 11, color: AppColors.g400),
                  const SizedBox(width: 4),
                  Text(a.contact, style: const TextStyle(fontSize: 11, color: AppColors.g600)),
                ]),
              ])),
              const SizedBox(width: 12),
              // Action buttons
              Column(children: [
                // Call button
                ElevatedButton.icon(
                  onPressed: () => _call(a.contact),
                  icon: const Icon(Icons.phone, size: 14),
                  label: const Text('Call', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(0, 34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 6),
                // Dismiss button
                OutlinedButton(
                  onPressed: () => setState(() => a.dismissed = true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.g400,
                    side: const BorderSide(color: AppColors.g200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: const Size(0, 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Dismiss', style: TextStyle(fontSize: 11)),
                ),
              ]),
              const SizedBox(width: 4),
              Icon(expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.g400, size: 18),
            ]),
          ),
          // Expanded detail
          if (expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.g200)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.navy),
                  const SizedBox(width: 6),
                  const Text('Alert Details', style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.bold, color: AppColors.g800)),
                ]),
                const SizedBox(height: 8),
                Text(a.detail, style: const TextStyle(fontSize: 12, color: AppColors.g600,
                    height: 1.6)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_note, size: 14),
                    label: const Text('Update Record', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navy),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.schedule, size: 14),
                    label: const Text('Schedule Checkup', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  )),
                ]),
              ]),
            ),
        ]),
      ),
    );
  }

  Widget _badge(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: const Center(child: Column(children: [
        Icon(Icons.check_circle_outline, color: AppColors.green, size: 48),
        SizedBox(height: 12),
        Text('No active alerts', style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.bold, color: AppColors.g800)),
        SizedBox(height: 4),
        Text('All patients are currently stable.', style: TextStyle(fontSize: 13,
            color: AppColors.g400)),
      ])),
    );
  }
}
