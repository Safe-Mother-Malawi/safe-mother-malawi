import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// IVR Alert model
class IvrAlert {
  final String sessionId;
  final DateTime timestamp;
  final String riskLevel; // LOW, MODERATE, HIGH, CRITICAL
  final String patientType; // prenatal, neonatal
  final String callerPhone;
  final String message;
  final Map<String, dynamic> answers;
  final int riskScore;
  final String action;

  IvrAlert({
    required this.sessionId,
    required this.timestamp,
    required this.riskLevel,
    required this.patientType,
    required this.callerPhone,
    required this.message,
    required this.answers,
    required this.riskScore,
    required this.action,
  });

  factory IvrAlert.fromJson(Map<String, dynamic> json) {
    return IvrAlert(
      sessionId: json['sessionId'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      riskLevel: json['riskLevel'] ?? 'LOW',
      patientType: json['patientType'] ?? 'prenatal',
      callerPhone: json['callerPhone'] ?? '',
      message: json['message'] ?? '',
      answers: Map<String, dynamic>.from(json['answers'] ?? {}),
      riskScore: json['riskScore'] ?? 0,
      action: json['action'] ?? '',
    );
  }

  Color getRiskColor() {
    switch (riskLevel) {
      case 'CRITICAL':
        return const Color(0xFFD32F2F); // Red
      case 'HIGH':
        return const Color(0xFFF57C00); // Orange
      case 'MODERATE':
        return const Color(0xFFFBC02D); // Amber
      default:
        return const Color(0xFF388E3C); // Green
    }
  }

  String getRiskEmoji() {
    switch (riskLevel) {
      case 'CRITICAL':
        return '🚨';
      case 'HIGH':
        return '⚠️';
      case 'MODERATE':
        return '⚡';
      default:
        return '✅';
    }
  }
}

/// IVR Alerts Service - Manages WebSocket connection for real-time alerts
class IvrAlertsService extends ChangeNotifier {
  late IO.Socket _socket;
  bool _isConnected = false;
  List<IvrAlert> _alerts = [];
  String? _userId;
  String? _district;
  final String _apiBaseUrl = 'https://backend-gsgb.onrender.com';

  bool get isConnected => _isConnected;
  List<IvrAlert> get alerts => _alerts;
  int get alertCount => _alerts.length;

  /// Connect to IVR alerts WebSocket
  Future<void> connect({
    required String userId,
    String? district,
  }) async {
    _userId = userId;
    _district = district;

    try {
      _socket = IO.io(
        _apiBaseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      // Connection events
      _socket.onConnect((_) {
        _isConnected = true;
        _joinAlerts();
        notifyListeners();
      });

      _socket.onDisconnect((_) {
        _isConnected = false;
        notifyListeners();
      });

      // Listen for IVR alerts
      _socket.on('ivr-alert', (data) {
        final alert = IvrAlert.fromJson(data);
        _alerts.insert(0, alert); // Add to top of list
        notifyListeners();
      });

      // Listen for join confirmation
      _socket.on('joined', (data) {
        // Joined alerts channel
      });

      // Listen for connection confirmation
      _socket.on('connection', (data) {
        // Connected to server
      });

      _socket.connect();
    } catch (e) {
      print('Error connecting to IVR alerts: $e');
    }
  }

  /// Join alerts channel
  void _joinAlerts() {
    if (_isConnected && _userId != null) {
      _socket.emit('join-alerts', {
        'userId': _userId,
        if (_district != null) 'district': _district,
      });
    }
  }

  /// Clear all alerts
  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  /// Remove specific alert
  void removeAlert(String sessionId) {
    _alerts.removeWhere((alert) => alert.sessionId == sessionId);
    notifyListeners();
  }

  /// Disconnect from WebSocket
  void disconnect() {
    if (_isConnected) {
      _socket.disconnect();
      _isConnected = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
