import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import 'notifications_screen.dart';
import 'daily_feed_detail_screen.dart';
import '../models/neonatal_data.dart';

// ── Blue palette ──────────────────────────────────────────────────────────────
const _kBg        = Color(0xFFF5F7FF);
const _kCard      = Color(0xFFFFFFFF);
const _kBrown     = Color(0xFF000000);      // primary text → black
const _kBrownMid  = Color(0xFF212121);      // secondary text → near black
const _kBrownSoft = Color(0xFF616161);      // muted text → dark grey
const _kOrange    = Color(0xFF1A237E);      // accent → primary blue
const _kGreeting  = Color(0xFFE8EAF6);     // greeting card bg → light blue
const _kStage1    = Color(0xFF9FA8DA);      // done stage → mid blue
const _kStage2    = Color(0xFF1A237E);      // active stage → primary blue
const _kStage3    = Color(0xFFE8EAF6);     // future stage → light blue
const _kFeedBg    = Color(0xFFE8EAF6);     // feed icon bg → light blue
const _kFeedAccent = Color(0xFF3949AB);    // feed accent → mid blue
const _kApptBar   = Color(0xFF1A237E);     // appointment bar → primary blue

// ── Screen ────────────────────────────────────────────────────────────────────

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
        body: Center(child: CircularProgressIndicator(color: _kOrange)),
      );
    }
    return Scaffold(
      backgroundColor: _kBg,
      body: _data == null
          ? _NoDataView(onSetup: _load)
          : _HomeBody(
              data: _data!,
              firstName: _firstName,
              tipDismissed: _tipDismissed,
              onDismissTip: () => setState(() => _tipDismissed = true),
              onOpenDrawer: widget.onOpenDrawer,
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
            const Icon(Icons.child_care, size: 80, color: _kOrange),
            const SizedBox(height: 20),
            const Text('Welcome to Neonatal Care',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _kBrown)),
            const SizedBox(height: 10),
            const Text("Your baby's profile is being loaded. Please wait or re-login.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _kBrownMid)),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange,
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

// ── Home Body ─────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final NeonatalData data;
  final String firstName;
  final bool tipDismissed;
  final VoidCallback onDismissTip;
  final VoidCallback? onOpenDrawer;

  const _HomeBody({
    required this.data,
    required this.firstName,
    required this.tipDismissed,
    required this.onDismissTip,
    this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Top bar (safe area) ──────────────────────────────────────────────
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => onOpenDrawer?.call(),
                  child: const Icon(Icons.menu, color: _kBrown, size: 24),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NeonatalNotificationsScreen())),
                  child: Stack(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: _kCard,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: const Icon(Icons.notifications_outlined, color: _kBrown, size: 20),
                      ),
                      Positioned(
                        top: 6, right: 6,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Scrollable content ───────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              children: [
                _WelcomeCard(firstName: firstName, data: data),
                const SizedBox(height: 14),
                _BabyInfoCard(data: data),
                const SizedBox(height: 14),
                _DailyFeedsCard(data: data),
                const SizedBox(height: 14),
                _TodayAppointmentCard(data: data),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Welcome Card ──────────────────────────────────────────────────────────────

class _WelcomeCard extends StatelessWidget {
  final String firstName;
  final NeonatalData data;
  const _WelcomeCard({required this.firstName, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: _kGreeting,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC5CAE9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WELCOME BACK',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kBrownSoft,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${NeonatalData.greeting},',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _kBrown),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                'Mama $firstName',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _kOrange),
              ),
              const SizedBox(width: 6),
              const Text('👋', style: TextStyle(fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Baby Info Card ────────────────────────────────────────────────────────────

class _BabyInfoCard extends StatelessWidget {
  final NeonatalData data;
  const _BabyInfoCard({required this.data});

  // Neonatal stage definitions
  static const _stageNames  = ['Early neonatal', 'Late neonatal', 'Post-neonatal'];
  static const _stageDays   = [7, 28, 60]; // end day of each stage
  static const _stageLabels = ['Day 0–7', 'Day 8–28', 'Day 29+'];

  int get _currentStageIndex {
    final d = data.ageInDays;
    if (d <= 7)  return 0;
    if (d <= 28) return 1;
    return 2;
  }

  String get _stageRangeLabel {
    final idx = _currentStageIndex;
    if (idx == 0) return 'Early neonatal (day 0–7)';
    if (idx == 1) return 'Late neonatal (day 8–28)';
    return 'Post-neonatal (day 29+)';
  }

  String get _stageDayProgress {
    final idx   = _currentStageIndex;
    // Stage boundaries (inclusive)
    // Early:  day 0–7  (8 days)
    // Late:   day 8–28 (21 days)
    // Post:   day 29–60 (32 days)
    final start = idx == 0 ? 0 : (idx == 1 ? 8 : 29);
    final end   = idx == 0 ? 7 : (idx == 1 ? 28 : 60);
    final total      = end - start + 1;           // inclusive count
    final dayInStage = (data.ageInDays - start + 1).clamp(1, total);
    return 'Day $dayInStage of $total';
  }

  @override
  Widget build(BuildContext context) {
    final stageIdx = _currentStageIndex;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baby name row
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('🍼', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.babyName.isNotEmpty ? data.babyName : 'Baby',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _kBrown)),
                    Text('Day ${data.ageInDays} · ${_stageNames[stageIdx]}',
                        style: const TextStyle(fontSize: 12, color: _kBrownSoft)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Age + badge row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${data.ageInDays}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: _kOrange, height: 1),
                    ),
                    const TextSpan(
                      text: '  days old',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _kBrownMid),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kOrange.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Text('Day ${_stageDays[stageIdx == 0 ? 0 : stageIdx == 1 ? 1 : 2] - (stageIdx == 0 ? 0 : stageIdx == 1 ? 7 : 27)}–${_stageDays[stageIdx]}',
                        style: const TextStyle(fontSize: 10, color: _kBrownMid)),
                    Text(_stageNames[stageIdx],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kOrange)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Stage label + day progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_stageRangeLabel,
                  style: const TextStyle(fontSize: 12, color: _kBrownMid, fontWeight: FontWeight.w500)),
              Text(_stageDayProgress,
                  style: const TextStyle(fontSize: 12, color: _kBrownSoft)),
            ],
          ),
          const SizedBox(height: 8),

          // Segmented stage progress bar
          Row(
            children: List.generate(3, (i) {
              Color barColor;
              if (i < stageIdx) {
                barColor = _kStage1;
              } else if (i == stageIdx) {
                barColor = _kStage2;
              } else {
                barColor = _kStage3;
              }
              return Expanded(
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Stage labels row
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_stageLabels[i],
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: i == stageIdx ? _kOrange : _kBrownSoft)),
                  Text(
                    i == 0 ? 'Early neonatal ${i < stageIdx ? "✓" : i == stageIdx ? "← now" : ""}' :
                    i == 1 ? 'Late neonatal ${i < stageIdx ? "✓" : i == stageIdx ? "← now" : ""}' :
                             'Post-neonatal${i == stageIdx ? " ← now" : ""}',
                    style: TextStyle(
                        fontSize: 9,
                        color: i == stageIdx ? _kOrange : _kBrownSoft),
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}

// ── Daily Feeds Card ──────────────────────────────────────────────────────────

class _DailyFeedsCard extends StatefulWidget {
  final NeonatalData data;
  const _DailyFeedsCard({required this.data});
  @override
  State<_DailyFeedsCard> createState() => _DailyFeedsCardState();
}

class _DailyFeedsCardState extends State<_DailyFeedsCard> {
  int _feedCount = 0;

  int get _targetFeeds {
    final d = widget.data.ageInDays;
    if (d <= 14) return 10;
    if (d <= 28) return 8;
    if (d <= 56) return 7;
    return 6;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: _kOrange, size: 18),
              const SizedBox(width: 8),
              const Text('Daily feed',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kBrown)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => DailyFeedDetailScreen(data: widget.data))),
                child: const Text('See more »',
                    style: TextStyle(fontSize: 12, color: _kOrange, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Feed content row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: _kFeedBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Text('😴', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('SLEEP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _kFeedAccent, letterSpacing: 0.8)),
                        const Text(' · ', style: TextStyle(fontSize: 10, color: _kBrownSoft)),
                        Text(
                          widget.data.ageInDays <= 7 ? 'EARLY NEONATAL' :
                          widget.data.ageInDays <= 28 ? 'LATE NEONATAL' : 'POST-NEONATAL',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _kBrownSoft, letterSpacing: 0.6),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Safe sleep: the ABCs every parent must know',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kBrown, height: 1.3)),
                    const SizedBox(height: 4),
                    Text(widget.data.sleepRecommendation,
                        style: const TextStyle(fontSize: 12, color: _kBrownMid, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => DailyFeedDetailScreen(data: widget.data))),
                child: const Icon(Icons.chevron_right, color: _kBrownSoft, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEE8E3), height: 1),
        ],
      ),
    );
  }
}

// ── Today's Appointment Card ──────────────────────────────────────────────────

class _TodayAppointmentCard extends StatelessWidget {
  final NeonatalData data;
  const _TodayAppointmentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final checkDate = data.babyDob.add(Duration(days: data.nextCheckDay));
    final isToday = checkDate.year == today.year &&
        checkDate.month == today.month &&
        checkDate.day == today.day;

    // Format time: e.g. "9:30 AM"
    final rawHour = today.hour;
    final timeHour = rawHour == 0 ? 12 : (rawHour > 12 ? rawHour - 12 : rawHour);
    final timePeriod = rawHour >= 12 ? 'PM' : 'AM';
    final timeStr = '$timeHour:${today.minute.toString().padLeft(2, '0')}';

    // Format date: e.g. "12 April"
    const _months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    final apptDate = isToday ? today : checkDate;
    final dateStr = '${apptDate.day} ${_months[apptDate.month - 1]}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: _kOrange, size: 18),
              const SizedBox(width: 8),
              const Text("Today's appointment",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kBrown)),
            ],
          ),
          const SizedBox(height: 14),

          // Appointment bar — dark brown like reference
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _kApptBar,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Time + date block
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('$timeStr $timePeriod',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(dateStr,
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
                  ],
                ),
                const SizedBox(width: 16),
                // Divider
                Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.15)),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CLINIC VISIT',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 0.8)),
                      const SizedBox(height: 3),
                      Text(
                        isToday ? 'Well-Baby Clinic Visit' : 'Day ${data.nextCheckDay} Check-up',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),

          // Vaccine row
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}



