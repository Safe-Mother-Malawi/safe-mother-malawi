import 'package:flutter/material.dart';
import '../../clinician/services/risk_service.dart';
import '../../clinician/models/risk_record.dart';
import '../../auth/services/auth_service.dart';
import '../models/neonatal_data.dart';

// ─── Diagnostic Models ────────────────────────────────────────────────────────

class _Question {
  final String question;
  final List<_Option> options;
  const _Question({required this.question, required this.options});
}

class _Option {
  final String text;
  final int weight;
  const _Option({required this.text, required this.weight});
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class NeonatalHealthScreen extends StatefulWidget {
  final NeonatalData? data;
  const NeonatalHealthScreen({super.key, this.data});

  @override
  State<NeonatalHealthScreen> createState() => _NeonatalHealthScreenState();
}

class _NeonatalHealthScreenState extends State<NeonatalHealthScreen> {
  static const _questions = [
    _Question(question: 'How is your baby breathing?', options: [
      _Option(text: 'Normal — calm and regular', weight: 0),
      _Option(text: 'Slightly fast but settled', weight: 1),
      _Option(text: 'Fast breathing (>60 breaths/min)', weight: 5),
      _Option(text: 'Grunting or struggling to breathe', weight: 8),
    ]),
    _Question(question: 'How is your baby feeding today?', options: [
      _Option(text: 'Feeding well — normal amount', weight: 0),
      _Option(text: 'Feeding a little less than usual', weight: 2),
      _Option(text: 'Refusing to feed for over 3 hours', weight: 6),
      _Option(text: 'Not feeding at all', weight: 8),
    ]),
    _Question(question: 'What is your baby\'s skin colour?', options: [
      _Option(text: 'Normal pink / healthy tone', weight: 0),
      _Option(text: 'Slightly yellow (mild jaundice)', weight: 2),
      _Option(text: 'Deep yellow — spreading to body', weight: 5),
      _Option(text: 'Blue, pale, or grey', weight: 9),
    ]),
    _Question(question: 'How is your baby\'s temperature?', options: [
      _Option(text: 'Normal (36.5–37.5°C)', weight: 0),
      _Option(text: 'Slightly warm to touch', weight: 2),
      _Option(text: 'Fever above 38°C', weight: 6),
      _Option(text: 'Cold — below 36°C', weight: 6),
    ]),
    _Question(question: 'How is your baby\'s activity level?', options: [
      _Option(text: 'Active, alert, and responsive', weight: 0),
      _Option(text: 'Sleeping more than usual', weight: 1),
      _Option(text: 'Difficult to wake for feeds', weight: 5),
      _Option(text: 'Limp, unresponsive, or having seizures', weight: 10),
    ]),
    _Question(question: 'How does the umbilical cord stump look?', options: [
      _Option(text: 'Drying normally — no concerns', weight: 0),
      _Option(text: 'Slightly moist but no smell', weight: 1),
      _Option(text: 'Red, swollen, or has a foul smell', weight: 6),
      _Option(text: 'Bleeding or oozing', weight: 7),
    ]),
    _Question(question: 'How many wet nappies today?', options: [
      _Option(text: '6 or more wet nappies', weight: 0),
      _Option(text: '4–5 wet nappies', weight: 1),
      _Option(text: 'Fewer than 4 wet nappies', weight: 4),
      _Option(text: 'No wet nappies today', weight: 7),
    ]),
  ];

  int _currentIndex  = 0;
  int _totalScore    = 0;
  bool _done         = false;
  int? _selectedOption;

  void _selectOption(int i) => setState(() => _selectedOption = i);

  void _next() {
    if (_selectedOption == null) return;
    _totalScore += _questions[_currentIndex].options[_selectedOption!].weight;
    if (_currentIndex < _questions.length - 1) {
      setState(() { _currentIndex++; _selectedOption = null; });
    } else {
      setState(() => _done = true);
      _saveResult();
    }
  }

  void _restart() => setState(() {
    _currentIndex   = 0;
    _totalScore     = 0;
    _done           = false;
    _selectedOption = null;
  });

  Map<String, dynamic> get _result {
    if (_totalScore <= 5) {
      return {
        'level': 'Baby Appears Well',
        'color': const Color(0xFF2E7D32),
        'bg': const Color(0xFFE8F5E9),
        'icon': Icons.check_circle,
        'message':
            'Your baby appears to be in good health. Continue regular feeding, keep baby warm, and attend your next well-baby clinic visit.',
      };
    } else if (_totalScore <= 14) {
      return {
        'level': 'Monitor Closely',
        'color': const Color(0xFFE65100),
        'bg': const Color(0xFFFFF3E0),
        'icon': Icons.warning_amber,
        'message':
            'Some signs need attention. Contact your nurse or health worker today. Do not wait if symptoms worsen.',
      };
    } else {
      return {
        'level': 'Seek Help Immediately',
        'color': const Color(0xFFC62828),
        'bg': const Color(0xFFFFEBEE),
        'icon': Icons.emergency,
        'message':
            'Your baby shows serious warning signs. Go to the nearest hospital or call 998 emergency services right now.',
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
      role:         'neonatal',
      riskLevel:    r['level'] as String,
      score:        _totalScore,
      message:      r['message'] as String,
      submittedAt:  DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
        title: const Text('Health Check',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        actions: [
          if (widget.data != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Day ${widget.data!.ageInDays}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
        ],
      ),
      body: _done ? _buildResult() : _buildQuestion(),
    );
  }

  // ── Question view ───────────────────────────────────────────────────────────

  Widget _buildQuestion() {
    final q        = _questions[_currentIndex];
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
              Text('${_totalScore}pts',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF00695C))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE0E0E0),
              color: const Color(0xFF00695C),
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
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Text(q.question,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121))),
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
                  color: selected ? const Color(0xFF00695C) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF00695C)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Text(
                  e.value.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: selected ? Colors.white : const Color(0xFF424242),
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
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
                backgroundColor: const Color(0xFF00695C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                _currentIndex == _questions.length - 1
                    ? 'See Results'
                    : 'Next',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Result view ─────────────────────────────────────────────────────────────

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
              border: Border.all(
                  color: (r['color'] as Color).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(r['icon'] as IconData,
                    color: r['color'] as Color, size: 56),
                const SizedBox(height: 14),
                Text(r['level'] as String,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: r['color'] as Color)),
                const SizedBox(height: 12),
                Text(r['message'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF424242),
                        height: 1.5)),
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
                const Text('Total Score: ',
                    style: TextStyle(
                        fontSize: 15, color: Color(0xFF757575))),
                Text('$_totalScore',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Danger signs reminder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_rounded,
                        color: Color(0xFFC62828), size: 18),
                    SizedBox(width: 8),
                    Text('Danger Signs — Act Immediately',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC62828))),
                  ],
                ),
                const SizedBox(height: 8),
                ...NeonatalData.dangerSigns.take(5).map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(
                                  color: Color(0xFFC62828),
                                  fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(s,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7F0000),
                                    height: 1.4)),
                          ),
                        ],
                      ),
                    )),
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
                backgroundColor: const Color(0xFF00695C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retake Assessment',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
