import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/neonatal_visit_model.dart';
import '../../../theme/app_colors.dart';

class NeonatalVisitsEnhancedScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  const NeonatalVisitsEnhancedScreen({super.key, this.onOpenDrawer});

  @override
  State<NeonatalVisitsEnhancedScreen> createState() => _NeonatalVisitsEnhancedScreenState();
}

class _NeonatalVisitsEnhancedScreenState extends State<NeonatalVisitsEnhancedScreen> {
  bool _loading = true;
  DateTime? _babyDateOfBirth;
  List<NeonatalVisitRecord> _visits = [];
  late NeonatalVisitTracker _tracker;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await AuthService().getCurrentUser();
      
      // Get baby date of birth from user data or use a default
      _babyDateOfBirth = DateTime.now().subtract(const Duration(days: 7)); // Default: 7 days old
      
      // Try to load from API if available
      if (user != null) {
        // TODO: Get baby DOB from user profile when available
      }

      // Load visits from API
      try {
        final data = await ApiService.instance.get('/appointments/neonatal-visits');
        if (data is List) {
          _visits = (data as List).map((v) => NeonatalVisitRecord.fromJson(v as Map<String, dynamic>)).toList();
        }
      } catch (_) {
        // If API fails, create default schedule
        _visits = _createDefaultSchedule();
      }

      _tracker = NeonatalVisitTracker(visits: _visits, babyDateOfBirth: _babyDateOfBirth!);

      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error loading neonatal data: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<NeonatalVisitRecord> _createDefaultSchedule() {
    if (_babyDateOfBirth == null) return [];

    final schedule = NeonatalVisitSchedule.getWHOSchedule();
    return schedule.map((s) {
      final scheduledDate = _babyDateOfBirth!.add(Duration(days: s.dayAfterBirth));
      return NeonatalVisitRecord(
        id: 'neonatal_${s.visitNumber}',
        visitNumber: s.visitNumber,
        scheduledDate: scheduledDate,
        status: _getDefaultStatus(scheduledDate),
      );
    }).toList();
  }

  String _getDefaultStatus(DateTime scheduledDate) {
    final now = DateTime.now();
    if (now.isBefore(scheduledDate.subtract(const Duration(days: 1)))) {
      return 'scheduled';
    } else if (now.isAfter(scheduledDate.add(const Duration(days: 3)))) {
      return 'missed';
    }
    return 'scheduled';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Neonatal Follow-Up', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Baby Age Card
                    _BabyAgeCard(tracker: _tracker),

                    // Compliance Summary Card
                    _ComplianceSummaryCard(tracker: _tracker),

                    // Alert Cards
                    if (_tracker.overdueVisits.isNotEmpty)
                      _AlertCard(
                        title: 'Overdue Visits',
                        count: _tracker.overdueVisits.length,
                        color: Colors.red,
                        icon: Icons.warning_rounded,
                      ),
                    if (_tracker.visitsDueSoon.isNotEmpty)
                      _AlertCard(
                        title: 'Due Soon',
                        count: _tracker.visitsDueSoon.length,
                        color: Colors.orange,
                        icon: Icons.schedule,
                      ),
                    if (_tracker.riskFlaggedVisits.isNotEmpty)
                      _AlertCard(
                        title: 'Risk Flags',
                        count: _tracker.riskFlaggedVisits.length,
                        color: Colors.deepOrange,
                        icon: Icons.flag,
                      ),

                    // WHO Schedule Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'FOLLOW-UP SCHEDULE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF9E9E9E),
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '${_tracker.completedVisits.length}/${_visits.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Visit Cards
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _visits.length,
                      itemBuilder: (context, index) {
                        final visit = _visits[index];
                        final schedule = NeonatalVisitSchedule.getWHOSchedule()[index];
                        return _VisitCard(
                          visit: visit,
                          schedule: schedule,
                          onTap: () => _showVisitDetails(context, visit, schedule),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  void _showVisitDetails(BuildContext context, NeonatalVisitRecord visit, NeonatalVisitSchedule schedule) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _VisitDetailsSheet(
        visit: visit,
        schedule: schedule,
      ),
    );
  }
}

// ─── Baby Age Card ────────────────────────────────────────────────────────────

class _BabyAgeCard extends StatelessWidget {
  final NeonatalVisitTracker tracker;

