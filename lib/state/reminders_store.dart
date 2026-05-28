import 'package:flutter/foundation.dart';
import '../services/offline_api_service.dart';

enum ReminderType {
  appointment,
  ironTablet,
  ancVisit,
  vaccine,
  prenatalCheckup,
  neonatalCheckup,
  custom,
}

enum ReminderStatus {
  pending,
  sent,
  failed,
  cancelled,
}

enum ReminderFrequency {
  once,
  daily,
  weekly,
  monthly,
}

class Reminder {
  final String id;
  final String title;
  final String body;
  final ReminderType type;
  final ReminderStatus status;
  final ReminderFrequency frequency;
  final DateTime scheduledFor;
  final DateTime? sentAt;
  final DateTime? nextReminderAt;
  final bool acknowledged;
  final Map<String, dynamic>? metadata;
  final String? appointmentId;
  final String? patientId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.status,
    required this.frequency,
    required this.scheduledFor,
    this.sentAt,
    this.nextReminderAt,
    this.acknowledged = false,
    this.metadata,
    this.appointmentId,
    this.patientId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: _parseReminderType(json['type']),
      status: _parseReminderStatus(json['status']),
      frequency: _parseReminderFrequency(json['frequency']),
      scheduledFor: DateTime.parse(json['scheduledFor'] ?? DateTime.now().toIso8601String()),
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      nextReminderAt: json['nextReminderAt'] != null ? DateTime.parse(json['nextReminderAt']) : null,
      acknowledged: json['acknowledged'] ?? false,
      metadata: json['metadata'],
      appointmentId: json['appointmentId'],
      patientId: json['patientId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': _reminderTypeToString(type),
    'status': _reminderStatusToString(status),
    'frequency': _reminderFrequencyToString(frequency),
    'scheduledFor': scheduledFor.toIso8601String(),
    'sentAt': sentAt?.toIso8601String(),
    'nextReminderAt': nextReminderAt?.toIso8601String(),
    'acknowledged': acknowledged,
    'metadata': metadata,
    'appointmentId': appointmentId,
    'patientId': patientId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static ReminderType _parseReminderType(String? type) {
    switch (type) {
      case 'appointment':
        return ReminderType.appointment;
      case 'iron_tablet':
        return ReminderType.ironTablet;
      case 'anc_visit':
        return ReminderType.ancVisit;
      case 'vaccine':
        return ReminderType.vaccine;
      case 'prenatal_checkup':
        return ReminderType.prenatalCheckup;
      case 'neonatal_checkup':
        return ReminderType.neonatalCheckup;
      case 'custom':
        return ReminderType.custom;
      default:
        return ReminderType.custom;
    }
  }

  static ReminderStatus _parseReminderStatus(String? status) {
    switch (status) {
      case 'pending':
        return ReminderStatus.pending;
      case 'sent':
        return ReminderStatus.sent;
      case 'failed':
        return ReminderStatus.failed;
      case 'cancelled':
        return ReminderStatus.cancelled;
      default:
        return ReminderStatus.pending;
    }
  }

  static ReminderFrequency _parseReminderFrequency(String? frequency) {
    switch (frequency) {
      case 'once':
        return ReminderFrequency.once;
      case 'daily':
        return ReminderFrequency.daily;
      case 'weekly':
        return ReminderFrequency.weekly;
      case 'monthly':
        return ReminderFrequency.monthly;
      default:
        return ReminderFrequency.once;
    }
  }

  static String _reminderTypeToString(ReminderType type) {
    switch (type) {
      case ReminderType.appointment:
        return 'appointment';
      case ReminderType.ironTablet:
        return 'iron_tablet';
      case ReminderType.ancVisit:
        return 'anc_visit';
      case ReminderType.vaccine:
        return 'vaccine';
      case ReminderType.prenatalCheckup:
        return 'prenatal_checkup';
      case ReminderType.neonatalCheckup:
        return 'neonatal_checkup';
      case ReminderType.custom:
        return 'custom';
    }
  }

  static String _reminderStatusToString(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.pending:
        return 'pending';
      case ReminderStatus.sent:
        return 'sent';
      case ReminderStatus.failed:
        return 'failed';
      case ReminderStatus.cancelled:
        return 'cancelled';
    }
  }

