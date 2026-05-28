import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';

/// Represents an offline action that needs to be synced
class OfflineAction {
  final String id;
  final String method; // 'POST', 'PUT', 'DELETE'
  final String endpoint;
  final Map<String, dynamic>? body;
  final DateTime createdAt;
  bool synced;

  OfflineAction({
    required this.id,
    required this.method,
    required this.endpoint,
    this.body,
    required this.createdAt,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'method': method,
    'endpoint': endpoint,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'synced': synced,
  };

  factory OfflineAction.fromJson(Map<String, dynamic> json) => OfflineAction(
    id: json['id'],
    method: json['method'],
    endpoint: json['endpoint'],
    body: json['body'],
    createdAt: DateTime.parse(json['createdAt']),
    synced: json['synced'] ?? false,
  );
}

/// Manages offline functionality and sync queue
class OfflineService extends ChangeNotifier {
  static final OfflineService _instance = OfflineService._();
  factory OfflineService() => _instance;
  OfflineService._();

  late SharedPreferences _prefs;
  final List<OfflineAction> _syncQueue = [];
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;
  bool _isSyncing = false;
  Timer? _syncTimer;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get isSyncing => _isSyncing;
  List<OfflineAction> get syncQueue => List.from(_syncQueue);
  int get pendingActionsCount => _syncQueue.where((a) => !a.synced).length;

  /// Initialize the offline service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSyncQueue();
    final initialConnection = await Connectivity().checkConnectivity();
    _isOnline = initialConnection != ConnectivityResult.none;
    _setupConnectivityListener();
    _startPeriodicSync();
    notifyListeners();
    if (_isOnline && pendingActionsCount > 0) {
      await _syncOfflineActions();
    }
  }

  /// Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;

      if (_isOnline && !wasOnline) {
        debugPrint('📡 Connection restored - starting sync');
        _syncOfflineActions();
      } else if (!_isOnline && wasOnline) {
        debugPrint('📡 Connection lost - offline mode enabled');
      }

      notifyListeners();
    });
  }

  /// Start periodic sync timer (every 30 seconds)
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isOnline && !_isSyncing && _syncQueue.isNotEmpty) {
        _syncOfflineActions();
      }
    });
  }

  /// Load sync queue from persistent storage
  Future<void> _loadSyncQueue() async {
    try {
      final queueJson = _prefs.getString('offline_sync_queue');
      if (queueJson != null) {
        final List<dynamic> decoded = jsonDecode(queueJson);
        _syncQueue.clear();
        _syncQueue.addAll(
          decoded.map((item) => OfflineAction.fromJson(item as Map<String, dynamic>)),
        );
        debugPrint('📦 Loaded ${_syncQueue.length} offline actions from storage');
      }
    } catch (e) {
      debugPrint('❌ Error loading sync queue: $e');
    }
  }

  /// Save sync queue to persistent storage
  Future<void> _saveSyncQueue() async {
    try {
      final queueJson = jsonEncode(_syncQueue.map((a) => a.toJson()).toList());
      await _prefs.setString('offline_sync_queue', queueJson);
    } catch (e) {
      debugPrint('❌ Error saving sync queue: $e');
    }
  }

  /// Queue an offline action
  Future<void> queueAction({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final action = OfflineAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: method,
      endpoint: endpoint,
      body: body,
      createdAt: DateTime.now(),
    );

    _syncQueue.add(action);
    await _saveSyncQueue();
    debugPrint('📝 Queued offline action: $method $endpoint');
    notifyListeners();
  }

  /// Sync all pending offline actions
  Future<void> _syncOfflineActions() async {
    if (_isSyncing || _syncQueue.isEmpty) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final pendingActions = _syncQueue.where((a) => !a.synced).toList();
      debugPrint('🔄 Syncing ${pendingActions.length} offline actions...');

      for (final action in pendingActions) {
        try {
          await _syncAction(action);
          action.synced = true;
        } catch (e) {
          debugPrint('❌ Failed to sync action ${action.id}: $e');
          // Keep the action in queue for retry
        }
      }

      // Remove synced actions
      _syncQueue.removeWhere((a) => a.synced);
      await _saveSyncQueue();

      debugPrint('✅ Sync completed. ${_syncQueue.length} actions remaining');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error during sync: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync a single action
  Future<void> _syncAction(OfflineAction action) async {
    switch (action.method) {
      case 'POST':
        await ApiService.instance.post(action.endpoint, action.body ?? {});
        break;
      case 'PUT':
        await ApiService.instance.put(action.endpoint, action.body ?? {});
        break;
      case 'DELETE':
        await ApiService.instance.delete(action.endpoint);
        break;
      default:
        throw Exception('Unknown method: ${action.method}');
    }
  }

  /// Clear all synced actions
  Future<void> clearSyncedActions() async {
    _syncQueue.removeWhere((a) => a.synced);
    await _saveSyncQueue();
    notifyListeners();
  }

  /// Clear all actions (use with caution)
  Future<void> clearAllActions() async {
    _syncQueue.clear();
    await _prefs.remove('offline_sync_queue');
    notifyListeners();
  }

  /// Get sync queue statistics
  Map<String, int> getStatistics() {
    return {
      'total': _syncQueue.length,
      'pending': _syncQueue.where((a) => !a.synced).length,
      'synced': _syncQueue.where((a) => a.synced).length,
    };
  }

  /// Dispose resources
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }
}
