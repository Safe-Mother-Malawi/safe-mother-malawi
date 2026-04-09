import 'package:flutter/material.dart';

class PregnancyTrackerScreen extends StatefulWidget {
  const PregnancyTrackerScreen({super.key});

  @override
  State<PregnancyTrackerScreen> createState() => _PregnancyTrackerScreenState();
}

class _PregnancyTrackerScreenState extends State<PregnancyTrackerScreen> {
  int _selectedWeek = 20;

  static const _weekData = {
    4: {'size': 'Poppy seed', 'length': '0.1 cm', 'weight': '< 1g', 'milestone': 'Implantation complete. Heart cells forming.', 'tip': 'Start taking folic acid daily.'},
    8: {'size': 'Raspberry', 'length': '1.6 cm', 'weight': '1g', 'milestone': 'All major organs are forming. Tiny fingers developing.', 'tip': 'Avoid alcohol and smoking completely.'},
    12: {'size': 'Lime', 'length': '5.4 cm', 'weight': '14g', 'milestone': 'Reflexes developing. Baby can open and close fists.', 'tip': 'Schedule your first trimester screening.'},
    16: {'size': 'Avocado', 'length': '11.6 cm', 'weight': '100g', 'milestone': 'Baby can hear sounds. Facial features more defined.', 'tip': 'Talk and sing to your baby — they can hear you!'},
    20: {'size': 'Banana', 'length': '16.4 cm', 'weight': '300g', 'milestone': 'Halfway there! Baby is swallowing and kicking.', 'tip': 'Get your anatomy scan this week.'},
    24: {'size': 'Corn', 'length': '21 cm', 'weight': '600g', 'milestone': 'Lungs developing. Baby responds to light and sound.', 'tip': 'Monitor baby movements daily.'},
    28: {'size': 'Eggplant', 'length': '25 cm', 'weight': '1 kg', 'milestone': 'Eyes open! Brain developing rapidly.', 'tip': 'Start preparing your birth plan.'},
    32: {'size': 'Squash', 'length': '28 cm', 'weight': '1.7 kg', 'milestone': 'Baby is practicing breathing. Gaining weight fast.', 'tip': 'Rest more and reduce heavy activity.'},
    36: {'size': 'Honeydew', 'length': '32 cm', 'weight': '2.6 kg', 'milestone': 'Baby is nearly full term. Head may engage.', 'tip': 'Pack your hospital bag now.'},
    40: {'size': 'Watermelon', 'length': '36 cm', 'weight': '3.4 kg', 'milestone': 'Full term! Baby is ready to meet you.', 'tip': 'Watch for signs of labour. Stay calm.'},
  };

  List<int> get _weeks => _weekData.keys.toList()..sort();

  Map<String, String> get _current {
    final sorted = _weeks;
    int closest = sorted.first;
    for (final w in sorted) {
      if (w <= _selectedWeek) closest = w;
    }
    return Map<String, String>.from(_weekData[closest]!);
  }

  @override
  Widget build(BuildContext context) {
    final data = _current;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        title: const Text('Pregnancy Tracker', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('Week $_selectedWeek of 40',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${40 - _selectedWeek} weeks remaining',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 14),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white30,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white24,
                    ),
                    child: Slider(
                      value: _selectedWeek.toDouble(),
                      min: 1,
                      max: 40,
                      divisions: 39,
                      onChanged: (v) => setState(() => _selectedWeek = v.round()),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Week 1', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      Text('Week 40', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Trimester badge
            _TrimesterBadge(week: _selectedWeek),
            const SizedBox(height: 20),
            // Baby size card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Baby Size', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(label: 'Size of', value: data['size']!),
                      _StatChip(label: 'Length', value: data['length']!),
                      _StatChip(label: 'Weight', value: data['weight']!),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Milestone
            _InfoCard(
              icon: Icons.star,
              color: const Color(0xFF6A1B9A),
              title: 'This Week\'s Milestone',
              body: data['milestone']!,
            ),
            const SizedBox(height: 14),
            // Health tip
            _InfoCard(
              icon: Icons.lightbulb_outline,
              color: const Color(0xFF00695C),
              title: 'Health Tip',
              body: data['tip']!,
            ),
            const SizedBox(height: 20),
            // Trimester overview
            const Text('Trimester Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
            const SizedBox(height: 12),
            _TrimesterRow(label: '1st Trimester', weeks: 'Weeks 1–12', active: _selectedWeek <= 12),
            const SizedBox(height: 8),
            _TrimesterRow(label: '2nd Trimester', weeks: 'Weeks 13–26', active: _selectedWeek > 12 && _selectedWeek <= 26),
            const SizedBox(height: 8),
            _TrimesterRow(label: '3rd Trimester', weeks: 'Weeks 27–40', active: _selectedWeek > 26),
          ],
        ),
      ),
    );
  }
}

class _TrimesterBadge extends StatelessWidget {
  final int week;
  const _TrimesterBadge({required this.week});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    if (week <= 12) {
      label = '1st Trimester';
      color = const Color(0xFF0288D1);
    } else if (week <= 26) {
      label = '2nd Trimester';
      color = const Color(0xFF00695C);
    } else {
      label = '3rd Trimester';
      color = const Color(0xFF6A1B9A);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _InfoCard({required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF212121))),
                const SizedBox(height: 6),
                Text(body, style: const TextStyle(fontSize: 13, color: Color(0xFF424242), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrimesterRow extends StatelessWidget {
  final String label;
  final String weeks;
  final bool active;
  const _TrimesterRow({required this.label, required this.weeks, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1A237E) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? const Color(0xFF1A237E) : const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(active ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: active ? Colors.white : const Color(0xFF9E9E9E), size: 18),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: active ? Colors.white : const Color(0xFF424242))),
          const Spacer(),
          Text(weeks, style: TextStyle(fontSize: 12, color: active ? Colors.white70 : const Color(0xFF9E9E9E))),
        ],
      ),
    );
  }
}
