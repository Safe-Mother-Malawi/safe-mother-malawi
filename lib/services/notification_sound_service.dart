import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service to handle notification sounds
class NotificationSoundService {
  static final NotificationSoundService _instance = NotificationSoundService._();
  
  factory NotificationSoundService() => _instance;
  
  NotificationSoundService._();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  /// Enable/disable notification sounds
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Play notification sound
  Future<void> playNotificationSound({
    String soundType = 'default', // 'default', 'alert', 'reminder', 'urgent'
  }) async {
    if (!_soundEnabled) return;

    try {
      // Map sound types to asset paths
      final soundPath = _getSoundPath(soundType);
      
      // Set volume
      await _audioPlayer.setVolume(0.8);
      
      // Play the sound
      await _audioPlayer.play(AssetSource(soundPath));
      
      debugPrint('🔔 Playing notification sound: $soundType');
    } catch (e) {
      debugPrint('❌ Error playing notification sound: $e');
    }
  }

  /// Get sound file path based on type
  String _getSoundPath(String soundType) {
    switch (soundType.toLowerCase()) {
      case 'alert':
        return 'sounds/alert.mp3';
      case 'reminder':
        return 'sounds/reminder.mp3';
      case 'urgent':
        return 'sounds/urgent.mp3';
      case 'default':
      default:
        return 'sounds/notification.mp3';
    }
  }

  /// Stop any playing sound
  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
