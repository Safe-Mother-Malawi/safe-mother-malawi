@echo off
echo 🏗️ Building SafeMother Malawi APK (Simple Build)...
echo.

echo 📱 Building universal APK...
flutter build apk --release --no-tree-shake-icons

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Build failed! Trying alternative approach...
    echo.
    echo 🔧 Cleaning and retrying...
    flutter clean
    flutter pub get
    flutter build apk --release --no-tree-shake-icons --no-shrink
)

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ APK built successfully!
    echo 📁 Location: build\app\outputs\flutter-apk\app-release.apk
    
    echo.
    echo 📊 APK Information:
    dir build\app\outputs\flutter-apk\app-release.apk
) else (
    echo.
    echo ❌ Build failed. Please check the error messages above.
    echo 💡 Try running: flutter doctor -v
)

echo.
pause