# Mobile Application Build & Testing Guide

## Prerequisites

Before building the mobile application, ensure you have the following installed:

### 1. **Flutter SDK**
- Download from: https://flutter.dev/docs/get-started/install
- Add Flutter to your PATH
- Verify installation:
  ```bash
  flutter --version
  flutter doctor
  ```

### 2. **Android SDK & Tools**
- Install Android Studio from: https://developer.android.com/studio
- Install Android SDK (API level 26 or higher)
- Install Android Emulator or use a physical device
- Set ANDROID_HOME environment variable

### 3. **Physical Android Device**
- Android 8.0 (API 26) or higher
- USB cable for connection
- USB debugging enabled:
  1. Go to Settings → About Phone
  2. Tap Build Number 7 times to enable Developer Options
  3. Go to Settings → Developer Options
  4. Enable "USB Debugging"

### 4. **Git** (for version control)
- Already installed on your system

## Step-by-Step Build Instructions

### Step 1: Prepare the Project

```bash
# Navigate to the project directory
cd safemothermalawi/safe-mother-malawi

# Get all dependencies
flutter pub get

# Clean previous builds
flutter clean
```

### Step 2: Connect Your Android Device

```bash
# Connect your phone via USB cable

# Verify device is recognized
flutter devices

# You should see output like:
# Android (mobile) • emulator-5554 • android-x86 • Android 11 (API 30)
# or
# Android (mobile) • 192.168.1.100:5555 • android-arm64 • Android 12 (API 31)
```

### Step 3: Build for Debug (Recommended for Testing)

```bash
# Build and run on connected device
flutter run

# Or with verbose output for debugging
flutter run -v
```

**What this does:**
- Compiles the Dart code
- Builds the APK
- Installs on your device
- Launches the app
- Attaches debugger

### Step 4: Build for Release (Production)

```bash
# Build release APK
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk

# Or build App Bundle (for Google Play Store)
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

## Testing the Mobile App

### 1. **Basic Functionality Testing**

After the app launches on your device:

- [ ] **Login Screen**
  - [ ] App loads without errors
  - [ ] Login form is visible
  - [ ] Email and password fields work
  - [ ] Login button is clickable

- [ ] **Navigation**
  - [ ] Hamburger menu opens drawer
  - [ ] All navigation items are visible
  - [ ] Drawer closes after selecting an item
  - [ ] Page content updates correctly

- [ ] **Dashboard/Overview**
  - [ ] Page loads without errors
  - [ ] All widgets display correctly
  - [ ] Charts render properly
  - [ ] Data is visible

- [ ] **Notifications**
  - [ ] Notification bell shows badge count
  - [ ] Clicking bell opens notification dialog
  - [ ] Notifications are readable
  - [ ] Mark as read works
  - [ ] Refresh works

- [ ] **Profile**
  - [ ] Profile button opens dialog
  - [ ] User information displays
  - [ ] Logout button works
  - [ ] Dialog closes properly

### 2. **Responsive Design Testing**

- [ ] **Mobile Layout (< 768px)**
  - [ ] Drawer navigation works
  - [ ] Content is full-width
  - [ ] No horizontal scrolling
  - [ ] Buttons are touch-friendly
  - [ ] Text is readable

- [ ] **Orientation**
  - [ ] Portrait mode works
  - [ ] Landscape mode works (if supported)
  - [ ] Layout adapts correctly

### 3. **Performance Testing**

- [ ] **App Launch**
  - [ ] App starts within 3 seconds
  - [ ] No crashes on startup
  - [ ] Splash screen displays

- [ ] **Navigation**
  - [ ] Page transitions are smooth
  - [ ] No lag when opening drawer
  - [ ] No lag when switching pages

- [ ] **Memory Usage**
  - [ ] App doesn't consume excessive memory
  - [ ] No memory leaks after navigation
  - [ ] App remains responsive

### 4. **Network Testing**

- [ ] **API Connectivity**
  - [ ] App connects to backend API
  - [ ] Data loads correctly
  - [ ] Error handling works
  - [ ] Offline mode (if implemented)

- [ ] **Firebase Integration**
  - [ ] Firebase initializes correctly
  - [ ] Push notifications work (if enabled)
  - [ ] No Firebase errors in logs

### 5. **UI/UX Testing**

- [ ] **Visual Design**
  - [ ] Colors match design specs
  - [ ] Fonts are readable
  - [ ] Icons display correctly
  - [ ] Spacing is consistent

- [ ] **Accessibility**
  - [ ] Text is readable
  - [ ] Buttons are large enough
  - [ ] Colors have sufficient contrast
  - [ ] Touch targets are adequate

## Debugging

### View Logs

```bash
# View real-time logs
flutter logs

