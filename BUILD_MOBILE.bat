@echo off
REM Safe Mother Malawi - Mobile Build Script for Windows
REM This script automates the build process for Android devices

setlocal enabledelayedexpansion

echo.
echo ============================================================
echo   Safe Mother Malawi - Mobile Build Script
echo ============================================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo [OK] Flutter found
flutter --version

REM Check if ADB is installed
adb version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] ADB is not installed or not in PATH
    echo Please install Android SDK tools
    pause
    exit /b 1
)

echo [OK] ADB found

REM Check for connected devices
echo.
echo Checking for connected devices...
for /f "tokens=*" %%A in ('adb devices ^| find "device" ^| find /v "List"') do (
    set "DEVICE_LINE=%%A"
)

if "!DEVICE_LINE!"=="" (
    echo [ERROR] No Android devices found
    echo Please:
    echo   1. Connect your Android device via USB
    echo   2. Enable USB Debugging in Developer Options
    echo   3. Run this script again
    pause
    exit /b 1
)

echo [OK] Device found: !DEVICE_LINE!

REM Display menu
echo.
echo Select build type:
echo   1) Debug (recommended for testing)
echo   2) Release (for production)
echo   3) APK only (no installation)
echo.
set /p BUILD_TYPE="Enter choice (1-3): "

if "%BUILD_TYPE%"=="1" (
    echo.
    echo Building Debug APK and installing on device...
    call flutter clean
    call flutter pub get
    call flutter run
    echo.
    echo [OK] Debug build complete!
) else if "%BUILD_TYPE%"=="2" (
    echo.
    echo Building Release APK...
    call flutter clean
    call flutter pub get
    call flutter build apk --release
    echo.
    echo [OK] Release APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
) else if "%BUILD_TYPE%"=="3" (
    echo.
    echo Building Debug APK (no installation)...
    call flutter clean
    call flutter pub get
    call flutter build apk --debug
    echo.
    echo [OK] Debug APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-debug.apk
) else (
    echo [ERROR] Invalid choice
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   Build Complete!
echo ============================================================
echo.
echo [OK] Mobile application is ready for testing
echo.
echo Next steps:
echo   1. Test the app on your device
echo   2. Check the MOBILE_BUILD_TESTING_GUIDE.md for testing checklist
echo   3. Report any issues with logs from: flutter logs
echo.
pause
