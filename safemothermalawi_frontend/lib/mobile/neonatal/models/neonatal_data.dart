// NeonatalData — All data models for the neonatal module.
// Everything is derived from [babyDob] — no extra input needed.

// ── Enums ──────────────────────────────────────────────────────────────────────

enum VaccineStatus { given, upcoming, scheduled }

enum FeedType { breast, formula, mixed }

enum SleepType { dayNap, nightSleep }

// ── Vaccine Entry ──────────────────────────────────────────────────────────────

class VaccineEntry {
  final String name;
  final String ageLabel;
  final int dueDayAge;
  final VaccineStatus status;

  const VaccineEntry({
    required this.name,
    required this.ageLabel,
    required this.dueDayAge,
    required this.status,
  });
}

// ── Feed Entry ─────────────────────────────────────────────────────────────────

class FeedEntry {
  final FeedType type;
  final int? volumeMl;
  final int? durationMin;
  final DateTime time;

  FeedEntry({
    required this.type,
    this.volumeMl,
    this.durationMin,
    required this.time,
  });

  String get typeLabel {
    switch (type) {
      case FeedType.breast:  return 'Breast';
      case FeedType.formula: return 'Formula';
      case FeedType.mixed:   return 'Mixed';
    }
  }

  String get formattedTime {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Sleep Entry ────────────────────────────────────────────────────────────────

class SleepEntry {
  final DateTime start;
  final DateTime end;
  final SleepType type;

  SleepEntry({required this.start, required this.end, required this.type});

  Duration get duration => end.difference(start);

  String get durationLabel {
    final total = duration.inMinutes.abs();
    final h = total ~/ 60;
    final m = total % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  String get timeRange {
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${fmt(start)} – ${fmt(end)}';
  }

  String get typeLabel =>
      type == SleepType.dayNap ? 'Day Nap ☀️' : 'Night Sleep 🌙';
}

// ── NeonatalData ───────────────────────────────────────────────────────────────

class NeonatalData {
  final DateTime babyDob;
  final String babyName;

  const NeonatalData({required this.babyDob, required this.babyName});

  // ─── Age ───────────────────────────────────────────────────────────────────

  int get ageInDays =>
      DateTime.now().difference(babyDob).inDays.clamp(0, 366);

  int get ageInWeeks => (ageInDays / 7).floor();

  // ─── Stage ─────────────────────────────────────────────────────────────────

  String get stageLabel {
    if (ageInDays <= 28) return 'Newborn Phase';
    if (ageInDays <= 90) return 'Early Infant';
    if (ageInDays <= 180) return 'Infant';
    return 'Older Infant';
  }

  double get stageProgress => (ageInDays / 28.0).clamp(0.0, 1.0);

  // ─── Greeting ──────────────────────────────────────────────────────────────

  static String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ─── Growth ────────────────────────────────────────────────────────────────

  int get expectedWeightGrams {
    if (ageInDays <= 4) return (3200 - ageInDays * 60).clamp(2900, 3200);
    if (ageInDays <= 14) return 3200 + ((ageInDays - 4) * 25);
    return (3200 + ageInWeeks * 150).clamp(3200, 12000);
  }

  String get displayWeight {
    final g = expectedWeightGrams;
    return g >= 1000 ? '${(g / 1000).toStringAsFixed(1)} kg' : '$g g';
  }

  double get expectedLengthCm =>
      (50.0 + ageInWeeks * 0.6).clamp(48.0, 85.0);

  double get headCircumferenceCm =>
      (34.0 + ageInWeeks * 0.5).clamp(33.0, 48.0);

  // ─── Development Milestone ─────────────────────────────────────────────────

  String get milestone {
    if (ageInDays <= 7) {
      return 'Adjusting to the world. Can focus 20–30 cm away and recognizes your voice.';
    } else if (ageInDays <= 14) {
      return 'Starting to recognize familiar voices and smells. Strong rooting reflex.';
    } else if (ageInDays <= 21) {
      return 'More alert when awake. Briefly following faces. Grasping reflex active.';
    } else if (ageInDays <= 28) {
      return 'May show a social smile. Tracking slow-moving objects with eyes.';
    } else if (ageInWeeks <= 6) {
      return 'Holding head up briefly during tummy time. Responding to familiar sounds.';
    } else if (ageInWeeks <= 8) {
      return 'Cooing and gurgling. Smiling at familiar faces. Improved eye contact.';
    } else if (ageInWeeks <= 12) {
      return 'Batting at objects, improved head control. Laughing and vocalizing!';
    } else {
      return 'Reaching for objects, great head control. Babbling and exploring socially!';
    }
  }

  // ─── Recommendations ───────────────────────────────────────────────────────

  String get feedingRecommendation {
    if (ageInDays <= 3)  return '8–12 feeds/day. Colostrum only — very important.';
    if (ageInDays <= 14) return '8–12 feeds/day. 30–60 ml per formula feed.';
    if (ageInWeeks <= 4) return '7–9 feeds/day. 60–90 ml per feed.';
    if (ageInWeeks <= 8) return '6–8 feeds/day. 90–120 ml per feed.';
    return '5–7 feeds/day. 120–150 ml per feed.';
  }

  String get sleepRecommendation {
    if (ageInDays <= 28) return '14–17 hrs/day in 45–60 min cycles.';
    if (ageInWeeks <= 8) return '14–16 hrs/day. Longer night stretches developing.';
    return '12–16 hrs/day including naps.';
  }

  String get wakeWindowRecommendation {
    if (ageInDays <= 28) return '45–60 min';
    if (ageInWeeks <= 8) return '60–90 min';
    return '90–120 min';
  }

  // ─── Daily Tip ─────────────────────────────────────────────────────────────

  static const List<String> _tips = [
    'Skin-to-skin (kangaroo care) helps regulate heart rate and temperature.',
    'Always place baby on their back to sleep — never tummy or side.',
    'Watch for hunger cues: rooting, sucking fists, or turning the head.',
    'Keep umbilical stump clean and dry — it should fall off in 1–3 weeks.',
    'Tummy time while awake builds neck muscles — start with 2–3 minutes.',
    'Talk and sing to your baby — language development starts from day one!',
    'Ensure everyone who holds baby has clean, washed hands.',
    'Yellow skin (jaundice) in week one is common — consult your nurse.',
    'Breast milk changes from colostrum to mature milk in 3–5 days.',
    'Normal newborn breathing is irregular — up to 60 breaths/min is okay.',
  ];

  static const List<String> _tipEmojis = [
    '🤱','😴','👀','🏥','💪','💬','🧼','💛','🍼','💨',
  ];

  String get tipOfTheDay   => _tips[ageInDays % _tips.length];
  String get tipEmoji      => _tipEmojis[ageInDays % _tipEmojis.length];

  // ─── Vaccines (Malawi EPI Schedule) ───────────────────────────────────────

  List<VaccineEntry> get vaccineSchedule {
    VaccineStatus statusFor(int dueDay) {
      if (ageInDays >= dueDay + 7) return VaccineStatus.given;
      if (ageInDays >= dueDay - 7) return VaccineStatus.upcoming;
      return VaccineStatus.scheduled;
    }

    return [
      VaccineEntry(name: 'BCG (Tuberculosis)',           ageLabel: 'At birth',  dueDayAge: 0,   status: VaccineStatus.given),
      VaccineEntry(name: 'OPV-0 (Oral Polio)',           ageLabel: 'At birth',  dueDayAge: 0,   status: VaccineStatus.given),
      VaccineEntry(name: 'Hepatitis B · Birth dose',     ageLabel: 'At birth',  dueDayAge: 0,   status: VaccineStatus.given),
      VaccineEntry(name: 'OPV-1 + PCV-1 + Pentavalent-1',ageLabel: '6 weeks', dueDayAge: 42,  status: statusFor(42)),
      VaccineEntry(name: 'Rotavirus · Dose 1',           ageLabel: '6 weeks',   dueDayAge: 42,  status: statusFor(42)),
      VaccineEntry(name: 'OPV-2 + PCV-2 + Pentavalent-2',ageLabel: '10 weeks',dueDayAge: 70,  status: statusFor(70)),
      VaccineEntry(name: 'Rotavirus · Dose 2',           ageLabel: '10 weeks',  dueDayAge: 70,  status: statusFor(70)),
      VaccineEntry(name: 'OPV-3 + PCV-3 + Pentavalent-3',ageLabel: '14 weeks',dueDayAge: 98,  status: statusFor(98)),
      VaccineEntry(name: 'IPV (Inactivated Polio)',      ageLabel: '14 weeks',  dueDayAge: 98,  status: statusFor(98)),
      VaccineEntry(name: 'Measles + Yellow Fever',       ageLabel: '9 months',  dueDayAge: 274, status: statusFor(274)),
    ];
  }

  VaccineEntry? get nextVaccine {
    for (final v in vaccineSchedule) {
      if (v.status != VaccineStatus.given) return v;
    }
    return null;
  }

  String get nextVaccineSummary {
    final v = nextVaccine;
    if (v == null) return 'All scheduled vaccines given ✓';
    final dueDate = babyDob.add(Duration(days: v.dueDayAge));
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${v.name} · ${dueDate.day} ${m[dueDate.month - 1]} ${dueDate.year}';
  }

  // ─── Well-Baby Checks ──────────────────────────────────────────────────────

  int get nextCheckDay {
    const checks = [7, 14, 21, 28, 42, 56, 84];
    for (final d in checks) {
      if (ageInDays < d) return d;
    }
    return ageInDays + 28;
  }

  String get nextCheckDate {
    final date = babyDob.add(Duration(days: nextCheckDay));
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${m[date.month - 1]} ${date.year}';
  }

  // ─── Danger Signs ──────────────────────────────────────────────────────────

  static const List<String> dangerSigns = [
    'Fast / difficult breathing (>60 breaths/min)',
    'Skin colour changes — blue, pale, or deep yellow (jaundice)',
    'Not feeding or refusing breast/bottle for more than 3 hours',
    'Fever above 38°C or temperature below 36°C',
    'Umbilical cord redness, swelling, or foul smell',
    'Excessive or unusual high-pitched crying',
    'Seizures or abnormal body movements',
    'Sunken fontanelle (soft spot) — sign of dehydration',
    'Fewer than 6 wet nappies per day after the first week',
    'Unusually lethargic or difficult to wake for feeds',
  ];

  // ─── Asset ─────────────────────────────────────────────────────────────────

  String get babyImageAsset => 'assets/baby/week_40.jpg';
}
