# Notification Sounds Setup

## Overview
Notification sounds are played when users interact with notifications in the mobile app.

## Sound Files Required

Place the following MP3 files in `assets/sounds/`:

1. **notification.mp3** (default)
   - Standard notification sound
   - Duration: 1-2 seconds
   - Use case: General notifications, tips

2. **alert.mp3**
   - Alert/warning sound
   - Duration: 1-2 seconds
   - Use case: Health alerts, warnings

3. **reminder.mp3**
   - Gentle reminder sound
   - Duration: 1-2 seconds
   - Use case: Appointment reminders, task reminders

4. **urgent.mp3**
   - Urgent/critical sound
   - Duration: 1-2 seconds
   - Use case: Emergency alerts, critical health notifications

## Directory Structure

```
safe-mother-malawi/
├── assets/
│   └── sounds/
│       ├── notification.mp3
│       ├── alert.mp3
│       ├── reminder.mp3
│       └── urgent.mp3
```

## pubspec.yaml Configuration

The following is already configured in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/sounds/notification.mp3
    - assets/sounds/alert.mp3
    - assets/sounds/reminder.mp3
    - assets/sounds/urgent.mp3
```

## Usage

### In Notifications Screen
When a user taps a notification, the appropriate sound plays based on notification type:

```dart
final soundService = NotificationSoundService();
await soundService.playNotificationSound(soundType: 'alert');
```

### Sound Types
- `'default'` → notification.mp3
- `'alert'` → alert.mp3
- `'reminder'` → reminder.mp3
- `'urgent'` → urgent.mp3

### Enable/Disable Sounds
```dart
final soundService = NotificationSoundService();
soundService.setSoundEnabled(true);  // Enable
soundService.setSoundEnabled(false); // Disable
```

## Implementation Details

### NotificationSoundService
- **Location:** `lib/services/notification_sound_service.dart`
- **Features:**
  - Play notification sounds by type
  - Enable/disable sounds globally
  - Stop playing sounds
  - Volume control (80%)

### Integration Points
1. **Notifications Screen** - Plays sound when notification is tapped
2. **Settings Screen** - Can add toggle to enable/disable sounds
3. **Other Screens** - Can use service to play sounds for other events

## Sound File Recommendations

### Creating Custom Sounds
Use free sound resources:
- [Freesound.org](https://freesound.org/)
- [Zapsplat](https://www.zapsplat.com/)
- [Notification Sounds](https://notificationsounds.com/)

### Audio Format
- **Format:** MP3
- **Bitrate:** 128 kbps
- **Sample Rate:** 44.1 kHz
- **Duration:** 1-2 seconds
- **File Size:** ~50-200 KB per file

## Testing

### Test Notification Sound
1. Open Notifications Screen
2. Tap any notification
3. Sound should play based on notification type

### Disable Sounds
Add to Settings Screen:
```dart
Checkbox(
  value: _soundEnabled,
  onChanged: (v) {
    NotificationSoundService().setSoundEnabled(v!);
    setState(() => _soundEnabled = v);
  },
)
```

## Troubleshooting

### Sound Not Playing
1. Check sound files exist in `assets/sounds/`
2. Verify `pubspec.yaml` includes sound assets
3. Run `flutter pub get`
4. Rebuild app

### Volume Too Low/High
Adjust in `notification_sound_service.dart`:
```dart
await _audioPlayer.setVolume(0.8); // Change 0.8 to desired level (0.0-1.0)
```

### Sound Plays Multiple Times
Use `stopSound()` before playing new sound:
```dart
await soundService.stopSound();
await soundService.playNotificationSound(soundType: 'alert');
```

## Future Enhancements

- [ ] Add vibration feedback
- [ ] Add haptic feedback
- [ ] Custom sound selection in settings
- [ ] Sound volume control in settings
- [ ] Mute during specific hours
- [ ] Different sounds for different notification types
