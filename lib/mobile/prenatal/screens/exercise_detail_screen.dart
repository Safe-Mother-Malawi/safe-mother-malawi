import 'package:flutter/material.dart';
import '../models/pregnancy_data.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final PregnancyData data;
  
  const ExerciseDetailScreen({super.key, required this.data});

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
        title: const Text('Exercise Tips',
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
                  colors: [Color(0xFFE8F5E9), Color(0xFFEFF8F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(data.exerciseEmoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  Text(
                    'Week ${data.currentWeek} Exercise',
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
              icon: Icons.fitness_center,
              iconColor: const Color(0xFF4CAF50),
              title: data.exerciseSubtitle,
              content: data.exerciseTip,
            ),
            const SizedBox(height: 24),

            // Benefits of Exercise
            _SectionTitle('Benefits of Exercise'),
            const SizedBox(height: 12),
            _getBenefits(),
            const SizedBox(height: 24),

            // Recommended Exercises
            _SectionTitle('Recommended Exercises'),
            const SizedBox(height: 12),
            _getRecommendedExercises(data.currentWeek),
            const SizedBox(height: 24),

            // Safety Guidelines
            _SectionTitle('Safety Guidelines'),
            const SizedBox(height: 12),
            _getSafetyGuidelines(),
            const SizedBox(height: 24),

            // Warning Signs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE57373).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.warning_amber, color: Color(0xFFD32F2F), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Stop Exercise If You Experience:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...[
                    'Vaginal bleeding or fluid leakage',
                    'Dizziness or feeling faint',
                    'Chest pain or difficulty breathing',
                    'Severe headache',
                    'Contractions or abdominal pain',
                    'Decreased fetal movement',
                  ].map((warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Color(0xFFD32F2F), fontSize: 16)),
                        Expanded(
                          child: Text(
                            warning,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF616161)),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                  const Text(
                    'Contact your healthcare provider immediately if you experience any of these symptoms.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      fontStyle: FontStyle.italic,
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

  Widget _getBenefits() {
    final benefits = [
      {'icon': Icons.favorite, 'title': 'Improves Mood', 'desc': 'Reduces stress and anxiety'},
      {'icon': Icons.energy_savings_leaf, 'title': 'Boosts Energy', 'desc': 'Combats fatigue'},
      {'icon': Icons.nights_stay, 'title': 'Better Sleep', 'desc': 'Improves sleep quality'},
      {'icon': Icons.fitness_center, 'title': 'Builds Strength', 'desc': 'Prepares for labor'},
      {'icon': Icons.healing, 'title': 'Faster Recovery', 'desc': 'Quicker postpartum healing'},
    ];

    return Column(
      children: benefits.map((benefit) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: const Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      benefit['desc'] as String,
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

  Widget _getRecommendedExercises(int week) {
    List<Map<String, dynamic>> exercises;
    
    if (week <= 12) {
      exercises = [
        {
          'name': 'Walking',
          'duration': '15-20 minutes',
          'desc': 'Low-impact cardio, safe throughout pregnancy',
          'icon': Icons.directions_walk,
        },
        {
          'name': 'Prenatal Yoga',
          'duration': '20-30 minutes',
          'desc': 'Improves flexibility and reduces stress',
          'icon': Icons.self_improvement,
        },
        {
          'name': 'Swimming',
          'duration': '20-30 minutes',
          'desc': 'Gentle on joints, full-body workout',
          'icon': Icons.pool,
        },
        {
          'name': 'Pelvic Floor Exercises',
          'duration': '10 minutes',
          'desc': 'Strengthens muscles for delivery',
          'icon': Icons.favorite,
        },
      ];
    } else if (week <= 26) {
      exercises = [
        {
          'name': 'Brisk Walking',
          'duration': '30 minutes',
          'desc': 'Maintains cardiovascular fitness',
          'icon': Icons.directions_walk,
        },
        {
          'name': 'Prenatal Yoga',
          'duration': '30-45 minutes',
          'desc': 'Builds strength and balance',
          'icon': Icons.self_improvement,
        },
        {
          'name': 'Squats',
          'duration': '10-15 reps',
          'desc': 'Strengthens legs for labor',
          'icon': Icons.fitness_center,
        },
        {
          'name': 'Pelvic Tilts',
          'duration': '10-15 reps',
          'desc': 'Relieves back pain',
          'icon': Icons.accessibility_new,
        },
        {
          'name': 'Swimming',
          'duration': '30 minutes',
          'desc': 'Low-impact full-body exercise',
          'icon': Icons.pool,
        },
      ];
    } else {
      exercises = [
        {
          'name': 'Gentle Walking',
          'duration': '20-30 minutes',
          'desc': 'Maintains fitness, may encourage labor',
          'icon': Icons.directions_walk,
        },
        {
          'name': 'Modified Yoga',
          'duration': '20-30 minutes',
          'desc': 'Gentle stretches for comfort',
          'icon': Icons.self_improvement,
        },
        {
          'name': 'Pelvic Floor Exercises',
          'duration': '10-15 minutes',
          'desc': 'Prepares for pushing',
          'icon': Icons.favorite,
        },
        {
          'name': 'Birthing Ball Exercises',
          'duration': '15-20 minutes',
          'desc': 'Helps baby engage, eases discomfort',
          'icon': Icons.sports_basketball,
        },
        {
          'name': 'Gentle Stretching',
          'duration': '10-15 minutes',
          'desc': 'Relieves aches, improves sleep',
          'icon': Icons.accessibility,
        },
      ];
    }

    return Column(
      children: exercises.map((exercise) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  exercise['icon'] as IconData,
                  color: const Color(0xFF1A237E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise['duration'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise['desc'] as String,
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

  Widget _getSafetyGuidelines() {
    final guidelines = [
      'Always warm up before and cool down after exercise',
      'Stay hydrated — drink water before, during, and after',
      'Avoid exercises lying flat on your back after 20 weeks',
      'Don\'t exercise in hot, humid weather',
      'Listen to your body — rest when needed',
      'Avoid contact sports and activities with fall risk',
      'Wear comfortable, supportive clothing and shoes',
      'Consult your healthcare provider before starting',
    ];

    return Column(
      children: guidelines.map((guideline) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFA726).withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFF57C00), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  guideline,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF616161),
                  ),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}
