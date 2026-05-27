#!/usr/bin/env python3
"""Remove firebase_messaging from pubspec.yaml"""
import re
import sys

try:
    with open('pubspec.yaml', 'r') as f:
        content = f.read()
    
    # Remove firebase_messaging and its configuration
    pattern = r'  firebase_messaging:.*?(?=\n  [a-z_]+:|$)'
    content = re.sub(pattern, '', content, flags=re.DOTALL)
    
    with open('pubspec.yaml', 'w') as f:
        f.write(content)
    
    print("✓ Removed firebase_messaging from pubspec.yaml")
    sys.exit(0)
except Exception as e:
    print(f"✗ Error: {e}")
    sys.exit(1)
