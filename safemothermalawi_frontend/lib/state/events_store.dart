import '../screens/clinician/pages/calendar_page.dart';

/// Singleton store shared between Alerts and Calendar pages.
class EventsStore {
  EventsStore._();
  static final EventsStore instance = EventsStore._();

  final List<CalEvent> events = [];

  void addEvent(CalEvent e) => events.add(e);

  /// Listeners notified when events change
  final List<void Function()> _listeners = [];
  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void notify() { for (final l in _listeners) {
    l();
  } }

  void add(CalEvent e) {
    events.add(e);
    notify();
  }

  void update(CalEvent e) {
    final idx = events.indexWhere((ev) => ev.id == e.id);
    if (idx != -1) { events[idx] = e; notify(); }
  }
}
