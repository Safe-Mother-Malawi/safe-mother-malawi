import 'package:flutter/material.dart';

class NeonatalNutritionScreen extends StatefulWidget {
  const NeonatalNutritionScreen({super.key});

  @override
  State<NeonatalNutritionScreen> createState() =>
      _NeonatalNutritionScreenState();
}

class _NeonatalNutritionScreenState extends State<NeonatalNutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nutrition & Baby Care',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Feeding'),
            Tab(text: 'Care Tips'),
            Tab(text: 'Safe Practices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          const _FeedingTab(),
          const _CareTipsTab(),
          const _SafePracticesTab(),
        ],
      ),
    );
  }
}

// ── Feeding Tab ───────────────────────────────────────────────────────────────

class _FeedingTab extends StatelessWidget {
  const _FeedingTab();

  static const _foods = [
    {'name': 'Breast Milk', 'benefit': 'Best nutrition for newborns — provides antibodies and immunity', 'icon': Icons.child_care, 'color': 0xFF00897B},
    {'name': 'Colostrum', 'benefit': 'First milk — rich in antibodies, vital in first 3–5 days', 'icon': Icons.water_drop, 'color': 0xFF0288D1},
    {'name': 'Formula Milk', 'benefit': 'Safe alternative when breastfeeding is not possible', 'icon': Icons.local_drink, 'color': 0xFF6D4C41},
    {'name': 'Vitamin D Drops', 'benefit': 'Recommended for breastfed babies from birth', 'icon': Icons.wb_sunny, 'color': 0xFFE65100},
    {'name': 'Iron Supplements', 'benefit': 'Premature babies may need extra iron — consult your nurse', 'icon': Icons.medication, 'color': 0xFFD32F2F},
    {'name': 'Water', 'benefit': 'Not needed before 6 months — breast milk provides all fluids', 'icon': Icons.opacity, 'color': 0xFF0288D1},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionBanner(
          title: 'Feed Your Baby Well',
          subtitle: 'Nutrition guide for the first months of life',
          icon: Icons.child_care,
        ),
        const SizedBox(height: 16),
        ..._foods.map((f) => _FoodCard(
              name: f['name'] as String,
              benefit: f['benefit'] as String,
              icon: f['icon'] as IconData,
              color: Color(f['color'] as int),
            )),
      ],
    );
  }
}

// ── Care Tips Tab ─────────────────────────────────────────────────────────────

class _CareTipsTab extends StatelessWidget {
  const _CareTipsTab();

  static const _tips = [
    {'title': 'Skin-to-Skin Contact', 'body': 'Hold baby against your bare chest daily. Regulates temperature, heart rate, and bonding.', 'icon': Icons.favorite, 'color': 0xFFD81B60},
    {'title': 'Safe Sleep Position', 'body': 'Always place baby on their back to sleep. Never on tummy or side.', 'icon': Icons.bedtime, 'color': 0xFF6A1B9A},
    {'title': 'Umbilical Cord Care', 'body': 'Keep the stump clean and dry. It falls off in 1–3 weeks. Do not pull it.', 'icon': Icons.healing, 'color': 0xFF00695C},
    {'title': 'Bathing', 'body': 'Sponge baths only until cord falls off. Use warm water and mild soap.', 'icon': Icons.bathtub, 'color': 0xFF0288D1},
    {'title': 'Tummy Time', 'body': 'Start 2–3 minutes while awake. Builds neck and shoulder muscles.', 'icon': Icons.fitness_center, 'color': 0xFF2E7D32},
    {'title': 'Talk and Sing', 'body': 'Language development starts from day one. Talk, sing, and read to your baby.', 'icon': Icons.record_voice_over, 'color': 0xFFE65100},
    {'title': 'Hand Hygiene', 'body': 'Everyone who holds baby must wash hands first. Newborns have weak immunity.', 'icon': Icons.clean_hands, 'color': 0xFF1565C0},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _tips
          .map((t) => _TipCard(
                title: t['title'] as String,
                body: t['body'] as String,
                icon: t['icon'] as IconData,
                color: Color(t['color'] as int),
              ))
          .toList(),
    );
  }
}

// ── Safe Practices Tab ────────────────────────────────────────────────────────

class _SafePracticesTab extends StatelessWidget {
  const _SafePracticesTab();

  static const _avoid = [
    'Placing baby on soft bedding, pillows, or cushions',
    'Smoking near the baby or in the same room',
    'Giving water, juice, or solid food before 6 months',
    'Shaking the baby — even gently',
    'Using strong perfumes or chemicals near baby',
    'Leaving baby unattended on raised surfaces',
    'Sharing a bed with baby (risk of suffocation)',
  ];

  static const _safe = [
    'Washing hands before every feed and nappy change',
    'Keeping baby warm but not overheated (18–20°C room)',
    'Attending all well-baby clinic visits',
    'Completing the full vaccine schedule on time',
    'Breastfeeding exclusively for the first 6 months',
    'Monitoring wet nappies (6+ per day after day 5)',
    'Seeking help immediately if baby shows danger signs',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ListSection(
            title: 'What to Avoid',
            items: _avoid,
            color: const Color(0xFFC62828),
            icon: Icons.cancel),
        const SizedBox(height: 16),
        _ListSection(
            title: 'Safe Practices',
            items: _safe,
            color: const Color(0xFF2E7D32),
            icon: Icons.check_circle),
      ],
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _SectionBanner extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _SectionBanner(
      {required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF00695C), Color(0xFF00ACC1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: Colors.white38, size: 44),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final String name, benefit;
  final IconData icon;
  final Color color;
  const _FoodCard(
      {required this.name,
      required this.benefit,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
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
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF212121))),
                const SizedBox(height: 3),
                Text(benefit,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF757575))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title, body;
  final IconData icon;
  final Color color;
  const _TipCard(
      {required this.title,
      required this.body,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            width: 42,
            height: 42,
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

class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final IconData icon;
  const _ListSection(
      {required this.title,
      required this.items,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: color, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(item,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF424242)))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
