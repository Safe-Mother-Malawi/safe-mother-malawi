#!/usr/bin/env node
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🔨 Building Safe Mother Malawi for Web...');

try {
  // Check if Flutter is installed
  if (!fs.existsSync('flutter')) {
    console.log('📥 Installing Flutter...');
    execSync('git clone https://github.com/flutter/flutter.git -b stable --depth 1', { stdio: 'inherit' });
    execSync('flutter/bin/flutter config --no-analytics', { stdio: 'inherit' });
  }

  // Use web-specific pubspec.yaml
  console.log('📦 Using web-specific pubspec.yaml...');
  fs.copyFileSync('pubspec.yaml', 'pubspec.yaml.bak');
  fs.copyFileSync('pubspec_web.yaml', 'pubspec.yaml');

  // Run flutter pub get
  console.log('📦 Running flutter pub get...');
  execSync('flutter/bin/flutter pub get', { stdio: 'inherit' });

  // Build for web
  console.log('🌐 Building Flutter web app...');
  execSync('flutter/bin/flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true', { stdio: 'inherit' });

  // Restore original pubspec.yaml
  fs.copyFileSync('pubspec.yaml.bak', 'pubspec.yaml');
  fs.unlinkSync('pubspec.yaml.bak');

  console.log('✅ Web build completed successfully!');
  process.exit(0);
} catch (error) {
  console.error('❌ Build failed:', error.message);
  // Restore pubspec.yaml on error
  if (fs.existsSync('pubspec.yaml.bak')) {
    fs.copyFileSync('pubspec.yaml.bak', 'pubspec.yaml');
    fs.unlinkSync('pubspec.yaml.bak');
  }
  process.exit(1);
}
