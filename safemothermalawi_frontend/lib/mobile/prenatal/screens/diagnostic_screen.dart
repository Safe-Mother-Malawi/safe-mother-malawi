import 'package:flutter/material.dart';
import '../../clinician/services/risk_service.dart';
import '../../clinician/models/risk_record.dart';
import '../../auth/services/auth_service.dart';

class DiagnosticQuestion {
  final String question;
  final List<DiagnosticOption> options;
  DiagnosticQuestion({required this.question, required this.options});
}

class DiagnosticOption {
  final String text;
  final int weight;
  DiagnosticOption({required this.text, required this.weight});
}

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  final _questions = [
    DiagnosticQuestion(question: 'How are you feeling today?', options: [
      DiagnosticOption(text: 'Very well', weight: 0),
      DiagnosticOption(text: 'Slightly tired', weight: 1),
      DiagnosticOption(text: 'Unwell / nauseous', weight: 3),
      DiagnosticOption(text: 'In pain', weight: 5),
    ]),
    DiagnosticQuestion(question: 'Do you have any headaches?', options: [
      DiagnosticOption(text: 'No headaches', weight: 0),
      DiagnosticOption(text: 'Mild headache', weight: 1),
      DiagnosticOption(text: 'Severe headache', weight: 4),
      DiagnosticOption(text: 'Headache with blurred vision', weight: 6),
    ]),
    DiagnosticQuestion(question: 'Have you noticed any swelling?', options: [
      DiagnosticOption(text: 'No swelling', weight: 0),
      DiagnosticOption(text: 'Mild foot swelling', weight: 2),
      DiagnosticOption(text: 'Swollen hands and face', weight: 5),
      DiagnosticOption(text: 'Sudden severe swelling', weight: 7),
    ]),
    DiagnosticQuestion(question: 'How is your baby\'s movement?', options: [
      DiagnosticOption(text: 'Moving normally', weight: 0),
      DiagnosticOption(text: 'Less active than usual', weight: 3),
      DiagnosticOption(text: 'No movement felt today', weight: 7),
      DiagnosticOption(text: 'Too early to feel movement', weight: 0),
    ]),
    DiagnosticQuestion(question: 'Do you have any bleeding or discharge?', options: [
      DiagnosticOption(text: 'None', weight: 0),
      DiagnosticOption(text: 'Light spotting', weight: 3),
      DiagnosticOption(text: 'Heavy bleeding', weight: 8),
      DiagnosticOption(text: 'Unusual discharge', weight: 4),
    ]),
  ];

  int _currentIndex = 0;
  int _totalScore = 0;
  bool _done = false;
  int? _selectedOption;

  void _selectOption(int index) {
    setState(() => _selectedOption = index);
  }

  void _next() {
    if (_selectedOption == null) return;
    _totalScore += _questions[_currentIndex].options[_selectedOption!].weight;
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
    } else {
      setState(() => _done = true);
      _saveResult();
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _totalScore = 0;
      _done = false;
      _selectedOption = null;
    });
  }

  Map<String, dynamic> get _result {
    if (_totalScore <= 4) {
      return {
        'level': 'Low Risk',
        'color': const Color(0xFF2E7D32),
        'bg': const Color(0xFFE8F5E9),
        'icon': Icons.check_circle,
        'message': 'You appear to be in good health. Continue your regular prenatal visits and maintain a healthy lifestyle.',
      };
    } else if (_totalScore <= 12) {
      return {
        'level': 'Moderate Risk',
        'color': const Color(0xFFE65100),
        'bg': const Color(0xFFFFF3E0),
        'icon': Icons.warning_amber,
        'message': 'Some symptoms may need attention. Please contact your midwife or schedule an appointment soon.',
      };
    } else {
      return {
        'level': 'High Risk — Seek Help Now',
        'color': const Color(0xFFC62828),
        'bg': const Color(0xFFFFEBEE),
        'icon': Icons.emergency,
        'message': 'Your symptoms suggest a potentially serious condition. Please visit a hospital or call emergency services immediately.',
      };
    }
  }


  Future<void> _saveResult() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) return;
    final r = _result;
    await RiskService().saveRecord(RiskRecord(
      patientId:    user.email,
      patientName:  user.fullName,
      patientPhone: user.phone,
      role:         'prenatal',
      riskLevel:    r['level'] as String,
      score:        _totalScore,
      message:      r['message'] as String,
      submittedAt:  DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        title: const Text('Health Diagnostic', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: _done ? _buildResult() : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${_currentIndex + 1} of ${_questions.length}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
              Text('${(_totalScore)}pts', style: const TextStyle(fontSize: 13, color: Color(0xFF1A237E))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE0E0E0),
              color: const Color(0xFF1A237E),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Text(q.question, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
          ),
          const SizedBox(height: 20),
          ...q.options.asMap().entries.map((e) {
            final selected = _selectedOption == e.key;
            return GestureDetector(
              onTap: () => _selectOption(e.key),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF1A237E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? const Color(0xFF1A237E) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Text(
                  e.value.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: selected ? Colors.white : const Color(0xFF424242),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedOption != null ? _next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                _currentIndex == _questions.length - 1 ? 'See Results' : 'Next',
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final r = _result;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: r['bg'] as Color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (r['color'] as Color).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(r['icon'] as IconData, color: r['color'] as Color, size: 56),
                const SizedBox(height: 14),
                Text(r['level'] as String,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: r['color'] as Color)),
                const SizedBox(height: 12),
                Text(r['message'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF424242), height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Total Score: ', style: TextStyle(fontSize: 15, color: Color(0xFF757575))),
                Text('$_totalScore', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _restart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retake Assessment', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
