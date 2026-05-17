# SafeMother Malawi - Build Troubleshooting Guide

## 🚨 Current Issue: Flutter Engine Artifacts Missing

The build is failing because Flutter engine artifacts are not available in the cache. This is likely due to the custom cache configuration.

## 🔧 Quick Fix Solutions

### Solution 1: Reset Flutter Cache (Recommended)

```bash
# Remove custom cache environment variable
set FLUTTER_STORAGE_BASE_URL=

# Clear Flutter cache
flutter clean
flutter pub cache clean
flutter pub get

# Try building again
flutter build apk --release --target=lib/main_mobile.dart
```

### Solution 2: Use Default Flutter Cache

1. **Remove custom cache setting** from environment variables
2. **Delete the custom cache folder**: `D:\flutter-cache`
3. **Let Flutter use default cache location**

### Solution 3: Fix Cache URL

```bash
# Set proper cache URL (if you want to keep custom cache)
set FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com

# Or remove it entirely
set FLUTTER_STORAGE_BASE_URL=
```

## 🎯 Simplified Build Process

### Step 1: Basic Build (No Optimizations)
```bash
flutter clean
flutter pub get
flutter build apk --release --target=lib/main_mobile.dart
```

### Step 2: Add Size Optimizations (After Basic Works)
```bash
flutter build apk --release --target=lib/main_mobile.dart --tree-shake-icons
```

### Step 3: Split APKs (Smallest Size)
```bash
flutter build apk --release --target=lib/main_mobile.dart --split-per-abi --tree-shake-icons
```

### Step 4: App Bundle (Play Store)
```bash
flutter build appbundle --release --target=lib/main_mobile.dart --tree-shake-icons
```

## 📱 Expected APK Sizes

| Build Type | Size Range | Notes |
|------------|------------|-------|
| Debug APK | 40-60 MB | Development only |
| Release APK | 20-30 MB | Single universal APK |
| Split APKs | 12-18 MB each | arm64-v8a, armeabi-v7a |
| App Bundle | 10-15 MB | Play Store optimized |

## 🔍 Alternative Build Methods

### Method 1: Android Studio
1. Open `android/` folder in Android Studio
2. Build → Generate Signed Bundle/APK
3. Choose APK or Bundle
4. Select release configuration

### Method 2: Gradle Direct
```bash
cd android
./gradlew assembleRelease
```

### Method 3: Web Build (Fallback)
```bash
flutter build web --target=lib/main.dart
```

## 🛠️ Environment Fixes

### Fix Android Toolchain
```bash
flutter doctor --android-licenses
```

### Fix Flutter Storage
```bash
# Remove custom storage setting
set FLUTTER_STORAGE_BASE_URL=

# Verify fix
flutter doctor
```

### Update Flutter (If Needed)
```bash
flutter upgrade
flutter doctor
```

## 📋 Pre-Build Checklist

- [ ] Flutter doctor shows no critical issues
- [ ] Android SDK properly configured
- [ ] No custom FLUTTER_STORAGE_BASE_URL set
- [ ] Internet connection available
- [ ] Sufficient disk space (5GB+)

## 🎉 Success Indicators

When build succeeds, you'll see:
```
✓ Built build/app/outputs/flutter-apk/app-release.apk (XX.X MB)
```

## 🚀 Quick Start Script

Use this if all else fails:

```batch
@echo off
echo Resetting Flutter environment...
set FLUTTER_STORAGE_BASE_URL=
flutter clean
flutter pub cache clean
flutter pub get
echo Building APK...
flutter build apk --release --target=lib/main_mobile.dart
echo Done! Check build/app/outputs/flutter-apk/
```

## 📞 Need Help?

If build still fails:
1. **Check Flutter version**: `flutter --version`
2. **Run Flutter doctor**: `flutter doctor -v`
3. **Check disk space**: Ensure 5GB+ available
4. **Try web build**: `flutter build web` (as fallback)

The SafeMother Malawi app should build successfully once the Flutter cache issue is resolved! 🎯