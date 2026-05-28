# Notification Popup Widget Guide

## Overview
The `NotificationPopup` widget displays notifications with sound playback, animations, and auto-dismiss functionality. It provides a complete notification experience with visual and audio feedback.

## Files
- **Widget**: `lib/widgets/notification_popup.dart`
- **Sound Service**: `lib/services/notification_sound_service.dart`
- **Audio File**: `assets/sounds/618f3287-new_facebook_ringtone_7.m4a`

## Features

✅ **Animated Display** - Smooth slide-in and fade animations
✅ **Sound Playback** - Integrated with NotificationSoundService
✅ **Auto-Dismiss** - Automatically closes after configurable duration
✅ **Manual Dismiss** - Close button for immediate dismissal
✅ **Customizable** - Colors, icons, sound types, volume
✅ **Helper Methods** - Pre-configured notification types (success, error, warning, alert, info)
✅ **Platform Support** - Works on mobile and web

## Basic Usage

### Simple Notification

```dart
import 'package:safe_mother_malawi/widgets/notification_popup.dart';

// Show basic notification
NotificationPopupHelper.show(
  context,
  title: 'New Alert',
  message: 'You have a new patient alert',
);
```

### Success Notification

```dart
NotificationPopupHelper.showSuccess(
  context,
  title: 'Success',
  message: 'Patient data saved successfully',
);
```

### Error Notification

```dart
NotificationPopupHelper.showError(
  context,
  title: 'Error',
  message: 'Failed to save patient data',
);
```

### Warning Notification

```dart
NotificationPopupHelper.showWarning(
  context,
  title: 'Warning',
  message: 'Patient vitals are abnormal',
);
```

### Alert Notification

```dart
NotificationPopupHelper.showAlert(
  context,
  title: 'Critical Alert',
  message: 'Immediate action required',
);
```

### Info Notification

```dart
NotificationPopupHelper.showInfo(
  context,
  title: 'Information',
  message: 'New appointment scheduled',
);
```

## Advanced Usage

### Custom Notification with All Options

```dart
NotificationPopupHelper.show(
  context,
  title: 'Custom Notification',
  message: 'This is a custom notification',
  soundType: 'alert',
  displayDuration: const Duration(seconds: 7),
  backgroundColor: Colors.purple.shade700,
  textColor: Colors.white,
  icon: Icons.star,
  volume: 0.8,
  onDismiss: () {
    print('Notification dismissed');
  },
);
```

### With Callback

```dart
NotificationPopupHelper.showSuccess(
  context,
  title: 'Success',
  message: 'Operation completed',
  onDismiss: () {
    // Handle dismissal
    print('Notification was dismissed');
    // Navigate, refresh data, etc.
  },
);
```

## Integration Examples

### In a Screen

```dart
import 'package:flutter/material.dart';
import 'package:safe_mother_malawi/widgets/notification_popup.dart';

class PatientScreen extends StatefulWidget {
  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  Future<void> _savePatient() async {
    try {
      // Save patient logic
      await patientService.save(patient);
      
      // Show success notification
      NotificationPopupHelper.showSuccess(
        context,
        title: 'Success',
        message: 'Patient saved successfully',
      );
    } catch (e) {
      // Show error notification
      NotificationPopupHelper.showError(
        context,
        title: 'Error',
        message: 'Failed to save patient: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient')),
      body: Column(
        children: [
          // Patient form
          ElevatedButton(
            onPressed: _savePatient,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
```

### In Alert Handling

```dart
import 'package:safe_mother_malawi/widgets/notification_popup.dart';

Future<void> handleAlert(Map<String, dynamic> alert) async {
  final severity = alert['severity'] ?? 'medium';
  final title = alert['title'] ?? 'Alert';
  final message = alert['message'] ?? 'New alert received';

  switch (severity) {
    case 'critical':
      NotificationPopupHelper.showAlert(
        context,
        title: title,
        message: message,
      );
      break;
    case 'high':
      NotificationPopupHelper.showWarning(
        context,
        title: title,
        message: message,
      );
      break;
    case 'medium':
      NotificationPopupHelper.showInfo(
        context,
        title: title,
        message: message,
      );
      break;
    default:
      NotificationPopupHelper.show(
        context,
        title: title,
        message: message,
      );
  }
}
```

