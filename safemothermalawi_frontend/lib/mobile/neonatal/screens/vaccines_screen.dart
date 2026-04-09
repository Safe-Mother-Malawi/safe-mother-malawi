import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/neonatal_data.dart';

const _kGreen  = Color(0xFF388E3C);
const _kAmber  = Color(0xFFF57F17);
const _kGrey   = Color(0xFF757575);
const _kBg     = Color(0xFFF5F7FF);

// ── Persistence helpers ───────────────────────────────────────────────────────

Future<Set<String>> _loadGivenKeys() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('vaccine_given_keys')?.toSet() ?? {};
}

Future<void> _saveGivenKeys(Set<String> keys) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('vaccine_given_keys', keys.toList());
}

class VaccinesScreen extends StatefulWidget {
  final NeonatalData? data;
  const VaccinesScreen({super.key, this.data});

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  late List<VaccineEntry> _schedule;
  Set<String> _givenKeys = {};

  @override
  void initState() {
    super.initState();
    _schedule = widget.data?.vaccineSchedule ?? _defaultSchedule();
    _loadGivenKeys().then((keys) {
      if (!mounted) return;
      setState(() => _givenKeys = keys);
    });
  }

  List<VaccineEntry> _defaultSchedule() {
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

  // A vaccine is "given" if its original status was given OR the user toggled it on
  bool _isGiven(VaccineEntry v) =>
      v.status == VaccineStatus.given || _givenKeys.contains(v.name);

  void _toggle(VaccineEntry v) {
    // Vaccines that were auto-marked given at birth cannot be untoggled
    if (v.status == VaccineStatus.given && !_givenKeys.contains(v.name)) {
      // First tap on a birth-given vaccine — allow untoggling by adding a "removed" key
    }
    setState(() {
      if (_givenKeys.contains(v.name)) {
        _givenKeys.remove(v.name);
      } else {
        _givenKeys.add(v.name);
      }
    });
    _saveGivenKeys(_givenKeys);
  }

  int get _givenCount => _schedule.where(_isGiven).length;
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
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.vaccines, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        const Text('Vaccine Schedule',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white70, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Malawi EPI Schedule',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                    const SizedBox(height: 16),
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
                  _InfoBanner(),
                  const SizedBox(height: 16),
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
        widgets.add(_VaccineTile(
          entry: v,
          isGiven: _isGiven(v),
          onToggle: () => _toggle(v),
        ));
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
  final bool isGiven;
  final VoidCallback onToggle;
  const _VaccineTile({required this.entry, required this.isGiven, required this.onToggle});

  Color get _dotColor {
    if (isGiven) return _kGreen;
    switch (entry.status) {
      case VaccineStatus.upcoming:  return _kAmber;
      case VaccineStatus.scheduled: return _kGrey;
      default:                      return _kGrey;
    }
  }

  String get _badgeText {
    if (isGiven) return '✓ Given';
    switch (entry.status) {
      case VaccineStatus.upcoming:  return 'Due Soon';
      case VaccineStatus.scheduled: return '';
      default:                      return '';
    }
  }

  Color get _badgeBg {
    if (isGiven) return const Color(0xFFE8F5E9);
    switch (entry.status) {
      case VaccineStatus.upcoming:  return const Color(0xFFFFF8E1);
      case VaccineStatus.scheduled: return const Color(0xFFF5F5F5);
      default:                      return const Color(0xFFF5F5F5);
    }
  }

  Color get _badgeFg {
    if (isGiven) return _kGreen;
    switch (entry.status) {
      case VaccineStatus.upcoming:  return _kAmber;
      case VaccineStatus.scheduled: return _kGrey;
      default:                      return _kGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isGiven ? const Color(0xFFF1FBF2) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isGiven ? _kGreen.withValues(alpha: 0.35) : const Color(0xFFE0E0E0),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Toggle checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isGiven ? _kGreen : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isGiven ? _kGreen : _dotColor,
                  width: 2,
                ),
                boxShadow: isGiven
                    ? [BoxShadow(color: _kGreen.withValues(alpha: 0.3), blurRadius: 6, spreadRadius: 1)]
                    : null,
              ),
              child: isGiven
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.name,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isGiven ? const Color(0xFF388E3C) : const Color(0xFF212121),
                          decoration: isGiven ? TextDecoration.none : null)),
                  const SizedBox(height: 2),
                  Text(entry.ageLabel,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (_badgeText.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_badgeText,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _badgeFg)),
              ),
          ],
        ),
      ),
    );
  }
}
