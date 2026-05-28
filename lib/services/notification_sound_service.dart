import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service for playing notification sounds
/// Supports multiple sound types and platforms (mobile, web)
class NotificationSoundService {
  static final NotificationSoundService _instance = NotificationSoundService._internal();

  factory NotificationSoundService() {
    return _instance;
  }

  NotificationSoundService._internal();

  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;

  /// Initialize the audio player
  Future<void> initialize() async {
    if (_isInitialized) return;

    _audioPlayer = AudioPlayer();
    _isInitialized = true;
    debugPrint('✓ NotificationSoundService initialized');
  }

  /// Play notification sound
  /// 
  /// Parameters:
  /// - [soundType]: Type of notification (default, alert, reminder, etc.)
  /// - [volume]: Volume level (0.0 to 1.0), default is 1.0
  /// 
  /// Supported sound types:
  /// - 'default': Standard notification sound
  /// - 'alert': High-priority alert sound
  /// - 'reminder': Reminder notification sound
  /// - 'success': Success notification sound
  /// - 'error': Error notification sound
  Future<void> playNotificationSound({
    String soundType = 'default',
    double volume = 1.0,
  }) async {
    try {
      // Ensure service is initialized
      if (!_isInitialized) {
        await initialize();
      }

      // Map sound types to audio files
      final soundPath = _getSoundPath(soundType);

      debugPrint('🔊 Playing notification sound: $soundType ($soundPath)');

      // Set volume
      await _audioPlayer.setVolume(volume);

      // Play the sound
      await _audioPlayer.play(
        AssetSource(soundPath),
        volume: volume,
      );

      debugPrint('✓ Notification sound played successfully');
    } catch (e) {
      debugPrint('❌ Error playing notification sound: $e');
      // Don't throw - notification should still work even if sound fails
    }
  }

  /// Play notification sound with custom path
  /// 
  /// Use this if you want to play a specific audio file
  Future<void> playCustomSound({
    required String assetPath,
    double volume = 1.0,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      debugPrint('🔊 Playing custom sound: $assetPath');

      await _audioPlayer.setVolume(volume);
      await _audioPlayer.play(
        AssetSource(assetPath),
        volume: volume,
      );

      debugPrint('✓ Custom sound played successfully');
    } catch (e) {
      debugPrint('❌ Error playing custom sound: $e');
    }
  }

  /// Stop currently playing sound
  Future<void> stopSound() async {
    try {
      if (_isInitialized) {
        await _audioPlayer.stop();
        debugPrint('⏹️ Sound stopped');
      }
    } catch (e) {
      debugPrint('❌ Error stopping sound: $e');
    }
  }

  /// Pause currently playing sound
  Future<void> pauseSound() async {
    try {
      if (_isInitialized) {
        await _audioPlayer.pause();
        debugPrint('⏸️ Sound paused');
      }
    } catch (e) {
      debugPrint('❌ Error pausing sound: $e');
    }
  }

  /// Resume paused sound
  Future<void> resumeSound() async {
    try {
      if (_isInitialized) {
        await _audioPlayer.resume();
        debugPrint('▶️ Sound resumed');
      }
    } catch (e) {
      debugPrint('❌ Error resuming sound: $e');
    }
  }

  /// Get the asset path for a sound type
  /// 
  /// Returns the path to the audio file for the given sound type
  String _getSoundPath(String soundType) {
    switch (soundType.toLowerCase()) {
      case 'alert':
      case 'high':
      case 'critical':
        return 'sounds/618f3287-new_facebook_ringtone_7.m4a';
      
      case 'reminder':
      case 'medium':
        return 'sounds/618f3287-new_facebook_ringtone_7.m4a';
      
      case 'success':
      case 'low':
        return 'sounds/618f3287-new_facebook_ringtone_7.m4a';
      
      case 'error':
      case 'warning':
        return 'sounds/618f3287-new_facebook_ringtone_7.m4a';
      
      case 'default':
      default:
        return 'sounds/618f3287-new_facebook_ringtone_7.m4a';
    }
  }

  /// Check if audio player is playing
  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  /// Get current playback state
  PlayerState get playerState => _audioPlayer.state;

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isInitialized = false;
      debugPrint('✓ NotificationSoundService disposed');
    } catch (e) {
      debugPrint('❌ Error disposing NotificationSoundService: $e');
    }
  }
}