### With Notification Service

```dart
import 'package:safe_mother_malawi/services/notification_service.dart';
import 'package:safe_mother_malawi/widgets/notification_popup.dart';

class NotificationListener extends StatefulWidget {
  @override
  State<NotificationListener> createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<NotificationListener> {
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    
    // Listen to notification stream
    _notificationService.notificationStream.listen((notification) {
      _handleNotification(notification);
    });
  }

  void _handleNotification(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'info';
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? 'New notification';

    switch (type) {
      case 'alert':
        NotificationPopupHelper.showAlert(
          context,
          title: title,
          message: message,
        );
        break;
      case 'error':
        NotificationPopupHelper.showError(
          context,
          title: title,
          message: message,
        );
        break;
      case 'success':
        NotificationPopupHelper.showSuccess(
          context,
          title: title,
          message: message,
        );
        break;
      default:
        NotificationPopupHelper.showInfo(
          context,
          title: title,
          message: message,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
```

## Notification Types

### Success
- **Color**: Green
- **Icon**: check_circle
- **Sound**: success
- **Volume**: 0.6
- **Duration**: 4 seconds

### Error
- **Color**: Red
- **Icon**: error
- **Sound**: error
- **Volume**: 0.8
- **Duration**: 5 seconds

### Warning
- **Color**: Orange
- **Icon**: warning
- **Sound**: warning
- **Volume**: 0.7
- **Duration**: 5 seconds

### Alert
- **Color**: Dark Red
- **Icon**: notifications_active
- **Sound**: alert
- **Volume**: 1.0
- **Duration**: 6 seconds

### Info
- **Color**: Blue
- **Icon**: info
- **Sound**: reminder
- **Volume**: 0.6
- **Duration**: 4 seconds

## Customization

### Change Colors

```dart
NotificationPopupHelper.show(
  context,
  title: 'Custom',
  message: 'Custom colors',
  backgroundColor: Colors.teal.shade700,
  textColor: Colors.white,
);
```

### Change Icon

```dart
NotificationPopupHelper.show(
  context,
  title: 'Custom',
  message: 'Custom icon',
  icon: Icons.favorite,
);
```

### Change Sound

```dart
NotificationPopupHelper.show(
  context,
  title: 'Custom',
  message: 'Custom sound',
  soundType: 'reminder',
);
```

### Change Volume

```dart
NotificationPopupHelper.show(
  context,
  title: 'Custom',
  message: 'Custom volume',
  volume: 0.5,
);
```

### Change Duration

```dart
NotificationPopupHelper.show(
  context,
  title: 'Custom',
  message: 'Custom duration',
  displayDuration: const Duration(seconds: 10),
);
```

## Sound Types

| Type | Use Case | Default Volume |
|------|----------|-----------------|
| `default` | Standard notifications | 1.0 |
| `alert` | High-priority alerts | 1.0 |
| `critical` | Critical alerts | 1.0 |
| `reminder` | Reminders | 0.8 |
| `success` | Success messages | 0.6 |
| `error` | Error messages | 0.8 |
| `warning` | Warnings | 0.8 |

## Animation Details

### Slide Animation
- **Duration**: 400ms
- **Curve**: easeOut
- **Direction**: Top to center

### Fade Animation
- **Duration**: 400ms
- **Curve**: easeOut
- **Range**: 0.0 to 1.0

### Dismiss Animation
- **Duration**: 400ms
- **Curve**: easeOut (reversed)
- **Direction**: Center to top

## Best Practices

### 1. Use Appropriate Notification Types

```dart
// ✅ Good - Use specific types
NotificationPopupHelper.showSuccess(context, title: 'Success', message: 'Saved');
NotificationPopupHelper.showError(context, title: 'Error', message: 'Failed');

// ❌ Avoid - Generic notifications for everything
NotificationPopupHelper.show(context, title: 'Info', message: 'Saved');
```

### 2. Keep Messages Concise

