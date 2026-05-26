import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';
import 'alerts_page.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  DateTime? _selected;

  List<Map<String, dynamic>> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month    = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getAppointments().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout. Please check your connection.'),
      );
      
      if (data is! List) {
        throw Exception('Invalid data format received from server');
      }
      
      setState(() {
        _events = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Failed to load calendar events: $e');
      setState(() { 
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false; 
      });
    }
  }

  List<Map<String, dynamic>> _eventsOn(DateTime d) => _events.where((e) {
        final date = DateTime.tryParse(e['scheduledDate'] ?? e['date'] ?? '');
        if (date == null) return false;
        return date.year == d.year && date.month == d.month && date.day == d.day;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeader(),
        const SizedBox(height: 20),
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
        else if (_error != null)
          Center(child: Column(children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 40),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ]))
        else
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
      const SizedBox(width: 8),
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
                            children: events.take(3).map((_) => Container(
                              width: 5, height: 5, margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.navy,
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
    final events = _selected != null ? _eventsOn(_selected!) : <Map<String, dynamic>>[];
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

  Widget _eventCard(Map<String, dynamic> e) {
    final title = (e['title'] ?? e['type'] ?? 'Appointment').toString();
    final time = (e['time'] ?? e['scheduledTime'] ?? '—').toString();
    final patientName = (e['patient']?['fullName'] ?? e['patientName'] ?? '—').toString();
    final patientContact = (e['patient']?['phone'] ?? e['patientContact'] ?? '—').toString();
    final notes = (e['notes'] ?? '').toString();
    final status = (e['status'] ?? 'Pending').toString();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: AppColors.navy, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: AppColors.g800))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.circular(8)),
              child: Text(status,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.navy)),
            ),
            const SizedBox(width: 4),
            // Edit button
            GestureDetector(
              onTap: () => _showEditDialog(e),
              child: const Icon(Icons.edit_outlined, size: 15, color: AppColors.navy),
            ),
            const SizedBox(width: 8),
            // Delete button
            GestureDetector(
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Appointment'),
                    content: Text('Delete "$title"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && e['id'] != null) {
                  try {
                    await ApiService.deleteAppointment(e['id'].toString());
                    setState(() => _events.remove(e));
                  } catch (err) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Delete failed: $err'), backgroundColor: AppColors.red),
                      );
                    }
                  }
                }
              },
              child: const Icon(Icons.delete_outline, size: 15, color: AppColors.red),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.access_time, size: 12, color: AppColors.g400),
            const SizedBox(width: 4),
            Text(time, style: const TextStyle(fontSize: 11, color: AppColors.g600)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.person_outline, size: 12, color: AppColors.g400),
            const SizedBox(width: 4),
            Text(patientName,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppColors.g800)),
          ]),
          if (patientContact.isNotEmpty && patientContact != '—') ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.phone_outlined, size: 12, color: AppColors.g400),
              const SizedBox(width: 4),
              Text(patientContact,
                  style: const TextStyle(fontSize: 11, color: AppColors.g600)),
            ]),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(notes,
                style: const TextStyle(fontSize: 11, color: AppColors.g400,
                    fontStyle: FontStyle.italic)),
          ],
        ]),
      ),
    );
  }

  // ── Add dialog ────────────────────────────────────────────────────────────────

  void _showAddDialog() {
    // Get pending appointment data from alerts page if available
    final pending = ClinicianAlertsPage.pendingAppointmentData;
    
    final titleCtrl   = TextEditingController(
      text: pending != null ? 'Checkup — ${pending['patientName']}' : ''
    );
    final patientCtrl = TextEditingController(
      text: pending != null ? pending['patientName'] as String : ''
    );
    final contactCtrl = TextEditingController(
      text: pending != null ? pending['patientContact'] as String : ''
    );
    final timeCtrl    = TextEditingController(text: '09:00 AM');
    final notesCtrl   = TextEditingController(
      text: pending != null ? 'Alert: ${pending['reason']}' : ''
    );
    String type       = pending != null ? (pending['patientType'] as String) : 'prenatal';
    DateTime date     = _selected ?? DateTime.now();
    List<Map<String, dynamic>> allPatients = [];
    List<Map<String, dynamic>> filteredPatients = [];
    bool loadingPatients = false;

    // Clear pending data after using it
    ClinicianAlertsPage.pendingAppointmentData = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return _eventDialog(
          title: 'Add New Event',
          titleCtrl: titleCtrl, patientCtrl: patientCtrl,
          contactCtrl: contactCtrl, timeCtrl: timeCtrl, notesCtrl: notesCtrl,
          type: type, date: date,
          allPatients: allPatients,
          filteredPatients: filteredPatients,
          loadingPatients: loadingPatients,
          onTypeChanged: (t) => setS(() => type = t),
          onDateChanged: (d) => setS(() => date = d),
          onPatientNameChanged: (query) async {
            setS(() {
              filteredPatients = allPatients.where((p) {
                final name = (p['fullName'] ?? p['motherName'] ?? '').toString().toLowerCase();
                return name.contains(query.toLowerCase());
              }).toList();
            });
          },
          onPatientSelected: (patient) {
            setS(() {
              patientCtrl.text = (patient['fullName'] ?? patient['motherName'] ?? '').toString();
              contactCtrl.text = (patient['phone'] ?? '').toString();
              filteredPatients = [];
            });
          },
          onLoadPatients: () async {
            setS(() => loadingPatients = true);
            try {
              final prenatal = await ApiService.instance.get('/patients/prenatal') as List<dynamic>;
              final neonatal = await ApiService.instance.get('/patients/neonatal') as List<dynamic>;
              final tempPatients = <Map<String, dynamic>>[];
              
              for (final p in prenatal.whereType<Map>()) {
                tempPatients.add({...Map<String, dynamic>.from(p), '_type': 'prenatal'});
              }
              for (final p in neonatal.whereType<Map>()) {
                tempPatients.add({...Map<String, dynamic>.from(p), '_type': 'neonatal'});
              }
              
              setS(() {
                allPatients = tempPatients;
                loadingPatients = false;
              });
            } catch (e) {
              setS(() => loadingPatients = false);
            }
          },
          onSave: () async {
            Navigator.pop(ctx);
            try {
              final created = await ApiService.createAppointment({
                'title': titleCtrl.text.trim(),
                'patientName': patientCtrl.text.trim(),
                'patientContact': contactCtrl.text.trim(),
                'time': timeCtrl.text.trim(),
                'notes': notesCtrl.text.trim(),
                'type': type,
                'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
                'status': 'scheduled',
              });
              setState(() => _events.add(created));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event added successfully'), backgroundColor: AppColors.green),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.red),
                );
              }
            }
          },
        );
      }),
    );
  }

  void _showEditDialog(Map<String, dynamic> event) {
    final titleCtrl   = TextEditingController(text: event['title'] ?? '');
    final patientCtrl = TextEditingController(text: event['patientName'] ?? '');
    final contactCtrl = TextEditingController(text: event['patientContact'] ?? '');
    final timeCtrl    = TextEditingController(text: event['time'] ?? '09:00 AM');
    final notesCtrl   = TextEditingController(text: event['notes'] ?? '');
    String type       = event['type'] ?? 'prenatal';
    DateTime date     = DateTime.tryParse(event['date'] ?? '') ?? DateTime.now();
    List<Map<String, dynamic>> allPatients = [];
    List<Map<String, dynamic>> filteredPatients = [];
    bool loadingPatients = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return _eventDialog(
          title: 'Edit Event',
          titleCtrl: titleCtrl, patientCtrl: patientCtrl,
          contactCtrl: contactCtrl, timeCtrl: timeCtrl, notesCtrl: notesCtrl,
          type: type, date: date,
          allPatients: allPatients,
          filteredPatients: filteredPatients,
          loadingPatients: loadingPatients,
          onTypeChanged: (t) => setS(() => type = t),
          onDateChanged: (d) => setS(() => date = d),
          onPatientNameChanged: (query) async {
            setS(() {
              filteredPatients = allPatients.where((p) {
                final name = (p['fullName'] ?? p['motherName'] ?? '').toString().toLowerCase();
                return name.contains(query.toLowerCase());
              }).toList();
            });
          },
          onPatientSelected: (patient) {
            setS(() {
              patientCtrl.text = (patient['fullName'] ?? patient['motherName'] ?? '').toString();
              contactCtrl.text = (patient['phone'] ?? '').toString();
              filteredPatients = [];
            });
          },
          onLoadPatients: () async {
            setS(() => loadingPatients = true);
            try {
              final prenatal = await ApiService.instance.get('/patients/prenatal') as List<dynamic>;
              final neonatal = await ApiService.instance.get('/patients/neonatal') as List<dynamic>;
              final tempPatients = <Map<String, dynamic>>[];
              
              for (final p in prenatal.whereType<Map>()) {
                tempPatients.add({...Map<String, dynamic>.from(p), '_type': 'prenatal'});
              }
              for (final p in neonatal.whereType<Map>()) {
                tempPatients.add({...Map<String, dynamic>.from(p), '_type': 'neonatal'});
              }
              
              setS(() {
                allPatients = tempPatients;
                loadingPatients = false;
              });
            } catch (e) {
              setS(() => loadingPatients = false);
            }
          },
          onSave: () async {
            Navigator.pop(ctx);
            try {
              await ApiService.updateAppointment(event['id'].toString(), {
                'title': titleCtrl.text.trim(),
                'patientName': patientCtrl.text.trim(),
                'patientContact': contactCtrl.text.trim(),
                'time': timeCtrl.text.trim(),
                'notes': notesCtrl.text.trim(),
                'type': type,
                'date': date.toIso8601String().split('T')[0],
              });
              setState(() {
                final idx = _events.indexWhere((e) => e['id'] == event['id']);
                if (idx != -1) {
                  _events[idx] = {
                    ..._events[idx],
                    'title': titleCtrl.text.trim(),
                    'patientName': patientCtrl.text.trim(),
                    'patientContact': contactCtrl.text.trim(),
                    'time': timeCtrl.text.trim(),
                    'notes': notesCtrl.text.trim(),
                    'type': type,
                    'date': date.toIso8601String().split('T')[0],
                  };
                }
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event updated successfully'), backgroundColor: AppColors.green),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppColors.red),
                );
              }
            }
          },
        );
      }),
    );
  }

  Widget _eventDialog({
    required String title,
    required TextEditingController titleCtrl, patientCtrl, contactCtrl, timeCtrl, notesCtrl,
    required String type, required DateTime date,
    required List<Map<String, dynamic>> allPatients,
    required List<Map<String, dynamic>> filteredPatients,
    required bool loadingPatients,
    required void Function(String) onTypeChanged,
    required void Function(DateTime) onDateChanged,
    required void Function(String) onPatientNameChanged,
    required void Function(Map<String, dynamic>) onPatientSelected,
    required Future<void> Function() onLoadPatients,
    required VoidCallback onSave,
  }) {
    final formKey = GlobalKey<FormState>();
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: formKey,
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
                _typeBtn('Prenatal', 'prenatal', type, onTypeChanged),
                const SizedBox(width: 8),
                _typeBtn('Neonatal', 'neonatal', type, onTypeChanged),
                const SizedBox(width: 8),
                _typeBtn('Other', 'other', type, onTypeChanged),
              ]),
              const SizedBox(height: 16),
              _dlgField('Event Title *', titleCtrl, Icons.title, validator: _validateEventTitle),
              const SizedBox(height: 12),
              // Patient name field with autocomplete
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Patient Name *', style: TextStyle(fontSize: 12, color: AppColors.g600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: patientCtrl,
                  onChanged: (query) {
                    onPatientNameChanged(query);
                    if (allPatients.isEmpty) {
                      onLoadPatients();
                    }
                  },
                  validator: _validateFullName,
                  decoration: InputDecoration(
                    hintText: 'Type patient name...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.g400),
                    prefixIcon: const Icon(Icons.person_outline, size: 16, color: AppColors.navy),
                    filled: true, fillColor: AppColors.bg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.g200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.g200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.navy, width: 1.5)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.red)),
                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.red, width: 1.5)),
                  ),
                ),
                // Filtered patient list dropdown
                if (patientCtrl.text.isNotEmpty && filteredPatients.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.g200),
                      boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredPatients.length,
                      itemBuilder: (_, i) {
                        final patient = filteredPatients[i];
                        final name = (patient['fullName'] ?? patient['motherName'] ?? '').toString();
                        final phone = (patient['phone'] ?? '').toString();
                        return GestureDetector(
                          onTap: () => onPatientSelected(patient),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.g200, width: i < filteredPatients.length - 1 ? 0.5 : 0)),
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800)),
                              if (phone.isNotEmpty)
                                Text(phone, style: const TextStyle(fontSize: 11, color: AppColors.g400)),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
              ]),
              const SizedBox(height: 12),
              _dlgField('Contact *', contactCtrl, Icons.phone_outlined, validator: _validatePhone),
              const SizedBox(height: 12),
              _dlgField('Time (e.g. 09:00 AM) *', timeCtrl, Icons.access_time, validator: _validateTime),
              const SizedBox(height: 12),
              // Date picker
              GestureDetector(
                onTap: () async {
                  final today = DateTime.now();
                  final todayDate = DateTime(today.year, today.month, today.day);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date.isBefore(todayDate) ? todayDate : date,
                    firstDate: todayDate,
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
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      onSave();
                    }
                  },
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
      ),
    );
  }

  Widget _typeBtn(String label, String t, String current, void Function(String) onChanged) {
    final sel = current == t;
    return GestureDetector(
      onTap: () => onChanged(t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? AppColors.navy : AppColors.g100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: sel ? Colors.white : AppColors.g600)),
      ),
    );
  }

  Widget _dlgField(String hint, TextEditingController ctrl, IconData icon, {String? Function(String?)? validator, void Function(String)? onChanged}) {
    return TextFormField(
      controller: ctrl,
      onChanged: onChanged,
      validator: validator,
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
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.red, width: 1.5)),
      ),
    );
  }

  // ── Validation Functions ──────────────────────────────────────────────────────

  String? _validateEventTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Event title is required';
    if (value.trim().length < 3) return 'Event title must be at least 3 characters';
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Full name is required';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) return 'Full name must include first and last name';
    if (parts.any((p) => RegExp(r'\d').hasMatch(p))) return 'Name cannot contain digits';
    if (parts.any((p) => !RegExp(r"^[a-zA-Z\-']+$").hasMatch(p))) return 'Name can only contain letters, hyphens, and apostrophes';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length != 10) return 'Phone must be exactly 10 digits';
    if (!value.startsWith('0')) return 'Phone must start with 0';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Phone must contain only digits';
    return null;
  }

  String? _validateTime(String? value) {
    if (value == null || value.trim().isEmpty) return 'Time is required';
    final trimmed = value.trim();
    // Accept formats like: 09:00 AM, 2:30 PM, 14:30, 9am, 2pm
    if (!RegExp(r'^(\d{1,2}:\d{2}\s*(AM|PM|am|pm)?|\d{1,2}\s*(AM|PM|am|pm))$', caseSensitive: false).hasMatch(trimmed)) {
      return 'Enter time in format like "09:00 AM" or "2:30 PM"';
    }
    return null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _monthName(int m) => const [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ][m];
}



