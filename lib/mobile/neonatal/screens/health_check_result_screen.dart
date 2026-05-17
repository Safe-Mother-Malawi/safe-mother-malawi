import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'health_check_screen.dart';
import 'assessment_history_screen.dart';

class NeonatalHealthCheckResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const NeonatalHealthCheckResultScreen({
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
        backgroundColor: AppColors.primary,
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
                  colors: [riskColor, riskColor.withValues(alpha: 0.8)],
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
                      color: Colors.white.withValues(alpha: 0.2),
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
                      color: riskColor.withValues(alpha: 0.1),
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

                  // Action button - Retake Assessment only
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const NeonatalHealthCheckScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Retake Assessment',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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

  Color _getRiskColor(String riskLevel) {
    if (riskLevel.contains('High') || riskLevel.contains('Seek Help')) {
      return AppColors.criticalText;
    } else if (riskLevel.contains('Moderate')) {
      return AppColors.warningText;
    } else if (riskLevel.contains('Low')) {
      return AppColors.successText;
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
