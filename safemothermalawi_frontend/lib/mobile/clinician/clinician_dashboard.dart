import 'package:flutter/material.dart';
import '../auth/services/auth_service.dart';
import '../auth/screens/login_screen.dart';
import 'models/risk_record.dart';
import 'services/risk_service.dart';

class ClinicianDashboard extends StatefulWidget {
  const ClinicianDashboard({super.key});
  @override
  State<ClinicianDashboard> createState() => _ClinicianDashboardState();
}

class _ClinicianDashboardState extends State<ClinicianDashboard> {
  List<RiskRecord> _records = [];
  bool _loading = true;
  String _filter = 'All'; // 'All' | 'High' | 'Moderate' | 'Low'
  String _roleFilter = 'All'; // 'All' | 'prenatal' | 'neonatal'

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await RiskService().loadAll();
    setState(() { _records = records; _loading = false; });
  }

  List<RiskRecord> get _filtered => _records.where((r) {
    final riskOk = _filter == 'All' || r.riskLevel.contains(_filter);
    final roleOk = _roleFilter == 'All' || r.role == _roleFilter;
    return riskOk && roleOk;
  }).toList();

  int _count(String level) =>
      _records.where((r) => r.riskLevel.contains(level)).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: Column(
        children: [
          _Header(onRefresh: _load),
          // Summary chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _SummaryChip(label: 'Total',    value: '${_records.length}', color: const Color(0xFF1A237E)),
              const SizedBox(width: 8),
              _SummaryChip(label: 'High',     value: '${_count('High')}',     color: const Color(0xFFC62828)),
              const SizedBox(width: 8),
              _SummaryChip(label: 'Moderate', value: '${_count('Moderate')}', color: const Color(0xFFE65100)),
              const SizedBox(width: 8),
              _SummaryChip(label: 'Low',      value: '${_count('Low')}',      color: const Color(0xFF2E7D32)),
            ]),
          ),
          // Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(children: [
              _FilterChip(label: 'All',      selected: _filter == 'All',      onTap: () => setState(() => _filter = 'All')),
              const SizedBox(width: 6),
              _FilterChip(label: 'High',     selected: _filter == 'High',     onTap: () => setState(() => _filter = 'High'),     color: const Color(0xFFC62828)),
              const SizedBox(width: 6),
              _FilterChip(label: 'Moderate', selected: _filter == 'Moderate', onTap: () => setState(() => _filter = 'Moderate'), color: const Color(0xFFE65100)),
              const SizedBox(width: 6),
              _FilterChip(label: 'Low',      selected: _filter == 'Low',      onTap: () => setState(() => _filter = 'Low'),      color: const Color(0xFF2E7D32)),
              const Spacer(),
              _FilterChip(label: 'Prenatal', selected: _roleFilter == 'prenatal', onTap: () => setState(() => _roleFilter = _roleFilter == 'prenatal' ? 'All' : 'prenatal'), color: const Color(0xFFE91E8C)),
              const SizedBox(width: 6),
              _FilterChip(label: 'Neonatal', selected: _roleFilter == 'neonatal', onTap: () => setState(() => _roleFilter = _roleFilter == 'neonatal' ? 'All' : 'neonatal'), color: const Color(0xFF00695C)),
            ]),
          ),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
                : _filtered.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _RecordCard(
                            record: _filtered[i],
                            onDelete: () async {
                              final idx = _records.indexOf(_filtered[i]);
                              await RiskService().deleteAt(idx);
                              _load();
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;
  const _Header({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Clinician Dashboard',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text('Patient Risk Assessments',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: onRefresh,
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await AuthService().logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary Chip ──────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    ),
  );
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color = const Color(0xFF1A237E)});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? color : const Color(0xFFE0E0E0)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF757575))),
    ),
  );
}

// ── Record Card ───────────────────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final RiskRecord record;
  final VoidCallback onDelete;
  const _RecordCard({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final r = record;
    return Dismissible(
      key: ValueKey('${r.patientId}${r.submittedAt}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFFFFEBEE),
        child: const Icon(Icons.delete_outline, color: Color(0xFFC62828)),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: r.color.withValues(alpha: 0.25)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.patientName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
                      const SizedBox(height: 2),
                      Text(r.patientPhone,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                    ],
                  ),
                ),
                // Risk badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: r.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: r.color.withValues(alpha: 0.4)),
                  ),
                  child: Text(r.riskLevel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: r.color)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Role + score
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: r.role == 'prenatal' ? const Color(0xFFFCE4EC) : const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  r.role == 'prenatal' ? '🤰 Prenatal' : '👶 Neonatal',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: r.role == 'prenatal' ? const Color(0xFFE91E8C) : const Color(0xFF00695C)),
                ),
              ),
              const SizedBox(width: 8),
              Text('Score: ${r.score}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
              const Spacer(),
              Text(r.formattedDate,
                  style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
            ]),
            const SizedBox(height: 8),
            Text(r.message,
                style: const TextStyle(fontSize: 12, color: Color(0xFF424242), height: 1.4)),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.assignment_outlined, size: 64, color: Color(0xFFBDBDBD)),
        SizedBox(height: 16),
        Text('No risk records yet', style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E))),
        SizedBox(height: 6),
        Text('Records appear here when patients complete health checks.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFFBDBDBD))),
      ],
    ),
  );
}
