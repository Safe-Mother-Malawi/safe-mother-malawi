import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/animated_pulse_dot.dart';
import '../../../services/api_service.dart';

class ClinicianAlertsPage extends StatefulWidget {
  final void Function(int)? onNavigate;
  const ClinicianAlertsPage({super.key, this.onNavigate});
  @override
  State<ClinicianAlertsPage> createState() => _ClinicianAlertsPageState();
}

class _ClinicianAlertsPageState extends State<ClinicianAlertsPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _alerts = [];
  bool _loading = true;
  late TabController _tabCtrl;
  String? _expandedId;
  String _filter = 'All';
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabCtrl.dispose(); _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getAllAlerts();
      setState(() { _alerts = data.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _markAttended(String id) async {
    try {
      await ApiService.markAlertAttended(id);
      setState(() {
        final idx = _alerts.indexWhere((a) => a['id'] == id);
        if (idx != -1) _alerts[idx]['attended'] = true;
        _expandedId = null;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
    }
  }

  List<Map<String, dynamic>> get _activeFiltered => _alerts.where((a) {
    if (a['attended'] == true) return false;
    if (_filter == 'Prenatal') return a['patientStatus'] == 'Prenatal';
    if (_filter == 'Neonatal') return a['patientStatus'] == 'Neonatal';
    if (_search.text.isNotEmpty &&
        !(a['patientName'] ?? '').toLowerCase().contains(_search.text.toLowerCase())) return false;
    return true;
  }).toList();

  List<Map<String, dynamic>> get _allAlerts => List.from(_alerts)
    ..sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));

  Map<String, List<Map<String, dynamic>>> _groupByDate(List<Map<String, dynamic>> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final map = <String, List<Map<String, dynamic>>>{};
    for (final a in list) {
      DateTime? dt;
      try { dt = DateTime.parse(a['createdAt'] ?? ''); } catch (_) {}
      final d = dt != null ? DateTime(dt.year, dt.month, dt.day) : today;
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
    final activeCount = _alerts.where((a) => a['attended'] != true).length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.g800)),
          const SizedBox(height: 4),
          const Text('Monitor and track patient alerts.', style: TextStyle(fontSize: 13, color: AppColors.g400)),
          const SizedBox(height: 16),
          TabBar(controller: _tabCtrl,
            labelColor: AppColors.navy, unselectedLabelColor: AppColors.g400,
            indicatorColor: AppColors.navy, indicatorWeight: 2,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Active ($activeCount)'),
              Tab(text: 'History (${_alerts.length})'),
            ]),
        ])),
      const Divider(height: 1, color: AppColors.g200),
      Expanded(child: TabBarView(controller: _tabCtrl, children: [
        _buildActiveTab(),
        _buildHistoryTab(),
      ])),
    ]);
  }

  Widget _buildActiveTab() {
    final groups = _groupByDate(_activeFiltered);
    return SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.navy.withOpacity(0.2))),
        child: const Row(children: [
          Icon(Icons.info_outline, color: AppColors.navy, size: 16), SizedBox(width: 10),
          Expanded(child: Text('Please remember to contact the patient, check their symptoms, and give the right care if needed.',
              style: TextStyle(fontSize: 12, color: AppColors.navy))),
        ])),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: TextField(controller: _search, onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: 'Search alerts...', hintStyle: const TextStyle(fontSize: 12, color: AppColors.g400),
            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.g400),
            filled: true, fillColor: AppColors.bg, contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)))),
        const SizedBox(width: 10),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.g200)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: _filter, style: const TextStyle(fontSize: 12, color: AppColors.g800),
            icon: const Icon(Icons.filter_list, size: 16, color: AppColors.navy),
            items: ['All','Prenatal','Neonatal'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (v) => setState(() => _filter = v!)))),
      ]),
      const SizedBox(height: 16),
      if (groups.isEmpty)
        _emptyState('No active alerts.', 'All patients are currently stable.', Icons.notifications_off_outlined)
      else
        ...groups.entries.map((e) => _buildGroup(e.key, e.value, isHistory: false)),
    ]));
  }

  Widget _buildHistoryTab() {
    final groups = _groupByDate(_allAlerts);
    return SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(8)),
        child: const Row(children: [
          Icon(Icons.history, color: AppColors.g600, size: 16), SizedBox(width: 10),
          Expanded(child: Text('Complete record of all alerts. This data is preserved for clinical accountability.',
              style: TextStyle(fontSize: 12, color: AppColors.g600))),
        ])),
      const SizedBox(height: 16),
      if (groups.isEmpty)
        _emptyState('No alert history yet.', 'Alerts will appear here once raised.', Icons.history)
      else
        ...groups.entries.map((e) => _buildGroup(e.key, e.value, isHistory: true)),
    ]));
  }

  Widget _buildGroup(String label, List<Map<String, dynamic>> alerts, {required bool isHistory}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.g600, letterSpacing: 0.5)),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: AppColors.g200, height: 1)),
      ])),
      ...alerts.map((a) => isHistory ? _historyCard(a) : _alertCard(a)),
      const SizedBox(height: 8),
    ]);
  }

  Widget _alertCard(Map<String, dynamic> a) {
    final isCritical = a['severity'] == 'critical';
    final riskColor  = isCritical ? AppColors.red : AppColors.orange;
    final expanded   = _expandedId == a['id'];
    final symptoms   = (a['symptoms'] as List<dynamic>?)?.cast<String>() ?? [];

    return GestureDetector(
      onTap: () => setState(() => _expandedId = expanded ? null : a['id']),
      child: AnimatedContainer(duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: riskColor.withOpacity(0.35), width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.all(14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(top: 4, right: 10),
                child: AnimatedPulseDot(color: riskColor, size: 9)),
            CircleAvatar(radius: 17, backgroundColor: AppColors.navyL,
                child: Text((a['patientName'] ?? '?')[0],
                    style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(a['patientName'] ?? '—', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800)),
                const SizedBox(width: 8),
                _badge(a['patientStatus'] ?? '', AppColors.navy, AppColors.navyL),
              ]),
              const SizedBox(height: 3),
              Text(a['reason'] ?? '', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: riskColor)),
              const SizedBox(height: 3),
              Text(_timeAgo(a['createdAt'] ?? ''), style: const TextStyle(fontSize: 10, color: AppColors.g400)),
            ])),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _markAttended(a['id']);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("${a['patientName']}'s alert has been attended to."),
                  backgroundColor: const Color(0xFF1A3A5C),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              },
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
                child: const Text('Mark as Done', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white))),
            ),
          ])),
          if (expanded)
            Container(padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.g200))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Reported Symptoms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800)),
                const SizedBox(height: 12),
                if (symptoms.isEmpty)
                  const Text('No symptoms recorded.', style: TextStyle(fontSize: 13, color: AppColors.g400))
                else
                  ...symptoms.map((s) => Container(margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.g200)),
                    child: Row(children: [
                      const Icon(Icons.report_outlined, size: 16, color: AppColors.navy),
                      const SizedBox(width: 12),
                      Expanded(child: Text(s, style: const TextStyle(fontSize: 13, color: AppColors.g800))),
                    ]))),
                const SizedBox(height: 16),
                const Text('Patient Contact', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.g800)),
                const SizedBox(height: 10),
                Container(width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.navyL, borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.navy.withOpacity(0.2))),
                  child: Row(children: [
                    const Icon(Icons.phone_outlined, size: 18, color: AppColors.navy),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Phone Number', style: TextStyle(fontSize: 11, color: AppColors.g600)),
                      const SizedBox(height: 2),
                      Text(a['contact'] ?? '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navy)),
                    ]),
                  ])),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: () async {
                    final tomorrow = DateTime.now().add(const Duration(days: 1));
                    final dateStr = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2,'0')}-${tomorrow.day.toString().padLeft(2,'0')}';
                    try {
                      await ApiService.createAppointment({
                        'title':          'Checkup — ${a['patientName']}',
                        'patientName':    a['patientName'] ?? '',
                        'patientContact': a['contact'] ?? '',
                        'patientStatus':  a['patientStatus'] ?? '',
                        'type':           a['patientStatus'] == 'Prenatal' ? 'prenatal' : 'neonatal',
                        'time':           '09:00 AM',
                        'notes':          'Scheduled from alert: ${a['reason']}',
                        'date':           dateStr,
                      });
                      widget.onNavigate?.call(6);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Row(children: [
                            Icon(Icons.calendar_today, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text('Checkup scheduled and added to Calendar.'),
                          ]),
                          backgroundColor: Color(0xFF1A3A5C),
                        ));
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Failed to schedule checkup.'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  },
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Schedule Checkup', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                )),
              ])),
        ])),
    );
  }

  Widget _historyCard(Map<String, dynamic> a) {
    final isCritical = a['severity'] == 'critical';
    final riskColor  = isCritical ? AppColors.red : AppColors.orange;
    final attended   = a['attended'] == true;

    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: attended ? AppColors.g100 : Colors.white,
          borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.g200)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 4, right: 10),
            child: Container(width: 9, height: 9,
                decoration: BoxDecoration(color: attended ? AppColors.green : riskColor, shape: BoxShape.circle))),
        CircleAvatar(radius: 16, backgroundColor: AppColors.navyL,
            child: Text((a['patientName'] ?? '?')[0],
                style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(a['patientName'] ?? '—', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                color: attended ? AppColors.g400 : AppColors.g800)),
            const SizedBox(width: 8),
            _badge(a['patientStatus'] ?? '', AppColors.navy, AppColors.navyL),
          ]),
          const SizedBox(height: 3),
          Text(a['reason'] ?? '', style: TextStyle(fontSize: 11, color: attended ? AppColors.g400 : riskColor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Row(children: [
            const Icon(Icons.access_time, size: 11, color: AppColors.g400), const SizedBox(width: 4),
            Text(_timeAgo(a['createdAt'] ?? ''), style: const TextStyle(fontSize: 10, color: AppColors.g400)),
          ]),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: attended ? AppColors.greenL : AppColors.redL, borderRadius: BorderRadius.circular(8)),
          child: Text(attended ? 'Attended To' : 'Pending',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: attended ? AppColors.green : AppColors.red))),
      ]));
  }

  Widget _badge(String label, Color color, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)));

  Widget _emptyState(String title, String sub, IconData icon) => Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.g200)),
    child: Center(child: Column(children: [
      Icon(icon, color: AppColors.green, size: 48), const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.g800)),
      const SizedBox(height: 4),
      Text(sub, style: const TextStyle(fontSize: 13, color: AppColors.g400)),
    ])));

  String _timeAgo(String iso) {
    try {
      final diff = DateTime.now().difference(DateTime.parse(iso));
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) { return '—'; }
  }
}
