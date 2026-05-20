import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_colors.dart';
import 'health_check_result_screen.dart';

class NeonatalHealthCheckScreen extends StatefulWidget {
  const NeonatalHealthCheckScreen({super.key});

  @override
  State<NeonatalHealthCheckScreen> createState() => _NeonatalHealthCheckScreenState();
}

class _NeonatalHealthCheckScreenState extends State<NeonatalHealthCheckScreen> {
  List<Map<String, dynamic>> _questions = [];
  Map<int, int> _answers = {}; // questionId -> 0 (NO) or 1 (YES)
  int _currentQuestionIndex = 0;
  bool _loading = true;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final result = await ApiService.getHealthCheckQuestions();
      final questions = (result['questions'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .toList() ?? [];
      
      debugPrint('=== NEONATAL QUESTIONS LOADED ===');
      debugPrint('Total questions: ${questions.length}');
      for (int i = 0; i < questions.length && i < 5; i++) {
        final q = questions[i];
        debugPrint('Q${i}: ID=${q['id']}, Text=${q['questionText']}, Weight=${q['weight']}');
      }
      debugPrint('=== END QUESTIONS ===');
      
      if (mounted) {
        setState(() {
          _questions = questions;
          _loading = false;
          if (questions.isEmpty) {
            _error = 'No questions available for your baby\'s stage';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load questions: ${e.toString()}';
          _loading = false;
        });
      }
    }
  }

  Future<void> _submitAssessment() async {
    if (_answers.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      debugPrint('=== NEONATAL SUBMITTING ASSESSMENT ===');
      debugPrint('Total answers: ${_answers.length}');
      debugPrint('YES answers: ${_answers.entries.where((e) => e.value == 1).length}');
      for (final entry in _answers.entries.where((e) => e.value == 1)) {
        debugPrint('  YES: Question ID ${entry.key}');
      }
      debugPrint('=== END SUBMIT ===');
      
      final answers = _questions.map((q) {
        final id = q['id'] as int;
        return {
          'questionId': id,
          'value': _answers[id] ?? 0,
        };
      }).toList();

      final result = await ApiService.submitHealthAssessment(answers);

      // Save to health check history
      await _saveToHistory(result);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => NeonatalHealthCheckResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _answerQuestion(int value) {
    setState(() {
      _answers[_questions[_currentQuestionIndex]['id']] = value;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  Future<void> _saveToHistory(Map<String, dynamic> result) async {
    try {
      await ApiService.saveHealthCheckResultToHistory(
        type: 'neonatal',
        result: result,
        questions: _questions,
        answers: _answers,
      );
    } catch (e) {
      debugPrint('Failed to save health check history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Baby Health Check'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Baby Health Check'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.criticalText),
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
                    _loadQuestions();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Baby Health Check'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No questions available'),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final currentAnswer = _answers[currentQuestion['id']] ?? -1;
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Health Check'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.infoBg,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question counter
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Question text
                    Text(
                      currentQuestion['questionText'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Severity tag if present
                    if (currentQuestion['severityTag'] != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(currentQuestion['severityTag']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getSeverityColor(currentQuestion['severityTag']),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Severity: ${currentQuestion['severityTag']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getSeverityColor(currentQuestion['severityTag']),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // YES/NO buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _answerQuestion(1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: currentAnswer == 1
                                    ? AppColors.successText
                                    : Colors.white,
                                border: Border.all(
                                  color: currentAnswer == 1
                                      ? AppColors.successText
                                      : const Color(0xFFE0E0E0),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 32,
                                    color: currentAnswer == 1
                                        ? Colors.white
                                        : AppColors.successText,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'YES',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: currentAnswer == 1
                                          ? Colors.white
                                          : AppColors.successText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _answerQuestion(0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: currentAnswer == 0
                                    ? AppColors.criticalText
                                    : Colors.white,
                                border: Border.all(
                                  color: currentAnswer == 0
                                      ? AppColors.criticalText
                                      : const Color(0xFFE0E0E0),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    size: 32,
                                    color: currentAnswer == 0
                                        ? Colors.white
                                        : AppColors.criticalText,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'NO',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: currentAnswer == 0
                                          ? Colors.white
                                          : AppColors.criticalText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'PREVIOUS',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : (_currentQuestionIndex == _questions.length - 1
                            ? _submitAssessment
                            : _nextQuestion),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.infoBg,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _currentQuestionIndex == _questions.length - 1
                                ? 'SUBMIT'
                                : 'NEXT',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity) {
      case 'HIGH':
        return AppColors.criticalText;
      case 'MEDIUM':
        return AppColors.warningText;
      case 'LOW':
        return AppColors.successText;
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
