import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/immunization_model.dart';
import '../../../theme/app_colors.dart';

class ImmunizationTrackerScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  const ImmunizationTrackerScreen({super.key, this.onOpenDrawer});

  @override
  State<ImmunizationTrackerScreen> createState() => _ImmunizationTrackerScreenState();
}

class _ImmunizationTrackerScreenState extends State<ImmunizationTrackerScreen> {
  bool _loading = true;
  DateTime? _babyDateOfBirth;
  List<ImmunizationRecord> _records = [];
  late ImmunizationTracker _tracker;

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
      
      // Load immunization records from API
      try {
        final data = await ApiService.instance.get('/appointments/immunizations');
        if (data is List) {
          _records = (data as List).map((r) => ImmunizationRecord.fromJson(r as Map<String, dynamic>)).toList();
        }
      } catch (_) {
        // If API fails, create default schedule
        _records = _createDefaultSchedule();
      }

      _tracker = ImmunizationTracker(records: _records, babyDateOfBirth: _babyDateOfBirth!);

      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error loading immunization data: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<ImmunizationRecord> _createDefaultSchedule() {
    if (_babyDateOfBirth == null) return [];

    final schedule = ImmunizationSchedule.getWHONeonatalSchedule();
    return schedule.map((s) {
      final scheduledDate = _babyDateOfBirth!.add(Duration(days: s.ageInDays));
      return ImmunizationRecord(
        id: 'imm_${s.vaccineId}',
        vaccineId: s.vaccineId,
        vaccineName: s.vaccineName,
        scheduledDate: scheduledDate,
        status: _getDefaultStatus(scheduledDate),
      );
    }).toList();
  }

