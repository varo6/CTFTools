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
SCRIPTS_DIR="$AUTOSETUP_DIR/scripts"

# Check if running as root, if not, re-run with sudo or exit
check_root() {
  if [[ $EUID -ne 0 ]]; then
    if [ -t 0 ]; then
      # Script is run directly
      echo -e "${YELLOW}This script needs root privileges. Re-running with sudo...${NC}"
      exec sudo "$0" "$@"
    else
      # Script is piped
      echo -e "${RED}This script must be run with root privileges.${NC}"
      echo -e "${YELLOW}Please run the command like this:${NC}"
      echo "curl -fsSL https://trustlab.upct.es/instalacionCTF | sudo bash"
      curl -fsSL https://trustlab.upct.es/CTFSetup | sudo bash
      exit 1
    fi
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

# Download scripts
download_scripts() {
  echo -e "${YELLOW}Downloading scripts...${NC}"
  mkdir -p "$SCRIPTS_DIR"
  # Download each script individually
  for script in gef.sh neovim.sh pwndbg.sh pwntools.sh ROPgadget.sh edit.sh; do
    echo "Downloading $script..."
    curl -fsSL "$REPO_URL/scripts/$script" -o "$SCRIPTS_DIR/$script"
    if [[ $? -ne 0 ]]; then
      echo -e "${RED}Failed to download $script.${NC}"
      exit 1
    fi
    chmod +x "$SCRIPTS_DIR/$script"
  done
}

# Modify and install autosetup script
install_script() {
  echo -e "${YELLOW}Installing autosetup script to $INSTALL_PATH...${NC}"

  # Modify the script to use the new apps.json path
  sed 's|local json_file="apps.json"|local json_file="'"$APPS_JSON_PATH"'"|' "/tmp/autosetup_temp" > "$INSTALL_PATH"

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

  # Modify the apps.json to use the new scripts path
  sed -i "s|scripts/|$SCRIPTS_DIR/|g" "$APPS_JSON_PATH"
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Failed to modify the apps.json.${NC}"
    exit 1
  fi
}

# Main function
main() {
  check_root

  echo -e "${YELLOW}Installing dependencies...${NC}"
  apt install -y jq
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Failed to install jq. Please install it manually.${NC}"
    exit 1
  fi

  create_dir
  download_files
  download_scripts
  install_script

  echo -e "${GREEN}autosetup installed successfully!${NC}"
  echo -e "${YELLOW}Run 'autosetup' to start the tool installer.${NC}"
}

main
