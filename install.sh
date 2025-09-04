#!/bin/bash

# Installer for autosetup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://raw.githubusercontent.com/varo6/CTFTools/refs/heads/main/" # Replace with your actual repo URL
AUTOSETUP_DIR="/etc/autosetup"
AUTOSETUP_SCRIPT_URL="$REPO_URL/setup.sh"
APPS_JSON_URL="$REPO_URL/apps.json"
INSTALL_PATH="/usr/local/bin/autosetup"
APPS_JSON_PATH="$AUTOSETUP_DIR/apps.json"

# Check if running as root, if not, re-run with sudo
check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}This script needs root privileges. Re-running with sudo...${NC}"
    exec sudo "$0" "$@"
  fi
}

# Create autosetup directory
create_dir() {
  if [ ! -d "$AUTOSETUP_DIR" ]; then
    echo -e "${YELLOW}Creating directory $AUTOSETUP_DIR...${NC}"
    mkdir -p "$AUTOSETUP_DIR"
    if [[ $? -ne 0 ]]; then
      echo -e "${RED}Failed to create directory $AUTOSETUP_DIR. Please check permissions.${NC}"
      exit 1
    fi
  fi
}

# Download files
download_files() {
  echo -e "${YELLOW}Downloading autosetup script...${NC}"
  curl -fsSL "$AUTOSETUP_SCRIPT_URL" -o "/tmp/autosetup_temp"
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Failed to download autosetup script.${NC}"
    exit 1
  fi

  echo -e "${YELLOW}Downloading apps.json...${NC}"
  curl -fsSL "$APPS_JSON_URL" -o "$APPS_JSON_PATH"
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Failed to download apps.json.${NC}"
    exit 1
  fi
}

# Modify and install autosetup script
install_script() {
  echo -e "${YELLOW}Installing autosetup script to $INSTALL_PATH...${NC}"

  # Modify the script to use the new apps.json path
  sed 's|local json_file="apps.json"|local json_file="'"$APPS_JSON_PATH"'"|' "/tmp/autosetup_temp" >"$INSTALL_PATH"

  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Failed to modify and install the script.${NC}"
    exit 1
  fi

  chmod +x "$INSTALL_PATH"
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Failed to make the script executable.${NC}"
    exit 1
  fi

  rm "/tmp/autosetup_temp"
}

# Main function
main() {
  check_root
  create_dir
  download_files
  install_script

  echo -e "${GREEN}autosetup installed successfully!${NC}"
  echo -e "${YELLOW}Run 'autosetup' to start the tool installer.${NC}"
}

main
