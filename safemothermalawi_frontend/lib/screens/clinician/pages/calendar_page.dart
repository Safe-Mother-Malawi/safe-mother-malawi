import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../state/events_store.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

enum EventType { prenatal, neonatal, other }

class CalEvent {
  final String id;
  final String title;
  final String patientName;
  final String patientContact;
  final String patientStatus;
  final String time;
  final String notes;
  final EventType type;
  final DateTime date;

  CalEvent({
    required this.id, required this.title, required this.patientName,
    required this.patientContact, required this.patientStatus,
    required this.time, required this.notes, required this.type,
    required this.date,
  });

  CalEvent copyWith({String? title, String? time, String? notes}) => CalEvent(
        id: id, patientName: patientName, patientContact: patientContact,
        patientStatus: patientStatus, type: type, date: date,
        title: title ?? this.title,
        time: time ?? this.time,
        notes: notes ?? this.notes,
      );
}

// ── Seed data ─────────────────────────────────────────────────────────────────

List<CalEvent> _seedEvents() {
  final now = DateTime.now();
  final y = now.year; final m = now.month;
  return [
    CalEvent(id: '1', title: 'ANC Check', patientName: 'Grace Banda',       patientContact: '+265 991 234 567', patientStatus: 'Prenatal',  time: '09:00 AM', notes: 'BP monitoring required', type: EventType.prenatal,  date: DateTime(y, m, 3)),
    CalEvent(id: '2', title: 'Ultrasound', patientName: 'Faith Mwale',      patientContact: '+265 888 345 678', patientStatus: 'Prenatal',  time: '10:30 AM', notes: 'Growth scan at 34 weeks', type: EventType.prenatal, date: DateTime(y, m, 3)),
    CalEvent(id: '3', title: 'PNC Visit',  patientName: 'Mercy Tembo',      patientContact: '+265 993 111 222', patientStatus: 'Neonatal', time: '11:00 AM', notes: 'Day 8 neonatal check',   type: EventType.neonatal, date: DateTime(y, m, 7)),
    CalEvent(id: '4', title: 'ANC Visit',  patientName: 'Liness Kachali',   patientContact: '+265 999 456 789', patientStatus: 'Prenatal',  time: '02:00 PM', notes: 'Diabetes follow-up',      type: EventType.prenatal,  date: DateTime(y, m, 10)),
    CalEvent(id: '5', title: 'Labour Assessment', patientName: 'Joyce Mwale', patientContact: '+265 992 678 901', patientStatus: 'Prenatal', time: '09:30 AM', notes: 'Week 30 assessment',     type: EventType.prenatal,  date: DateTime(y, m, now.day)),
    CalEvent(id: '6', title: 'Counselling', patientName: 'Rose Phiri',      patientContact: '+265 994 222 333', patientStatus: 'Neonatal', time: '03:30 PM', notes: 'Neonatal mental health', type: EventType.neonatal, date: DateTime(y, m, now.day)),
    CalEvent(id: '7', title: 'First Visit', patientName: 'Aisha Tembo',     patientContact: '+265 881 567 890', patientStatus: 'Prenatal',  time: '01:00 PM', notes: 'New registration',        type: EventType.prenatal,  date: DateTime(y, m, now.day + 2 > 28 ? 28 : now.day + 2)),
    CalEvent(id: '8', title: 'PNC Day 14', patientName: 'Fatima Chirwa',    patientContact: '+265 995 333 444', patientStatus: 'Neonatal', time: '10:00 AM', notes: 'Routine day 14 check',    type: EventType.neonatal, date: DateTime(y, m, now.day + 4 > 28 ? 28 : now.day + 4)),
  ];
}

