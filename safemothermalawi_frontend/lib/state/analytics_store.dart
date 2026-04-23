/// Shared state between GenerateAnalytics and AnalyticsDashboard.
/// When the DHO/Admin generates analytics, the result is stored here
/// and AnalyticsDashboard reads from it.
class AnalyticsStore {
  AnalyticsStore._();
  static final AnalyticsStore instance = AnalyticsStore._();

  Map<String, dynamic>? lastResult;
  DateTime? generatedAt;
  String? generatedForDistrict;

  void save(Map<String, dynamic> data, {String? district}) {
    lastResult = data;
    generatedAt = DateTime.now();
    generatedForDistrict = district;
    _notify();
  }

  void clear() {
    lastResult = null;
    generatedAt = null;
    generatedForDistrict = null;
    _notify();
  }

  final List<void Function()> _listeners = [];
  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void _notify() { for (final l in _listeners) { l(); } }
}
