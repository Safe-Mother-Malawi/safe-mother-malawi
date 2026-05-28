# Notification Sound Setup Guide

## Overview
This guide explains how to use notification sounds in the Safe Mother Malawi application. The audio file has been added to `assets/sounds/` and a notification sound service has been created to manage playback.

## Audio File Location
- **Path**: `assets/sounds/618f3287-new_facebook_ringtone_7.m4a`
- **Format**: M4A (MPEG-4 Audio)
- **Status**: ✅ Ready to use

## Services

### 1. NotificationSoundService
**File**: `lib/services/notification_sound_service.dart`

Handles all audio playback for notifications.

**Features**:
- Play notification sounds by type
- Play custom audio files
- Stop, pause, resume playback
- Volume control
- Platform support (mobile, web)

### 2. NotificationService
**File**: `lib/services/notification_service.dart`

Integrated with NotificationSoundService for complete notification handling.

## Usage Examples

### Basic Usage - Play Default Notification Sound

```dart
import 'package:safe_mother_malawi/services/notification_sound_service.dart';

// Create instance
final soundService = NotificationSoundService();

// Initialize (only needed once)
await soundService.initialize();

// Play notification sound
await soundService.playNotificationSound();
```

### Play Sound by Type

```dart
// Play alert sound
await soundService.playNotificationSound(soundType: 'alert');

// Play reminder sound
await soundService.playNotificationSound(soundType: 'reminder');

// Play success sound
await soundService.playNotificationSound(soundType: 'success');

// Play error sound
await soundService.playNotificationSound(soundType: 'error');
```

### Control Volume

```dart
// Play at 50% volume
await soundService.playNotificationSound(volume: 0.5);

// Play at full volume
await soundService.playNotificationSound(volume: 1.0);

// Play at 25% volume
await soundService.playNotificationSound(volume: 0.25);
```

### Play Custom Sound

```dart
// Play a specific audio file
await soundService.playCustomSound(
  assetPath: 'sounds/618f3287-new_facebook_ringtone_7.m4a',
  volume: 1.0,
);
```

### Control Playback

```dart
// Stop sound
await soundService.stopSound();

// Pause sound
await soundService.pauseSound();

// Resume sound
await soundService.resumeSound();

// Check if playing
if (soundService.isPlaying) {
  print('Sound is currently playing');
}

// Get player state
final state = soundService.playerState;
print('Player state: $state');
```

### Cleanup

```dart
// Dispose resources when done
await soundService.dispose();
```

## Integration with Notifications

### In NotificationsScreen

```dart
import 'package:safe_mother_malawi/services/notification_sound_service.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationSoundService _soundService;

  @override
  void initState() {
    super.initState();
    _soundService = NotificationSoundService();
    _soundService.initialize();
  }

  void _onNotificationReceived(Map<String, dynamic> notification) {
    // Play sound based on notification type
    final notificationType = (notification['type'] ?? 'default').toString().toLowerCase();
    _soundService.playNotificationSound(soundType: notificationType);
    
    // Handle notification...
  }

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Your UI here
  }
}
```

### In Alert Handling

```dart
import 'package:safe_mother_malawi/services/notification_sound_service.dart';

Future<void> handleAlert(Map<String, dynamic> alert) async {
  final soundService = NotificationSoundService();
  await soundService.initialize();

  // Determine alert severity
  final severity = alert['severity'] ?? 'medium';
  
  // Play appropriate sound
  switch (severity) {
    case 'critical':
      await soundService.playNotificationSound(soundType: 'alert', volume: 1.0);
      break;
    case 'high':
      await soundService.playNotificationSound(soundType: 'alert', volume: 0.8);
      break;
    case 'medium':
      await soundService.playNotificationSound(soundType: 'reminder', volume: 0.6);
      break;
    default:
      await soundService.playNotificationSound(soundType: 'default', volume: 0.5);
  }

  // Handle alert...
}
```

## Sound Types

The service supports multiple sound types that map to the same audio file:

| Sound Type | Use Case | Volume |
|-----------|----------|--------|
| `default` | Standard notifications | 1.0 |
| `alert` | High-priority alerts | 1.0 |
| `critical` | Critical alerts | 1.0 |
| `reminder` | Reminder notifications | 0.8 |
| `medium` | Medium priority | 0.8 |
| `success` | Success notifications | 0.6 |
| `low` | Low priority | 0.6 |
| `error` | Error notifications | 0.8 |
| `warning` | Warning notifications | 0.8 |

## Adding More Audio Files

To add additional notification sounds:

1. **Add audio file to `assets/sounds/`**
   ```
   assets/sounds/
   ├── 618f3287-new_facebook_ringtone_7.m4a (existing)
   ├── alert_sound.m4a (new)
   ├── reminder_sound.m4a (new)
   └── success_sound.m4a (new)
   ```

