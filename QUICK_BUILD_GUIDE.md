# Quick Build Guide - Mobile App Testing

## 🚀 Quick Start (5 minutes)

### Prerequisites
- ✅ Flutter SDK installed
- ✅ Android device connected via USB
- ✅ USB Debugging enabled on device

### Build & Run

**Option 1: Using Build Script (Recommended)**

**Windows:**
```bash
BUILD_MOBILE.bat
# Select option 1 for Debug build
```

**macOS/Linux:**
```bash
chmod +x BUILD_MOBILE.sh
./BUILD_MOBILE.sh
# Select option 1 for Debug build
```

**Option 2: Manual Build**

```bash
cd safemothermalawi/safe-mother-malawi

# Prepare
flutter clean
flutter pub get

# Build and run
flutter run
```

## ✅ What to Expect

1. **Build Process** (2-5 minutes)
   - Compiling Dart code
   - Building APK
   - Installing on device
   - Launching app

2. **App Launch**
   - Splash screen appears
   - Login screen loads
   - App is ready for testing

## 🧪 Quick Testing

### Test 1: Navigation (1 minute)
- [ ] Tap hamburger menu (☰)
- [ ] Drawer opens from left
- [ ] Tap "Overview"
- [ ] Drawer closes
- [ ] Page updates

### Test 2: Notifications (1 minute)
- [ ] Tap bell icon (🔔)
- [ ] Notification dialog opens
- [ ] Tap "Mark all read"
- [ ] Close dialog

### Test 3: Profile (1 minute)
- [ ] Tap profile icon (👤)
- [ ] Profile dialog opens
- [ ] View user information
- [ ] Close dialog

### Test 4: Responsive Design (2 minutes)
- [ ] Rotate device to landscape
- [ ] Layout adapts correctly
- [ ] All buttons are accessible
- [ ] No horizontal scrolling

## 📱 Device Requirements

| Requirement | Minimum | Recommended |
|------------|---------|-------------|
| Android Version | 8.0 (API 26) | 10+ (API 29+) |
| RAM | 2GB | 4GB+ |
| Storage | 100MB | 500MB+ |
| Screen Size | 4.5" | 5.5"+ |

## 🔧 Troubleshooting

### Device Not Found
```bash
# Restart ADB
adb kill-server
adb start-server

# Check devices
adb devices
```

### Build Fails
```bash
# Clean and retry
flutter clean
flutter pub get
flutter run -v
```

### App Crashes
```bash
# View logs
flutter logs

# Rebuild with verbose
flutter run -v
```

## 📊 Build Outputs

### Debug Build
- **Location:** `build/app/outputs/flutter-apk/app-debug.apk`
- **Size:** ~50-80MB
- **Use:** Testing and development

### Release Build
- **Location:** `build/app/outputs/flutter-apk/app-release.apk`
- **Size:** ~30-50MB
- **Use:** Production deployment

## 🎯 Testing Checklist

### Functionality
- [ ] App launches without crashes
- [ ] Login screen appears
- [ ] Navigation drawer works
- [ ] All pages load correctly
- [ ] Notifications display
- [ ] Profile dialog opens

### Responsive Design
- [ ] Mobile layout works (< 768px)
- [ ] Drawer opens/closes smoothly
- [ ] All buttons are accessible
- [ ] Text is readable
- [ ] No horizontal scrolling

### Performance
- [ ] App launches in < 3 seconds
- [ ] Navigation is smooth
- [ ] No lag or stuttering
- [ ] Memory usage is reasonable

## 📝 Useful Commands

```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run release build
flutter run --release

# View logs
flutter logs

# Hot reload (press 'r' in terminal)
# Hot restart (press 'R' in terminal)
# Stop app (press 'q' in terminal)
```

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| Device not recognized | Enable USB Debugging, restart ADB |
| Build fails | Run `flutter clean && flutter pub get` |
| App crashes | Check `flutter logs -v` for errors |
| Slow build | Increase RAM, close other apps |
| Firebase errors | Verify `google-services.json` exists |

## 📚 Full Documentation

For detailed information, see:
- `MOBILE_BUILD_TESTING_GUIDE.md` - Complete build and testing guide
- `RESPONSIVE_DESIGN_GUIDE.md` - Responsive design documentation
- `README.md` - Project overview

## 🎓 Next Steps

1. **Build the app** using the Quick Start section
2. **Test on your device** using the Quick Testing section
3. **Report issues** with logs from `flutter logs`
4. **Iterate** based on feedback

## 💡 Tips

- Keep USB cable connected during development
- Use `flutter run` for faster iteration
- Use `flutter run --release` for performance testing
- Check `flutter logs` for any errors
- Test on multiple devices if possible

## ⏱️ Estimated Times

| Task | Time |
|------|------|
| First build | 5-10 minutes |
| Subsequent builds | 2-5 minutes |
| Hot reload | < 1 second |
| Full rebuild | 3-5 minutes |

---

**Ready to build?** Start with the Quick Start section above! 🚀
