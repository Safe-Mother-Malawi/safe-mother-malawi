import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/responsive_helper.dart';

class IvrSimulatorWeb extends StatefulWidget {
  const IvrSimulatorWeb({super.key});

  @override
  State<IvrSimulatorWeb> createState() => _IvrSimulatorWebState();
}

class _IvrSimulatorWebState extends State<IvrSimulatorWeb> {
  String _screenText = 'Initializing...';
  String _sessionId = '';
  String _riskLevel = '';
  bool _isLoading = false;
  bool _isConnected = false;
  final String _apiBaseUrl = 'https://backend-gsgb.onrender.com/api/v1/ivr';

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    try {
      setState(() {
        _isLoading = true;
        _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      });

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/simulator/init'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': _sessionId,
          'language': 'en',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Welcome to Safe Mother Malawi IVR';
        setState(() {
          _screenText = message;
          _isConnected = true;
          _isLoading = false;
        });
      } else {
        _handleConnectionError('Failed to initialize session');
      }
    } catch (e) {
      _handleConnectionError('Connection error: $e');
    }
  }

  Future<void> _pressKey(String key) async {
    if (!_isConnected || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/simulator/digit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': _sessionId,
          'digit': key,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'No response';
        setState(() {
          _screenText = message;
          _riskLevel = data['riskLevel'] ?? '';
          _isLoading = false;

          if (data['shouldHangup'] == true) {
            Future.delayed(const Duration(seconds: 2), _endCall);
          }
        });
      } else {
        _handleConnectionError('Failed to process digit');
      }
    } catch (e) {
      _handleConnectionError('Error: $e');
    }
  }

  void _handleConnectionError(String error) {
    setState(() {
      _screenText = error;
      _isConnected = false;
      _isLoading = false;
    });
  }

  Future<void> _endCall() async {
    try {
      await http.post(
        Uri.parse('$_apiBaseUrl/simulator/end'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': _sessionId}),
      );
    } catch (e) {
      // Ignore errors on end
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _reset() {
    _initializeSession();
  }

  Widget _buildKey(String label, bool isMobile) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 4 : 6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          onPressed: _isConnected && !_isLoading ? () => _pressKey(label) : null,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MODERATE':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FF),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A237E),
            elevation: 0,
            title: Text(
              'IVR Simulator',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Connection Status
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: 8,
                  ),
                  color: _isConnected ? Colors.green[100] : Colors.red[100],
                  child: Row(
                    children: [
                      Icon(
                        _isConnected ? Icons.check_circle : Icons.error,
                        color: _isConnected ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isConnected ? 'Connected to Backend' : 'Connection Failed',
                        style: TextStyle(
                          color: _isConnected ? Colors.green[900] : Colors.red[900],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Call Display Screen
                Container(
                  margin: EdgeInsets.all(isMobile ? 12 : 20),
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  height: isMobile ? 200 : 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        )
                      else
                        Text(
                          _screenText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: isMobile ? 14 : 18,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                            fontFamily: 'Courier',
                          ),
                        ),
                      if (_riskLevel.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getRiskColor(_riskLevel),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Risk: $_riskLevel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Dial Pad
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
                  child: Column(
                    children: [
                      Row(children: [_buildKey('1', isMobile), _buildKey('2', isMobile), _buildKey('3', isMobile)]),
                      Row(children: [_buildKey('4', isMobile), _buildKey('5', isMobile), _buildKey('6', isMobile)]),
                      Row(children: [_buildKey('7', isMobile), _buildKey('8', isMobile), _buildKey('9', isMobile)]),
                      Row(children: [_buildKey('*', isMobile), _buildKey('0', isMobile), _buildKey('#', isMobile)]),
                      SizedBox(height: isMobile ? 12 : 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
