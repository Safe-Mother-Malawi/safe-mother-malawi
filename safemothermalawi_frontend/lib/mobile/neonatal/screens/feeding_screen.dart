import 'package:flutter/material.dart';
import '../models/neonatal_data.dart';

const _kAccent = Color(0xFF00897B);
const _kTeal1  = Color(0xFF00695C);
const _kBg     = Color(0xFFE8F5F3);

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  final List<FeedEntry> _logs = [
    FeedEntry(type: FeedType.breast,  durationMin: 12, time: DateTime.now().subtract(const Duration(hours: 2, minutes: 10))),
    FeedEntry(type: FeedType.formula, volumeMl: 80,    time: DateTime.now().subtract(const Duration(hours: 4, minutes: 30))),
    FeedEntry(type: FeedType.breast,  durationMin: 10, time: DateTime.now().subtract(const Duration(hours: 6, minutes: 45))),
  ];

  FeedType _selectedType = FeedType.breast;
  final _volumeCtrl   = TextEditingController();
  final _durationCtrl = TextEditingController();

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

  void _logFeed() {
    final entry = FeedEntry(
      type: _selectedType,
      volumeMl: int.tryParse(_volumeCtrl.text),
      durationMin: int.tryParse(_durationCtrl.text),
      time: DateTime.now(),
    );
    setState(() => _logs.insert(0, entry));
    _volumeCtrl.clear();
    _durationCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feed logged ✓'), backgroundColor: _kAccent, duration: Duration(seconds: 2)),
    );
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
                    const Text('Feeding Tracker',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
            child: SingleChildScrollView(
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
          color: Colors.white.withValues(alpha: 0.2),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
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
                      color: active ? _kAccent : const Color(0xFFE0F2F1),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFB2DFDB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kAccent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFE0F7FA),
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
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(8)),
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