// ── Page ──────────────────────────────────────────────────────────────────────

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  DateTime? _selected;

  List<CalEvent> get _events => EventsStore.instance.events;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month    = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
    // Seed initial events into the store if empty
    if (_events.isEmpty) {
      for (final e in _seedEvents()) {
        EventsStore.instance.events.add(e);
      }
    }
    EventsStore.instance.addListener(_onStoreUpdate);
  }

  @override
  void dispose() {
    EventsStore.instance.removeListener(_onStoreUpdate);
    super.dispose();
  }

  void _onStoreUpdate() => setState(() {});

  List<CalEvent> _eventsOn(DateTime d) =>
      _events.where((e) => e.date.year == d.year && e.date.month == d.month && e.date.day == d.day).toList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeader(),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 3, child: _buildCalendar()),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildDayPanel()),
        ]),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(children: [
      const Icon(Icons.calendar_month_outlined, color: AppColors.navy, size: 22),
      const SizedBox(width: 10),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Calendar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
        Text('Track appointments and maternal events.', style: TextStyle(fontSize: 13, color: AppColors.g400)),
      ])),
      ElevatedButton.icon(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add Event', style: TextStyle(fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    ]);
  }

  // ── Calendar grid ─────────────────────────────────────────────────────────────

  Widget _buildCalendar() {
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun
    final today = DateTime.now();

    return Container(
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(children: [
        // Month nav
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            ),
            Expanded(
              child: Text(
                '${_monthName(_month.month)} ${_month.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            ),
          ]),
        ),
        // Day headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(children: ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
              .map((d) => Expanded(child: Center(
                child: Text(d, style: const TextStyle(fontSize: 11,
                    fontWeight: FontWeight.bold, color: AppColors.g400)))))
              .toList()),
        ),
        // Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, childAspectRatio: 1.1),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (_, i) {
              if (i < startWeekday) return const SizedBox();
              final day = i - startWeekday + 1;
              final date = DateTime(_month.year, _month.month, day);
              final events = _eventsOn(date);
              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
              final isSelected = _selected != null && date.year == _selected!.year &&
                  date.month == _selected!.month && date.day == _selected!.day;

              return GestureDetector(
                onTap: () => setState(() => _selected = date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.navy : isToday ? AppColors.navyL : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('$day', style: TextStyle(
                        fontSize: 13,
                        fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : isToday ? AppColors.navy : AppColors.g800)),
                    if (events.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: events.take(3).map((e) => Container(
                              width: 5, height: 5, margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withOpacity(0.8) : _eventColor(e.type),
                                shape: BoxShape.circle,
                              ),
                            )).toList()),
                      ),
                  ]),
                ),
              );
            },
          ),
        ),
        // Legend
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(children: [
            _legend('Scheduled Event', AppColors.navy),
          ]),
        ),
      ]),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.g400)),
    ]);
  }

  // ── Day panel ─────────────────────────────────────────────────────────────────

  Widget _buildDayPanel() {
    final events = _selected != null ? _eventsOn(_selected!) : <CalEvent>[];
    final label = _selected != null
        ? '${_selected!.day} ${_monthName(_selected!.month)} ${_selected!.year}'
        : 'Select a date';

    return Container(
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.g200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.g200)),
          ),
          child: Row(children: [
            const Icon(Icons.event_note_outlined, color: AppColors.navy, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                    color: AppColors.g800))),
            Text('${events.length} event${events.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 11, color: AppColors.g400)),
          ]),
        ),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Column(children: [
              Icon(Icons.event_available_outlined, color: AppColors.g200, size: 40),
              SizedBox(height: 8),
              Text('No events for this day.', style: TextStyle(color: AppColors.g400, fontSize: 13)),
            ])),
          )
        else
          ...events.map((e) => _eventCard(e)),
      ]),
    );
  }

  Widget _eventCard(CalEvent e) {
    final color = _eventColor(e.type);
    final bg    = _eventBg(e.type);
    final typeLabel = e.type == EventType.prenatal ? 'Prenatal'
        : e.type == EventType.neonatal ? 'Neonatal' : 'Other';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(e.title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: AppColors.g800))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
              child: Text(typeLabel,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
            ),
            const SizedBox(width: 8),
            // Edit
            GestureDetector(
              onTap: () => _showEditDialog(e),
              child: const Icon(Icons.edit_outlined, size: 15, color: AppColors.g400),
            ),
            const SizedBox(width: 8),
            // Delete
            GestureDetector(
              onTap: () => setState(() => EventsStore.instance.events.removeWhere((ev) => ev.id == e.id)),
              child: const Icon(Icons.delete_outline, size: 15, color: AppColors.red),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.access_time, size: 12, color: AppColors.g400),
            const SizedBox(width: 4),
            Text(e.time, style: const TextStyle(fontSize: 11, color: AppColors.g600)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.person_outline, size: 12, color: AppColors.g400),
            const SizedBox(width: 4),
            Text(e.patientName,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppColors.g800)),
            const SizedBox(width: 6),
            Text('· ${e.patientStatus}',
                style: const TextStyle(fontSize: 11, color: AppColors.g400)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.phone_outlined, size: 12, color: AppColors.g400),
            const SizedBox(width: 4),
            Text(e.patientContact,
                style: const TextStyle(fontSize: 11, color: AppColors.g600)),
          ]),
          if (e.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(e.notes,
                style: const TextStyle(fontSize: 11, color: AppColors.g400,
                    fontStyle: FontStyle.italic)),
          ],
        ]),
      ),
    );
  }

  // ── Add / Edit dialogs ────────────────────────────────────────────────────────

  void _showAddDialog() {
    final titleCtrl   = TextEditingController();
    final patientCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final timeCtrl    = TextEditingController(text: '09:00 AM');
    final notesCtrl   = TextEditingController();
    EventType type    = EventType.prenatal;
    DateTime date     = _selected ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return _eventDialog(
          title: 'Add New Event',
          titleCtrl: titleCtrl, patientCtrl: patientCtrl,
          contactCtrl: contactCtrl, timeCtrl: timeCtrl, notesCtrl: notesCtrl,
          type: type, date: date,
          onTypeChanged: (t) => setS(() => type = t),
          onDateChanged: (d) => setS(() => date = d),
          onSave: () {
            if (titleCtrl.text.trim().isEmpty || patientCtrl.text.trim().isEmpty) return;
              setState(() {
                EventsStore.instance.add(CalEvent(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleCtrl.text.trim(),
                  patientName: patientCtrl.text.trim(),
                  patientContact: contactCtrl.text.trim(),
                  patientStatus: type == EventType.prenatal ? 'Prenatal' : 'Neonatal',
                  time: timeCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                  type: type, date: date,
                ));
              });
            Navigator.pop(ctx);
          },
        );
      }),
    );
  }

  void _showEditDialog(CalEvent e) {
    final titleCtrl   = TextEditingController(text: e.title);
    final patientCtrl = TextEditingController(text: e.patientName);
    final contactCtrl = TextEditingController(text: e.patientContact);
    final timeCtrl    = TextEditingController(text: e.time);
    final notesCtrl   = TextEditingController(text: e.notes);
    EventType type    = e.type;
    DateTime date     = e.date;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return _eventDialog(
          title: 'Edit Event',
          titleCtrl: titleCtrl, patientCtrl: patientCtrl,
          contactCtrl: contactCtrl, timeCtrl: timeCtrl, notesCtrl: notesCtrl,
          type: type, date: date,
          onTypeChanged: (t) => setS(() => type = t),
          onDateChanged: (d) => setS(() => date = d),
          onSave: () {
            setState(() {
              final idx = EventsStore.instance.events.indexWhere((ev) => ev.id == e.id);
              if (idx != -1) {
                EventsStore.instance.events[idx] = CalEvent(
                  id: e.id, title: titleCtrl.text.trim(),
                  patientName: patientCtrl.text.trim(),
                  patientContact: contactCtrl.text.trim(),
                  patientStatus: type == EventType.prenatal ? 'Prenatal' : 'Neonatal',
                  time: timeCtrl.text.trim(), notes: notesCtrl.text.trim(),
                  type: type, date: date,
                );
                EventsStore.instance.notify();
              }
            });
            Navigator.pop(ctx);
          },
        );
      }),
    );
  }

  Widget _eventDialog({
    required String title,
    required TextEditingController titleCtrl, patientCtrl, contactCtrl, timeCtrl, notesCtrl,
    required EventType type, required DateTime date,
    required void Function(EventType) onTypeChanged,
    required void Function(DateTime) onDateChanged,
    required VoidCallback onSave,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.event, color: AppColors.navy, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: AppColors.g800)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 18, color: AppColors.g400),
                  padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ]),
            const SizedBox(height: 20),
            // Type toggle
            Row(children: [
              _typeBtn('Prenatal', EventType.prenatal, type, onTypeChanged),
              const SizedBox(width: 8),
              _typeBtn('Neonatal', EventType.neonatal, type, onTypeChanged),
              const SizedBox(width: 8),
              _typeBtn('Other', EventType.other, type, onTypeChanged),
            ]),
            const SizedBox(height: 16),
            _dlgField('Event Title', titleCtrl, Icons.title),
            const SizedBox(height: 12),
            _dlgField('Patient Name', patientCtrl, Icons.person_outline),
            const SizedBox(height: 12),
            _dlgField('Contact', contactCtrl, Icons.phone_outlined),
            const SizedBox(height: 12),
            _dlgField('Time (e.g. 09:00 AM)', timeCtrl, Icons.access_time),
            const SizedBox(height: 12),
            // Date picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2028),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(primary: AppColors.navy)),
                    child: child!,
                  ),
                );
                if (picked != null) onDateChanged(picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.bg, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.g200),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.navy),
                  const SizedBox(width: 10),
                  Text('${date.day} ${_monthName(date.month)} ${date.year}',
                      style: const TextStyle(fontSize: 13, color: AppColors.g800)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            _dlgField('Notes (optional)', notesCtrl, Icons.notes_outlined),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.g400))),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Save Event'),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _typeBtn(String label, EventType t, EventType current, void Function(EventType) onChanged) {
    final sel = current == t;
    final color = AppColors.navy;
    return GestureDetector(
      onTap: () => onChanged(t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? color : AppColors.g100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: sel ? Colors.white : AppColors.g600)),
      ),
    );
  }

  Widget _dlgField(String hint, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(fontSize: 12, color: AppColors.g400),
        prefixIcon: Icon(icon, size: 16, color: AppColors.navy),
        filled: true, fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.g200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.g200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.navy, width: 1.5)),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Color _eventColor(EventType t) => AppColors.navy;

  Color _eventBg(EventType t) => AppColors.navyL;

  String _monthName(int m) => const [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ][m];
}
