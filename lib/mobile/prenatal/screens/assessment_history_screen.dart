import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import 'health_check_screen.dart';

class PrenatalAssessmentHistoryScreen extends StatefulWidget {
  const PrenatalAssessmentHistoryScreen({super.key});

  @override
  State<PrenatalAssessmentHistoryScreen> createState() => _PrenatalAssessmentHistoryScreenState();
}

class _PrenatalAssessmentHistoryScreenState extends State<PrenatalAssessmentHistoryScreen> {
  List<Map<String, dynamic>> _assessments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final result = await ApiService.getAssessmentHistory();
      final assessments = result
          .cast<Map<String, dynamic>>()
          .toList();
      
      if (mounted) {
        setState(() {
          _assessments = assessments;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load history: ${e.toString()}';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment History'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A237E)),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Color(0xFFD32F2F)),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF212121)),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _loading = true;
                              _error = null;
                            });
                            _loadHistory();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : _assessments.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history, size: 64, color: Color(0xFFBBBEF0)),
                            const SizedBox(height: 16),
                            const Text(
                              'No assessments yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start your first health check to see results here',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const PrenatalHealthCheckScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              child: const Text(
                                'Start Health Check',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _assessments.length,
                      itemBuilder: (context, index) {
                        final assessment = _assessments[index];
                        final riskLevel = assessment['riskLevel'] as String? ?? 'Unknown';
                        final score = assessment['score'] as num? ?? 0;
                        final submittedAt = assessment['submittedAt'] as String?;
                        final date = submittedAt != null
                            ? DateTime.tryParse(submittedAt)
                            : null;
                        final formattedDate = date != null
                            ? DateFormat('MMM d, yyyy • h:mm a').format(date)
                            : 'Unknown date';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1A237E).withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _getRiskColor(riskLevel).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getRiskIcon(riskLevel),
                                      color: _getRiskColor(riskLevel),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          riskLevel,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: _getRiskColor(riskLevel),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9E9E9E),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Score: ${score.toStringAsFixed(1)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF757575),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8EAF6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFF1A237E),
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: _assessments.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const PrenatalHealthCheckScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF1A237E),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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
