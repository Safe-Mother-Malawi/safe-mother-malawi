import 'package:flutter/material.dart';
import '../models/neonatal_data.dart';

const _kAccent = Color(0xFF00897B);
const _kBg     = Color(0xFFE8F5F3);

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final List<SleepEntry> _logs = [
    SleepEntry(
      start: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      end: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      type: SleepType.dayNap,
    ),
    SleepEntry(
      start: DateTime.now().subtract(const Duration(hours: 6)),
      end: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
      type: SleepType.nightSleep,
    ),
  ];

  SleepType _selectedType = SleepType.dayNap;
  TimeOfDay _start = TimeOfDay.now();
  TimeOfDay _end = TimeOfDay.now();

  int get _totalMinutesToday {
    return _logs.fold(0, (sum, e) => sum + e.duration.inMinutes.abs());
  }

  String get _totalHoursLabel {
    final h = _totalMinutesToday ~/ 60;
    final m = _totalMinutesToday % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  double get _sleepProgress =>
      (_totalMinutesToday / (16 * 60)).clamp(0.0, 1.0);

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _kAccent),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  void _logSleep() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, _start.hour, _start.minute);
    var end   = DateTime(now.year, now.month, now.day, _end.hour, _end.minute);
    if (end.isBefore(start)) end = end.add(const Duration(days: 1));

    setState(() => _logs.insert(0, SleepEntry(start: start, end: end, type: _selectedType)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sleep session logged ✓'), backgroundColor: _kAccent, duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // Header with ring summary
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sleep Tracker',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Circular progress ring
                        SizedBox(
                          width: 80, height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: _sleepProgress,
                                strokeWidth: 8,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              Text(_totalHoursLabel,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SleepStat(label: 'Total sleep today', value: _totalHoursLabel),
                              const SizedBox(height: 6),
                              _SleepStat(label: 'Sessions logged', value: '${_logs.length}'),
                              const SizedBox(height: 6),
                              _SleepStat(label: 'Goal', value: '14–17 hrs/day'),
                            ],
                          ),
                        ),
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
                  _SleepLogForm(
                    selectedType: _selectedType,
                    onTypeChanged: (t) => setState(() => _selectedType = t),
                    start: _start,
                    end: _end,
                    onPickStart: () => _pickTime(true),
                    onPickEnd: () => _pickTime(false),
                    onLog: _logSleep,
                  ),
                  const SizedBox(height: 20),
                  const Text('SLEEP LOG',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: Color(0xFF9E9E9E), letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  ..._logs.map((e) => _SleepTile(entry: e)),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sleep Stat ─────────────────────────────────────────────────────────────────

class _SleepStat extends StatelessWidget {
  final String label, value;
  const _SleepStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ── Log Form ───────────────────────────────────────────────────────────────────

class _SleepLogForm extends StatelessWidget {
  final SleepType selectedType;
  final ValueChanged<SleepType> onTypeChanged;
  final TimeOfDay start, end;
  final VoidCallback onPickStart, onPickEnd, onLog;

  const _SleepLogForm({
    required this.selectedType,
    required this.onTypeChanged,
    required this.start,
    required this.end,
    required this.onPickStart,
    required this.onPickEnd,
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
          const Text('Log Sleep Session',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          const SizedBox(height: 14),
          // Type toggle
          Row(
            children: SleepType.values.map((t) {
              final active = t == selectedType;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChanged(t),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF3949AB) : const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      t == SleepType.dayNap ? '☀️ Day Nap' : '🌙 Night Sleep',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: active ? Colors.white : const Color(0xFF3949AB)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _TimePicker(label: 'Start time', time: start, onTap: onPickStart)),
              const SizedBox(width: 10),
              Expanded(child: _TimePicker(label: 'End time',   time: end,   onTap: onPickEnd)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3949AB),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('+ Log Sleep', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimePicker({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EAF6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC5CAE9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('$h:$m', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                const Spacer(),
                const Icon(Icons.access_time, size: 18, color: Color(0xFF3949AB)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sleep Tile ─────────────────────────────────────────────────────────────────

class _SleepTile extends StatelessWidget {
  final SleepEntry entry;
  const _SleepTile({required this.entry});

  @override
  Widget build(BuildContext context) {
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
          Text(entry.type == SleepType.dayNap ? '☀️' : '🌙',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.typeLabel,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                Text(entry.timeRange,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(entry.durationLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3949AB))),
          ),
        ],
      ),
    );
  }
}
