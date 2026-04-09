import 'package:flutter/material.dart';
import '../models/neonatal_data.dart';

const _kGreen  = Color(0xFF388E3C);
const _kAmber  = Color(0xFFF57F17);
const _kGrey   = Color(0xFF757575);
const _kBg     = Color(0xFFE8F5F3);

class VaccinesScreen extends StatefulWidget {
  final NeonatalData? data;
  const VaccinesScreen({super.key, this.data});

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  late List<VaccineEntry> _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = widget.data?.vaccineSchedule ?? _defaultSchedule();
  }

  List<VaccineEntry> _defaultSchedule() {
    // Fallback if NeonatalData is not yet loaded (baby DOB unknown)
    return const [
      VaccineEntry(name: 'BCG (Tuberculosis)',            ageLabel: 'At birth',  dueDayAge: 0,   status: VaccineStatus.given),
      VaccineEntry(name: 'OPV-0 (Oral Polio)',            ageLabel: 'At birth',  dueDayAge: 0,   status: VaccineStatus.given),
      VaccineEntry(name: 'Hepatitis B · Birth dose',      ageLabel: 'At birth',  dueDayAge: 0,   status: VaccineStatus.given),
      VaccineEntry(name: 'OPV-1 + PCV-1 + Pentavalent-1',ageLabel: '6 weeks',   dueDayAge: 42,  status: VaccineStatus.upcoming),
      VaccineEntry(name: 'Rotavirus · Dose 1',            ageLabel: '6 weeks',   dueDayAge: 42,  status: VaccineStatus.upcoming),
      VaccineEntry(name: 'OPV-2 + PCV-2 + Pentavalent-2',ageLabel: '10 weeks',  dueDayAge: 70,  status: VaccineStatus.scheduled),
      VaccineEntry(name: 'Rotavirus · Dose 2',            ageLabel: '10 weeks',  dueDayAge: 70,  status: VaccineStatus.scheduled),
      VaccineEntry(name: 'OPV-3 + PCV-3 + Pentavalent-3',ageLabel: '14 weeks',  dueDayAge: 98,  status: VaccineStatus.scheduled),
      VaccineEntry(name: 'IPV (Inactivated Polio)',        ageLabel: '14 weeks',  dueDayAge: 98,  status: VaccineStatus.scheduled),
      VaccineEntry(name: 'Measles + Yellow Fever',         ageLabel: '9 months',  dueDayAge: 274, status: VaccineStatus.scheduled),
    ];
  }

  int get _givenCount =>
      _schedule.where((v) => v.status == VaccineStatus.given).length;

  double get _progress => _schedule.isEmpty ? 0 : _givenCount / _schedule.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.vaccines, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text('Vaccine Schedule',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Malawi EPI Schedule',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                    const SizedBox(height: 16),
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$_givenCount of ${_schedule.length} vaccines given',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _progress,
                                  backgroundColor: Colors.white30,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${(_progress * 100).round()}%',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  _InfoBanner(),
                  const SizedBox(height: 16),
                  // Group by age
                  ..._buildGroupedList(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedList() {
    final grouped = <String, List<VaccineEntry>>{};
    for (final v in _schedule) {
      grouped.putIfAbsent(v.ageLabel, () => []).add(v);
    }

    final widgets = <Widget>[];
    grouped.forEach((ageLabel, vaccines) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 4),
          child: Text(ageLabel.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: Color(0xFF9E9E9E), letterSpacing: 0.8)),
        ),
      );
      for (final v in vaccines) {
        widgets.add(_VaccineTile(entry: v));
      }
      widgets.add(const SizedBox(height: 8));
    });
    return widgets;
  }
}

// ── Info Banner ────────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCE93D8)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF6A1B9A), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Always bring your Health Passport to clinic visits. '
              'Consult your nurse or health worker if a vaccine is missed.',
              style: TextStyle(fontSize: 12, color: Color(0xFF4A148C), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vaccine Tile ───────────────────────────────────────────────────────────────

class _VaccineTile extends StatelessWidget {
  final VaccineEntry entry;
  const _VaccineTile({required this.entry});

  Color get _dotColor {
    switch (entry.status) {
      case VaccineStatus.given:     return _kGreen;
      case VaccineStatus.upcoming:  return _kAmber;
      case VaccineStatus.scheduled: return _kGrey;
    }
  }

  String get _badgeText {
    switch (entry.status) {
      case VaccineStatus.given:     return '✓ Given';
      case VaccineStatus.upcoming:  return 'Due Soon';
      case VaccineStatus.scheduled: return 'Scheduled';
    }
  }

  Color get _badgeBg {
    switch (entry.status) {
      case VaccineStatus.given:     return const Color(0xFFE8F5E9);
      case VaccineStatus.upcoming:  return const Color(0xFFFFF8E1);
      case VaccineStatus.scheduled: return const Color(0xFFF5F5F5);
    }
  }

  Color get _badgeText2 {
    switch (entry.status) {
      case VaccineStatus.given:     return _kGreen;
      case VaccineStatus.upcoming:  return _kAmber;
      case VaccineStatus.scheduled: return _kGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Status dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 12, height: 12,
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
              boxShadow: entry.status == VaccineStatus.upcoming
                  ? [BoxShadow(color: _dotColor.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 2)]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
                const SizedBox(height: 2),
                Text(entry.ageLabel,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_badgeText,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: _badgeText2)),
          ),
        ],
      ),
    );
  }
}
