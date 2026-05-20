import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../widgets/notification_icon.dart';
import '../models/neonatal_data.dart';
import 'notifications_screen.dart' as notif;
import 'health_screen.dart';
import 'health_check_history_screen.dart';

/// Unified Neonatal Health Check page - combines Start Health Check and History
class NeonatalHealthCheckStartScreen extends StatefulWidget {
  final NeonatalData? data;
  final VoidCallback? onOpenDrawer;
  const NeonatalHealthCheckStartScreen({super.key, this.data, this.onOpenDrawer});

  @override
  State<NeonatalHealthCheckStartScreen> createState() => _NeonatalHealthCheckStartScreenState();
}

class _NeonatalHealthCheckStartScreenState extends State<NeonatalHealthCheckStartScreen> {
  bool _loading = true;
  String? _stage;
  List<dynamic> _fullHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });
    try {
      await ApiService.instance.loadToken();
      
      // Load user stage info
      final questionsData = await ApiService.getHealthCheckQuestions();
      final stage = questionsData['stage']?.toString() ?? '';
      
      // Load full history
      final result = await ApiService.getMyHealthCheckHistory();
      final history = (result['data'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .toList() ?? [];
      
      setState(() {
        _stage = stage;
        _fullHistory = history;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  String _stageLabel(String stage) {
    switch (stage) {
      case 'newborn': return 'Newborn (0–28 days)';
      case 'infant': return 'Infant (1–12 months)';
      case 'toddler': return 'Toddler (1–3 years)';
      default: return stage;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }

  Color _getRiskColor(String? riskLevel) {
    if (riskLevel == null) return const Color(0xFF9E9E9E);
    if (riskLevel.contains('Low')) return const Color(0xFF2E7D32);
    if (riskLevel.contains('Moderate')) return const Color(0xFFE65100);
    return const Color(0xFFC62828);
  }

  IconData _getRiskIcon(String? riskLevel) {
    if (riskLevel == null) return Icons.help_outline;
    if (riskLevel.contains('Low')) return Icons.check_circle;
    if (riskLevel.contains('Moderate')) return Icons.warning_amber;
    return Icons.emergency;
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
                MaterialPageRoute(builder: (_) => notif.NeonatalNotificationsScreen()),
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
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ═══════════════════════════════════════════════════════════
                    // SECTION 1: START HEALTH CHECK
                    // ═══════════════════════════════════════════════════════════
                    
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
                            'Neonatal Health Check',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Monitor your baby\'s health with our quick assessment. Answer a few questions to get personalized health insights.',
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
                              builder: (_) => NeonatalHealthScreen(data: widget.data, onOpenDrawer: widget.onOpenDrawer),
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
                              'Regular health checks help monitor your baby\'s development and identify any concerns early.',
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

                    const SizedBox(height: 32),

                    // ═══════════════════════════════════════════════════════════
                    // SECTION 2: HEALTH CHECK HISTORY
                    // ═══════════════════════════════════════════════════════════

                    // History header
                    Row(
                      children: [
                        const Icon(Icons.history, color: Color(0xFF1A237E), size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Health Check History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Historical tracking of your assessments',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // History content
                    if (_fullHistory.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 56,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No health checks yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your health check history will appear here after you complete your first assessment.',
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _fullHistory.length,
                        itemBuilder: (context, index) {
                          final assessment = _fullHistory[index];
                          final riskLevel = assessment['riskLevel']?.toString() ?? 'Unknown';
                          final message = assessment['message']?.toString() ?? '';
                          final date = assessment['createdAt']?.toString();
                          final score = assessment['score']?.toString() ?? '0';
                          final maxScore = assessment['maxScore']?.toString() ?? '0';
                          final percentage = assessment['percentage']?.toString() ?? '0';
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getRiskColor(riskLevel).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  _getRiskIcon(riskLevel),
                                  color: _getRiskColor(riskLevel),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                riskLevel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _getRiskColor(riskLevel),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Score: $score/$maxScore ($percentage%)',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        _formatDate(date),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                      if (_formatTime(date).isNotEmpty) ...[
                                        const Text(
                                          ' • ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9E9E9E),
                                          ),
                                        ),
                                        Text(
                                          _formatTime(date),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9E9E9E),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              children: [
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getRiskColor(riskLevel).withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _getRiskColor(riskLevel).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    message,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF424242),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 16),

                    // View All History button
                    if (_fullHistory.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NeonatalHealthCheckHistoryScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('View All History'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A237E),
                            side: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