  const _BabyAgeCard({required this.tracker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Baby Age',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            tracker.babyAgeFormatted,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AgeStatItem(
                label: 'Days',
                value: tracker.babyAgeDays.toString(),
              ),
              _AgeStatItem(
                label: 'Weeks',
                value: tracker.babyAgeWeeks.toString(),
              ),
              _AgeStatItem(
                label: 'Months',
                value: tracker.babyAgeMonths.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgeStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _AgeStatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

// ─── Compliance Summary Card ──────────────────────────────────────────────────

class _ComplianceSummaryCard extends StatelessWidget {
  final NeonatalVisitTracker tracker;

  const _ComplianceSummaryCard({required this.tracker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Follow-Up Compliance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tracker.completionPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(tracker.complianceColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tracker.complianceStatus,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(tracker.complianceColor),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: tracker.completionPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(tracker.complianceColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ComplianceStatItem(
                label: 'Completed',
                value: tracker.completedVisits.length.toString(),
                color: Colors.green,
              ),
              _ComplianceStatItem(
                label: 'Scheduled',
                value: tracker.visits.where((v) => v.status == 'scheduled').length.toString(),
                color: Colors.blue,
              ),
              _ComplianceStatItem(
                label: 'Missed',
                value: tracker.missedVisits.length.toString(),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComplianceStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ComplianceStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
        ),
      ],
    );
  }
}

// ─── Alert Card ───────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _AlertCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$title: $count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ],
      ),
    );
  }
}

// ─── Visit Card ───────────────────────────────────────────────────────────────

class _VisitCard extends StatelessWidget {
  final NeonatalVisitRecord visit;
  final NeonatalVisitSchedule schedule;
  final VoidCallback onTap;

  const _VisitCard({
    required this.visit,
    required this.schedule,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (visit.status) {
      case 'completed':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'rescheduled':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    if (visit.isOverdue) return 'OVERDUE';
    if (visit.isDueSoon) return 'DUE SOON';
    if (visit.isUpcoming) return 'UPCOMING';
    switch (visit.status) {
      case 'completed':
        return 'COMPLETED';
      case 'missed':
        return 'MISSED';
      case 'rescheduled':
        return 'RESCHEDULED';
      default:
        return 'SCHEDULED';
    }
  }

  IconData _getStatusIcon() {
    switch (visit.status) {
      case 'completed':
        return Icons.check_circle;
      case 'missed':
        return Icons.cancel;
      case 'rescheduled':
        return Icons.edit_calendar;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final dateStr = DateFormat('MMM d, yyyy').format(visit.scheduledDate);
    final daysUntil = visit.scheduledDate.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Visit ${schedule.visitNumber}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(), color: color, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                schedule.purpose,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Color(0xFF757575)),
                  const SizedBox(width: 6),
                  Text(
                    'Target: ${schedule.label} ($dateStr)',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  ),
                ],
              ),
              if (daysUntil >= 0 && daysUntil <= 3)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Due in $daysUntil days',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (visit.riskFlagRaised == true)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag, color: Colors.red.shade700, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Risk Flag Raised',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Visit Details Sheet ──────────────────────────────────────────────────────

class _VisitDetailsSheet extends StatelessWidget {
  final NeonatalVisitRecord visit;
  final NeonatalVisitSchedule schedule;

  const _VisitDetailsSheet({
    required this.visit,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Neonatal Visit ${schedule.visitNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.purpose,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scheduled Date
                  _DetailRow(
                    label: 'Scheduled Date',
                    value: DateFormat('EEEE, MMMM d, yyyy').format(visit.scheduledDate),
                  ),

                  // Status
                  _DetailRow(
                    label: 'Status',
                    value: visit.status.toUpperCase(),
                    valueColor: _getStatusColor(),
                  ),

                  if (visit.completedDate != null) ...[
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Completed Date',
                      value: DateFormat('EEEE, MMMM d, yyyy').format(visit.completedDate!),
                    ),
                  ],

                  if (visit.clinicianName != null) ...[
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Clinician',
                      value: visit.clinicianName!,
                    ),
                  ],

                  // Check Items
                  const SizedBox(height: 24),
                  const Text(
                    'Recommended Checks',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...schedule.checkItems.map((item) {
                    final isCompleted = visit.completedChecks?.contains(item) ?? false;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isCompleted ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 13,
                                color: isCompleted ? Colors.green : Color(0xFF757575),
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Immunizations
                  if (visit.immunizationsGiven != null && visit.immunizationsGiven!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Immunizations Given',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...visit.immunizationsGiven!.map((vaccine) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                vaccine,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF212121),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  // Notes
                  if (visit.notes != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        visit.notes!,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
                      ),
                    ),
                  ],

                  // Risk Notes
                  if (visit.riskNotes != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_rounded, color: Colors.red.shade700, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Risk Alert',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            visit.riskNotes!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (visit.status) {
      case 'completed':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'rescheduled':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9E9E9E),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}
