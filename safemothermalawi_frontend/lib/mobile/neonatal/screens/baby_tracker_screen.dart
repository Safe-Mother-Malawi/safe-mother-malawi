import 'package:flutter/material.dart';
import '../models/neonatal_data.dart';

class BabyTrackerScreen extends StatefulWidget {
  final NeonatalData? data;
  const BabyTrackerScreen({super.key, this.data});

  @override
  State<BabyTrackerScreen> createState() => _BabyTrackerScreenState();
}

class _BabyTrackerScreenState extends State<BabyTrackerScreen> {
  int _selectedDay = 0;

  static const _milestoneData = {
    0:   {'size': 'Newborn',    'weight': '2.5–4.0 kg', 'length': '48–52 cm', 'milestone': 'Adjusting to the world. Recognizes your voice and smell.', 'tip': 'Skin-to-skin contact regulates temperature and heart rate.'},
    7:   {'size': 'Week 1',     'weight': '~3.0 kg',    'length': '~50 cm',   'milestone': 'Rooting and sucking reflexes strong. Sleeps 16–18 hrs/day.', 'tip': 'Watch for jaundice — yellow skin is common in week 1.'},
    14:  {'size': 'Week 2',     'weight': '~3.2 kg',    'length': '~51 cm',   'milestone': 'Regaining birth weight. More alert during wake windows.', 'tip': 'Tummy time starts now — 2–3 minutes while awake.'},
    21:  {'size': 'Week 3',     'weight': '~3.5 kg',    'length': '~52 cm',   'milestone': 'Briefly following faces. Grasping reflex active.', 'tip': 'Talk and sing — language development starts from day one.'},
    28:  {'size': 'Week 4',     'weight': '~3.8 kg',    'length': '~53 cm',   'milestone': 'May show a social smile. Tracking slow-moving objects.', 'tip': 'Umbilical cord should have fallen off by now.'},
    42:  {'size': '6 Weeks',    'weight': '~4.5 kg',    'length': '~55 cm',   'milestone': 'Holding head up briefly. Responding to familiar sounds.', 'tip': 'First vaccines due at 6 weeks — OPV, PCV, Pentavalent.'},
    56:  {'size': '8 Weeks',    'weight': '~5.0 kg',    'length': '~57 cm',   'milestone': 'Cooing and gurgling. Smiling at familiar faces.', 'tip': 'Improved eye contact — baby can see up to 60 cm clearly.'},
    84:  {'size': '12 Weeks',   'weight': '~5.8 kg',    'length': '~60 cm',   'milestone': 'Batting at objects. Laughing and vocalizing!', 'tip': 'Longer wake windows — 90 minutes between naps.'},
    112: {'size': '16 Weeks',   'weight': '~6.5 kg',    'length': '~63 cm',   'milestone': 'Rolling from tummy to back. Reaching for objects.', 'tip': 'Drooling increases — teething may begin soon.'},
    168: {'size': '6 Months',   'weight': '~7.5 kg',    'length': '~67 cm',   'milestone': 'Sitting with support. Babbling and exploring socially!', 'tip': 'Solid foods can begin at 6 months alongside breast milk.'},
  };

  List<int> get _days => _milestoneData.keys.toList()..sort();

  Map<String, String> get _current {
    final sorted = _days;
    int closest = sorted.first;
    for (final d in sorted) {
      if (d <= _selectedDay) closest = d;
    }
    return Map<String, String>.from(_milestoneData[closest]!);
  }

  @override
  Widget build(BuildContext context) {
    final data   = _current;
    final actual = widget.data;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Baby Tracker',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF00ACC1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('Day $_selectedDay of 168',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${168 - _selectedDay} days remaining in tracker',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 14),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white30,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white24,
                    ),
                    child: Slider(
                      value: _selectedDay.toDouble(),
                      min: 0,
                      max: 168,
                      divisions: 168,
                      onChanged: (v) =>
                          setState(() => _selectedDay = v.round()),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Day 0', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      Text('6 Months', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Current actual age badge
            if (actual != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF00897B).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${actual.babyName} is currently Day ${actual.ageInDays} · ${actual.stageLabel}',
                  style: const TextStyle(
                      color: Color(0xFF00695C),
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            const SizedBox(height: 20),

            // Size card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Baby Size & Growth',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121))),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(label: 'Stage', value: data['size']!),
                      _StatChip(label: 'Weight', value: data['weight']!),
                      _StatChip(label: 'Length', value: data['length']!),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Milestone
            _InfoCard(
              icon: Icons.star,
              color: const Color(0xFF00695C),
              title: 'Development Milestone',
              body: data['milestone']!,
            ),
            const SizedBox(height: 14),

            // Health tip
            _InfoCard(
              icon: Icons.lightbulb_outline,
              color: const Color(0xFF00897B),
              title: 'Care Tip',
              body: data['tip']!,
            ),
            const SizedBox(height: 20),

            // Stage overview
            const Text('Stage Overview',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121))),
            const SizedBox(height: 12),
            _StageRow(label: 'Newborn Phase',  days: 'Days 0–28',   active: _selectedDay <= 28),
            const SizedBox(height: 8),
            _StageRow(label: 'Early Infant',   days: 'Days 29–90',  active: _selectedDay > 28 && _selectedDay <= 90),
            const SizedBox(height: 8),
            _StageRow(label: 'Infant',         days: 'Days 91–168', active: _selectedDay > 90),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00695C))),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF757575))),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, body;
  const _InfoCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF212121))),
                const SizedBox(height: 6),
                Text(body,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF424242),
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  final String label, days;
  final bool active;
  const _StageRow(
      {required this.label, required this.days, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF00695C) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: active
                ? const Color(0xFF00695C)
                : const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(
              active
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: active ? Colors.white : const Color(0xFF9E9E9E),
              size: 18),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: active ? Colors.white : const Color(0xFF424242))),
          const Spacer(),
          Text(days,
              style: TextStyle(
                  fontSize: 12,
                  color: active
                      ? Colors.white70
                      : const Color(0xFF9E9E9E))),
        ],
      ),
    );
  }
}