  static String _reminderFrequencyToString(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'once';
      case ReminderFrequency.daily:
        return 'daily';
      case ReminderFrequency.weekly:
        return 'weekly';
      case ReminderFrequency.monthly:
        return 'monthly';
    }
  }

  String get frequencyLabel {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'One time';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.monthly:
        return 'Monthly';
    }
  }

  String get statusLabel {
    switch (status) {
      case ReminderStatus.pending:
        return 'Pending';
      case ReminderStatus.sent:
        return 'Sent';
      case ReminderStatus.failed:
        return 'Failed';
      case ReminderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get typeLabel {
    switch (type) {
      case ReminderType.appointment:
        return 'Appointment';
      case ReminderType.ironTablet:
        return 'Iron Tablet';
      case ReminderType.ancVisit:
        return 'ANC Visit';
      case ReminderType.vaccine:
        return 'Vaccine';
      case ReminderType.prenatalCheckup:
        return 'Prenatal Checkup';
      case ReminderType.neonatalCheckup:
        return 'Neonatal Checkup';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  String get timeUntilReminder {
    final now = DateTime.now();
    final diff = scheduledFor.difference(now);

    if (diff.isNegative) {
      return 'Overdue';
    } else if (diff.inSeconds < 60) {
      return 'In ${diff.inSeconds}s';
    } else if (diff.inMinutes < 60) {
      return 'In ${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return 'In ${diff.inHours}h';
    } else {
      return 'In ${diff.inDays}d';
    }
  }
}

class RemindersStore extends ChangeNotifier {
  RemindersStore._();
  static final RemindersStore instance = RemindersStore._();

  final List<Reminder> _reminders = [];
  final List<Reminder> _filteredReminders = [];
  bool _loaded = false;
  bool _loading = false;
  String? _error;

  // Filters
  ReminderStatus? _selectedStatus;
  ReminderType? _selectedType;

  // Getters
  List<Reminder> get reminders => List.from(_filteredReminders);
  List<Reminder> get allReminders => List.from(_reminders);
  bool get loaded => _loaded;
  bool get loading => _loading;
  String? get error => _error;

  ReminderStatus? get selectedStatus => _selectedStatus;
  ReminderType? get selectedType => _selectedType;

  int get totalCount => _reminders.length;
  int get pendingCount => _reminders.where((r) => r.status == ReminderStatus.pending).length;
  int get sentCount => _reminders.where((r) => r.status == ReminderStatus.sent).length;
  int get failedCount => _reminders.where((r) => r.status == ReminderStatus.failed).length;

  /// Load all reminders
  Future<void> load() async {
    if (_loaded && _reminders.isNotEmpty) return;
    _loading = true;
    _error = null;
    _notify();

    try {
      final remindersData = await OfflineApiService().get('/reminders') as List<dynamic>;
      _reminders.clear();
      _reminders.addAll(
        remindersData.cast<Map<String, dynamic>>().map(Reminder.fromJson),
      );
      _loaded = true;
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _notify();
    }
  }

  /// Load pending reminders
  Future<void> loadPending() async {
    _loading = true;
    _error = null;
    _notify();

    try {
      final remindersData = await OfflineApiService().get('/reminders/pending') as List<dynamic>;
      final pending = remindersData.cast<Map<String, dynamic>>().map(Reminder.fromJson).toList();
      
      // Update existing reminders with pending status
      for (final reminder in pending) {
        final index = _reminders.indexWhere((r) => r.id == reminder.id);
        if (index >= 0) {
          _reminders[index] = reminder;
        } else {
          _reminders.add(reminder);
        }
      }
      
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _notify();
    }
  }

  /// Create a new reminder
  Future<void> createReminder({
    required String title,
    required String body,
    required ReminderType type,
    required ReminderFrequency frequency,
    required DateTime scheduledFor,
    String? appointmentId,
    String? patientId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final body_data = {
        'title': title,
        'body': body,
        'type': Reminder._reminderTypeToString(type),
        'frequency': Reminder._reminderFrequencyToString(frequency),
        'scheduledFor': scheduledFor.toIso8601String(),
        if (appointmentId != null) 'appointmentId': appointmentId,
        if (patientId != null) 'patientId': patientId,
        if (metadata != null) 'metadata': metadata,
      };

      final result = await OfflineApiService().post('/reminders', body_data);
      if (result is Map && result['queued'] == true) {
        final now = DateTime.now();
        final reminder = Reminder(
          id: 'offline-${now.millisecondsSinceEpoch}',
          title: title,
          body: body,
          type: type,
          status: ReminderStatus.pending,
          frequency: frequency,
          scheduledFor: scheduledFor,
          acknowledged: false,
          metadata: metadata,
          appointmentId: appointmentId,
          patientId: patientId,
          createdAt: now,
          updatedAt: now,
        );
        _reminders.add(reminder);
        _applyFilters();
        _notify();
        return;
      }
      final reminder = Reminder.fromJson(result as Map<String, dynamic>);
      _reminders.add(reminder);
      _applyFilters();
      _notify();
    } catch (e) {
      _error = e.toString();
      _notify();
      rethrow;
    }
  }

  /// Acknowledge a reminder
  Future<void> acknowledgeReminder(String reminderId) async {
    try {
      final result = await OfflineApiService().put('/reminders/$reminderId/acknowledge', {});
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index >= 0) {
        final reminder = _reminders[index];
        if (result is Map && result['queued'] == true) {
          _reminders[index] = Reminder(
            id: reminder.id,
            title: reminder.title,
            body: reminder.body,
            type: reminder.type,
            status: reminder.status,
            frequency: reminder.frequency,
            scheduledFor: reminder.scheduledFor,
            sentAt: reminder.sentAt,
            nextReminderAt: reminder.nextReminderAt,
            acknowledged: true,
            metadata: reminder.metadata,
            appointmentId: reminder.appointmentId,
            patientId: reminder.patientId,
            createdAt: reminder.createdAt,
            updatedAt: DateTime.now(),
          );
          _applyFilters();
          _notify();
          return;
        }
        _reminders[index] = Reminder(
          id: reminder.id,
          title: reminder.title,
          body: reminder.body,
          type: reminder.type,
          status: reminder.status,
          frequency: reminder.frequency,
          scheduledFor: reminder.scheduledFor,
          sentAt: reminder.sentAt,
          nextReminderAt: reminder.nextReminderAt,
          acknowledged: true,
          metadata: reminder.metadata,
          appointmentId: reminder.appointmentId,
          patientId: reminder.patientId,
          createdAt: reminder.createdAt,
          updatedAt: reminder.updatedAt,
        );
        _applyFilters();
        _notify();
      }
    } catch (e) {
      _error = e.toString();
      _notify();
      rethrow;
    }
  }

  /// Cancel a reminder
  Future<void> cancelReminder(String reminderId) async {
    try {
      final result = await OfflineApiService().put('/reminders/$reminderId/cancel', {});
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index >= 0) {
        final reminder = _reminders[index];
        if (result is Map && result['queued'] == true) {
          _reminders[index] = Reminder(
            id: reminder.id,
            title: reminder.title,
            body: reminder.body,
            type: reminder.type,
            status: ReminderStatus.cancelled,
            frequency: reminder.frequency,
            scheduledFor: reminder.scheduledFor,
            sentAt: reminder.sentAt,
            nextReminderAt: reminder.nextReminderAt,
            acknowledged: reminder.acknowledged,
            metadata: reminder.metadata,
            appointmentId: reminder.appointmentId,
            patientId: reminder.patientId,
            createdAt: reminder.createdAt,
            updatedAt: DateTime.now(),
          );
          _applyFilters();
          _notify();
          return;
        }
        _reminders[index] = Reminder(
          id: reminder.id,
          title: reminder.title,
          body: reminder.body,
          type: reminder.type,
          status: ReminderStatus.cancelled,
          frequency: reminder.frequency,
          scheduledFor: reminder.scheduledFor,
          sentAt: reminder.sentAt,
          nextReminderAt: reminder.nextReminderAt,
          acknowledged: reminder.acknowledged,
          metadata: reminder.metadata,
          appointmentId: reminder.appointmentId,
          patientId: reminder.patientId,
          createdAt: reminder.createdAt,
          updatedAt: reminder.updatedAt,
        );
        _applyFilters();
        _notify();
      }
    } catch (e) {
      _error = e.toString();
      _notify();
      rethrow;
    }
  }

  /// Reschedule a reminder
  Future<void> rescheduleReminder(String reminderId, DateTime newScheduledFor) async {
    try {
      final result = await OfflineApiService().put('/reminders/$reminderId/reschedule', {
        'scheduledFor': newScheduledFor.toIso8601String(),
      });
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index >= 0) {
        final reminder = _reminders[index];
        _reminders[index] = Reminder(
          id: reminder.id,
          title: reminder.title,
          body: reminder.body,
          type: reminder.type,
          status: reminder.status,
          frequency: reminder.frequency,
          scheduledFor: newScheduledFor,
          sentAt: reminder.sentAt,
          nextReminderAt: reminder.nextReminderAt,
          acknowledged: reminder.acknowledged,
          metadata: reminder.metadata,
          appointmentId: reminder.appointmentId,
          patientId: reminder.patientId,
          createdAt: reminder.createdAt,
          updatedAt: DateTime.now(),
        );
        _applyFilters();
        _notify();
        if (result is Map && result['queued'] == true) return;
      }
      await load();
    } catch (e) {
      _error = e.toString();
      _notify();
      rethrow;
    }
  }

  /// Delete a reminder
  Future<void> deleteReminder(String reminderId) async {
    try {
      final result = await OfflineApiService().delete('/reminders/$reminderId');
      if (result is Map && result['queued'] == true) {
        _reminders.removeWhere((r) => r.id == reminderId);
        _applyFilters();
        _notify();
        return;
      }
      _reminders.removeWhere((r) => r.id == reminderId);
      _applyFilters();
      _notify();
    } catch (e) {
      _error = e.toString();
      _notify();
      rethrow;
    }
  }

  /// Set status filter
  void setStatusFilter(ReminderStatus? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  /// Set type filter
  void setTypeFilter(ReminderType? type) {
    _selectedType = type;
    _applyFilters();
  }

  /// Clear filters
  void clearFilters() {
    _selectedStatus = null;
    _selectedType = null;
    _applyFilters();
  }

  /// Apply filters
  void _applyFilters() {
    _filteredReminders.clear();
    var results = _reminders;

    if (_selectedStatus != null) {
      results = results.where((r) => r.status == _selectedStatus).toList();
    }

    if (_selectedType != null) {
      results = results.where((r) => r.type == _selectedType).toList();
    }

    _filteredReminders.addAll(results);
    _notify();
  }

  /// Reload reminders
  Future<void> reload() async {
    _loaded = false;
    _reminders.clear();
    _filteredReminders.clear();
    await load();
  }

  final List<void Function()> _listeners = [];
  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void _notify() {
    for (final l in _listeners) {
      l();
    }
  }
}
