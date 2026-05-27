import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/animated_pulse_dot.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service_web.dart';
import '../../../utils/live_data_mixin.dart';

class ClinicianAlertsPage extends StatefulWidget {
  final void Function(int)? onNavigate;
  const ClinicianAlertsPage({super.key, this.onNavigate});

  // Static variable to pass patient data to calendar
  static Map<String, dynamic>? pendingAppointmentData;

  @override
  State<ClinicianAlertsPage> createState() => _ClinicianAlertsPageState();
}

class _ClinicianAlertsPageState extends State<ClinicianAlertsPage>
    with SingleTickerProviderStateMixin, LiveDataMixin<ClinicianAlertsPage> {
  late TabController _tabCtrl;
  final _search = TextEditingController();
  String _filter = 'All';

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _alerts = [];
  Timer? _timeTicker;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
    startLive(
      _load,
      pollInterval: const Duration(seconds: 5),
      onEvent: _handleLiveEvent,
    );
    _timeTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _alerts.isNotEmpty) setState(() {});
    });
  }

  @override
  void dispose() {
    stopLive();
    _timeTicker?.cancel();
    _tabCtrl.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final raw = await ApiService.instance.get('/alerts');
      final list = raw is List ? raw : (raw is Map ? (raw['data'] as List? ?? []) : []);
      if (!mounted) return;
      setState(() {
        _alerts = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
          ..sort(_newestFirst);
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _handleLiveEvent(String event, dynamic payload) {
    if (event != 'alert:created' || payload is! Map || !mounted) return;

    final alert = _alertFromPayload(payload);
    if (!_isVisibleForCurrentClinician(alert)) return;

    setState(() {
      final id = _text(alert['id']);
      final index = id.isEmpty
          ? -1
          : _alerts.indexWhere((item) => _text(item['id']) == id);

      if (index >= 0) {
        _alerts[index] = {..._alerts[index], ...alert};
      } else {
        _alerts.insert(0, alert);
      }

      _alerts.sort(_newestFirst);
      _loading = false;
      _error = null;
    });
  }

  Map<String, dynamic> _alertFromPayload(Map payload) {
    final alert = payload.map((key, value) => MapEntry(key.toString(), value));
    alert['createdAt'] = _text(
      alert['createdAt'],
      fallback: DateTime.now().toUtc().toIso8601String(),
    );
    alert['attended'] = alert['attended'] == true;

    final symptoms = alert['symptoms'];
    alert['symptoms'] = symptoms is List
        ? symptoms.map((item) => item.toString()).toList()
        : <String>[];

    return alert;
  }

  bool _isVisibleForCurrentClinician(Map<String, dynamic> alert) {
    final user = AuthServiceWeb.instance.currentUser;
    if (user == null) return true;

    final role = _text(user['role']).toLowerCase();
    if (role != 'clinician') return true;

    final clinicianId = _text(user['id']);
    final alertClinicianId = _text(alert['clinicianId']);
    if (clinicianId.isNotEmpty && clinicianId == alertClinicianId) return true;

    final userDistrict = _text(user['district']);
    final userFacility = _text(user['facilityName']);
    final alertDistrict = _text(alert['district']);
    final alertFacility = _text(alert['facilityName']);

    if (userDistrict.isEmpty) return alertDistrict.isEmpty;
    if (alertDistrict.isNotEmpty && !_same(userDistrict, alertDistrict)) {
      return false;
    }

    if (userFacility.isEmpty) return true;
    return alertFacility.isEmpty || _same(userFacility, alertFacility);
  }

  Future<void> _markAttended(Map<String, dynamic> alert) async {
    final id = alert['id'] as String;
    try {
      await ApiService.instance.patch('/alerts/$id/attended', {});
      setState(() => alert['attended'] = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${alert['patientName']}'s alert has been attended to."),
        backgroundColor: const Color(0xFF1A3A5C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _active => _alerts.where((a) {
        if (a['attended'] == true) return false;
        final status = (a['patientStatus'] ?? '').toString();
        if (_filter == 'Prenatal' && status != 'Prenatal') return false;
        if (_filter == 'Neonatal' && status != 'Neonatal') return false;
        final q = _search.text.toLowerCase();
        if (q.isNotEmpty && !(a['patientName'] ?? '').toString().toLowerCase().contains(q)) return false;
        return true;
      }).toList()
        ..sort(_newestFirst);

  List<Map<String, dynamic>> get _history =>
      List<Map<String, dynamic>>.from(_alerts)..sort(_newestFirst);

  Map<String, List<Map<String, dynamic>>> _groupByDate(List<Map<String, dynamic>> list) {
    final now       = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final map       = <String, List<Map<String, dynamic>>>{};
    for (final a in list) {
      final dt = _parseCreatedAt(a['createdAt']);
      final d  = DateTime(dt.year, dt.month, dt.day);
      String key;
      if (d == today) key = 'Today';
      else if (d == yesterday) key = 'Yesterday';
      else key = '${d.day}/${d.month}/${d.year}';
      map.putIfAbsent(key, () => []).add(a);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        const Text('Failed to load alerts'),
        TextButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Retry')),
      ]));
    }

    final activeCount = _alerts.where((a) => a['attended'] != true).length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
          const SizedBox(height: 4),
          const Text('Monitor and track patient alerts.', style: TextStyle(fontSize: 13, color: AppColors.g400)),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabCtrl,
            labelColor: AppColors.navy,
            unselectedLabelColor: AppColors.g400,
            indicatorColor: AppColors.navy,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Active ($activeCount)'),
              Tab(text: 'History (${_alerts.length})'),
            ],
          ),
        ]),
      ),
      const Divider(height: 1, color: AppColors.g200),
      Expanded(child: TabBarView(
        controller: _tabCtrl,
        children: [_buildActiveTab(), _buildHistoryTab()],
      )),
    ]);
  }

  Widget _buildActiveTab() {
    final groups = _groupByDate(_active);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.navy.withOpacity(0.2))),
          child: const Row(children: [
            Icon(Icons.info_outline, color: AppColors.navy, size: 16),
            SizedBox(width: 10),
            Expanded(child: Text('Please contact the patient, check their symptoms, and give the right care if needed.', style: TextStyle(fontSize: 12, color: AppColors.navy))),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search alerts...',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.g400),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.g400),
              filled: true, fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          )),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.g200)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filter,
                style: const TextStyle(fontSize: 12, color: AppColors.g800),
                icon: const Icon(Icons.filter_list, size: 16, color: AppColors.navy),
                items: ['All','Prenatal','Neonatal'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (v) => setState(() => _filter = v!),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        if (groups.isEmpty)
          _emptyState('No active alerts.', 'All patients are currently stable.', Icons.notifications_off_outlined)
        else
          ...groups.entries.map((e) => _buildGroup(e.key, e.value, isHistory: false)),
      ]),
    );
  }

  Widget _buildHistoryTab() {
    final groups = _groupByDate(_history);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Icon(Icons.history, color: AppColors.g600, size: 16),
            SizedBox(width: 10),
            Expanded(child: Text('Complete record of all alerts. Preserved for clinical accountability.', style: TextStyle(fontSize: 12, color: AppColors.g600))),
          ]),
        ),
        const SizedBox(height: 16),
        if (groups.isEmpty)
          _emptyState('No alert history yet.', 'Alerts will appear here once raised.', Icons.history)
        else
          ...groups.entries.map((e) => _buildGroup(e.key, e.value, isHistory: true)),
      ]),
    );
  }

  Widget _buildGroup(String label, List<Map<String, dynamic>> alerts, {required bool isHistory}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.g600, letterSpacing: 0.5)),
          const SizedBox(width: 8),
          const Expanded(child: Divider(color: AppColors.g200, height: 1)),
        ]),
      ),
      ...alerts.map((a) => isHistory ? _historyCard(a) : _alertCard(a)),
      const SizedBox(height: 8),
    ]);
  }

  Widget _alertCard(Map<String, dynamic> a) {
    final severity   = (a['severity'] ?? 'high').toString();
    final isCritical = severity == 'critical';
    final riskColor  = isCritical ? AppColors.red : AppColors.orange;
    final name       = _text(a['patientName'], fallback: 'Unknown');
    final status     = _text(a['patientStatus']);
    final reason     = _text(a['reason']);
    final contact    = _text(a['contact']);
    final symptoms   = (a['symptoms'] as List<dynamic>? ?? []).cast<String>();
    final ts         = _parseCreatedAt(a['createdAt']);

    return GestureDetector(
      onTap: () => setState(() => a['_expanded'] = !(a['_expanded'] == true)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: riskColor.withOpacity(0.35), width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(top: 4, right: 10), child: AnimatedPulseDot(color: riskColor, size: 9)),
              CircleAvatar(radius: 17, backgroundColor: AppColors.navyL,
                  child: Text(_initial(name), style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800)),
                  const SizedBox(width: 8),
                  _badge(status, AppColors.navy, AppColors.navyL),
                ]),
                const SizedBox(height: 3),
                Text(reason, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: riskColor)),
                const SizedBox(height: 3),
                Text(_timeAgo(ts), style: const TextStyle(fontSize: 10, color: AppColors.g400)),
              ])),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _markAttended(a),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Mark as Done', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ]),
          ),
          if (a['_expanded'] == true)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.g200))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Reported Symptoms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800)),
                const SizedBox(height: 12),
                if (symptoms.isEmpty)
                  const Text('No symptoms recorded.', style: TextStyle(fontSize: 13, color: AppColors.g400))
                else
                  ...symptoms.map((s) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.g200)),
                        child: Row(children: [
                          const Icon(Icons.report_outlined, size: 16, color: AppColors.navy),
                          const SizedBox(width: 12),
                          Expanded(child: Text(s, style: const TextStyle(fontSize: 13, color: AppColors.g800))),
                        ]),
                      )),
                const SizedBox(height: 16),
                if (contact.isNotEmpty) ...[
                  const Text('Patient Contact', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.navy.withOpacity(0.2))),
                    child: Row(children: [
                      const Icon(Icons.phone_outlined, size: 18, color: AppColors.navy),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Phone Number', style: TextStyle(fontSize: 11, color: AppColors.g600)),
                        const SizedBox(height: 2),
                        Text(contact, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navy)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        // Store patient details for calendar to auto-fill
                        ClinicianAlertsPage.pendingAppointmentData = {
                          'patientName': name,
                          'patientContact': contact,
                          'patientType': status == 'Prenatal' ? 'prenatal' : 'neonatal',
                          'reason': reason,
                          'symptoms': symptoms,
                        };
                        
                        await ApiService.createAppointment({
                          'title': 'Checkup — $name',
                          'patientName': name,
                          'patientContact': contact,
                          'patientType': status == 'Prenatal' ? 'prenatal' : 'neonatal',
                          'time': '09:00 AM',
                          'notes': 'Scheduled from alert: $reason',
                          'scheduledDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
                          'status': 'Pending',
                        });
                      } catch (_) {}
                      widget.onNavigate?.call(5);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Row(children: [
                            Icon(Icons.calendar_today, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text('Checkup scheduled and added to Calendar.'),
                          ]),
                          backgroundColor: Color(0xFF1A3A5C),
                          duration: Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    },
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('Schedule Checkup', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
              ]),
            ),
        ]),
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> a) {
    final severity   = (a['severity'] ?? 'high').toString();
    final isCritical = severity == 'critical';
    final riskColor  = isCritical ? AppColors.red : AppColors.orange;
    final attended   = a['attended'] == true;
    final name       = _text(a['patientName'], fallback: 'Unknown');
    final status     = _text(a['patientStatus']);
    final reason     = _text(a['reason']);
    final ts         = _parseCreatedAt(a['createdAt']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: attended ? AppColors.g100 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.g200),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 4, right: 10),
            child: Container(width: 9, height: 9, decoration: BoxDecoration(color: attended ? AppColors.green : riskColor, shape: BoxShape.circle))),
        CircleAvatar(radius: 16, backgroundColor: AppColors.navyL,
            child: Text(_initial(name), style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: attended ? AppColors.g400 : AppColors.g800)),
            const SizedBox(width: 8),
            _badge(status, AppColors.navy, AppColors.navyL),
          ]),
          const SizedBox(height: 3),
          Text(reason, style: TextStyle(fontSize: 11, color: attended ? AppColors.g400 : riskColor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Row(children: [
            const Icon(Icons.access_time, size: 11, color: AppColors.g400),
            const SizedBox(width: 4),
            Text(_timeAgo(ts), style: const TextStyle(fontSize: 10, color: AppColors.g400)),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: attended ? AppColors.greenL : AppColors.redL, borderRadius: BorderRadius.circular(8)),
          child: Text(attended ? 'Attended To' : 'Pending',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: attended ? AppColors.green : AppColors.red)),
        ),
      ]),
    );
  }

  Widget _badge(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _emptyState(String title, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
      child: Center(child: Column(children: [
        Icon(icon, color: AppColors.green, size: 48),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.g800)),
        const SizedBox(height: 4),
        Text(sub, style: const TextStyle(fontSize: 13, color: AppColors.g400)),
      ])),
    );
  }

  String _timeAgo(DateTime t) {
    final localTime = t.isUtc ? t.toLocal() : t;
    var diff = DateTime.now().difference(localTime);
    if (diff.isNegative) diff = Duration.zero;
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  int _newestFirst(Map<String, dynamic> a, Map<String, dynamic> b) {
    return _parseCreatedAt(b['createdAt']).compareTo(_parseCreatedAt(a['createdAt']));
  }

  DateTime _parseCreatedAt(dynamic value) {
    final parsed = DateTime.tryParse(_text(value));
    if (parsed == null) return DateTime.now();
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  String _initial(String name) {
    final value = name.trim();
    if (value.isEmpty) return '?';
    return value.substring(0, 1).toUpperCase();
  }

  String _text(dynamic value, {String fallback = ''}) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? fallback : text;
  }

  bool _same(String left, String right) {
    return left.trim().toLowerCase() == right.trim().toLowerCase();
  }
}

