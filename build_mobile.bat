@echo off
REM SafeMother Malawi Mobile App Build Script for Windows

echo 🚀 Building SafeMother Malawi Mobile App...

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Generate app icons
echo 🎨 Generating app icons...
flutter pub run flutter_launcher_icons

REM Build mobile APK (debug)
echo 🔨 Building mobile debug APK...
flutter build apk --debug -t lib/main_mobile.dart

REM Build mobile APK (release)
echo 🔨 Building mobile release APK...
flutter build apk --release -t lib/main_mobile.dart

REM Build App Bundle for Play Store
echo 📱 Building App Bundle for Play Store...
flutter build appbundle --release -t lib/main_mobile.dart

echo ✅ Build complete!
echo 📁 APK files location: build\app\outputs\flutter-apk\
echo 📁 App Bundle location: build\app\outputs\bundle\release\

REM List generated files
echo 📋 Generated files:
dir build\app\outputs\flutter-apk\ 2>nul || echo APK directory not found
dir build\app\outputs\bundle\release\ 2>nul || echo Bundle directory not found

pause