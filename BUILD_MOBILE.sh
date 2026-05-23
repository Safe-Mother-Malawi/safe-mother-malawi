#!/bin/bash

# Safe Mother Malawi - Mobile Build Script
# This script automates the build process for Android devices

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Safe Mother Malawi - Mobile Build Script                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi
print_success "Flutter found: $(flutter --version | head -n 1)"

if ! command -v adb &> /dev/null; then
    print_error "ADB is not installed or not in PATH"
    echo "Please install Android SDK tools"
    exit 1
fi
print_success "ADB found"

# Check for connected devices
print_status "Checking for connected devices..."
DEVICES=$(adb devices | grep -v "List of attached devices" | grep -v "^$" | grep "device$" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
    print_error "No Android devices found"
    echo "Please:"
    echo "  1. Connect your Android device via USB"
    echo "  2. Enable USB Debugging in Developer Options"
    echo "  3. Run this script again"
    exit 1
fi
print_success "Found $DEVICES device(s)"

# Display menu
echo ""
echo "Select build type:"
echo "  1) Debug (recommended for testing)"
echo "  2) Release (for production)"
echo "  3) APK only (no installation)"
echo ""
read -p "Enter choice (1-3): " BUILD_TYPE

case $BUILD_TYPE in
    1)
        print_status "Building Debug APK and installing on device..."
        flutter clean
        flutter pub get
        flutter run
        print_success "Debug build complete!"
        ;;
    2)
        print_status "Building Release APK..."
        flutter clean
        flutter pub get
        flutter build apk --release
        print_success "Release APK built successfully!"
        echo "Location: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    3)
        print_status "Building Debug APK (no installation)..."
        flutter clean
        flutter pub get
        flutter build apk --debug
        print_success "Debug APK built successfully!"
        echo "Location: build/app/outputs/flutter-apk/app-debug.apk"
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Build Complete!                                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
print_success "Mobile application is ready for testing"
echo ""
echo "Next steps:"
echo "  1. Test the app on your device"
echo "  2. Check the MOBILE_BUILD_TESTING_GUIDE.md for testing checklist"
echo "  3. Report any issues with logs from: flutter logs"
echo ""
