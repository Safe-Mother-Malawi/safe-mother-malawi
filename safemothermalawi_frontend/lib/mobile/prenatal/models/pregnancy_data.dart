/// All pregnancy calculations are derived from LMP (Last Menstrual Period)
/// or from a known total weeks count at registration.
class PregnancyData {
  final DateTime lmp;

  PregnancyData({required this.lmp});

  /// Construct from a known total-weeks count recorded at signup.
  /// Back-calculates an approximate LMP so all derived getters work normally.
  factory PregnancyData.fromTotalWeeks(int totalWeeks) {
    final lmp = DateTime.now().subtract(Duration(days: totalWeeks * 7));
    return PregnancyData(lmp: lmp);
  }

  /// Estimated Due Date = LMP + 280 days (Naegele's rule)
  DateTime get edd => lmp.add(const Duration(days: 280));

  /// Days pregnant from today
  int get daysPregnant {
    final d = DateTime.now().difference(lmp).inDays;
    return d.clamp(0, 280);
  }

  /// Current week (1-based)
  int get currentWeek => (daysPregnant / 7).floor() + 1;

  /// Day within current week (1–7)
  int get dayOfWeek => (daysPregnant % 7) + 1;

  /// Days remaining
  int get daysRemaining => (280 - daysPregnant).clamp(0, 280);

  /// Progress 0.0 – 1.0
  double get progress => (daysPregnant / 280).clamp(0.0, 1.0);

  /// Trimester label
  String get trimester {
    if (currentWeek <= 12) return 'First Trimester';
    if (currentWeek <= 26) return 'Second Trimester';
    return 'Third Trimester';
  }

  /// Greeting based on time of day
  static String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Baby size description per week
  String get babySize {
    if (currentWeek <= 4) return 'Poppy seed';
    if (currentWeek <= 6) return 'Sweet pea';
    if (currentWeek <= 8) return 'Raspberry';
    if (currentWeek <= 10) return 'Strawberry';
    if (currentWeek <= 12) return 'Lime';
    if (currentWeek <= 14) return 'Lemon';
    if (currentWeek <= 16) return 'Avocado';
    if (currentWeek <= 18) return 'Bell pepper';
    if (currentWeek <= 20) return 'Banana';
    if (currentWeek <= 22) return 'Papaya';
    if (currentWeek <= 24) return 'Corn';
    if (currentWeek <= 26) return 'Scallion';
    if (currentWeek <= 28) return 'Eggplant';
    if (currentWeek <= 30) return 'Cabbage';
    if (currentWeek <= 32) return 'Squash';
    if (currentWeek <= 34) return 'Butternut squash';
    if (currentWeek <= 36) return 'Honeydew melon';
    if (currentWeek <= 38) return 'Leek';
    return 'Watermelon';
  }

  /// Approximate length in cm
  double get lengthCm {
    if (currentWeek <= 4) return 0.1;
    if (currentWeek <= 6) return 0.6;
    if (currentWeek <= 8) return 1.6;
    if (currentWeek <= 10) return 3.1;
    if (currentWeek <= 12) return 5.4;
    if (currentWeek <= 14) return 8.7;
    if (currentWeek <= 16) return 11.6;
    if (currentWeek <= 18) return 14.2;
    if (currentWeek <= 20) return 16.4;
    if (currentWeek <= 22) return 19.0;
    if (currentWeek <= 24) return 21.0;
    if (currentWeek <= 26) return 23.0;
    if (currentWeek <= 28) return 25.0;
    if (currentWeek <= 30) return 27.0;
    if (currentWeek <= 32) return 28.9;
    if (currentWeek <= 34) return 31.0;
    if (currentWeek <= 36) return 33.0;
    if (currentWeek <= 38) return 35.0;
    return 36.0;
  }

  /// Approximate weight in grams
  int get weightGrams {
    if (currentWeek <= 8) return 1;
    if (currentWeek <= 10) return 4;
    if (currentWeek <= 12) return 14;
    if (currentWeek <= 14) return 43;
    if (currentWeek <= 16) return 100;
    if (currentWeek <= 18) return 190;
    if (currentWeek <= 20) return 300;
    if (currentWeek <= 22) return 430;
    if (currentWeek <= 24) return 600;
    if (currentWeek <= 26) return 760;
    if (currentWeek <= 28) return 1005;
    if (currentWeek <= 30) return 1300;
    if (currentWeek <= 32) return 1700;
    if (currentWeek <= 34) return 2100;
    if (currentWeek <= 36) return 2600;
    if (currentWeek <= 38) return 3000;
    return 3400;
  }

