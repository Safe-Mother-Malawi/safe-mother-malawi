import 'package:flutter/material.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> with SingleTickerProviderStateMixin {
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
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        title: const Text('Nutrition & Health', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Nutrition'),
            Tab(text: 'Health Tips'),
            Tab(text: 'Safe Practices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _NutritionTab(),
          _HealthTipsTab(),
          _SafePracticesTab(),
        ],
      ),
    );
  }
}

class _NutritionTab extends StatelessWidget {
  final _foods = const [
    {'name': 'Leafy Greens', 'benefit': 'Rich in folate — prevents neural tube defects', 'icon': Icons.eco, 'color': 0xFF2E7D32},
    {'name': 'Beans & Lentils', 'benefit': 'High in iron and protein for baby\'s growth', 'icon': Icons.grain, 'color': 0xFF6D4C41},
    {'name': 'Dairy Products', 'benefit': 'Calcium for strong bones and teeth', 'icon': Icons.local_drink, 'color': 0xFF0288D1},
    {'name': 'Eggs', 'benefit': 'Choline supports brain development', 'icon': Icons.egg, 'color': 0xFFE65100},
    {'name': 'Sweet Potatoes', 'benefit': 'Beta-carotene for baby\'s vision', 'icon': Icons.restaurant, 'color': 0xFFE65100},
    {'name': 'Fish (low mercury)', 'benefit': 'Omega-3 for brain and eye development', 'icon': Icons.set_meal, 'color': 0xFF0288D1},
    {'name': 'Fruits', 'benefit': 'Vitamins C and antioxidants for immunity', 'icon': Icons.apple, 'color': 0xFFD32F2F},
    {'name': 'Whole Grains', 'benefit': 'Fibre and energy for mother and baby', 'icon': Icons.breakfast_dining, 'color': 0xFF6D4C41},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionBanner(
          title: 'Eat Well, Grow Strong',
          subtitle: 'Essential foods for a healthy pregnancy',
          icon: Icons.restaurant_menu,
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

class _HealthTipsTab extends StatelessWidget {
  final _tips = const [
    {'title': 'Stay Hydrated', 'body': 'Drink at least 8–10 glasses of water daily. Dehydration can cause contractions.', 'icon': Icons.water_drop, 'color': 0xFF0288D1},
    {'title': 'Rest Adequately', 'body': 'Aim for 8 hours of sleep. Sleep on your left side to improve blood flow.', 'icon': Icons.bedtime, 'color': 0xFF6A1B9A},
    {'title': 'Gentle Exercise', 'body': 'Walking and prenatal yoga are safe and beneficial. Avoid heavy lifting.', 'icon': Icons.directions_walk, 'color': 0xFF00695C},
    {'title': 'Manage Stress', 'body': 'Practice deep breathing and relaxation. High stress can affect baby\'s development.', 'icon': Icons.self_improvement, 'color': 0xFF1A237E},
    {'title': 'Take Prenatal Vitamins', 'body': 'Folic acid, iron, and calcium supplements are essential throughout pregnancy.', 'icon': Icons.medication, 'color': 0xFFE65100},
    {'title': 'Attend All Checkups', 'body': 'Regular antenatal visits help detect complications early.', 'icon': Icons.medical_services, 'color': 0xFFD32F2F},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _tips.map((t) => _TipCard(
        title: t['title'] as String,
        body: t['body'] as String,
        icon: t['icon'] as IconData,
        color: Color(t['color'] as int),
      )).toList(),
    );
  }
}

class _SafePracticesTab extends StatelessWidget {
  final _avoid = const [
    'Alcohol and tobacco in any amount',
    'Raw or undercooked meat and fish',
    'Unpasteurized dairy products',
    'High-mercury fish (shark, swordfish)',
    'Excessive caffeine (limit to 200mg/day)',
    'Contact sports or heavy lifting',
    'Hot tubs and saunas',
    'Certain medications without doctor approval',
  ];

  final _safe = const [
    'Washing hands frequently',
    'Cooking food thoroughly',
    'Wearing a seatbelt (below the bump)',
    'Gentle prenatal yoga and stretching',
    'Sleeping on your left side',
    'Using insect repellent (DEET-free)',
    'Dental checkups (safe during pregnancy)',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ListSection(title: 'What to Avoid', items: _avoid, color: const Color(0xFFC62828), icon: Icons.cancel),
        const SizedBox(height: 16),
        _ListSection(title: 'Safe Practices', items: _safe, color: const Color(0xFF2E7D32), icon: Icons.check_circle),
      ],
    );
  }
}

class _SectionBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _SectionBanner({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF283593)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
  final String name;
  final String benefit;
  final IconData icon;
  final Color color;
  const _FoodCard({required this.name, required this.benefit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF212121))),
                const SizedBox(height: 3),
                Text(benefit, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  const _TipCard({required this.title, required this.body, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            width: 42,
            height: 42,
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

class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final IconData icon;
  const _ListSection({required this.title, required this.items, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
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
                Expanded(child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF424242)))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
