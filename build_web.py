#!/usr/bin/env python3
"""
Build script for web platform
Removes firebase_messaging from pubspec.yaml before building for web
"""

import os
import sys
import subprocess
import shutil
import re

def remove_firebase_messaging(pubspec_path):
    """Remove firebase_messaging from pubspec.yaml"""
    with open(pubspec_path, 'r') as f:
        content = f.read()
    
    # Remove firebase_messaging and its configuration
    # Match: firebase_messaging: ^14.6.0 or firebase_messaging: \n    version: ...
    pattern = r'  firebase_messaging:.*?(?=\n  [a-z_]+:|$)'
    content = re.sub(pattern, '', content, flags=re.DOTALL)
    
    with open(pubspec_path, 'w') as f:
        f.write(content)
    
    print("✓ Removed firebase_messaging from pubspec.yaml")

def restore_pubspec(pubspec_path, backup_path):
    """Restore original pubspec.yaml"""
    shutil.copy(backup_path, pubspec_path)
    print("✓ Restored original pubspec.yaml")

def run_command(cmd, description):
    """Run a shell command"""
    print(f"\n→ {description}...")
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        print(f"✗ {description} failed!")
        sys.exit(1)
    print(f"✓ {description} completed")

def main():
    print("Building Safe Mother Malawi for Web...\n")
    
    pubspec_path = "pubspec.yaml"
    backup_path = "pubspec.yaml.bak"
    
    try:
        # Install Flutter if not already installed
        if not os.path.exists("flutter/bin/flutter"):
            run_command(
                "git clone https://github.com/flutter/flutter.git -b stable --depth 1",
                "Cloning Flutter"
            )
            run_command(
                "flutter/bin/flutter config --no-analytics",
                "Configuring Flutter"
            )
        
        # Backup original pubspec.yaml
        shutil.copy(pubspec_path, backup_path)
        print("✓ Backed up pubspec.yaml")
        
        # Remove firebase_messaging
        remove_firebase_messaging(pubspec_path)
        
        # Run flutter pub get
        run_command("flutter/bin/flutter pub get", "Flutter pub get")
        
        # Build for web
        run_command(
            "flutter/bin/flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true",
            "Flutter web build"
        )
        
        print("\n✓ Web build completed successfully!")
        
    except Exception as e:
        print(f"\n✗ Error: {e}")
        sys.exit(1)
    finally:
        # Always restore original pubspec.yaml
        if os.path.exists(backup_path):
            restore_pubspec(pubspec_path, backup_path)
            os.remove(backup_path)

if __name__ == "__main__":
    main()
