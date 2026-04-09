import 'package:flutter/material.dart';
import '../models/pregnancy_data.dart';
import '../widgets/baby_illustration.dart';

class PregnancyDetailScreen extends StatelessWidget {
  final PregnancyData data;
  const PregnancyDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Week ${data.currentWeek} Details',
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large baby illustration — edge-to-edge, cover fit, gradient fade
            Container(
              width: double.infinity,
              height: 280,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF80AB).withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Warm gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFE4EE), Color(0xFFFCE4EC)],
                      ),
                    ),
                  ),
                  // Image — fills full area
                  Image.asset(
                    data.babyImageAsset,
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: BabyFallbackPainter(week: data.currentWeek, size: 220),
                    ),
                  ),
                  // Bottom fade into page background
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xFFFFF0F5)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Week + trimester badge
            Row(
              children: [
                _Badge(label: 'Week ${data.currentWeek}', color: const Color(0xFFE91E8C)),
                const SizedBox(width: 10),
                _Badge(label: data.trimester, color: const Color(0xFFAD1457)),
              ],
            ),
            const SizedBox(height: 20),

            // Stats grid
            Row(
              children: [
                Expanded(child: _DetailStat(label: 'Length', value: '${data.lengthCm} cm', icon: Icons.straighten)),
                const SizedBox(width: 12),
                Expanded(
                  child: _DetailStat(
                    label: 'Weight',
                    value: data.weightGrams >= 1000
                        ? '${(data.weightGrams / 1000).toStringAsFixed(1)} kg'
                        : '${data.weightGrams} g',
                    icon: Icons.monitor_weight_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _DetailStat(label: 'Day', value: '${data.daysPregnant}', icon: Icons.today)),
                const SizedBox(width: 12),
                Expanded(child: _DetailStat(label: 'Days Left', value: '${data.daysRemaining}', icon: Icons.hourglass_bottom)),
              ],
            ),
            const SizedBox(height: 20),

            // Size comparison
            _InfoSection(
              icon: Icons.eco,
              color: const Color(0xFF00695C),
              title: 'Size Comparison',
              body: 'Your baby is about the size of a ${data.babySize}.',
            ),
            const SizedBox(height: 12),

            // Milestone
            _InfoSection(
              icon: Icons.star_outline,
              color: const Color(0xFFE91E8C),
              title: 'This Week\'s Milestone',
              body: data.milestone,
            ),
            const SizedBox(height: 12),

            // Health tip
            _InfoSection(
              icon: Icons.lightbulb_outline,
              color: const Color(0xFFFF6F00),
              title: 'Health Tip',
              body: data.weeklyTip,
            ),
            const SizedBox(height: 24),

            // Progress bar
            const Text('Pregnancy Progress',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: data.progress,
                backgroundColor: const Color(0xFFFCE4EC),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E8C)),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(data.progress * 100).toStringAsFixed(0)}% complete',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFE91E8C), fontWeight: FontWeight.w500)),
                Text('${data.daysRemaining} days remaining',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DetailStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFFFF80AB).withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE91E8C), size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _InfoSection({required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
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
