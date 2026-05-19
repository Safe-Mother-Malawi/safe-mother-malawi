import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../widgets/notification_icon.dart';
import 'notifications_screen.dart';

/// Neonatal health check history screen - shows all past assessments
class NeonatalHealthCheckHistoryScreen extends StatefulWidget {
  const NeonatalHealthCheckHistoryScreen({super.key});

  @override
  State<NeonatalHealthCheckHistoryScreen> createState() => _NeonatalHealthCheckHistoryScreenState();
}

class _NeonatalHealthCheckHistoryScreenState extends State<NeonatalHealthCheckHistoryScreen> {
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
      final history = await ApiService.getAssessmentHistory();
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
      return '${date.day}/${date.month}/${date.year}';
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

  Color _getRiskBgColor(String? riskLevel) {
    if (riskLevel == null) return const Color(0xFFF5F5F5);
    if (riskLevel.contains('Low')) return const Color(0xFFE8F5E9);
    if (riskLevel.contains('Moderate')) return const Color(0xFFFFF3E0);
    return const Color(0xFFFFEBEE);
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
                MaterialPageRoute(builder: (_) => const NeonatalNotificationsScreen()),
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
              ? _buildError()
              : _history.isEmpty
                  ? _buildEmpty()
                  : _buildHistory(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF9E9E9E)),
            const SizedBox(height: 16),
            const Text(
              'Could not load history',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
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
              'Your baby\'s health check history will appear here once you complete your first assessment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Take First Health Check'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: const Color(0xFF1A237E),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final assessment = _history[index];
          final riskLevel = assessment['riskLevel']?.toString() ?? 'Unknown';
          final date = assessment['createdAt']?.toString();
          final score = assessment['score']?.toString() ?? '0';
          final maxScore = assessment['maxScore']?.toString() ?? '0';
          final percentage = assessment['percentage']?.toString() ?? '0';
          final message = assessment['message']?.toString() ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(20),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getRiskBgColor(riskLevel),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getRiskIcon(riskLevel),
                  color: _getRiskColor(riskLevel),
                  size: 24,
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
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getRiskBgColor(riskLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: _getRiskColor(riskLevel),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Assessment Result',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _getRiskColor(riskLevel),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 13,
                          color: _getRiskColor(riskLevel),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}