import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/api_config.dart';

/// Mixin that adds real-time updates to any StatefulWidget via Socket.IO.
///
/// When the backend emits 'analytics:updated' or 'alert:created', the widget
/// automatically re-fetches its data. A 30-second polling fallback ensures
/// data stays fresh even if the socket disconnects.
///
/// Usage:
///   class _MyState extends State<My> with LiveDataMixin {
///     @override
///     void initState() {
///       super.initState();
///       startLive(_load);
///     }
///     @override
///     void dispose() {
///       stopLive();
///       super.dispose();
///     }
///   }
mixin LiveDataMixin<T extends StatefulWidget> on State<T> {
  io.Socket? _socket;
  Timer? _pollTimer;

  static const _events = ['analytics:updated', 'alert:created', 'patient:registered'];
  static const _pollInterval = Duration(seconds: 30);

  /// Start real-time updates. [callback] is called on every socket event
  /// and also every 30 seconds as a fallback.
  void startLive(
    Future<void> Function() callback, {
    Duration pollInterval = _pollInterval,
    void Function(String event, dynamic payload)? onEvent,
  }) {
    _connectSocket(callback, onEvent: onEvent);
    _pollTimer = Timer.periodic(pollInterval, (_) async {
      if (!mounted) return;
      try { await callback(); } catch (_) {}
    });
  }

  /// Stop socket and polling timer.
  void stopLive() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ── Legacy alias so existing startPolling calls still compile ────────────
  void startPolling(Future<void> Function() callback, {Duration interval = _pollInterval}) {
    startLive(callback, pollInterval: interval);
  }

  void stopPolling() => stopLive();

  void _connectSocket(
    Future<void> Function() callback, {
    void Function(String event, dynamic payload)? onEvent,
  }) {
    try {
      _socket = io.io(
        ApiConfig.wsUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(3000)
            .build(),
      );

      for (final event in _events) {
        _socket!.on(event, (payload) async {
          if (!mounted) return;
          onEvent?.call(event, payload);
          try { await callback(); } catch (_) {}
        });
      }

      _socket!.onConnectError((e) => debugPrint('[Socket] connect error: $e'));
      _socket!.onError((e) => debugPrint('[Socket] error: $e'));

      _socket!.connect();
    } catch (e) {
      debugPrint('[Socket] init failed: $e');
    }
  }
}

