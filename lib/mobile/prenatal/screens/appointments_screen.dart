import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../auth/services/auth_service.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class AppointmentsScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  const AppointmentsScreen({super.key, this.onOpenDrawer});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();

  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getAppointments();
      setState(() {
        _appointments = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _prevMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      });

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _AddAppointmentDialog(
        selectedDay: _selectedDay,
        onSave: (appointment) {
          setState(() {
            _appointments.add(appointment);
            _appointments.sort((a, b) {
              final da = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
              final db = DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
              return da.compareTo(db);
            });
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: Column(
        children: [
          _CalendarHeader(
            focusedMonth: _focusedMonth,
            onPrev: _prevMonth,
            onNext: _nextMonth,
            onNew: _showAddDialog,
            onOpenDrawer: widget.onOpenDrawer,
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 40),
                          const SizedBox(height: 8),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _load, child: const Text('Retry')),
                        ]),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _CalendarGrid(
                                focusedMonth: _focusedMonth,
                                selectedDay: _selectedDay,
                                appointments: _appointments,
                                onDayTap: (d) => setState(() => _selectedDay = d),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                                child: Text(
                                  'UPCOMING APPOINTMENTS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF9E9E9E),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              ..._appointments
                                  .where((a) {
                                    final date = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
                                    return !date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                                  })
                                  .map((a) => _AppointmentCard(
                                    appointment: a,
                                    onView: () => _showViewDialog(context, a),
                                    onEdit: () => _showEditDialog(context, a),
                                    onDelete: () => _showDeleteDialog(context, a),
                                  )),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _fmtFull(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // ── Validation Functions ──────────────────────────────────────────────────────

  String? _validateEventTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Event title is required';
    if (value.trim().length < 3) return 'Event title must be at least 3 characters';
    return null;
  }

  String? _validateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Time is optional in mobile app
    final trimmed = value.trim();
    // Accept formats like: 09:00 AM, 2:30 PM, 14:30, 9am, 2pm
    if (!RegExp(r'^(\d{1,2}:\d{2}\s*(AM|PM|am|pm)?|\d{1,2}\s*(AM|PM|am|pm))$', caseSensitive: false).hasMatch(trimmed)) {
      return 'Enter time in format like "09:00 AM" or "2:30 PM"';
    }
    return null;
  }

  // ── View Appointment Dialog ──────────────────────────────────────────────────

  void _showViewDialog(BuildContext context, Map<String, dynamic> appointment) {
    final date = DateTime.tryParse(appointment['date'] ?? '') ?? DateTime.now();
    final title = (appointment['title'] ?? appointment['type'] ?? 'Appointment').toString();
    final time = (appointment['time'] ?? '—').toString();
    final location = (appointment['location'] ?? appointment['facility'] ?? '—').toString();
    final doctor = (appointment['doctor'] ?? appointment['clinician']?['fullName'] ?? '—').toString();
    final notes = (appointment['notes'] ?? '').toString();
    final status = (appointment['status'] ?? 'Pending').toString();
    bool remindersEnabled = appointment['remindersEnabled'] ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Appointment Details',
              style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                detailRow('Title', title),
                detailRow('Date', _fmtFull(date)),
                detailRow('Time', time),
                detailRow('Location', location),
                detailRow('Doctor/Provider', doctor),
                detailRow('Status', status),
                if (notes.isNotEmpty) detailRow('Notes', notes),
                const SizedBox(height: 16),
                // Reminder toggle
                Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, size: 16, color: Color(0xFF1A237E)),
                    const SizedBox(width: 8),
                    const Text('Reminders:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Switch(
                      value: remindersEnabled,
                      onChanged: (value) {
                        setDialogState(() {
                          remindersEnabled = value;
                        });
                        // Update the appointment in the list
                        setState(() {
                          appointment['remindersEnabled'] = value;
                        });
                        // TODO: Send update to backend when API supports it
                      },
                      activeTrackColor: const Color(0xFF1A237E),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  remindersEnabled
                      ? 'You will receive reminders:\n• 1 day before appointment\n• 1 hour before appointment'
                      : 'Reminders are disabled for this appointment',
                  style: TextStyle(
                    fontSize: 11,
                    color: remindersEnabled ? const Color(0xFF757575) : const Color(0xFF9E9E9E),
                    fontStyle: remindersEnabled ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
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
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
          ),
        ],
      ),
    );
  }

  // ── Edit Appointment Dialog ──────────────────────────────────────────────────

  void _showEditDialog(BuildContext context, Map<String, dynamic> appointment) {
    final titleCtrl = TextEditingController(text: appointment['title'] ?? '');
    final timeCtrl = TextEditingController(text: appointment['time'] ?? '');
    final locationCtrl = TextEditingController(text: appointment['location'] ?? '');
    final doctorCtrl = TextEditingController(text: appointment['doctor'] ?? '');
    final notesCtrl = TextEditingController(text: appointment['notes'] ?? '');
    DateTime? picked = DateTime.tryParse(appointment['date'] ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Appointment',
              style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogFieldWithValidation(
                    hint: 'Title *',
                    controller: titleCtrl,
                    validator: _validateEventTitle,
                  ),
                  const SizedBox(height: 10),
                  _DialogFieldWithValidation(
                    hint: 'Time (e.g. 10:00 AM)',
                    controller: timeCtrl,
                    validator: _validateTime,
                  ),
                  const SizedBox(height: 10),
                  _DialogField(hint: 'Location', controller: locationCtrl),
                  const SizedBox(height: 10),
                  _DialogField(hint: 'Doctor / Provider', controller: doctorCtrl),
                  const SizedBox(height: 10),
                  _DialogField(hint: 'Notes (optional)', controller: notesCtrl),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: picked ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2028),
                        builder: (c, child) => Theme(
                          data: Theme.of(c).copyWith(
                            colorScheme: const ColorScheme.light(primary: Color(0xFF1A237E)),
                          ),
                          child: child!,
                        ),
                      );
                      if (d != null) setS(() => picked = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFF5F5F5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Color(0xFF1A237E)),
                          const SizedBox(width: 8),
                          Text(
                            picked == null ? 'Select date *' : _fmtFull(picked!),
                            style: TextStyle(
                              fontSize: 13,
                              color: picked == null ? const Color(0xFFBDBDBD) : const Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (picked == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Date is required',
                        style: TextStyle(fontSize: 11, color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Reminder toggle
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, size: 16, color: Color(0xFF1A237E)),
                      const SizedBox(width: 8),
                      const Text('Enable Reminders:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Switch(
                        value: appointment['remindersEnabled'] ?? true,
                        onChanged: (value) {
                          setS(() {
                            appointment['remindersEnabled'] = value;
                          });
                        },
                        activeTrackColor: const Color(0xFF1A237E),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
              onPressed: () async {
                if (picked == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a date'), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await ApiService.updateAppointment(appointment['id'].toString(), {
                      'title': titleCtrl.text,
                      'patientName': titleCtrl.text,
                      'patientContact': doctorCtrl.text.isEmpty ? 'N/A' : doctorCtrl.text,
                      'date': picked!.toIso8601String().split('T')[0],
                      'time': timeCtrl.text.isEmpty ? 'TBD' : timeCtrl.text,
                      'location': locationCtrl.text.isEmpty ? null : locationCtrl.text,
                      'doctor': doctorCtrl.text.isEmpty ? null : doctorCtrl.text,
                      'notes': (notesCtrl.text.isEmpty ? '' : notesCtrl.text) + 
                               (locationCtrl.text.isEmpty ? '' : '\nLocation: ${locationCtrl.text}'),
                    });
                    setState(() {
                      final idx = _appointments.indexWhere((a) => a['id'] == appointment['id']);
                      if (idx != -1) {
                        _appointments[idx] = {
                          ..._appointments[idx],
                          'title': titleCtrl.text,
                          'time': timeCtrl.text.isEmpty ? 'TBD' : timeCtrl.text,
                          'location': locationCtrl.text.isEmpty ? null : locationCtrl.text,
                          'doctor': doctorCtrl.text.isEmpty ? null : doctorCtrl.text,
                          'notes': notesCtrl.text.isEmpty ? null : notesCtrl.text,
                          'date': picked!.toIso8601String().split('T')[0],
                        };
                      }
                    });
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Appointment updated successfully'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Appointment Dialog ───────────────────────────────────────────────

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> appointment) {
    final title = (appointment['title'] ?? appointment['type'] ?? 'Appointment').toString();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Appointment',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ApiService.deleteAppointment(appointment['id'].toString());
                setState(() {
                  _appointments.removeWhere((a) => a['id'] == appointment['id']);
                });
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Appointment deleted successfully'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Calendar Header ──────────────────────────────────────────────────────────

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onNew;
  final VoidCallback? onOpenDrawer;

  const _CalendarHeader({
    required this.focusedMonth,
    required this.onPrev,
    required this.onNext,
    required this.onNew,
    this.onOpenDrawer,
  });

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1A237E)),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => onOpenDrawer?.call(),
                child: const Icon(Icons.menu, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_months[focusedMonth.month - 1]} ${focusedMonth.year}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    const Text('Schedule',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onNew,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3949AB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('+ New',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Calendar Grid ────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<Map<String, dynamic>> appointments;
  final ValueChanged<DateTime> onDayTap;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDay,
    required this.appointments,
    required this.onDayTap,
  });

  bool _hasAppointment(DateTime day) => appointments.any((a) {
        final date = DateTime.tryParse(a['date'] ?? '');
        if (date == null) return false;
        return date.year == day.year && date.month == day.month && date.day == day.day;
      });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9E9E9E))),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (_, i) {
              if (i < startWeekday) return const SizedBox();
              final day = DateTime(focusedMonth.year, focusedMonth.month, i - startWeekday + 1);
              final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
              final isSelected = day.year == selectedDay.year &&
                  day.month == selectedDay.month &&
                  day.day == selectedDay.day;
              final hasAppt = _hasAppointment(day);

              return GestureDetector(
                onTap: () => onDayTap(day),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1A237E)
                        : isToday
                            ? const Color(0xFFE8EAF6)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? const Color(0xFF1A237E)
                                  : const Color(0xFF424242),
                        ),
                      ),
                      if (hasAppt && !isSelected)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A237E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Appointment Card ─────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const _AppointmentCard({
    required this.appointment,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final date = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
    final title = (a['title'] ?? a['type'] ?? 'Appointment').toString();
    final time = (a['time'] ?? '—').toString();
    final location = (a['location'] ?? a['facility'] ?? '—').toString();
    final doctor = (a['doctor'] ?? a['clinician']?['fullName'] ?? '—').toString();
    final status = (a['status'] ?? 'Pending').toString();

    final badgeData = _statusBadge(status, date);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _dateBadgeColor(status),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  _months[date.month - 1],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _dateBadgeTextColor(status),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _dateBadgeTextColor(status),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF212121))),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeData['bg'] as Color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeData['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeData['color'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('$time · $location',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                const SizedBox(height: 2),
                Text(doctor,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                const SizedBox(height: 8),
                // Action buttons
                Row(
                  children: [
                    // View button
                    _ActionButton(
                      icon: Icons.visibility_outlined,
                      label: 'View',
                      color: const Color(0xFF1A237E),
                      onTap: onView,
                    ),
                    const SizedBox(width: 8),
                    // Edit button
                    _ActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      color: const Color(0xFF1A237E),
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    _ActionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: Colors.red,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _dateBadgeColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return const Color(0xFFE8F5E9);
      case 'completed': return const Color(0xFFE8F5E9);
      default: return const Color(0xFFE8EAF6);
    }
  }

  Color _dateBadgeTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed': return const Color(0xFF2E7D32);
      default: return const Color(0xFF1A237E);
    }
  }

  Map<String, dynamic> _statusBadge(String status, DateTime date) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return {'label': 'Confirmed', 'color': const Color(0xFF2E7D32), 'bg': const Color(0xFFE8F5E9)};
      case 'completed':
        return {'label': 'Completed', 'color': const Color(0xFF2E7D32), 'bg': const Color(0xFFE8F5E9)};
      case 'missed':
        return {'label': 'Missed', 'color': const Color(0xFFC62828), 'bg': const Color(0xFFFFEBEE)};
      default:
        final diff = date.difference(DateTime.now()).inDays;
        if (diff == 0) return {'label': 'Today', 'color': const Color(0xFFC62828), 'bg': const Color(0xFFFFEBEE)};
        if (diff == 1) return {'label': 'Tomorrow', 'color': const Color(0xFFC62828), 'bg': const Color(0xFFFFEBEE)};
        return {'label': 'Pending', 'color': const Color(0xFFE65100), 'bg': const Color(0xFFFFF3E0)};
    }
  }
}