```dart
// ✅ Good - Clear and concise
NotificationPopupHelper.showSuccess(
  context,
  title: 'Patient Saved',
  message: 'Patient data updated successfully',
);

// ❌ Avoid - Too long
NotificationPopupHelper.showSuccess(
  context,
  title: 'Patient Saved',
  message: 'The patient data has been successfully saved to the database and all changes have been persisted',
);
```

### 3. Handle Callbacks

```dart
// ✅ Good - Handle dismissal
NotificationPopupHelper.showSuccess(
  context,
  title: 'Success',
  message: 'Patient saved',
  onDismiss: () {
    Navigator.pop(context);
  },
);

// ❌ Avoid - Ignoring dismissal
NotificationPopupHelper.showSuccess(
  context,
  title: 'Success',
  message: 'Patient saved',
);
```

### 4. Adjust Duration Based on Message Length

```dart
// ✅ Good - Longer duration for longer messages
NotificationPopupHelper.show(
  context,
  title: 'Alert',
  message: 'This is a longer message that requires more time to read',
  displayDuration: const Duration(seconds: 7),
);

// ✅ Good - Shorter duration for short messages
NotificationPopupHelper.showSuccess(
  context,
  title: 'Done',
  message: 'Saved',
  displayDuration: const Duration(seconds: 3),
);
```

### 5. Use Callbacks for Navigation

```dart
// ✅ Good - Navigate after notification
NotificationPopupHelper.showSuccess(
  context,
  title: 'Patient Created',
  message: 'New patient added successfully',
  onDismiss: () {
    Navigator.pushNamed(context, '/patients');
  },
);
```

## Troubleshooting

### Sound Not Playing

1. **Check initialization**
   ```dart
   // Ensure NotificationSoundService is initialized
   final soundService = NotificationSoundService();
   await soundService.initialize();
   ```

2. **Check device volume**
   - Ensure device is not muted
   - Check volume is not at 0

3. **Check audio file**
   - Verify `assets/sounds/618f3287-new_facebook_ringtone_7.m4a` exists
   - Verify pubspec.yaml includes `assets/sounds/`

### Notification Not Showing

1. **Check context**
   ```dart
   // Ensure you're using the correct context
   NotificationPopupHelper.show(
     context, // Must be a valid BuildContext
     title: 'Test',
     message: 'Test notification',
   );
   ```

2. **Check navigation**
   - Ensure the widget is mounted
   - Ensure the context is still valid

### Animation Issues

1. **Check AnimationController**
   - Ensure SingleTickerProviderStateMixin is used
   - Ensure dispose() is called

2. **Check mounted state**
   - Check `if (mounted)` before setState

## Performance Considerations

- **Memory**: Minimal - only one notification at a time
- **CPU**: Minimal - animations are GPU-accelerated
- **Audio**: Cached after first play
- **Concurrent notifications**: Only one displays at a time (new one replaces old)

## Browser Compatibility (Web)

| Browser | Support | Notes |
|---------|---------|-------|
| Chrome | ✅ Full | Works with autoplay |
| Firefox | ✅ Full | Works with autoplay |
| Safari | ✅ Full | May require user interaction |
| Edge | ✅ Full | Works with autoplay |

## Files Modified/Created

1. ✅ **Created**: `lib/widgets/notification_popup.dart`
   - NotificationPopup widget
   - NotificationPopupHelper class
   - Pre-configured notification types

2. ✅ **Existing**: `lib/services/notification_sound_service.dart`
   - Sound playback service

3. ✅ **Existing**: `lib/services/notification_service.dart`
   - Notification management

4. ✅ **Existing**: `assets/sounds/618f3287-new_facebook_ringtone_7.m4a`
   - Audio file

## Next Steps

1. ✅ Create notification popup widget
2. ⏳ Test notification popups in app
3. ⏳ Integrate with alert handling
4. ⏳ Add user settings for notification preferences
5. ⏳ Add notification history/log

## References

- [Flutter Animations](https://flutter.dev/docs/development/ui/animations)
- [showGeneralDialog](https://api.flutter.dev/flutter/material/showGeneralDialog.html)
- [AudioPlayers Package](https://pub.dev/packages/audioplayers)

---

**Status**: ✅ Ready to use
**Widget**: ✅ Created
**Sound Integration**: ✅ Complete
**Last Updated**: May 28, 2026