  /// Milestone description
  String get milestone {
    if (currentWeek <= 4) return 'Implantation complete. The embryo is forming.';
    if (currentWeek <= 6) return 'Heart begins to beat. Neural tube forming.';
    if (currentWeek <= 8) return 'All major organs forming. Tiny fingers developing.';
    if (currentWeek <= 10) return 'Baby can move! Vital organs are functional.';
    if (currentWeek <= 12) return 'Reflexes developing. Baby can open and close fists.';
    if (currentWeek <= 14) return 'Baby can squint, frown and grimace.';
    if (currentWeek <= 16) return 'Baby can hear sounds. Facial features more defined.';
    if (currentWeek <= 18) return 'Baby is yawning and hiccupping.';
    if (currentWeek <= 20) return 'Halfway there! Baby is swallowing and kicking.';
    if (currentWeek <= 22) return 'Baby has eyebrows and eyelids now.';
    if (currentWeek <= 24) return 'Lungs developing. Baby responds to light and sound.';
    if (currentWeek <= 26) return 'Eyes begin to open. Brain developing rapidly.';
    if (currentWeek <= 28) return 'Baby can blink and has eyelashes.';
    if (currentWeek <= 30) return 'Baby is practicing breathing movements.';
    if (currentWeek <= 32) return 'Baby is gaining weight fast. Skin smoothing out.';
    if (currentWeek <= 34) return 'Baby\'s fingernails have reached fingertips.';
    if (currentWeek <= 36) return 'Baby is nearly full term. Head may engage.';
    if (currentWeek <= 38) return 'Baby is considered early term. Lungs are mature.';
    return 'Full term! Baby is ready to meet you.';
  }

  /// Health tip for current week
  String get weeklyTip {
    if (currentWeek <= 8) return 'Take folic acid daily and avoid alcohol completely.';
    if (currentWeek <= 12) return 'Schedule your first trimester screening this week.';
    if (currentWeek <= 16) return 'Talk and sing to your baby — they can hear you!';
    if (currentWeek <= 20) return 'Get your anatomy scan this week.';
    if (currentWeek <= 24) return 'Monitor baby movements daily.';
    if (currentWeek <= 28) return 'Start preparing your birth plan.';
    if (currentWeek <= 32) return 'Rest more and reduce heavy activity.';
    if (currentWeek <= 36) return 'Pack your hospital bag now.';
    return 'Watch for signs of labour. Stay calm and breathe.';
  }

  /// Dynamic nutrition tip based on current week
  String get nutritionTip {
    if (currentWeek <= 4) return 'Start folic acid supplements now';
    if (currentWeek <= 8) return 'Eat small meals to ease nausea';
    if (currentWeek <= 12) return 'Iron & folate are essential this trimester';
    if (currentWeek <= 16) return 'Increase calcium-rich foods this week';
    if (currentWeek <= 20) return 'Iron & calcium are key this week';
    if (currentWeek <= 24) return 'Boost protein intake for baby\'s growth';
    if (currentWeek <= 28) return 'Omega-3 supports baby\'s brain development';
    if (currentWeek <= 32) return 'Eat fibre-rich foods to ease digestion';
    if (currentWeek <= 36) return 'Stay hydrated — drink 8+ glasses daily';
    return 'Light, frequent meals help with comfort now';
  }

  /// Dynamic exercise tip based on trimester
  String get exerciseTip {
    if (currentWeek <= 12) return 'Safe movements for trimester 1';
    if (currentWeek <= 26) return 'Safe movements for trimester 2';
    return 'Gentle stretches for trimester 3';
  }

  /// Emoji icon for nutrition tip
  String get nutritionEmoji {
    if (currentWeek <= 12) return '🥦';
    if (currentWeek <= 20) return '🍎';
    if (currentWeek <= 28) return '🐟';
    if (currentWeek <= 36) return '🥛';
    return '🍌';
  }

  /// Emoji icon for exercise tip
  String get exerciseEmoji => '🧘';

  /// Asset path for baby image — falls back to painted widget if not found.
  /// weeks 1–3 use week_01.jpg (fertilization/early cell stage)
  /// weeks 4–40 use week_04.jpg through week_40.jpg
  String get babyImageAsset {
    if (currentWeek <= 3) return 'assets/baby/week_01.jpg';
    final w = currentWeek.clamp(4, 40);
    return 'assets/baby/week_${w.toString().padLeft(2, '0')}.jpg';
  }

  /// Formatted EDD string
  String get formattedEdd {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    final d = edd;
    final suffix = _daySuffix(d.day);
    return '${d.day}$suffix ${months[d.month - 1]} ${d.year}';
  }

  String _daySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}
