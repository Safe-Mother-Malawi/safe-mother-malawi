import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/ivr_tts_service.dart';
import '../../auth/services/auth_service.dart';

class IvrSimulatorScreen extends StatefulWidget {
  final String selectedLanguage;
  const IvrSimulatorScreen({super.key, this.selectedLanguage = 'en'});

  @override
  State<IvrSimulatorScreen> createState() => _IvrSimulatorScreenState();
}

class _IvrSimulatorScreenState extends State<IvrSimulatorScreen> {
  String _screenText = 'Initializing...';
  String _input = '';
  String _sessionId = '';
  String _riskLevel = '';
  bool _isLoading = false;
  bool _isConnected = false;
  final String _apiBaseUrl = 'https://backend-gsgb.onrender.com/api/v1/ivr';
  
  // Call history
  List<Map<String, dynamic>> _callHistory = [];
  bool _historyLoading = false;
  int _currentTab = 0; // 0 = simulator, 1 = history

  // TTS
  late IvrTtsService _ttsService;
  bool _ttsEnabled = true;

  // Language support
  String _selectedLanguage = 'en';
  
  // User info
  String? _userType; // 'prenatal' or 'neonatal'
  String? _userName;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _ttsService = IvrTtsService();
    _selectedLanguage = widget.selectedLanguage;
    _loadCallHistory();
    _loadUserInfo();
    _initializeSession();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  /// Load current user information to determine patient type
  Future<void> _loadUserInfo() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          _userType = user.role; // 'prenatal' or 'neonatal'
          _userName = user.fullName;
          _userPhone = user.phone;
        });
      }
    } catch (e) {
      // If user info fails to load, continue without it
      print('Failed to load user info: $e');
    }
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
          'language': _selectedLanguage,
          'patientType': _userType, // Pass user type (prenatal or neonatal)
          'patientName': _userName,
          'patientPhone': _userPhone,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Welcome to Health IVR';
        setState(() {
          _screenText = message;
          _isConnected = true;
          _isLoading = false;
        });
        // Speak the welcome message
        if (_ttsEnabled) {
          await _ttsService.speak(message);
        }
      } else {
        _handleConnectionError('Failed to initialize session');
      }
    } catch (e) {
      _handleConnectionError('Connection error: $e');
    }
  }

  Future<void> _loadCallHistory() async {
    setState(() => _historyLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/call-history?limit=20&offset=0'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _callHistory = List<Map<String, dynamic>>.from(data['calls'] ?? []);
          _historyLoading = false;
        });
      } else {
        setState(() => _historyLoading = false);
      }
    } catch (e) {
      setState(() => _historyLoading = false);
    }
  }

  Future<void> _pressKey(String key) async {
    if (!_isConnected || _isLoading) return;

    setState(() {
      _input = key;
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
      ).timeout(const Duration(seconds: 5));

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
        // Speak the response
        if (_ttsEnabled) {
          await _ttsService.speak(message);
        }
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
    _endCall();
  }

  Widget _buildKey(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          onPressed: _isConnected && !_isLoading ? () => _pressKey(label) : null,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        title: const Text(
          'IVR Simulator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_currentTab == 0)
            IconButton(
              onPressed: () => setState(() => _ttsEnabled = !_ttsEnabled),
              icon: Icon(
                _ttsEnabled ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
              ),
              tooltip: _ttsEnabled ? 'Disable Voice' : 'Enable Voice',
            ),
          if (_currentTab == 0)
            IconButton(
              onPressed: _isConnected ? _reset : null,
              icon: const Icon(Icons.phone_disabled, color: Colors.white),
              tooltip: 'End Call',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF1A237E),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _currentTab == 0 ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Simulator',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: _currentTab == 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _currentTab == 1 ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Call History',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: _currentTab == 1 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _currentTab == 0 ? _buildSimulator() : _buildCallHistory(),
    );
  }

  Widget _buildSimulator() {
    return Column(
      children: [
        // Connection Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
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
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
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
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(children: [_buildKey('1'), _buildKey('2'), _buildKey('3')]),
                Row(children: [_buildKey('4'), _buildKey('5'), _buildKey('6')]),
                Row(children: [_buildKey('7'), _buildKey('8'), _buildKey('9')]),
                Row(children: [_buildKey('*'), _buildKey('0'), _buildKey('#')]),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallHistory() {
    if (_historyLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A237E)),
      );
    }

    if (_callHistory.isEmpty) {
      return const Center(
        child: Text(
          'No call history yet',
          style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _callHistory.length,
      itemBuilder: (context, index) {
        final call = _callHistory[index];
        final startTime = DateTime.parse(call['startedAt'] as String);
        final duration = call['durationSeconds'] as int?;
        final riskLevel = call['riskLevel'] as String?;
        final outcome = call['outcome'] as String?;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE3E8FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          call['patientName'] ?? call['callerPhone'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${startTime.day}/${startTime.month}/${startTime.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (riskLevel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRiskColor(riskLevel),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        riskLevel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Type: ${call['patientType'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                    ),
                  ),
                  if (duration != null)
                    Text(
                      'Duration: ${duration}s',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                    ),
                ],
              ),
              if (outcome != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Outcome: $outcome',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Interactions: ${call['interactionCount'] ?? 0}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF1A237E), fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: () {
                      // TODO: Show detailed transcript
                    },
                    child: const Text(
                      'View',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
}
