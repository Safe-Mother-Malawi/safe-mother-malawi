#!/bin/bash

# Git Module Push Script
# Automatically routes commits to the correct branch based on changed files
# Usage: ./scripts/git-module-push.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE=".git-module-config.json"

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    print_error "Config file not found: $CONFIG_FILE"
    exit 1
fi

# Get changed files
print_info "Detecting changed files..."
CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || git diff --name-only --cached)

if [ -z "$CHANGED_FILES" ]; then
    print_warning "No changed files detected"
    exit 0
fi

print_info "Changed files:"
echo "$CHANGED_FILES" | sed 's/^/  /'

# Determine which modules were changed
MODULES_CHANGED=()

# Check prenatal
if echo "$CHANGED_FILES" | grep -qE "lib/mobile/prenatal/|lib/mobile/auth/screens/signup_screen.dart"; then
    MODULES_CHANGED+=("prenatal")
fi

# Check neonatal
if echo "$CHANGED_FILES" | grep -qE "lib/mobile/neonatal/|lib/mobile/auth/screens/neonatal_signup_screen.dart"; then
    MODULES_CHANGED+=("neonatal")
fi

# Check clinician
if echo "$CHANGED_FILES" | grep -qE "lib/screens/clinician/|lib/web/clinician/"; then
    MODULES_CHANGED+=("clinician")
fi

# Check admin
if echo "$CHANGED_FILES" | grep -qE "lib/web/admin/|backend/backend/src/"; then
    MODULES_CHANGED+=("admin")
fi

# Check dho
if echo "$CHANGED_FILES" | grep -qE "lib/web/dho/|backend/backend/src/"; then
    MODULES_CHANGED+=("dho")
fi

if [ ${#MODULES_CHANGED[@]} -eq 0 ]; then
    print_warning "No module-specific changes detected"
    exit 0
fi

print_success "Modules changed: ${MODULES_CHANGED[*]}"

# Process each module
for module in "${MODULES_CHANGED[@]}"; do
    print_info "Processing module: $module"
    
    # Extract module config
    BRANCH=$(echo "$CONFIG_FILE" | jq -r ".modules.$module.branch")
    AUTHOR=$(echo "$CONFIG_FILE" | jq -r ".modules.$module.author")
    EMAIL=$(echo "$CONFIG_FILE" | jq -r ".modules.$module.email")
    DESCRIPTION=$(echo "$CONFIG_FILE" | jq -r ".modules.$module.description")
    
    print_info "Branch: $BRANCH"
    print_info "Author: $AUTHOR <$EMAIL>"
    print_info "Description: $DESCRIPTION"
    
    # Check if branch exists
    if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
        print_success "Branch exists: $BRANCH"
    else
        print_warning "Branch does not exist: $BRANCH, creating..."
        git branch "$BRANCH"
        print_success "Created branch: $BRANCH"
    fi
    
    # Checkout branch
    print_info "Checking out branch: $BRANCH"
    git checkout "$BRANCH"
    
    # Set git config for this branch
    print_info "Setting git config for branch: $BRANCH"
    git config user.name "$AUTHOR"
    git config user.email "$EMAIL"
    
    # Cherry-pick or merge changes
    print_info "Pulling latest changes from origin/$BRANCH"
    git pull origin "$BRANCH" --no-edit || true
    
    # Push to remote
    print_info "Pushing to origin/$BRANCH"
    git push -u origin "$BRANCH"
    
    print_success "Module $module pushed to $BRANCH"
    echo ""
done

print_success "All modules processed successfully!"
