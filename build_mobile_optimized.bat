@echo off
REM SafeMother Malawi Mobile App Build Script - Optimized for Small APK Size

echo 🚀 Building SafeMother Malawi Mobile App (Optimized for Small Size)...

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Build optimized release APK with size optimizations
echo 🔨 Building optimized release APK...
flutter build apk --release ^
  --target=lib/main_mobile.dart ^
  --split-per-abi ^
  --tree-shake-icons ^
  --shrink ^
  --obfuscate ^
  --split-debug-info=build/debug-info

REM Build App Bundle for Play Store (smaller than APK)
echo 📱 Building optimized App Bundle...
flutter build appbundle --release ^
  --target=lib/main_mobile.dart ^
  --tree-shake-icons ^
  --shrink ^
  --obfuscate ^
  --split-debug-info=build/debug-info

echo ✅ Build complete!
echo 📁 APK files location: build\app\outputs\flutter-apk\
echo 📁 App Bundle location: build\app\outputs\bundle\release\

REM Show file sizes
echo 📊 APK Sizes:
for %%f in (build\app\outputs\flutter-apk\*.apk) do (
    echo   %%~nxf: %%~zf bytes ^(%%~zf / 1048576 MB^)
)

echo.
echo 💡 Size Optimization Tips Applied:
echo   ✅ Split APKs by ABI (arm64-v8a, armeabi-v7a)
echo   ✅ Tree-shake unused icons
echo   ✅ Code shrinking enabled
echo   ✅ Code obfuscation enabled
echo   ✅ ProGuard optimization
echo   ✅ Debug info separated
echo.
echo 📱 Recommended: Use App Bundle (.aab) for Play Store - it's smaller!

pause