# Or with device filter
flutter logs -d <device-id>
```

### Common Issues and Solutions

#### Issue: Device not recognized
```bash
# Restart ADB
adb kill-server
adb start-server

# Check device connection
adb devices
```

#### Issue: Build fails with Gradle error
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### Issue: App crashes on startup
```bash
# Check logs
flutter logs -v

# Rebuild with verbose output
flutter run -v
```

#### Issue: Firebase errors
- Ensure `google-services.json` is in `android/app/`
- Check Firebase project configuration
- Verify API keys are correct

#### Issue: Permission errors
- Check `AndroidManifest.xml` for required permissions
- Grant permissions on device if prompted
- Check Android version compatibility

## Building APK for Distribution

### Debug APK (for testing)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (for production)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

## Installing APK Manually

```bash
# Install APK on device
adb install build/app/outputs/flutter-apk/app-debug.apk

# Or for release
adb install build/app/outputs/flutter-apk/app-release.apk

# Uninstall app
adb uninstall com.example.safemothermalawi_frontend
```

## Testing Checklist

### Pre-Build
- [ ] Flutter SDK installed and updated
- [ ] Android SDK installed
- [ ] Device connected and recognized
- [ ] USB debugging enabled
- [ ] Project dependencies updated (`flutter pub get`)

### Build
- [ ] Build completes without errors
- [ ] No warnings in build output
- [ ] APK size is reasonable (< 100MB)

### Installation
- [ ] APK installs successfully
- [ ] App launches without crashes
- [ ] No permission errors

### Functionality
- [ ] All screens load correctly
- [ ] Navigation works as expected
- [ ] Data displays properly
- [ ] No console errors

### Performance
- [ ] App is responsive
- [ ] No lag or stuttering
- [ ] Memory usage is reasonable
- [ ] Battery drain is acceptable

### Responsive Design
- [ ] Mobile layout works correctly
- [ ] Drawer opens/closes smoothly
- [ ] All navigation items accessible
- [ ] Content is readable on small screens

## Useful Commands

```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run with specific flavor
flutter run --flavor dev

# Build and run release
flutter run --release

# Hot reload (during development)
# Press 'r' in terminal

# Hot restart
# Press 'R' in terminal

# Stop app
# Press 'q' in terminal

# View device info
adb shell getprop ro.build.version.release

# Clear app data
adb shell pm clear com.example.safemothermalawi_frontend

# View app logs
adb logcat | grep flutter
```

## Project Structure

```
safemothermalawi/safe-mother-malawi/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/                  # Screen widgets
│   ├── services/                 # API and services
│   ├── theme/                    # Colors and styling
│   └── web/                      # Web-specific screens
├── android/
│   ├── app/
│   │   ├── build.gradle.kts      # App build config
│   │   └── google-services.json  # Firebase config
│   └── build.gradle.kts          # Project build config
├── pubspec.yaml                  # Dependencies
└── README.md                      # Project documentation
```

## Next Steps

1. **Build the app** using the instructions above
2. **Test on your device** using the testing checklist
3. **Report any issues** with detailed logs
4. **Iterate and improve** based on feedback

## Support

For issues or questions:
1. Check the Flutter documentation: https://flutter.dev/docs
2. Review the project README
3. Check git commit history for recent changes
4. Review logs with `flutter logs -v`

## Additional Resources

- Flutter Documentation: https://flutter.dev/docs
- Android Development: https://developer.android.com/docs
- Firebase Setup: https://firebase.google.com/docs
- Flutter Packages: https://pub.dev
