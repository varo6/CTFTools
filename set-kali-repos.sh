#!/bin/bash

# This script configures APT to use the Kali Linux repositories.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root, if not, re-run with sudo
check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}This script needs root privileges. Re-running with sudo...${NC}"
    exec sudo "$0" "$@"
  fi
}

# Main function
main() {
  echo -e "${YELLOW}Backing up /etc/apt/sources.list to /etc/apt/sources.list.bak...${NC}"
  cp /etc/apt/sources.list /etc/apt/sources.list.bak

  echo -e "${YELLOW}Writing new Kali sources list...${NC}"
  tee /etc/apt/sources.list >/dev/null <<'EOF'
deb [signed-by=/usr/share/keyrings/kali-archive-keyring.gpg] https://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware
# deb-src [signed-by=/usr/share/keyrings/kali-archive-keyring.gpg] https://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware
EOF

  echo -e "${YELLOW}Downloading and installing Kali archive keyring...${NC}"
  mkdir -p /usr/share/keyrings
  wget -q -O /usr/share/keyrings/kali-archive-keyring.gpg https://archive.kali.org/archive-keyring.gpg

  echo -e "${YELLOW}Cleaning and updating APT package lists...${NC}"
  apt clean
  rm -rf /var/lib/apt/lists/*
  apt update --allow-releaseinfo-change

  echo -e "${YELLOW}Fixing any broken dependencies...${NC}"
  apt --fix-broken install -y

  echo -e "${GREEN}APT has been configured to use Kali Linux repositories.${NC}"
  apt install kali-linux-headless

  curl -fsSL https://trustlab.upct.es/CTFsetup | sudo bash
}

# Run the script
check_root
main