  String _getDefaultStatus(DateTime scheduledDate) {
    final now = DateTime.now();
    if (now.isBefore(scheduledDate.subtract(const Duration(days: 1)))) {
      return 'pending';
    } else if (now.isAfter(scheduledDate.add(const Duration(days: 7)))) {
      return 'missed';
    }
    return 'pending';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Immunization Schedule', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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
                    // Immunization Status Card
                    _ImmunizationStatusCard(tracker: _tracker),

                    // Alert Cards
                    if (_tracker.overdueVaccines.isNotEmpty)
                      _AlertCard(
                        title: 'Overdue Vaccines',
                        count: _tracker.overdueVaccines.length,
                        color: Colors.red,
                        icon: Icons.warning_rounded,
                      ),
                    if (_tracker.vaccinesDueSoon.isNotEmpty)
                      _AlertCard(
                        title: 'Due Soon',
                        count: _tracker.vaccinesDueSoon.length,
                        color: Colors.orange,
                        icon: Icons.schedule,
                      ),
                    if (_tracker.vaccinesWithAdverseReactions.isNotEmpty)
                      _AlertCard(
                        title: 'Adverse Reactions',
                        count: _tracker.vaccinesWithAdverseReactions.length,
                        color: Colors.deepOrange,
                        icon: Icons.flag,
                      ),

                    // Vaccines by Age Group
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'IMMUNIZATION SCHEDULE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF9E9E9E),
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '${_tracker.administeredVaccines.length}/${_records.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Vaccine Cards by Age Group
                    ..._buildVaccinesByAgeGroup(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildVaccinesByAgeGroup() {
    final grouped = _tracker.getVaccinesByAgeGroup();
    final ageOrder = ['At birth', 'Day 7', 'Day 14', 'Day 28'];
    
    final widgets = <Widget>[];
    
    for (final age in ageOrder) {
      if (grouped.containsKey(age)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  age,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 8),
                ...grouped[age]!.map((record) {
                  final schedule = ImmunizationSchedule.getWHONeonatalSchedule()
                      .firstWhere((s) => s.vaccineId == record.vaccineId);
                  return _VaccineCard(
                    record: record,
                    schedule: schedule,
                    onTap: () => _showVaccineDetails(context, record, schedule),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }
    }
    
    return widgets;
  }

  void _showVaccineDetails(BuildContext context, ImmunizationRecord record, ImmunizationSchedule schedule) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _VaccineDetailsSheet(
        record: record,
        schedule: schedule,
      ),
    );
  }
}

// ─── Immunization Status Card ─────────────────────────────────────────────

class _ImmunizationStatusCard extends StatelessWidget {
  final ImmunizationTracker tracker;

  const _ImmunizationStatusCard({required this.tracker});

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
            'Immunization Status',
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
                        color: Color(tracker.immunizationStatusColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tracker.immunizationStatus,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(tracker.immunizationStatusColor),
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
                      Color(tracker.immunizationStatusColor),
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
              _StatusStatItem(
                label: 'Administered',
                value: tracker.administeredVaccines.length.toString(),
                color: Colors.green,
              ),
              _StatusStatItem(
                label: 'Pending',
                value: tracker.records.where((r) => r.status == 'pending').length.toString(),
                color: Colors.blue,
              ),
              _StatusStatItem(
                label: 'Missed',
                value: tracker.missedVaccines.length.toString(),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusStatItem({
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

// ─── Alert Card ───────────────────────────────────────────────────────────

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

// ─── Vaccine Card ─────────────────────────────────────────────────────────

class _VaccineCard extends StatelessWidget {
  final ImmunizationRecord record;
  final ImmunizationSchedule schedule;
  final VoidCallback onTap;

  const _VaccineCard({
    required this.record,
    required this.schedule,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (record.status) {
      case 'administered':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'contraindicated':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    if (record.isOverdue) return 'OVERDUE';
    if (record.isDueSoon) return 'DUE SOON';
    if (record.isUpcoming) return 'UPCOMING';
    switch (record.status) {
      case 'administered':
        return 'ADMINISTERED';
      case 'missed':
        return 'MISSED';
      case 'contraindicated':
        return 'CONTRAINDICATED';
      default:
        return 'PENDING';
    }
  }

  IconData _getStatusIcon() {
    switch (record.status) {
      case 'administered':
        return Icons.check_circle;
      case 'missed':
        return Icons.cancel;
      case 'contraindicated':
        return Icons.block;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final dateStr = DateFormat('MMM d, yyyy').format(record.scheduledDate);
    final daysUntil = record.scheduledDate.difference(DateTime.now()).inDays;

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
                      schedule.abbreviation,
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
                record.vaccineName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                schedule.purpose,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Color(0xFF757575)),
                  const SizedBox(width: 6),
                  Text(
                    'Scheduled: $dateStr',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  ),
                ],
              ),
              if (record.administeredDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      'Administered: ${DateFormat('MMM d, yyyy').format(record.administeredDate!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ],
              if (daysUntil >= 0 && daysUntil <= 3 && record.status == 'pending')
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
              if (record.adverseReaction == true)
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
                        Icon(Icons.warning_rounded, color: Colors.red.shade700, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Adverse Reaction Reported',
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

// ─── Vaccine Details Sheet ────────────────────────────────────────────────

class _VaccineDetailsSheet extends StatelessWidget {
  final ImmunizationRecord record;
  final ImmunizationSchedule schedule;

  const _VaccineDetailsSheet({
    required this.record,
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
                        record.vaccineName,
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
                    value: DateFormat('EEEE, MMMM d, yyyy').format(record.scheduledDate),
                  ),

                  // Status
                  _DetailRow(
                    label: 'Status',
                    value: record.status.toUpperCase(),
                    valueColor: _getStatusColor(),
                  ),

                  if (record.administeredDate != null) ...[
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Administered Date',
                      value: DateFormat('EEEE, MMMM d, yyyy').format(record.administeredDate!),
                    ),
                  ],

                  // Purpose and Protection
                  const SizedBox(height: 24),
                  const Text(
                    'Purpose',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    schedule.purpose,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                      height: 1.5,
                    ),
                  ),

                  // Protects Against
                  const SizedBox(height: 16),
                  const Text(
                    'Protects Against',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...schedule.protectsAgainst.map((disease) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.shield, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              disease,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Administration Details
                  const SizedBox(height: 24),
                  const Text(
                    'Administration Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Route', value: schedule.route),
                  const SizedBox(height: 8),
                  _DetailRow(label: 'Site', value: schedule.site),

                  if (record.batchNumber != null) ...[
                    const SizedBox(height: 8),
                    _DetailRow(label: 'Batch Number', value: record.batchNumber!),
                  ],

                  if (record.manufacturer != null) ...[
                    const SizedBox(height: 8),
                    _DetailRow(label: 'Manufacturer', value: record.manufacturer!),
                  ],

                  // Notes
                  if (schedule.notes != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Important Notes',
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
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        schedule.notes!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1976D2),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  // Adverse Reaction
                  if (record.adverseReaction == true) ...[
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
                                'Adverse Reaction Reported',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                            ],
                          ),
                          if (record.adverseReactionDetails != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              record.adverseReactionDetails!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Clinician Information
                  if (record.clinicianName != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Clinician Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(label: 'Clinician', value: record.clinicianName!),
                    if (record.clinicianPhone != null) ...[
                      const SizedBox(height: 8),
                      _DetailRow(label: 'Phone', value: record.clinicianPhone!),
                    ],
                    if (record.healthFacility != null) ...[
                      const SizedBox(height: 8),
                      _DetailRow(label: 'Facility', value: record.healthFacility!),
                    ],
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
    switch (record.status) {
      case 'administered':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'contraindicated':
        return Colors.grey;
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
