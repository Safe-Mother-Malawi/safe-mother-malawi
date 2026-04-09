import 'package:flutter/material.dart';
import '../models/neonatal_data.dart';

// ── Color constants (matches home_screen palette) ─────────────────────────────
const _kPrimary  = Color(0xFF1A237E);
const _kMid      = Color(0xFF3949AB);
const _kLightBg  = Color(0xFFE8EAF6);
const _kPageBg   = Color(0xFFF5F7FF);
const _kBlack    = Color(0xFF0D0D0D);
const _kGrey     = Color(0xFF424242);
const _kMuted    = Color(0xFF9E9E9E);

class DailyFeedDetailScreen extends StatelessWidget {
  final NeonatalData data;
  const DailyFeedDetailScreen({super.key, required this.data});

  // ── Age-based feed article ─────────────────────────────────────────────────
  _FeedArticle get _article {
    final d = data.ageInDays;

    if (d <= 7) {
      return const _FeedArticle(
        emoji: '🤱',
        category: 'FEEDING · EARLY NEONATAL',
        title: 'Colostrum: your baby\'s first superfood',
        intro:
            'In the first days of life, your body produces colostrum — a thick, '
            'golden milk packed with antibodies, proteins, and nutrients your '
            'newborn needs most right now.',
        sections: [
          _Section('Why colostrum matters', Icons.star_outline, [
            'Rich in antibodies that protect against infection',
            'Helps establish healthy gut bacteria',
            'Acts as a natural laxative to clear meconium',
            'Provides exactly the right nutrition for a tiny stomach',
          ]),
          _Section('How often to feed', Icons.schedule_outlined, [
            'Feed 8–12 times every 24 hours',
            'Every 2–3 hours — even at night',
            'Watch for hunger cues: rooting, sucking fists, turning head',
            'Do not wait for baby to cry — that is a late hunger sign',
          ]),
          _Section('Latch & positioning tips', Icons.child_care_outlined, [
            'Baby\'s mouth should cover most of the areola, not just the nipple',
            'Tummy to tummy — baby\'s ear, shoulder, and hip in a straight line',
            'Support baby\'s head and neck at all times',
            'You should hear swallowing, not clicking or smacking',
          ]),
          _Section('Signs feeding is going well', Icons.check_circle_outline, [
            '6 or more wet nappies per day after day 5',
            'Baby seems satisfied after feeds',
            'Steady weight gain after day 4',
            'Soft, yellow stools by day 4–5',
          ]),
        ],
      );
    }

    if (d <= 28) {
      return const _FeedArticle(
        emoji: '😴',
        category: 'SLEEP · LATE NEONATAL',
        title: 'Safe sleep: the ABCs every parent must know',
        intro:
            'Newborns sleep 14–17 hours a day, but their sleep is fragmented into '
            'short cycles. Following safe sleep guidelines every time protects '
            'your baby from sudden infant death syndrome (SIDS).',
        sections: [
          _Section('The ABCs of safe sleep', Icons.shield_outlined, [
            'A — Alone: baby sleeps alone, not with adults or siblings',
            'B — Back: always place baby on their back to sleep',
            'C — Crib: use a firm, flat surface with no soft items',
          ]),
          _Section('What to avoid in the sleep space', Icons.block_outlined, [
            'No pillows, blankets, bumpers, or soft toys',
            'No inclined sleepers or car seats for routine sleep',
            'No bed-sharing — use a bedside bassinet instead',
            'No loose clothing or swaddles that cover the face',
          ]),
          _Section('Normal newborn sleep patterns', Icons.bedtime_outlined, [
            'Sleeps in 45–60 minute cycles, waking between cycles',
            'Total sleep: 14–17 hours spread across day and night',
            'No day/night rhythm yet — this develops around 6–8 weeks',
            'Noisy, irregular breathing during sleep is normal',
          ]),
          _Section('Helping baby sleep safely', Icons.lightbulb_outline, [
            'Swaddle snugly with arms in — stops startle reflex waking baby',
            'White noise mimics the womb and soothes newborns',
            'Room temperature 18–20°C — check neck warmth, not hands',
            'Pacifier at sleep time reduces SIDS risk once feeding is established',
          ]),
        ],
      );
    }

    if (d <= 90) {
      return const _FeedArticle(
        emoji: '🍼',
        category: 'FEEDING · EARLY INFANT',
        title: 'Building a feeding routine at 1–3 months',
        intro:
            'Your baby is growing fast and feeds are becoming more efficient. '
            'This is a great time to start recognising hunger and fullness cues '
            'and move toward a gentle feeding rhythm.',
        sections: [
          _Section('How much and how often', Icons.schedule_outlined, [
            '6–8 feeds per day, roughly every 3–4 hours',
            'Formula: 90–120 ml per feed at 4–8 weeks',
            'Formula: 120–150 ml per feed at 2–3 months',
            'Breastfed babies self-regulate — feed on demand',
          ]),
          _Section('Hunger and fullness cues', Icons.visibility_outlined, [
            'Hunger: rooting, sucking hands, turning head, fussing',
            'Fullness: turning away, relaxing hands, falling asleep',
            'Crying is a late hunger cue — try to feed before this point',
            'Spitting up small amounts after feeds is normal',
          ]),
          _Section('Burping your baby', Icons.air_outlined, [
            'Burp halfway through and after every feed',
            'Over-the-shoulder, sitting upright, or face-down on your lap',
            'Gentle circular back rubs — not patting',
            'If no burp after 5 minutes, it\'s fine to stop',
          ]),
          _Section('Growth spurts to expect', Icons.trending_up_outlined, [
            'Around 3 weeks, 6 weeks, and 3 months',
            'Baby feeds more frequently for 2–3 days',
            'This is normal — feed on demand during spurts',
            'Supply increases to meet demand within a few days',
          ]),
        ],
      );
    }

    return const _FeedArticle(
      emoji: '🥣',
      category: 'FEEDING · INFANT',
      title: 'Preparing for solid foods at 4–6 months',
      intro:
          'Breast milk or formula remains the primary nutrition until 6 months. '
          'But now is the time to watch for readiness signs and prepare for '
          'the exciting transition to solid foods.',
      sections: [
        _Section('Signs of readiness for solids', Icons.check_circle_outline, [
          'Can sit with minimal support and hold head steady',
          'Shows interest in food — watching you eat, reaching for food',
          'Has lost the tongue-thrust reflex (no longer pushes food out)',
          'Typically ready between 5.5 and 6 months — not before 4 months',
        ]),
        _Section('Continue breast milk or formula', Icons.local_drink_outlined, [
          '5–7 feeds per day, 120–180 ml per formula feed',
          'Milk remains the main nutrition source until 12 months',
          'Introduce solids alongside milk, not instead of it',
          'Offer milk before solids in the early weeks of weaning',
        ]),
        _Section('First foods to try', Icons.restaurant_outlined, [
          'Single-ingredient purées: sweet potato, butternut, banana',
          'Iron-rich foods: pureed meat, lentils, fortified cereals',
          'Introduce one new food every 3–5 days to watch for reactions',
          'No honey, salt, sugar, or cow\'s milk as a drink before 12 months',
        ]),
        _Section('Feeding safety', Icons.shield_outlined, [
          'Always supervise feeding — never leave baby alone with food',
          'Avoid round, hard foods that are choking hazards',
          'Offer water in a cup from 6 months — small sips only',
          'Expect mess — it\'s part of learning to eat!',
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final article = _article;
    return Scaffold(
      backgroundColor: _kPageBg,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _kPrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kMid, _kPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(article.category,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: 1.0)),
                        const SizedBox(height: 6),
                        Text(article.title,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.25)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intro card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(article.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(article.intro,
                              style: const TextStyle(
                                  fontSize: 14, color: _kGrey, height: 1.6)),
                        ),
                      ],
                    ),
                  ),

                  // Age badge
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kLightBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _kPrimary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Day ${data.ageInDays} · ${data.stageLabel}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, color: _kPrimary),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sections
                  ...article.sections.map((s) => _SectionCard(section: s)),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final _Section section;
  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: _kLightBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(section.icon, color: _kPrimary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(section.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: _kBlack)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...section.points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6, height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 10),
                  decoration: const BoxDecoration(color: _kPrimary, shape: BoxShape.circle),
                ),
                Expanded(
                  child: Text(p,
                      style: const TextStyle(fontSize: 13, color: _kGrey, height: 1.5)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _FeedArticle {
  final String emoji;
  final String category;
  final String title;
  final String intro;
  final List<_Section> sections;
  const _FeedArticle({
    required this.emoji,
    required this.category,
    required this.title,
    required this.intro,
    required this.sections,
  });
}

class _Section {
  final String title;
  final IconData icon;
  final List<String> points;
  const _Section(this.title, this.icon, this.points);
}
