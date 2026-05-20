import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import 'health_check_screen.dart';
import 'assessment_history_screen.dart';

class PrenatalHealthCheckResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const PrenatalHealthCheckResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final riskLevel = result['riskLevel'] as String? ?? 'Unknown';
    final score = result['score'] as num? ?? 0;
    final maxScore = result['maxScore'] as num? ?? 1;
    final percentage = result['percentage'] as num? ?? 0;
    final message = result['message'] as String? ?? '';
    final answeredQuestions = (result['answeredQuestions'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>()
        .toList() ?? [];

    final riskColor = _getRiskColor(riskLevel);
    final riskIcon = _getRiskIcon(riskLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Result'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Risk level card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [riskColor, riskColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  Icon(riskIcon, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    riskLevel,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Score: ${score.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.1),
                      border: Border.all(color: riskColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: riskColor,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Question breakdown
                  const Text(
                    'Question Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: answeredQuestions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final q = entry.value;
                        final isYes = q['answer'] == 'YES';
                        final contributed = q['contributed'] as num? ?? 0;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isYes
                                          ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                                          : const Color(0xFFE0E0E0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isYes ? Icons.check : Icons.close,
                                      color: isYes
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFF9E9E9E),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          q['question'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF212121),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              'Answer: ${q['answer']}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF757575),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Weight: ${(q['weight'] as num?)?.toStringAsFixed(1) ?? '0'}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF9E9E9E),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: contributed > 0
                                                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                                                    : const Color(0xFFE0E0E0),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '+${contributed.toStringAsFixed(1)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: contributed > 0
                                                      ? const Color(0xFF4CAF50)
                                                      : const Color(0xFF9E9E9E),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index < answeredQuestions.length - 1)
                              const Divider(height: 1, color: Color(0xFFE0E0E0)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const PrenatalAssessmentHistoryScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF1A237E), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'VIEW HISTORY',
                            style: TextStyle(
                              color: Color(0xFF1A237E),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const PrenatalHealthCheckScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'NEW CHECK',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    if (riskLevel.contains('High') || riskLevel.contains('Seek Help')) {
      return const Color(0xFFC62828);
    } else if (riskLevel.contains('Moderate')) {
      return const Color(0xFFFF9800);
    } else if (riskLevel.contains('Low')) {
      return const Color(0xFF4CAF50);
    }
    return const Color(0xFF9E9E9E);
  }

  IconData _getRiskIcon(String riskLevel) {
    if (riskLevel.contains('High') || riskLevel.contains('Seek Help')) {
      return Icons.warning_rounded;
    } else if (riskLevel.contains('Moderate')) {
      return Icons.info_rounded;
    } else if (riskLevel.contains('Low')) {
      return Icons.check_circle_rounded;
    }
    return Icons.help_rounded;
  }
}
