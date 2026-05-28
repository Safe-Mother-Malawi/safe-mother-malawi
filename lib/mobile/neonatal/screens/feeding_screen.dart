import 'package:flutter/material.dart';
import '../../../services/offline_api_service.dart';
import '../models/neonatal_data.dart';

const _kAccent = Color(0xFF1A237E);
const _kTeal1  = Color(0xFF1A237E);
const _kBg     = Color(0xFFF5F7FF);

class FeedingScreen extends StatefulWidget {
  final String? patientId;
  const FeedingScreen({super.key, this.patientId});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  List<FeedEntry> _logs = [];
  bool _loading = true;

  FeedType _selectedType = FeedType.breast;
  final _volumeCtrl   = TextEditingController();
  final _durationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    if (widget.patientId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await OfflineApiService().get('/tracking/feeding/${widget.patientId}');
      if (data is List) {
        setState(() {
          _logs = data.map((e) {
            final m = e as Map<String, dynamic>;
            return FeedEntry(
              type: _parseFeedType(m['type']?.toString() ?? 'breast'),
              volumeMl: m['volumeMl'] as int?,
              durationMin: m['durationMin'] as int?,
              time: DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
            );
          }).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  FeedType _parseFeedType(String t) {
    if (t == 'formula') return FeedType.formula;
    if (t == 'mixed') return FeedType.mixed;
    return FeedType.breast;
  }

  @override
  void dispose() {
    _volumeCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  int get _totalFeedsToday {
    final today = DateTime.now();
    return _logs.where((e) =>
      e.time.year == today.year &&
      e.time.month == today.month &&
      e.time.day == today.day
    ).length;
  }

  int get _totalVolToday {
    final today = DateTime.now();
    return _logs
        .where((e) => e.time.day == today.day && e.volumeMl != null)
        .fold(0, (sum, e) => sum + (e.volumeMl ?? 0));
  }

  void _logFeed() async {
    final entry = FeedEntry(
      type: _selectedType,
      volumeMl: int.tryParse(_volumeCtrl.text),
      durationMin: int.tryParse(_durationCtrl.text),
      time: DateTime.now(),
    );

    // Optimistically add to UI
    setState(() => _logs.insert(0, entry));
    _volumeCtrl.clear();
    _durationCtrl.clear();

    // Persist to backend
    if (widget.patientId != null) {
      try {
        await OfflineApiService().post('/tracking/feeding', {
          'patientId': widget.patientId,
          'type': _selectedType == FeedType.breast ? 'breast'
              : _selectedType == FeedType.formula ? 'formula' : 'mixed',
          if (entry.volumeMl != null) 'volumeMl': entry.volumeMl,
          if (entry.durationMin != null) 'durationMin': entry.durationMin,
        });
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feed logged ✓'), backgroundColor: _kAccent, duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // Summary header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_kTeal1, _kAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Text('Feeding Tracker',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white70, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _SummaryChip(label: 'Feeds today', value: '$_totalFeedsToday'),
                        const SizedBox(width: 12),
                        _SummaryChip(label: 'Total volume', value: '$_totalVolToday ml'),
                        const SizedBox(width: 12),
                        _SummaryChip(label: 'Last feed', value: _logs.isEmpty ? '–' : _sinceLabel(_logs.first.time)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _kAccent))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Log form
                        _LogCard(
                          selectedType: _selectedType,
                          onTypeChanged: (t) => setState(() => _selectedType = t),
                          volumeCtrl: _volumeCtrl,
                          durationCtrl: _durationCtrl,
                          onLog: _logFeed,
                        ),
                        const SizedBox(height: 20),
                        const Text('FEED LOG',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                color: Color(0xFF9E9E9E), letterSpacing: 0.8)),
                        const SizedBox(height: 10),
                        ..._logs.map((e) => _FeedTile(entry: e)),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _sinceLabel(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

// ── Summary Chip ───────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label, value;
  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ── Log Form Card ──────────────────────────────────────────────────────────────

class _LogCard extends StatelessWidget {
  final FeedType selectedType;
  final ValueChanged<FeedType> onTypeChanged;
  final TextEditingController volumeCtrl, durationCtrl;
  final VoidCallback onLog;

  const _LogCard({
    required this.selectedType,
    required this.onTypeChanged,
    required this.volumeCtrl,
    required this.durationCtrl,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Log a Feed', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _kTeal1)),
          const SizedBox(height: 14),
          // Feed type toggle
          Row(
            children: FeedType.values.map((t) {
              final active = t == selectedType;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChanged(t),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: active ? _kAccent : const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      t == FeedType.breast ? 'Breast' : t == FeedType.formula ? 'Formula' : 'Mixed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: active ? Colors.white : _kTeal1,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _NeoTextField(
                  controller: volumeCtrl,
                  label: selectedType == FeedType.breast ? 'ml (optional)' : 'Volume (ml)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NeoTextField(
                  controller: durationCtrl,
                  label: 'Duration (min)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLog,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('+ Log Feed', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;

  const _NeoTextField({required this.controller, required this.label, required this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFC5CAE9))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kAccent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFE8EAF6),
      ),
    );
  }
}

// ── Feed Tile ──────────────────────────────────────────────────────────────────

class _FeedTile extends StatelessWidget {
  final FeedEntry entry;
  const _FeedTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final icon = entry.type == FeedType.breast ? '🤱' : entry.type == FeedType.formula ? '🍼' : '🔀';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC5CAE9)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(8)),
            child: Text(entry.typeLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTeal1)),
          ),
          const SizedBox(width: 8),
          if (entry.volumeMl != null)
            Text('${entry.volumeMl} ml',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
          if (entry.durationMin != null)
            Text('  ${entry.durationMin} min',
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
          const Spacer(),
          Text(entry.formattedTime,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }
}

