#!/bin/bash

# SafeMother Malawi Mobile App Build Script
echo "🚀 Building SafeMother Malawi Mobile App..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate app icons
echo "🎨 Generating app icons..."
flutter pub run flutter_launcher_icons

# Build mobile APK (debug)
echo "🔨 Building mobile debug APK..."
flutter build apk --debug -t lib/main_mobile.dart

# Build mobile APK (release)
echo "🔨 Building mobile release APK..."
flutter build apk --release -t lib/main_mobile.dart

# Build App Bundle for Play Store
echo "📱 Building App Bundle for Play Store..."
flutter build appbundle --release -t lib/main_mobile.dart

echo "✅ Build complete!"
echo "📁 APK files location: build/app/outputs/flutter-apk/"
echo "📁 App Bundle location: build/app/outputs/bundle/release/"

# List generated files
echo "📋 Generated files:"
ls -la build/app/outputs/flutter-apk/ 2>/dev/null || echo "APK directory not found"
ls -la build/app/outputs/bundle/release/ 2>/dev/null || echo "Bundle directory not found"