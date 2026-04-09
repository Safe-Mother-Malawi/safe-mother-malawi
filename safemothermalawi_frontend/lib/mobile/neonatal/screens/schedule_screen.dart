import 'package:flutter/material.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

class _Appointment {
  final String title;
  final String time;
  final String location;
  final String provider;
  final DateTime date;
  final String status;
  final bool clinicianAssigned;

  _Appointment({
    required this.title,
    required this.time,
    required this.location,
    required this.provider,
    required this.date,
    required this.status,
    this.clinicianAssigned = false,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay  = DateTime.now();

  final List<_Appointment> _appointments = [
    _Appointment(
      title: 'Well-Baby Clinic Visit',
      time: '09:00 AM',
      location: 'Area 25 Health Centre',
      provider: 'Nurse Banda',
      date: DateTime.now().add(const Duration(days: 1)),
      status: 'tomorrow',
      clinicianAssigned: true,
    ),
    _Appointment(
      title: 'BCG Follow-up Check',
      time: '11:00 AM',
      location: 'Ndirande Health Centre',
      provider: 'Dr. Phiri',
      date: DateTime.now().add(const Duration(days: 14)),
      status: 'weeks',
    ),
    _Appointment(
      title: 'Weight & Growth Check',
      time: '08:30 AM',
      location: 'Area 25 Health Centre',
      provider: 'Nurse Chirwa',
      date: DateTime(DateTime.now().year, DateTime.now().month + 1, 5),
      status: 'confirmed',
    ),
  ];

  void _prevMonth() => setState(() =>
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1));

  void _nextMonth() => setState(() =>
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1));

  void _showAddDialog() {
    final titleCtrl    = TextEditingController();
    final timeCtrl     = TextEditingController();
    final locationCtrl = TextEditingController();
    final providerCtrl = TextEditingController();
    DateTime? picked   = _selectedDay;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('New Appointment',
              style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF00695C))),
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
                _DialogField(hint: 'Nurse / Provider', controller: providerCtrl),
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
                          colorScheme: const ColorScheme.light(primary: Color(0xFF00695C)),
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
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF00695C)),
                        const SizedBox(width: 8),
                        Text(
                          picked == null ? 'Select date' : _fmtFull(picked!),
                          style: TextStyle(
                            fontSize: 13,
                            color: picked == null
                                ? const Color(0xFFBDBDBD)
                                : const Color(0xFF212121),
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
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C)),
              onPressed: () {
                if (titleCtrl.text.isNotEmpty && picked != null) {
                  setState(() {
                    _appointments.add(_Appointment(
                      title: titleCtrl.text,
                      time: timeCtrl.text.isEmpty ? 'TBD' : timeCtrl.text,
                      location: locationCtrl.text.isEmpty ? 'TBD' : locationCtrl.text,
                      provider: providerCtrl.text.isEmpty ? 'TBD' : providerCtrl.text,
                      date: picked!,
                      status: 'pending',
                    ));
                    _appointments.sort((a, b) => a.date.compareTo(b.date));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F5),
      body: Column(
        children: [
          _CalendarHeader(
            focusedMonth: _focusedMonth,
            onPrev: _prevMonth,
            onNext: _nextMonth,
            onNew: _showAddDialog,
          ),
          Expanded(
            child: SingleChildScrollView(
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
                      .where((a) => !a.date.isBefore(
                          DateTime.now().subtract(const Duration(days: 1))))
                      .map((a) => _AppointmentCard(appointment: a)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtFull(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ─── Calendar Header ──────────────────────────────────────────────────────────

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedMonth;
  final VoidCallback onPrev, onNext, onNew;
  const _CalendarHeader({
    required this.focusedMonth,
    required this.onPrev,
    required this.onNext,
    required this.onNew,
  });

  static const _months = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF00695C),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            children: [
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
                    color: const Color(0xFF00897B),
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
  final List<_Appointment> appointments;
  final ValueChanged<DateTime> onDayTap;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDay,
    required this.appointments,
    required this.onDayTap,
  });

  bool _hasAppt(DateTime day) => appointments.any((a) =>
      a.date.year == day.year &&
      a.date.month == day.month &&
      a.date.day == day.day);

  @override
  Widget build(BuildContext context) {
    final today       = DateTime.now();
    final firstDay    = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S','M','T','W','T','F','S']
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
              final day = DateTime(
                  focusedMonth.year, focusedMonth.month, i - startWeekday + 1);
              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              final isSelected = day.year == selectedDay.year &&
                  day.month == selectedDay.month &&
                  day.day == selectedDay.day;
              final hasAppt = _hasAppt(day);

              return GestureDetector(
                onTap: () => onDayTap(day),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00897B)
                        : isToday
                            ? const Color(0xFFB2DFDB)
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
                          fontWeight: isToday || isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? const Color(0xFF00695C)
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
                              color: Color(0xFF00695C),
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
  final _Appointment appointment;
  const _AppointmentCard({required this.appointment});

  static const _months = [
    'JAN','FEB','MAR','APR','MAY','JUN',
    'JUL','AUG','SEP','OCT','NOV','DEC'
  ];

  @override
  Widget build(BuildContext context) {
    final a         = appointment;
    final badgeData = _statusBadge(a.status, a.date);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _dateBadgeColor(a.status),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(_months[a.date.month - 1],
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _dateBadgeTextColor(a.status),
                        letterSpacing: 0.5)),
                Text('${a.date.day}',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _dateBadgeTextColor(a.status),
                        height: 1.1)),
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
                      child: Text(a.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF212121))),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeData['bg'] as Color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(badgeData['label'] as String,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeData['color'] as Color)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${a.time} · ${a.location}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF757575))),
                const SizedBox(height: 2),
                Text(a.provider,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF757575))),
                if (a.clinicianAssigned) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Clinician assigned',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF00695C),
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _dateBadgeColor(String s) {
    switch (s) {
      case 'tomorrow':  return const Color(0xFFE0F7FA);
      case 'confirmed': return const Color(0xFFE8F5E9);
      default:          return const Color(0xFFF5F5F5);
    }
  }

  Color _dateBadgeTextColor(String s) {
    switch (s) {
      case 'tomorrow':  return const Color(0xFF00695C);
      case 'confirmed': return const Color(0xFF2E7D32);
      default:          return const Color(0xFF616161);
    }
  }

  Map<String, dynamic> _statusBadge(String status, DateTime date) {
    switch (status) {
      case 'tomorrow':
        return {
          'label': 'Tomorrow',
          'color': const Color(0xFFC0392B),
          'bg': const Color(0xFFFDECEC)
        };
      case 'confirmed':
        return {
          'label': 'Confirmed',
          'color': const Color(0xFF2E7D32),
          'bg': const Color(0xFFE8F5E9)
        };
      case 'weeks':
        final diff  = date.difference(DateTime.now()).inDays;
        final weeks = (diff / 7).ceil();
        return {
          'label': '$weeks week${weeks == 1 ? '' : 's'}',
          'color': const Color(0xFF616161),
          'bg': const Color(0xFFF5F5F5)
        };
      default:
        return {
          'label': 'Pending',
          'color': const Color(0xFFE65100),
          'bg': const Color(0xFFFFF3E0)
        };
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF00695C))),
      ),
    );
  }
}
