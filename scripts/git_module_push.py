#!/usr/bin/env python3
"""
Git Module Push Script
Automatically routes commits to the correct branch based on changed files
Usage: python3 scripts/git_module_push.py
"""

import json
import subprocess
import sys
from pathlib import Path
from typing import List, Dict, Set

# Colors for output
class Colors:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'

def print_info(msg: str):
    print(f"{Colors.BLUE}ℹ{Colors.END} {msg}")

def print_success(msg: str):
    print(f"{Colors.GREEN}✓{Colors.END} {msg}")

def print_warning(msg: str):
    print(f"{Colors.YELLOW}⚠{Colors.END} {msg}")

def print_error(msg: str):
    print(f"{Colors.RED}✗{Colors.END} {msg}")

def run_command(cmd: List[str], check: bool = True) -> str:
    """Run a shell command and return output"""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=check)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print_error(f"Command failed: {' '.join(cmd)}")
        print_error(f"Error: {e.stderr}")
        if check:
            sys.exit(1)
        return ""

def get_changed_files() -> Set[str]:
    """Get list of changed files"""
    print_info("Detecting changed files...")
    
    # Try to get files changed in last commit
    files = run_command(['git', 'diff', '--name-only', 'HEAD~1', 'HEAD'], check=False)
    
    # If that fails, get staged files
    if not files:
        files = run_command(['git', 'diff', '--name-only', '--cached'], check=False)
    
    # If still nothing, get all modified files
    if not files:
        files = run_command(['git', 'status', '--porcelain'], check=False)
        files = '\n'.join([line[3:] for line in files.split('\n') if line])
    
    changed_files = set(f.strip() for f in files.split('\n') if f.strip())
    return changed_files

def load_config(config_file: str) -> Dict:
    """Load module configuration"""
    try:
        with open(config_file, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print_error(f"Config file not found: {config_file}")
        sys.exit(1)
    except json.JSONDecodeError:
        print_error(f"Invalid JSON in config file: {config_file}")
        sys.exit(1)

def detect_modules(changed_files: Set[str], config: Dict) -> Set[str]:
    """Detect which modules were changed"""
    modules_changed = set()
    
    for module, paths in config.get('paths', {}).items():
        for path_pattern in paths:
            # Convert glob pattern to simple prefix matching
            prefix = path_pattern.replace('/**', '').replace('*', '')
            
            for file in changed_files:
                if file.startswith(prefix):
                    modules_changed.add(module)
                    break
    
    return modules_changed

def push_module(module: str, config: Dict):
    """Push changes for a specific module"""
    print_info(f"Processing module: {module}")
    
    module_config = config['modules'].get(module)
    if not module_config:
        print_error(f"Module config not found: {module}")
        return False
    
    branch = module_config['branch']
    author = module_config['author']
    email = module_config['email']
    description = module_config['description']
    
    print_info(f"Branch: {branch}")
    print_info(f"Author: {author} <{email}>")
    print_info(f"Description: {description}")
    
    # Check if branch exists
    branches = run_command(['git', 'branch', '-a'], check=False)
    branch_exists = any(branch in line for line in branches.split('\n'))
    
    if not branch_exists:
        print_warning(f"Branch does not exist: {branch}, creating...")
        run_command(['git', 'branch', branch])
        print_success(f"Created branch: {branch}")
    else:
        print_success(f"Branch exists: {branch}")
    
    # Checkout branch
    print_info(f"Checking out branch: {branch}")
    run_command(['git', 'checkout', branch])
    
    # Set git config for this branch
    print_info(f"Setting git config for branch: {branch}")
    run_command(['git', 'config', 'user.name', author])
    run_command(['git', 'config', 'user.email', email])
    
    # Pull latest changes
    print_info(f"Pulling latest changes from origin/{branch}")
    run_command(['git', 'pull', 'origin', branch, '--no-edit'], check=False)
    
    # Push to remote
    print_info(f"Pushing to origin/{branch}")
    run_command(['git', 'push', '-u', 'origin', branch])
    
    print_success(f"Module {module} pushed to {branch}")
    print()
    
    return True

def main():
    """Main function"""
    print_info("Git Module Push Script")
    print()
    
    # Load configuration
    config_file = '.git-module-config.json'
    config = load_config(config_file)
    
    # Get changed files
    changed_files = get_changed_files()
    
    if not changed_files:
        print_warning("No changed files detected")
        return
    
    print_success(f"Found {len(changed_files)} changed file(s):")
    for file in sorted(changed_files):
        print(f"  {file}")
    print()
    
    # Detect modules
    modules_changed = detect_modules(changed_files, config)
    
    if not modules_changed:
        print_warning("No module-specific changes detected")
        return
    
    print_success(f"Modules changed: {', '.join(sorted(modules_changed))}")
    print()
    
    # Process each module
    for module in sorted(modules_changed):
        try:
            push_module(module, config)
        except Exception as e:
            print_error(f"Error processing module {module}: {e}")
            continue
    
    print_success("All modules processed successfully!")

if __name__ == '__main__':
    main()
