#!/bin/bash
set -e

echo "Building Safe Mother Malawi for Web..."

# Backup pubspec.yaml
cp pubspec.yaml pubspec.yaml.bak

# Remove firebase_messaging from pubspec.yaml using sed
# This removes the line "firebase_messaging: ^14.6.0" or the entire firebase_messaging block
sed -i '/^  firebase_messaging:/,/^  [a-z]/{ /^  [a-z]/!d; }' pubspec.yaml

# Run flutter pub get
flutter/bin/flutter pub get

# Build for web
flutter/bin/flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true

# Restore pubspec.yaml
mv pubspec.yaml.bak pubspec.yaml

echo "✓ Web build completed successfully!"
