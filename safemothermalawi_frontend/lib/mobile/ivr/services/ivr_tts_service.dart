import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// IVR Text-to-Speech Service
/// Handles voice playback for IVR messages
class IvrTtsService {
  static final IvrTtsService _instance = IvrTtsService._internal();
  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  late Future<void> _initFuture;

  factory IvrTtsService() {
    return _instance;
  }

  IvrTtsService._internal() {
    _flutterTts = FlutterTts();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Set language
      await _flutterTts.setLanguage('en-US');

      // Set speech rate (0.5 = slow, 1.0 = normal, 2.0 = fast)
      await _flutterTts.setSpeechRate(0.9);

      // Set pitch (1.0 = normal)
      await _flutterTts.setPitch(1.0);

      // Set volume (0.0 to 1.0)
      await _flutterTts.setVolume(1.0);

      // Listen to completion
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      // Listen to errors
      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
      });

      _isInitialized = true;
      if (kDebugMode) debugPrint('TTS initialized successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing TTS: $e');
    }
  }

  /// Speak a message
  Future<void> speak(String message) async {
    try {
      // Ensure initialization is complete before speaking
      await _initFuture;

      // Stop any ongoing speech
      await stop();

      _isSpeaking = true;
      await _flutterTts.speak(message);
    } catch (e) {
      if (kDebugMode) debugPrint('Error speaking: $e');
      _isSpeaking = false;
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      if (kDebugMode) debugPrint('Error stopping TTS: $e');
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      if (kDebugMode) debugPrint('Error pausing TTS: $e');
    }
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Set speech rate (0.5 to 2.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.5, 2.0));
    } catch (e) {
      if (kDebugMode) debugPrint('Error setting speech rate: $e');
    }
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
    } catch (e) {
      if (kDebugMode) debugPrint('Error setting pitch: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) debugPrint('Error setting volume: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _flutterTts.stop();
      _isInitialized = false;
    } catch (e) {
      if (kDebugMode) debugPrint('Error disposing TTS: $e');
    }
  }
}
