import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../widgets/notification_icon.dart';
import 'notifications_screen.dart';
import 'diagnostic_screen.dart';
import 'health_check_history_screen.dart';

/// Prenatal health check start screen - shows overview and options to start or view history
class HealthCheckStartScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  const HealthCheckStartScreen({super.key, this.onOpenDrawer});

  @override
  State<HealthCheckStartScreen> createState() => _HealthCheckStartScreenState();
}

class _HealthCheckStartScreenState extends State<HealthCheckStartScreen> {
  bool _loading = true;
  String? _stage;
  List<dynamic> _recentHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      await ApiService.instance.loadToken();
      
      // Load user stage info
      final questionsData = await ApiService.getHealthCheckQuestions();
      final stage = questionsData['stage']?.toString() ?? '';
      
      // Load recent history
      final history = await ApiService.getAssessmentHistory();
      
      setState(() {
        _stage = stage;
        _recentHistory = history.take(3).toList(); // Show last 3 assessments
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _stageLabel(String stage) {
    switch (stage) {
      case 'trimester_1': return 'Trimester 1 (0–12 weeks)';
      case 'trimester_2': return 'Trimester 2 (13–27 weeks)';
      case 'trimester_3': return 'Trimester 3 (28+ weeks)';
      default: return stage;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Color _getRiskColor(String? riskLevel) {
    if (riskLevel == null) return const Color(0xFF9E9E9E);
    if (riskLevel.contains('Low')) return const Color(0xFF2E7D32);
    if (riskLevel.contains('Moderate')) return const Color(0xFFE65100);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => widget.onOpenDrawer?.call(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Health Check',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
            if (_stage?.isNotEmpty == true)
              Text(_stageLabel(_stage!),
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NotificationIcon(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              iconColor: Colors.white,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A237E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.favorite, color: Colors.white, size: 32),
                        const SizedBox(height: 12),
                        const Text(
                          'Prenatal Health Check',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Monitor your pregnancy health with our quick assessment. Answer a few questions to get personalized health insights.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Start health check button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiagnosticScreen(onOpenDrawer: widget.onOpenDrawer),
                          ),
                        ).then((_) => _loadData()); // Refresh when returning
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Start Health Check',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent history section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Assessments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                      if (_recentHistory.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrenatalHealthCheckHistoryScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xFF1A237E),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_recentHistory.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No assessments yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Take your first health check to start tracking your pregnancy health.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._recentHistory.map((assessment) {
                      final riskLevel = assessment['riskLevel']?.toString() ?? 'Unknown';
                      final date = assessment['createdAt']?.toString();
                      final score = assessment['score']?.toString() ?? '0';
                      final maxScore = assessment['maxScore']?.toString() ?? '0';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getRiskColor(riskLevel),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    riskLevel,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _getRiskColor(riskLevel),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Score: $score/$maxScore',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatDate(date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 24),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF1976D2), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Regular health checks help monitor your pregnancy progress and identify any concerns early.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1976D2),
                              height: 1.4,
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
}