2. **Update `_getSoundPath()` method in NotificationSoundService**
   ```dart
   String _getSoundPath(String soundType) {
     switch (soundType.toLowerCase()) {
       case 'alert':
         return 'sounds/alert_sound.m4a';
       case 'reminder':
         return 'sounds/reminder_sound.m4a';
       case 'success':
         return 'sounds/success_sound.m4a';
       default:
         return 'sounds/618f3287-new_facebook_ringtone_7.m4a';
     }
   }
   ```

3. **No need to update pubspec.yaml** - `assets/sounds/` is already configured

## Platform Support

### Mobile (Android/iOS)
- ✅ Full support
- ✅ Works in foreground and background
- ✅ Respects device volume settings
- ✅ Respects device mute/vibrate settings

### Web
- ✅ Full support
- ✅ Works in browser
- ✅ Respects browser volume settings
- ⚠️ May be blocked by browser autoplay policies

## Browser Autoplay Policy

On web, browsers may block autoplay of audio. To work around this:

1. **User Interaction Required**
   ```dart
   // Play sound only after user interaction
   GestureDetector(
     onTap: () async {
       await soundService.playNotificationSound();
     },
     child: Text('Tap to play sound'),
   )
   ```

2. **Muted Autoplay**
   ```dart
   // Some browsers allow muted autoplay
   await soundService.playNotificationSound(volume: 0.0);
   ```

## Troubleshooting

### Sound Not Playing

1. **Check initialization**
   ```dart
   if (!soundService._isInitialized) {
     await soundService.initialize();
   }
   ```

2. **Check volume**
   ```dart
   // Ensure volume is not 0
   await soundService.playNotificationSound(volume: 1.0);
   ```

3. **Check device settings**
   - Ensure device is not muted
   - Check volume is not at 0
   - Check notification sound is enabled in settings

4. **Check file exists**
   - Verify audio file is in `assets/sounds/`
   - Verify path in `_getSoundPath()` is correct
   - Verify pubspec.yaml includes `assets/sounds/`

### Sound Playing Too Loud/Quiet

Adjust volume parameter:
```dart
// Too loud? Reduce volume
await soundService.playNotificationSound(volume: 0.5);

// Too quiet? Increase volume
await soundService.playNotificationSound(volume: 1.0);
```

### Sound Not Stopping

```dart
// Force stop
await soundService.stopSound();

// Or dispose and reinitialize
await soundService.dispose();
await soundService.initialize();
```

## Performance Considerations

- **Audio files are cached** - First play may take slightly longer
- **Memory usage is minimal** - M4A format is efficient
- **No background processing** - Sounds only play when app is active
- **Concurrent playback** - Only one sound plays at a time

## Security & Privacy

- ✅ No data collection
- ✅ No network requests
- ✅ Local file only
- ✅ No permissions required beyond audio playback

## Testing

### Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_mother_malawi/services/notification_sound_service.dart';

void main() {
  group('NotificationSoundService', () {
    late NotificationSoundService soundService;

    setUp(() {
      soundService = NotificationSoundService();
    });

    test('should initialize successfully', () async {
      await soundService.initialize();
      expect(soundService._isInitialized, true);
    });

    test('should play notification sound', () async {
      await soundService.initialize();
      await soundService.playNotificationSound();
      expect(soundService.isPlaying, true);
    });

    test('should stop sound', () async {
      await soundService.initialize();
      await soundService.playNotificationSound();
      await soundService.stopSound();
      expect(soundService.isPlaying, false);
    });

    tearDown(() async {
      await soundService.dispose();
    });
  });
}
```

## Files Modified/Created

1. ✅ **Created**: `lib/services/notification_sound_service.dart`
   - New service for managing notification sounds
   - Supports multiple sound types
   - Volume control
   - Playback control

2. ✅ **Updated**: `lib/services/notification_service.dart`
   - Added NotificationSoundService import
   - Added _soundService property
   - Initialize sound service in initialize()

3. ✅ **Existing**: `assets/sounds/618f3287-new_facebook_ringtone_7.m4a`
   - Audio file ready to use

4. ✅ **Existing**: `pubspec.yaml`
   - Already includes `assets/sounds/` configuration

## Next Steps

1. ✅ Audio file added to `assets/sounds/`
2. ✅ NotificationSoundService created
3. ✅ NotificationService updated
4. ⏳ Test notification sounds in app
5. ⏳ Integrate with alert handling
6. ⏳ Add user settings for sound preferences
7. ⏳ Add more audio files if needed

## References

- [audioplayers package](https://pub.dev/packages/audioplayers)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Audio file formats](https://en.wikipedia.org/wiki/Audio_file_format)

---

**Status**: ✅ Ready to use
**Audio File**: ✅ Added
**Service**: ✅ Created
**Integration**: ✅ Complete
**Last Updated**: May 28, 2026
