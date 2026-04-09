import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import 'notifications_screen.dart';
import '../models/neonatal_data.dart';

// ── Color Constants ────────────────────────────────────────────────────────────
const _kTeal1 = Color(0xFF00695C);
const _kTeal2 = Color(0xFF00ACC1);
const _kAccent = Color(0xFF00897B);
const _kBg = Color(0xFFE8F5F3);

class NeonatalHomeScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  const NeonatalHomeScreen({super.key, this.onOpenDrawer});

  @override
  State<NeonatalHomeScreen> createState() => _NeonatalHomeScreenState();
}

class _NeonatalHomeScreenState extends State<NeonatalHomeScreen> {
  NeonatalData? _data;
  String _firstName = 'Mama';
  bool _loading = true;
  bool _tipDismissed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService().getCurrentUser();
    if (!mounted) return;
    if (user == null) { setState(() => _loading = false); return; }

    final firstName = user.fullName.split(' ').first;
    final babyDob = user.babyDob.isNotEmpty
        ? DateTime.tryParse(user.babyDob) ?? DateTime.now()
        : DateTime.now();
    final babyName = user.babyName.isNotEmpty ? user.babyName : 'Baby';

    setState(() {
      _firstName = firstName;
      _data = NeonatalData(babyDob: babyDob, babyName: babyName);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: CircularProgressIndicator(color: _kAccent)),
      );
    }
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _NeoHeader(firstName: _firstName, onOpenDrawer: widget.onOpenDrawer),
          Expanded(
            child: _data == null
                ? _NoDataView(onSetup: _load)
                : _Body(
                    data: _data!,
                    tipDismissed: _tipDismissed,
                    onDismissTip: () => setState(() => _tipDismissed = true),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _NeoHeader extends StatelessWidget {
  final String firstName;
  final VoidCallback? onOpenDrawer;
  const _NeoHeader({required this.firstName, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kTeal1, _kTeal2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => onOpenDrawer?.call(),
                child: const Icon(Icons.menu, color: Colors.white, size: 24),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NeonatalNotificationsScreen())),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── No Data View ───────────────────────────────────────────────────────────────

class _NoDataView extends StatelessWidget {
  final VoidCallback onSetup;
  const _NoDataView({required this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.child_care, size: 80, color: _kAccent),
            const SizedBox(height: 20),
            const Text('Welcome to Neonatal Care',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _kTeal1)),
            const SizedBox(height: 10),
            const Text('Your baby\'s profile is being loaded. Please wait or re-login.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF757575))),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final NeonatalData data;
  final bool tipDismissed;
  final VoidCallback onDismissTip;

  const _Body({
    required this.data,
    required this.tipDismissed,
    required this.onDismissTip,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Greeting continuation on teal background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kTeal2, _kTeal1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(NeonatalData.greeting,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Row(children: [
                  Text(data.babyName.isNotEmpty ? 'Hi, Mama 👋' : 'Hi, Mama 👋',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _AgeCard(data: data),
                const SizedBox(height: 20),
                _BabyTodayCard(data: data),
                const SizedBox(height: 16),
                _NextVaccineCard(data: data),
                const SizedBox(height: 16),
                _QuickStatsRow(data: data),
                const SizedBox(height: 16),
                if (!tipDismissed) _TipCard(data: data, onDismiss: onDismissTip),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Age Card ───────────────────────────────────────────────────────────────────

class _AgeCard extends StatelessWidget {
  final NeonatalData data;
  const _AgeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: _kAccent.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: Color(0xFF212121), fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: data.babyName.isNotEmpty ? data.babyName : 'Baby'),
                      const TextSpan(text: ' is'),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.ageInDays} Days Old',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF004D40)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(data.stageLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: data.stageProgress,
                    backgroundColor: const Color(0xFFB2DFDB),
                    valueColor: const AlwaysStoppedAnimation<Color>(_kAccent),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Week ${data.ageInWeeks + 1} of Newborn Stage',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60, height: 64,
            decoration: BoxDecoration(
              color: _kAccent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Day', style: TextStyle(color: Colors.white, fontSize: 11)),
                Text('${data.ageInDays}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Baby Today Card ────────────────────────────────────────────────────────────

class _BabyTodayCard extends StatelessWidget {
  final NeonatalData data;
  const _BabyTodayCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text('YOUR BABY TODAY',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: Color(0xFF9E9E9E), letterSpacing: 0.8)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              // Stats row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: Row(
                  children: [
                    Expanded(child: _StatBox(label: 'Approx weight', value: data.displayWeight)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(
                        label: 'Approx length',
                        value: '${data.expectedLengthCm.toStringAsFixed(1)} cm',
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showMilestoneSheet(context, data),
                      child: Container(
                        width: 76, height: 66,
                        decoration: BoxDecoration(
                          color: _kAccent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: _kAccent.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('See more', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                            SizedBox(height: 5),
                            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _showMilestoneSheet(BuildContext context, NeonatalData data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _MilestoneSheet(data: data),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB2EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _kTeal1)),
        ],
      ),
    );
  }
}

// ── Milestone Bottom Sheet ─────────────────────────────────────────────────────

class _MilestoneSheet extends StatelessWidget {
  final NeonatalData data;
  const _MilestoneSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('👁️', 'Vision',        'Focuses 20–30 cm. Prefers faces and high-contrast patterns.'),
      ('👂', 'Hearing',       'Startles to loud sounds. Calmed by familiar voices.'),
      ('🤲', 'Motor',         'Strong grasp and root reflex. Turns head side to side.'),
      ('💬', 'Communication', 'Cries to express all needs. May begin to coo.'),
      ('🍼', 'Feeding',       data.feedingRecommendation),
      ('😴', 'Sleep',         data.sleepRecommendation),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          Text('${data.babyName} · Day ${data.ageInDays} Development',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
          const SizedBox(height: 4),
          Text(data.milestone,
              style: const TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: items
                .map((t) => _DevTile(emoji: t.$1, label: t.$2, desc: t.$3))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DevTile extends StatelessWidget {
  final String emoji, label, desc;
  const _DevTile({required this.emoji, required this.label, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB2EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _kTeal1)),
          const SizedBox(height: 2),
          Flexible(
            child: Text(desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Color(0xFF757575), height: 1.3)),
          ),
        ],
      ),
    );
  }
}

// ── Next Vaccine Card ──────────────────────────────────────────────────────────

class _NextVaccineCard extends StatelessWidget {
  final NeonatalData data;
  const _NextVaccineCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF388E3C).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.vaccines, color: Color(0xFF388E3C), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Next Vaccine Due',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 2),
                Text(data.nextVaccineSummary,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Stats Row ────────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final NeonatalData data;
  const _QuickStatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickStat(icon: '🍼', label: 'Feeding', value: data.feedingRecommendation.split('.').first),
        const SizedBox(width: 10),
        _QuickStat(icon: '😴', label: 'Sleep', value: data.sleepRecommendation.split('.').first),
        const SizedBox(width: 10),
        _QuickStat(icon: '📅', label: 'Next Check', value: data.nextCheckDate),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String icon, label, value;
  const _QuickStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
          ],
        ),
      ),
    );
  }
}

// ── Tip Card ───────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final NeonatalData data;
  final VoidCallback onDismiss;
  const _TipCard({required this.data, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.tipEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tip of the Day',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                const SizedBox(height: 3),
                Text(data.tipOfTheDay,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037), height: 1.45)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, size: 18, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}
