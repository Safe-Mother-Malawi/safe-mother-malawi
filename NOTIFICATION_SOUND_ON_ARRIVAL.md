# Notification Sound on Arrival - Implementation

## ✅ What Was Implemented

### Sound Plays When Notification Arrives

Notifications now play sound in THREE scenarios:

1. **Foreground** - App is open
   - Sound plays immediately when notification arrives
   - Handler: `FirebaseMessaging.onMessage`

2. **Background** - App is closed/minimized
   - Sound plays when notification arrives
   - Handler: `_firebaseMessagingBackgroundHandler`

3. **Notification Tapped** - User taps notification
   - Sound plays when user opens notification
   - Handler: `FirebaseMessaging.onMessageOpenedApp`

## 📝 Changes Made

### 1. Updated `lib/main.dart`
- Added Firebase Messaging initialization
- Added background message handler
- Added foreground notification listener
- Added notification tap listener
- Request notification permissions (alert, sound, badge)

### 2. Updated `pubspec.yaml`
- Added `firebase_messaging: ^14.7.0`
- Already has `audioplayers: ^5.2.1`

### 3. Existing `NotificationSoundService`
- Used by all three notification handlers
- Plays sound based on notification type

## 🔊 How Sound Selection Works

Sound type is determined from notification data:

```dart
final notificationType = message.data['type'] ?? 'default';
```

Maps to:
- `'alert'` → alert.mp3
- `'reminder'` → reminder.mp3
- `'urgent'` → urgent.mp3
- `'default'` → notification.mp3

## 📱 Notification Flow

```
Backend sends notification
        ↓
Firebase Cloud Messaging
        ↓
    ┌───┴───┐
    ↓       ↓
Foreground  Background
    ↓       ↓
  Sound    Sound
    ↓       ↓
User sees notification
    ↓
User taps notification
    ↓
  Sound
```

## 🧪 Testing

### Test Foreground Sound
1. Open app
2. Send notification from backend
3. Sound should play immediately

### Test Background Sound
1. Close app (or minimize)
2. Send notification from backend
3. Sound should play
4. Notification appears in system tray

### Test Tap Sound
1. Tap notification in system tray
2. Sound should play
3. App opens

## 📋 Required Setup

### 1. Sound Files
Create `assets/sounds/` with:
- notification.mp3
- alert.mp3
- reminder.mp3
- urgent.mp3

### 2. Dependencies
Run: `flutter pub get`

### 3. Android Permissions
Already configured in AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### 4. iOS Setup
Add to `ios/Podfile`:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

## 🔧 Backend Integration

Backend should send notifications with `type` field:

```json
{
  "notification": {
    "title": "Appointment Reminder",
    "body": "Your appointment is tomorrow"
  },
  "data": {
    "type": "reminder"
  }
}
```

## 📊 Notification Types

| Type | Sound | Use Case |
|------|-------|----------|
| default | notification.mp3 | General notifications, tips |
| alert | alert.mp3 | Health alerts, warnings |
| reminder | reminder.mp3 | Appointment reminders |
| urgent | urgent.mp3 | Emergency alerts |

## ⚙️ Configuration

### Volume Control
Edit `notification_sound_service.dart`:
```dart
await _audioPlayer.setVolume(0.8); // Change 0.8 to 0.0-1.0
```

### Disable Sounds
```dart
NotificationSoundService().setSoundEnabled(false);
```

## 🐛 Troubleshooting

### Sound Not Playing on Android
1. Check notification permissions granted
2. Check sound files exist
3. Check volume is not muted
4. Test on physical device (emulator may have issues)

### Sound Not Playing on iOS
1. Check iOS permissions in Info.plist
2. Check device volume
3. Check notification settings in iOS Settings

### Multiple Sounds Playing
- Already handled by service
- Only one sound plays at a time

## 📞 Debug Logs

Check console for:
```
✅ Firebase Messaging initialized
🔔 Foreground notification received: [title]
🔔 Background notification received: [title]
📱 Notification tapped: [title]
```

## 🚀 Next Steps

1. Add sound files to `assets/sounds/`
2. Run `flutter pub get`
3. Test on device
4. Configure backend to send `type` field
5. Optional: Add sound toggle in Settings

## ⚠️ Important Notes

- Sound plays EVERY time notification arrives
- Can be disabled via `setSoundEnabled(false)`
- Requires sound files in assets
- Requires Firebase setup
- Requires notification permissions