// ─── Dialog Field ─────────────────────────────────────────────────────────────

class _DialogField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  const _DialogField({required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1A237E))),
      ),
    );
  }
}

// ─── Dialog Field with Validation ──────────────────────────────────────────────

class _DialogFieldWithValidation extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  const _DialogFieldWithValidation({
    required this.hint,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1A237E))),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




// ─── Add Appointment Dialog ───────────────────────────────────────────────────

class _AddAppointmentDialog extends StatefulWidget {
  final DateTime selectedDay;
  final Function(Map<String, dynamic>) onSave;

  const _AddAppointmentDialog({
    required this.selectedDay,
    required this.onSave,
  });

  @override
  State<_AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<_AddAppointmentDialog> {
  late TextEditingController titleCtrl;
  late TextEditingController timeCtrl;
  late TextEditingController locationCtrl;
  late DateTime pickedDate;
  
  List<Map<String, dynamic>> clinicians = [];
  String? selectedClinicianId;
  String? selectedClinicianName;
  bool loadingClinicians = false;
  String? patientId;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController();
    timeCtrl = TextEditingController();
    locationCtrl = TextEditingController();
    pickedDate = widget.selectedDay;
    _loadCliniciansAndPatient();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    timeCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCliniciansAndPatient() async {
    setState(() => loadingClinicians = true);
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null && user.facilityName.isNotEmpty) {
        // Fetch clinicians
        final clinicianData = await ApiService.getCliniciansByFacility(user.facilityName);
        
        // Fetch patient ID
        final patientData = await ApiService.instance.get('/patients/me/prenatal');
        final patientId = patientData is Map ? patientData['id'] as String? : null;
        
        setState(() {
          clinicians = (clinicianData as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          this.patientId = patientId;
          loadingClinicians = false;
        });
      } else {
        setState(() => loadingClinicians = false);
      }
    } catch (e) {
      setState(() => loadingClinicians = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('New Appointment',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(hint: 'Title', controller: titleCtrl),
            const SizedBox(height: 10),
            _DialogField(hint: 'Time (e.g. 10:00 AM)', controller: timeCtrl),
            const SizedBox(height: 10),
            _DialogField(hint: 'Location', controller: locationCtrl),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: pickedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2028),
                  builder: (c, child) => Theme(
                    data: Theme.of(c).copyWith(
                      colorScheme: const ColorScheme.light(primary: Color(0xFF1A237E)),
                    ),
                    child: child!,
                  ),
                );
                if (d != null) {
                  setState(() => pickedDate = d);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF5F5F5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF1A237E)),
                    const SizedBox(width: 8),
                    Text(
                      _fmtFull(pickedDate),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
          onPressed: () async {
            if (titleCtrl.text.isNotEmpty) {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final created = await ApiService.createAppointment({
                  'title': titleCtrl.text,
                  'patientName': titleCtrl.text,
                  'patientContact': 'N/A',
                  'type': 'prenatal',
                  'date': pickedDate.toIso8601String().split('T')[0],
                  'time': timeCtrl.text.isEmpty ? 'TBD' : timeCtrl.text,
                  'location': locationCtrl.text.isEmpty ? null : locationCtrl.text,
                  'doctor': selectedClinicianName,
                  'clinicianId': selectedClinicianId,
                  'prenatalPatientId': patientId,
                  'notes': locationCtrl.text.isEmpty ? '' : 'Location: ${locationCtrl.text}',
                  'status': 'scheduled',
                });
                widget.onSave(created);
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                        content: Text('Appointment created successfully'),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            }
          },
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  String _fmtFull(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

