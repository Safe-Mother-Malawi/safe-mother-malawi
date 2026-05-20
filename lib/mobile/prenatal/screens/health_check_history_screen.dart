import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../widgets/notification_icon.dart';
import 'notifications_screen.dart';

/// Prenatal health check history screen - shows all past assessments
class PrenatalHealthCheckHistoryScreen extends StatefulWidget {
  const PrenatalHealthCheckHistoryScreen({super.key});

  @override
  State<PrenatalHealthCheckHistoryScreen> createState() => _PrenatalHealthCheckHistoryScreenState();
}

class _PrenatalHealthCheckHistoryScreenState extends State<PrenatalHealthCheckHistoryScreen> {
  bool _loading = true;
  List<dynamic> _history = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      await ApiService.instance.loadToken();
      final result = await ApiService.getMyHealthCheckHistory();
      final history = (result['data'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .toList() ?? [];
      setState(() {
        _history = history;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Health Check History',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
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
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Color(0xFF9E9E9E)),
                        const SizedBox(height: 16),
                        const Text(
                          'Could not load history',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadHistory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _history.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No health checks yet',
                              style: TextStyle(
                                fontSize: 18,
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
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final assessment = _history[index];
                          final riskLevel = assessment['riskLevel']?.toString() ?? 'Unknown';
                          final message = assessment['message']?.toString() ?? '';
                          final date = assessment['createdAt']?.toString();
                          final score = assessment['score']?.toString() ?? '0';
                          final maxScore = assessment['maxScore']?.toString() ?? '0';
                          final percentage = assessment['percentage']?.toString() ?? '0';
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                                const SizedBox(height: 16),
                                // Symptoms section - always show
                                const Text(
                                  'Symptoms Reported:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Builder(
                                  builder: (context) {
                                    final symptoms = assessment['symptoms'];
                                    final symptomsList = symptoms is List 
                                        ? symptoms.map((s) => s.toString()).toList()
                                        : <String>[];
                                    
                                    if (symptomsList.isEmpty) {
                                      return const Text(
                                        'No symptoms reported',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9E9E9E),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      );
                                    }
                                    return Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: symptomsList
                                          .map((symptom) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _getRiskColor(riskLevel).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: _getRiskColor(riskLevel).withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Text(
                                              symptom,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: _getRiskColor(riskLevel),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ))
                                          .toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

