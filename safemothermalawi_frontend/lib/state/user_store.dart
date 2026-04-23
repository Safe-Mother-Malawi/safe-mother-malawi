/// Singleton that holds the currently logged-in user's data.
/// Populated on login (both web and mobile) and cleared on logout.
class UserStore {
  UserStore._();
  static final UserStore instance = UserStore._();

  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  // Convenience getters
  String get id           => _user?['id']?.toString()           ?? '';
  String get fullName     => _user?['fullName']?.toString()     ?? '';
  String get email        => _user?['email']?.toString()        ?? '';
  String get phone        => _user?['phone']?.toString()        ?? '';
  String get role         => _user?['role']?.toString()         ?? '';
  String get district     => _user?['district']?.toString()     ?? '';
  String get healthCentre => _user?['healthCentre']?.toString() ?? '';
  String get facility     => _user?['facility']?.toString()     ?? '';
  String get age          => _user?['age']?.toString()          ?? '';
  String get nationality  => _user?['nationality']?.toString()  ?? '';

  // Prenatal
  String get pregnancyMonths       => _user?['pregnancyMonths']?.toString()       ?? '';
  String get pregnancyWeeks        => _user?['pregnancyWeeks']?.toString()        ?? '';
  String get expectedDeliveryDate  => _user?['expectedDeliveryDate']?.toString()  ?? '';
  String get lmpDate               => _user?['lmpDate']?.toString()               ?? '';

  // Neonatal
  String get babyName        => _user?['babyName']?.toString()        ?? '';
  String get babyDob         => _user?['babyDob']?.toString()         ?? '';
  String get babyGender      => _user?['babyGender']?.toString()      ?? '';
  String get babyBirthWeight => _user?['babyBirthWeight']?.toString() ?? '';

  bool get isLoggedIn => _user != null;

  void save(Map<String, dynamic> userData) {
    _user = userData;
    _notify();
  }

  void clear() {
    _user = null;
    _notify();
  }

  // Simple listener pattern for reactive updates
  final List<void Function()> _listeners = [];
  void addListener(void Function() l)    => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void _notify() { for (final l in _listeners) { l(); } }
}
