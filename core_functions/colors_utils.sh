#!/bin/bash

# Colors and Utility Functions Module
# This module provides color definitions and basic utility functions

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Version information
# Try to find the version file in different locations
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/../version" ]]; then
  CURRENT_VERSION=$(cat "$(dirname "${BASH_SOURCE[0]}")/../version")
elif [[ -f "/etc/autosetup/version" ]]; then
  CURRENT_VERSION=$(cat "/etc/autosetup/version")
else
  CURRENT_VERSION="1.1"  # Default version as fallback
fi
REPO_URL_FOR_VERSION="https://raw.githubusercontent.com/varo6/CTFTools/refs/heads/main/"

# Clear screen and show header
clear_screen() {
  clear
  echo -e "${BLUE}===============================================${NC}"
  echo -e "${BLUE}    Kali Linux Interactive Tool Installer${NC}"
  echo -e "${BLUE}===============================================${NC}"
  echo ""
}

# Clear screen with custom header
clear_screen_with_header() {
  local header="$1"
  clear
  echo -e "${BLUE}===============================================${NC}"
  echo -e "${BLUE}    $header${NC}"
  echo -e "${BLUE}===============================================${NC}"
  echo ""
}

# Check if running as root
check_root() {
  if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}This script should not be run as root!${NC}"
    echo -e "${YELLOW}Run as regular user, sudo will be used when needed.${NC}"
    exit 1
  fi
}

# Compare semantic versions (returns 0 if v1 >= v2, 1 if v1 < v2)
version_compare() {
  local v1="$1"
  local v2="$2"

  # Split versions into arrays
  IFS='.' read -ra V1 <<< "$v1"
  IFS='.' read -ra V2 <<< "$v2"

  # Compare each part
  for i in {0..2}; do
    local part1=${V1[i]:-0}
    local part2=${V2[i]:-0}

    if [[ $part1 -gt $part2 ]]; then
      return 0  # v1 is greater
    elif [[ $part1 -lt $part2 ]]; then
      return 1  # v1 is less
    fi
  done

  return 0  # versions are equal
}

# Check for updates
check_for_updates() {
  echo -e "${YELLOW}Checking for updates...${NC}"
  # The version file might have a newline, so we remove it
  LATEST_VERSION=$(curl -sSL "${REPO_URL_FOR_VERSION}version" | tr -d '\n')

  if [ -z "$LATEST_VERSION" ]; then
    echo -e "${RED}Could not check for updates. Please check your internet connection.${NC}"
    return
  fi

  # Only prompt for update if remote version is actually newer
  if ! version_compare "$CURRENT_VERSION" "$LATEST_VERSION"; then
    echo -e "${GREEN}A new version ($LATEST_VERSION) is available!${NC}"
    echo -e "${YELLOW}Current version: $CURRENT_VERSION${NC}"
    echo -e "${YELLOW}Would you like to update? (y/N)${NC}"
    read -r update_choice
    if [[ "$update_choice" =~ ^[Yy]$ ]]; then
      echo -e "${YELLOW}Updating...${NC}"
      # Re-run the installer
      curl -fsSL ${REPO_URL_FOR_VERSION}install.sh | sudo bash
      echo -e "${GREEN}Update complete! Please restart the tool.${NC}"
      exit 0
    fi
  else
    echo -e "${GREEN}You are running the latest version ($CURRENT_VERSION).${NC}"
    if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
      echo -e "${CYAN}Remote version: $LATEST_VERSION${NC}"
    fi
  fi
  sleep 0.3 # Give user time to read the message
}

# Update system packages
update_system() {
  echo -e "${YELLOW}Updating package lists...${NC}"
  sudo apt update
  echo -e "${GREEN}Package lists updated!${NC}"
  echo ""
}

# Pause function for user interaction
pause_for_user() {
  local message="${1:-Press Enter to continue...}"
  echo "$message"
  read -r
}

# Success message function
show_success() {
  local message="$1"
  echo -e "${GREEN}✓ $message${NC}"
}

# Error message function
show_error() {
  local message="$1"
  echo -e "${RED}✗ $message${NC}"
}

# Warning message function
show_warning() {
  local message="$1"
  echo -e "${YELLOW}⚠ $message${NC}"
}

# Info message function
show_info() {
  local message="$1"
  echo -e "${BLUE}ℹ $message${NC}"
}

# Print separator line
print_separator() {
  echo -e "${CYAN}===============================================${NC}"
}
