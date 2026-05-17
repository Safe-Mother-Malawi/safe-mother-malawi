@echo off
REM Simple SafeMother Malawi Mobile Build Script

echo 🚀 Building SafeMother Malawi Mobile App (Simple Build)...

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Build debug APK first (faster, for testing)
echo 🔨 Building debug APK...
flutter build apk --debug --target=lib/main_mobile.dart

REM If debug works, build release
if %ERRORLEVEL% EQU 0 (
    echo ✅ Debug build successful! Now building release...
    echo 🔨 Building release APK...
    flutter build apk --release --target=lib/main_mobile.dart
) else (
    echo ❌ Debug build failed. Check errors above.
    pause
    exit /b 1
)

echo ✅ Build complete!
echo 📁 APK files location: build\app\outputs\flutter-apk\

REM Show file sizes
echo 📊 APK Files:
for %%f in (build\app\outputs\flutter-apk\*.apk) do (
    set /a size=%%~zf/1048576
    echo   %%~nxf: %%~zf bytes (~!size! MB)
)

echo.
echo 💡 To reduce APK size further:
echo   1. Use App Bundle for Play Store: flutter build appbundle --release
echo   2. Split by architecture: flutter build apk --split-per-abi --release
echo   3. Remove unused dependencies from pubspec.yaml

pause