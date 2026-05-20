import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../widgets/notification_icon.dart';
import '../models/neonatal_data.dart';
import 'notifications_screen.dart';

/// Neonatal health check — loads WHO questions from the backend
/// via GET /who/questions (auto-detects early/late neonatal from baby DOB).
/// Submits YES/NO answers to POST /who/assessment.
class NeonatalHealthScreen extends StatefulWidget {
  final NeonatalData? data;
  final VoidCallback? onOpenDrawer;
  const NeonatalHealthScreen({super.key, this.data, this.onOpenDrawer});

  @override
  State<NeonatalHealthScreen> createState() => _NeonatalHealthScreenState();
}

class _NeonatalHealthScreenState extends State<NeonatalHealthScreen> {
  // ── Loading questions ─────────────────────────────────────────────────────
  bool _loadingQuestions = true;
  String? _loadError;
  List<Map<String, dynamic>> _questions = [];
  String _stage = '';

  // ── Assessment state ──────────────────────────────────────────────────────
  int _currentIndex = 0;
  final Map<int, int> _answers = {};
  int? _selectedAnswer; // 0=No, 1=Yes

  // ── Result ────────────────────────────────────────────────────────────────
  bool _submitting = false;
  Map<String, dynamic>? _result;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() { _loadingQuestions = true; _loadError = null; });
    try {
      // Ensure token is loaded from storage
      await ApiService.instance.loadToken();
      final res = await ApiService.instance.get('/who/questions') as Map<String, dynamic>;
      final qs  = (res['questions'] as List).cast<Map<String, dynamic>>();
      setState(() {
        _questions = qs;
        _stage = res['stage']?.toString() ?? '';
        _loadingQuestions = false;
      });
    } catch (e) {
      setState(() { _loadError = e.toString(); _loadingQuestions = false; });
    }
  }

  void _selectAnswer(int value) => setState(() => _selectedAnswer = value);

  void _next() {
    if (_selectedAnswer == null) return;
    final q = _questions[_currentIndex];
    _answers[q['id'] as int] = _selectedAnswer!;

    if (_currentIndex < _questions.length - 1) {
      setState(() { _currentIndex++; _selectedAnswer = null; });
    } else {
      _submit();
    }
  }

  void _restart() => setState(() {
    _currentIndex = 0;
    _selectedAnswer = null;
    _answers.clear();
    _result = null;
    _offline = false;
    _submitting = false;
  });

  Future<void> _submit() async {
    setState(() { _submitting = true; _offline = false; });
    try {
      final payload = {
        'answers': _answers.entries
            .map((e) => {'questionId': e.key, 'value': e.value})
            .toList(),
      };
      final res = await ApiService.instance.post('/who/assessment', payload)
          as Map<String, dynamic>;
      final savedToHistory = await _saveToHistory(res);
      if (!mounted) return;
      setState(() { _result = res; _submitting = false; });
      if (!savedToHistory) {
        _showHistorySaveWarning();
      }
    } catch (_) {
      // Offline fallback
      final score = _answers.entries.fold<double>(0, (s, e) {
        if (e.value == 0) return s;
        final q = _questions.firstWhere((q) => q['id'] == e.key, orElse: () => {});
        return s + ((q['weight'] as num?)?.toDouble() ?? 0);
      });
      final maxScore = _questions.fold<double>(
          0, (s, q) => s + ((q['weight'] as num?)?.toDouble() ?? 0));
      final pct = maxScore > 0 ? (score / maxScore) * 100 : 0;
      String riskLevel;
      String message;
      if (pct >= 70) {
        riskLevel = 'Seek Help Immediately';
        message = 'Your baby shows serious warning signs. Go to the nearest hospital or call 998 emergency services right now.';
      } else if (pct >= 40) {
        riskLevel = 'Moderate Risk';
        message = 'Some signs need attention. Contact your nurse or health worker today. Do not wait if symptoms worsen.';
      } else {
        riskLevel = 'Low Risk';
        message = 'Your baby appears to be in good health. Continue regular feeding, keep baby warm, and attend your next well-baby clinic visit.';
      }
      setState(() {
        _result = {
          'riskLevel': riskLevel,
          'message': message,
          'score': score.round(),
          'maxScore': maxScore.round(),
          'percentage': pct.roundToDouble(),
        };
        _submitting = false;
        _offline = true;
      });
    }
  }

  Map<String, dynamic> _uiForLevel(String level) {
    if (level.contains('Low')) {
      return {'color': const Color(0xFF2E7D32), 'bg': const Color(0xFFE8F5E9), 'icon': Icons.check_circle};
    } else if (level.contains('Moderate') || level.contains('Monitor')) {
      return {'color': const Color(0xFFE65100), 'bg': const Color(0xFFFFF3E0), 'icon': Icons.warning_amber};
    } else {
      return {'color': const Color(0xFFC62828), 'bg': const Color(0xFFFFEBEE), 'icon': Icons.emergency};
    }
  }

  Future<bool> _saveToHistory(Map<String, dynamic> result) async {
    try {
      await ApiService.saveHealthCheckResultToHistory(
        type: 'neonatal',
        result: result,
        questions: _questions,
        answers: _answers,
      );
      return true;
    } catch (e) {
      debugPrint('Failed to save health check history: $e');
      return false;
    }
  }

  void _showHistorySaveWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Result shown, but it could not be saved to history.'),
      ),
    );
  }

  String _stageLabel(String stage) {
    switch (stage) {
      case 'early_neonatal': return 'Early Neonatal (0–7 days)';
      case 'late_neonatal':  return 'Late Neonatal (8–28 days)';
      default: return stage;
    }
  }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Health Check',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
            if (_stage.isNotEmpty)
              Text(_stageLabel(_stage),
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: NotificationIcon(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NeonatalNotificationsScreen()),
              ),
              iconColor: Colors.white,
            ),
          ),
          if (widget.data != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Day ${widget.data!.ageInDays}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          if (_result == null && !_submitting && !_loadingQuestions && _currentIndex > 0)
            TextButton(
              onPressed: _restart,
              child: const Text('Restart', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
      body: _loadingQuestions
          ? _buildLoading('Loading health questions…')
          : _loadError != null
              ? _buildError()
              : _submitting
                  ? _buildLoading("Analysing your baby's responses…")
                  : _result != null
                      ? _buildResult()
                      : _buildQuestion(),
    );
  }

  Widget _buildLoading(String msg) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(color: Color(0xFF1A237E)),
      const SizedBox(height: 20),
      Text(msg, style: const TextStyle(fontSize: 15, color: Color(0xFF1A237E), fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFF9E9E9E)),
        const SizedBox(height: 16),
        const Text('Could not load questions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF424242))),
        const SizedBox(height: 8),
        Text(_loadError ?? '', textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loadQuestions,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Try Again'),
        ),
      ]),
    ),
  );

  Widget _buildQuestion() {
    if (_questions.isEmpty) return _buildError();
    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final severity = q['severityTag']?.toString() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Question ${_currentIndex + 1} of ${_questions.length}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
          if (severity.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: severity == 'HIGH'
                    ? const Color(0xFFFFEBEE)
                    : severity == 'MEDIUM'
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(severity,
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: severity == 'HIGH'
                        ? const Color(0xFFC62828)
                        : severity == 'MEDIUM'
                            ? const Color(0xFFE65100)
                            : const Color(0xFF2E7D32),
                  )),
            ),
        ]),
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Text(q['questionText']?.toString() ?? '',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
        ),
        const SizedBox(height: 24),

        Row(children: [
          Expanded(
            child: _AnswerBtn(
              label: 'YES',
              selected: _selectedAnswer == 1,
              color: const Color(0xFFC62828),
              selectedBg: const Color(0xFFFFEBEE),
              icon: Icons.check_circle_outline,
              onTap: () => _selectAnswer(1),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _AnswerBtn(
              label: 'NO',
              selected: _selectedAnswer == 0,
              color: const Color(0xFF2E7D32),
              selectedBg: const Color(0xFFE8F5E9),
              icon: Icons.cancel_outlined,
              onTap: () => _selectAnswer(0),
            ),
          ),
        ]),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedAnswer != null ? _next : null,
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
      ]),
    );
  }

  Widget _buildResult() {
    final level    = (_result!['riskLevel'] ?? 'Low Risk').toString();
    final message  = (_result!['message'] ?? '').toString();
    final score    = _result!['score'] ?? 0;
    final maxScore = _result!['maxScore'] ?? 0;
    final pct      = _result!['percentage'] ?? 0;
    final ui       = _uiForLevel(level);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ui['bg'] as Color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (ui['color'] as Color).withValues(alpha: 0.3)),
          ),
          child: Column(children: [
            Icon(ui['icon'] as IconData, color: ui['color'] as Color, size: 56),
            const SizedBox(height: 14),
            Text(level,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ui['color'] as Color)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF424242), height: 1.5)),
          ]),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _ScoreStat(label: 'Score', value: '$score / $maxScore'),
            Container(width: 1, height: 36, color: const Color(0xFFE0E0E0)),
            _ScoreStat(label: 'Risk %', value: '$pct%'),
            Container(width: 1, height: 36, color: const Color(0xFFE0E0E0)),
            _ScoreStat(label: 'Questions', value: '${_questions.length}'),
          ]),
        ),

        if (_offline) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFCC02)),
            ),
            child: const Row(children: [
              Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFFE65100)),
              SizedBox(width: 8),
              Expanded(child: Text('Offline result — will sync when connected.',
                  style: TextStyle(fontSize: 12, color: Color(0xFFE65100)))),
            ]),
          ),
        ],

        const SizedBox(height: 20),
        // Danger signs
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.warning_rounded, color: Color(0xFFC62828), size: 18),
              SizedBox(width: 8),
              Text('Danger Signs — Act Immediately',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
            ]),
            const SizedBox(height: 8),
            ...NeonatalData.dangerSigns.take(5).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('• ', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
                Expanded(child: Text(s,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF7F0000), height: 1.4))),
              ]),
            )),
          ]),
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
            child: const Text('Retake Assessment',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _AnswerBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color, selectedBg;
  final IconData icon;
  final VoidCallback onTap;
  const _AnswerBtn({
    required this.label, required this.selected, required this.color,
    required this.selectedBg, required this.icon, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : const Color(0xFFE0E0E0),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Column(children: [
          Icon(icon, color: selected ? color : const Color(0xFF9E9E9E), size: 28),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: selected ? color : const Color(0xFF757575),
              )),
        ]),
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  final String label, value;
  const _ScoreStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
  ]);
}
