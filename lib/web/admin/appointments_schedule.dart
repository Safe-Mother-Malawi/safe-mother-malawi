import 'package:flutter/material.dart';
import 'dart:async';

import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/auth_service_web.dart';
import '../shared/widgets/status_badge.dart';

class AppointmentsSchedule extends StatefulWidget {
  const AppointmentsSchedule({super.key});

  @override
  State<AppointmentsSchedule> createState() => _AppointmentsScheduleState();
}

class _AppointmentsScheduleState extends State<AppointmentsSchedule> {
  List<Map<String, dynamic>> _todayAppointments = [];
  List<Map<String, dynamic>> _allAppointments = [];
  bool _loading = true;
  String? _error;
  late Timer _refreshTimer;
  String _filterMode = 'Today'; // 'Today' or 'All'

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    // Refresh appointments every 10 seconds to catch updates/deletions
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadAppointments();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    try {
      // Get current user to filter appointments by their ID
      final currentUser = AuthServiceWeb.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
      }

      final userId = currentUser['id']?.toString() ?? '';
      if (userId.isEmpty) {
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
      }

      // Fetch appointments for this user with timeout
      final allAppointments = await ApiService.getAppointments(patientId: userId).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );
      
      if (allAppointments is! List) {
        throw Exception('Invalid data format');
      }
      
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      final todayAppointmentsList = (allAppointments as List)
          .cast<Map<String, dynamic>>()
          .where((a) {
            // Try multiple date field names
            final dateStr = (a['date'] ?? a['appointmentDate'] ?? a['appointment_date'] ?? '').toString().trim();
            if (dateStr.isEmpty) return false;

            DateTime? date;

            // Try parsing as ISO format (2024-05-19 or 2024-05-19T10:30:00)
            if (dateStr.contains('-')) {
              date = DateTime.tryParse(dateStr);
            }

            // If parsing failed, try other formats
            if (date == null) {
              // Try DD/MM/YYYY format
              try {
                final parts = dateStr.split('/');
                if (parts.length == 3) {
                  date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                }
              } catch (e) {
                // Ignore parsing errors
              }
            }

            if (date == null) return false;

            // Compare only year, month, and day (ignore time)
            final appointmentDate = DateTime(date.year, date.month, date.day);
            return appointmentDate == todayDate;
          })
          .toList();

      if (mounted) {
        setState(() {
          _todayAppointments = todayAppointmentsList;
          _allAppointments = (allAppointments as List).cast<Map<String, dynamic>>();
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load appointments: $e');
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    final date = DateTime.tryParse(appointment['date'] ?? '') ?? DateTime.now();
    final title = (appointment['title'] ?? appointment['type'] ?? 'Appointment').toString();
    final time = (appointment['time'] ?? '—').toString();
    final location = (appointment['location'] ?? appointment['facility'] ?? '—').toString();
    final doctor = (appointment['doctor'] ?? appointment['clinician']?['fullName'] ?? '—').toString();
    final notes = (appointment['notes'] ?? '').toString();
    final status = (appointment['status'] ?? 'Pending').toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700, color: AppColors.primary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Date', _formatDate(date)),
              _detailRow('Time', time),
              _detailRow('Location', location),
              _detailRow('Doctor/Provider', doctor),
              _detailRow('Status', status),
              if (notes.isNotEmpty) _detailRow('Notes', notes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontFamily: 'Roboto', 
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontFamily: 'Roboto', 
              fontSize: 13,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final displayAppointments = _filterMode == 'Today' ? _todayAppointments : _allAppointments;
    
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _filterMode == 'Today' ? "Today's Appointments" : "All Appointments",
                    style: TextStyle(fontFamily: 'Public Sans', 
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.headings,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _filterMode == 'Today' 
                      ? 'View and manage appointments scheduled for today'
                      : 'View and manage all appointments and events',
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _FilterButton(
                      label: 'Today',
                      isActive: _filterMode == 'Today',
                      onTap: () => setState(() => _filterMode = 'Today'),
                    ),
                    _FilterButton(
                      label: 'All',
                      isActive: _filterMode == 'All',
                      onTap: () => setState(() => _filterMode = 'All'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.criticalText, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.criticalText),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAppointments,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : displayAppointments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 56,
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _filterMode == 'Today' ? 'No Appointments Today' : 'No Appointments',
                                  style: TextStyle(fontFamily: 'Roboto', 
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.headings,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You have no appointments scheduled for today.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Roboto', 
                                    fontSize: 13,
                                    color: AppColors.mutedText,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAppointments,
                            color: AppColors.primary,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: displayAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = displayAppointments[index];
                                final date = DateTime.tryParse(appointment['date'] ?? '') ?? DateTime.now();
                                final title = (appointment['title'] ?? appointment['type'] ?? 'Appointment').toString();
                                final time = (appointment['time'] ?? '—').toString();
                                final status = (appointment['status'] ?? 'Pending').toString();

                                return GestureDetector(
                                  onTap: () => _showAppointmentDetails(appointment),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.surfaceContainerLow),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppColors.shadowColor,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.calendar_today,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: TextStyle(fontFamily: 'Roboto', 
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 12,
                                                    color: AppColors.mutedText,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    time,
                                                    style: TextStyle(fontFamily: 'Roboto', 
                                                      fontSize: 12,
                                                      color: AppColors.mutedText,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        StatusBadge(
                                          label: status,
                                          type: status == 'Completed'
                                              ? BadgeType.success
                                              : status == 'Cancelled'
                                                  ? BadgeType.critical
                                                  : BadgeType.warning,
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right,
                                          color: AppColors.mutedText,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Button Widget ──────────────────────────────────────────────────────

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}
