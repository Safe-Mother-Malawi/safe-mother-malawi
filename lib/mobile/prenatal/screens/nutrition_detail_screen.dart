import 'package:flutter/material.dart';
import '../models/pregnancy_data.dart';

class NutritionDetailScreen extends StatelessWidget {
  final PregnancyData data;
  
  const NutritionDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nutrition Tips',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEBEE), Color(0xFFFFF0F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(data.nutritionEmoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  Text(
                    'Week ${data.currentWeek} Nutrition',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.trimester,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // This Week's Focus
            _SectionTitle('This Week\'s Focus'),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.star,
              iconColor: const Color(0xFFF9A825),
              title: data.nutritionSubtitle,
              content: data.nutritionTip,
            ),
            const SizedBox(height: 24),

            // Detailed Nutrition Guide
            _SectionTitle('Detailed Nutrition Guide'),
            const SizedBox(height: 12),
            _getNutritionDetails(data.currentWeek),
            const SizedBox(height: 24),

            // Foods to Include
            _SectionTitle('Foods to Include'),
            const SizedBox(height: 12),
            _getFoodsToInclude(data.currentWeek),
            const SizedBox(height: 24),

            // Foods to Avoid
            _SectionTitle('Foods to Avoid'),
            const SizedBox(height: 12),
            _getFoodsToAvoid(data.currentWeek),
            const SizedBox(height: 24),

            // Sample Meal Plan
            _SectionTitle('Sample Meal Ideas'),
            const SizedBox(height: 12),
            _getSampleMeals(data.currentWeek),
            const SizedBox(height: 24),

            // Hydration Reminder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.water_drop, color: Color(0xFF1A237E), size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stay Hydrated',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Drink 8-10 glasses of water daily. Add lemon or cucumber for flavor.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF616161)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _SectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF9E9E9E),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _InfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF616161),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getNutritionDetails(int week) {
    String details;
    if (week <= 12) {
      details = 'During the first trimester, focus on folic acid (400-800mcg daily) to prevent neural tube defects. '
          'Vitamin B6 helps reduce nausea. Iron supports increased blood volume. '
          'Eat small, frequent meals if experiencing morning sickness.';
    } else if (week <= 26) {
      details = 'The second trimester requires increased calories (about 300 extra per day). '
          'Calcium (1000mg daily) supports baby\'s bone development. '
          'Omega-3 fatty acids (especially DHA) are crucial for brain development. '
          'Protein needs increase to support rapid growth.';
    } else {
      details = 'In the third trimester, focus on iron to prevent anemia and support increased blood volume. '
          'Fiber helps with constipation. Smaller, frequent meals ease heartburn. '
          'Continue calcium and protein intake. Stay well-hydrated to support amniotic fluid.';
    }

    return _InfoCard(
      icon: Icons.info_outline,
      iconColor: const Color(0xFF1A237E),
      title: 'Why This Matters',
      content: details,
    );
  }

  Widget _getFoodsToInclude(int week) {
    List<Map<String, String>> foods;
    
    if (week <= 12) {
      foods = [
        {'name': 'Leafy Greens', 'benefit': 'Rich in folate and iron'},
        {'name': 'Whole Grains', 'benefit': 'Provide B vitamins and fiber'},
        {'name': 'Lean Proteins', 'benefit': 'Support tissue growth'},
        {'name': 'Citrus Fruits', 'benefit': 'Vitamin C aids iron absorption'},
        {'name': 'Legumes', 'benefit': 'Folate, iron, and protein'},
      ];
    } else if (week <= 26) {
      foods = [
        {'name': 'Dairy Products', 'benefit': 'Calcium for bone development'},
        {'name': 'Fatty Fish', 'benefit': 'Omega-3 for brain development'},
        {'name': 'Eggs', 'benefit': 'Complete protein and choline'},
        {'name': 'Nuts & Seeds', 'benefit': 'Healthy fats and minerals'},
        {'name': 'Colorful Vegetables', 'benefit': 'Vitamins A, C, and K'},
      ];
    } else {
      foods = [
        {'name': 'Red Meat', 'benefit': 'Iron to prevent anemia'},
        {'name': 'Dried Fruits', 'benefit': 'Iron and natural sugars'},
        {'name': 'Oats & Bran', 'benefit': 'Fiber for digestion'},
        {'name': 'Dates', 'benefit': 'May help with labor'},
        {'name': 'Sweet Potatoes', 'benefit': 'Vitamin A and fiber'},
      ];
    }

    return Column(
      children: foods.map((food) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food['name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      food['benefit']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _getFoodsToAvoid(int week) {
    final foods = [
      {'name': 'Raw/Undercooked Meat', 'reason': 'Risk of toxoplasmosis'},
      {'name': 'Unpasteurized Dairy', 'reason': 'Risk of listeria'},
      {'name': 'High-Mercury Fish', 'reason': 'Harmful to baby\'s brain'},
      {'name': 'Alcohol', 'reason': 'No safe amount during pregnancy'},
      {'name': 'Excessive Caffeine', 'reason': 'Limit to 200mg per day'},
    ];

    return Column(
      children: foods.map((food) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE57373).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.close, color: Color(0xFFD32F2F), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food['name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      food['reason']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _getSampleMeals(int week) {
    final meals = [
      {
        'meal': 'Breakfast',
        'suggestion': 'Oatmeal with berries, nuts, and milk',
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'meal': 'Mid-Morning Snack',
        'suggestion': 'Greek yogurt with honey and almonds',
        'icon': Icons.coffee_outlined,
      },
      {
        'meal': 'Lunch',
        'suggestion': 'Grilled chicken salad with whole grain bread',
        'icon': Icons.lunch_dining_outlined,
      },
      {
        'meal': 'Afternoon Snack',
        'suggestion': 'Apple slices with peanut butter',
        'icon': Icons.fastfood_outlined,
      },
      {
        'meal': 'Dinner',
        'suggestion': 'Baked fish with sweet potato and vegetables',
        'icon': Icons.dinner_dining_outlined,
      },
    ];

    return Column(
      children: meals.map((meal) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  meal['icon'] as IconData,
                  color: const Color(0xFF1A237E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal['meal'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meal['suggestion'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF616161),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

