import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class SystemLogs extends StatefulWidget {
  const SystemLogs({super.key});

  @override
  State<SystemLogs> createState() => _SystemLogsState();
}

class _SystemLogsState extends State<SystemLogs> {
  final _searchCtrl = TextEditingController();
  String _eventFilter = 'All';
  String _roleFilter  = 'All';
  int _page = 0;
  static const int _perPage = 10;

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.instance.get('/activity-logs') as List<dynamic>;
      setState(() {
        _logs = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _logs.where((l) {
      final action = (l['action'] ?? '').toString();
      final desc   = (l['description'] ?? '').toString().toLowerCase();
      final role   = (l['actor']?['role'] ?? '').toString();
      final q      = _searchCtrl.text.toLowerCase();

      final matchSearch = q.isEmpty || desc.contains(q) || action.toLowerCase().contains(q);
      final matchEvent  = _eventFilter == 'All' || action == _eventFilter;
      final matchRole   = _roleFilter == 'All' || role == _roleFilter.toLowerCase();
      return matchSearch && matchEvent && matchRole;
    }).toList();
  }

  String _timeStr(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
    } catch (_) { return iso; }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        Text('Failed to load logs'),
        TextButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Retry')),
      ]));
    }

    final filtered   = _filtered;
    final totalPages = (filtered.length / _perPage).ceil().clamp(1, 9999);
    final pageData   = filtered.skip(_page * _perPage).take(_perPage).toList();

    // Collect unique actions for filter
    final actions = {'All', ..._logs.map((l) => l['action']?.toString() ?? '')}.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Logs', style: TextStyle(fontFamily: 'Public Sans', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 6),
          Text('Full audit trail of all system events', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
            ),
            child: Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() => _page = 0),
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    hintStyle: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.mutedText),
                    filled: true, fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              _LogDrop(label: 'Event', value: _eventFilter, items: actions,
                  onChanged: (v) => setState(() { _eventFilter = v!; _page = 0; })),
              _LogDrop(label: 'Role', value: _roleFilter,
                  items: const ['All', 'admin', 'dho', 'clinician', 'prenatal', 'neonatal'],
                  onChanged: (v) => setState(() { _roleFilter = v!; _page = 0; })),
            ]),
          ),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(children: [
                Container(
                  color: AppColors.pageBg,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(children: [
                    _hdr('#', 1), _hdr('Timestamp', 3), _hdr('Action', 2),
                    _hdr('Description', 5), _hdr('Actor', 3),
                  ]),
                ),
                ...pageData.asMap().entries.map((e) {
                  final log = e.value;
                  final idx = _page * _perPage + e.key + 1;
                  final action = log['action']?.toString() ?? '';
                  final desc   = log['description']?.toString() ?? '';
                  final actor  = log['actor'] as Map<String, dynamic>?;
                  final actorName = actor?['fullName']?.toString() ?? actor?['email']?.toString() ?? 'System';
                  final ts     = _timeStr(log['createdAt']?.toString());

                  return Container(
                    color: e.key.isEven ? AppColors.surfaceContainerLowest : AppColors.pageBg.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(children: [
                      Expanded(flex: 1, child: Text('$idx', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.mutedText))),
                      Expanded(flex: 3, child: Text(ts, style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.bodyText))),
                      Expanded(flex: 2, child: Text(action, style: TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
                      Expanded(flex: 5, child: Text(desc, style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.bodyText))),
                      Expanded(flex: 3, child: Text(actorName, style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.mutedText))),
                    ]),
                  );
                }),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text('${filtered.length} records', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.mutedText)),
            const SizedBox(width: 16),
            IconButton(
              onPressed: _page > 0 ? () => setState(() => _page--) : null,
              icon: const Icon(Icons.chevron_left_rounded), color: AppColors.primary,
            ),
            Text('${_page + 1} / $totalPages', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface)),
            IconButton(
              onPressed: _page < totalPages - 1 ? () => setState(() => _page++) : null,
              icon: const Icon(Icons.chevron_right_rounded), color: AppColors.primary,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _hdr(String label, int flex) => Expanded(
    flex: flex,
    child: Text(label, style: TextStyle(fontFamily: 'Roboto', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText, letterSpacing: 0.5)),
  );
}

class _LogDrop extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _LogDrop({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$label: ', style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.mutedText)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(value) ? value : items.first,
            onChanged: onChanged,
            style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.onSurface),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          ),
        ),
      ),
    ]);
  }
}

