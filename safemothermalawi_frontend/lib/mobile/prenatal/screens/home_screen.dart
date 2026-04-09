import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../models/pregnancy_data.dart';
import '../widgets/baby_illustration.dart';
import '../widgets/app_drawer.dart';
import 'pregnancy_detail_screen.dart';
import 'notifications_screen.dart';

class PrenatalHomeScreen extends StatefulWidget {
  const PrenatalHomeScreen({super.key});

  @override
  State<PrenatalHomeScreen> createState() => _PrenatalHomeScreenState();
}

class _PrenatalHomeScreenState extends State<PrenatalHomeScreen> {
  PregnancyData? _data;
  String _firstName = 'Mama';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) return;
    final firstName = user.fullName.split(' ').first;
    PregnancyData? data;
    if (user.lmpDate.isNotEmpty) {
      data = PregnancyData(lmp: DateTime.parse(user.lmpDate));
    } else if (user.totalPregnancyWeeks > 0) {
      data = PregnancyData.fromTotalWeeks(user.totalPregnancyWeeks);
    }
    setState(() {
      _firstName = firstName;
      _data = data;
      _loading = false;
    });
  }

  Future<void> _editDueDate() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('logged_in_email') ?? '';
    final key = 'user_$email';

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _data?.lmp ?? DateTime.now().subtract(const Duration(days: 70)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now(),
      helpText: 'Select Last Menstrual Period (LMP)',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFE91E8C)),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      await prefs.setString('${key}_lmpDate', picked.toIso8601String());
      setState(() => _data = PregnancyData(lmp: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFCE4EC),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _Header(firstName: _firstName),
          Expanded(
            child: _data == null
                ? _NoDataView(onSetup: _editDueDate)
                : _Body(data: _data!, firstName: _firstName, onEditDueDate: _editDueDate),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String firstName;
  const _Header({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF80AB), Color(0xFFFF4081)],
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
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu, color: Colors.white, size: 24),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                child: Container(
                  width: 38,
                  height: 38,
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

// ─── No Data View ─────────────────────────────────────────────────────────────

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
            const Icon(Icons.pregnant_woman, size: 80, color: Color(0xFFFF80AB)),
            const SizedBox(height: 20),
            const Text('Set up your pregnancy tracker',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
            const SizedBox(height: 10),
            const Text('Enter your Last Menstrual Period (LMP) to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF757575))),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Set LMP Date', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Main Body ────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final PregnancyData data;
  final String firstName;
  final VoidCallback onEditDueDate;
  const _Body({required this.data, required this.firstName, required this.onEditDueDate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Pink header continuation with greeting
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(PregnancyData.greeting,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      firstName,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Text('👋', style: TextStyle(fontSize: 24)),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _ProgressCard(data: data),
                const SizedBox(height: 20),
                _BabyThisWeekCard(data: data),
                const SizedBox(height: 16),
                _DueDateCard(data: data, onEdit: onEditDueDate),
                const SizedBox(height: 20),
                _ThisWeekForYou(data: data),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Card ────────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final PregnancyData data;
  const _ProgressCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFFFF80AB).withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.currentWeek} weeks, ${data.dayOfWeek} days Pregnant',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                ),
                const SizedBox(height: 4),
                Text(data.trimester,
                    style: const TextStyle(fontSize: 13, color: Color(0xFFE91E8C), fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: data.progress,
                    backgroundColor: const Color(0xFFFCE4EC),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E8C)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E8C),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Day', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w400)),
                Text(
                  '${data.daysPregnant}',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Baby This Week Card ──────────────────────────────────────────────────────

class _BabyThisWeekCard extends StatelessWidget {
  final PregnancyData data;
  const _BabyThisWeekCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'YOUR BABY THIS WEEK · DAY ${data.daysPregnant}',
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9E9E9E),
                letterSpacing: 0.8),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF80AB).withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Full-bleed image area ──
              Stack(
                children: [
                  // Solid warm background so painted fallback blends too
                  Container(
                    height: 230,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFE4EE), Color(0xFFFCE4EC)],
                      ),
                    ),
                    child: Image.asset(
                      data.babyImageAsset,
                      width: double.infinity,
                      height: 230,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: BabyFallbackPainter(week: data.currentWeek, size: 190),
                      ),
                    ),
                  ),
                  // Bottom fade so stats row sits flush
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.white],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Stats row — sits directly below the image ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Row(
                  children: [
                    Expanded(child: _StatBox(label: 'Approx size', value: '${data.lengthCm} cm')),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(
                        label: 'Approx weight',
                        value: data.weightGrams >= 1000
                            ? '${(data.weightGrams / 1000).toStringAsFixed(1)} kg'
                            : '${data.weightGrams} g',
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PregnancyDetailScreen(data: data)),
                      ),
                      child: Container(
                        width: 76,
                        height: 66,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E8C),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE91E8C).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('See more',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
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
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFE91E8C))),
        ],
      ),
    );
  }
}
// ─── Due Date Card ────────────────────────────────────────────────────────────

class _DueDateCard extends StatelessWidget {
  final PregnancyData data;
  final VoidCallback onEdit;
  const _DueDateCard({required this.data, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E8C).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_month, color: Color(0xFFE91E8C), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Due date', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 2),
                Text(data.formattedEdd,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E8C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── This Week For You ────────────────────────────────────────────────────────

class _ThisWeekForYou extends StatelessWidget {
  final PregnancyData data;
  const _ThisWeekForYou({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 14),
          child: Text(
            'THIS WEEK FOR YOU',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF757575),
              letterSpacing: 1.0,
            ),
          ),
        ),
        _WeeklyTipCard(
          emoji: data.nutritionEmoji,
          emojiBackground: const Color(0xFFFFF0F0),
          title: 'Nutrition tips',
          subtitle: data.nutritionTip,
          onTap: () => Navigator.pushNamed(context, '/nutrition')
              .catchError((_) => null),
        ),
        const SizedBox(height: 12),
        _WeeklyTipCard(
          emoji: data.exerciseEmoji,
          emojiBackground: const Color(0xFFEFF8F0),
          title: 'Gentle exercises',
          subtitle: data.exerciseTip,
          onTap: () {},
        ),
      ],
    );
  }
}

class _WeeklyTipCard extends StatelessWidget {
  final String emoji;
  final Color emojiBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _WeeklyTipCard({
    required this.emoji,
    required this.emojiBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF80AB).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: emojiBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                          height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward,
                  color: Color(0xFFE91E8C), size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
