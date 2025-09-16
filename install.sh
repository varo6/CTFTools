#!/bin/bash

# CTF Tools Global Installer
# This script installs CTF Tools system-wide so it can be run from any directory

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="/opt/ctftools"
BIN_DIR="/usr/local/bin"
CONFIG_DIR="/etc/ctftools"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root (use sudo)${NC}"
    echo -e "${YELLOW}Please run: sudo $0${NC}"
    exit 1
fi

# Show banner
echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}       CTF Tools Global Installation          ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create installation directories
echo -e "${YELLOW}Creating installation directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"

# Copy all files from the current directory to the installation directory
echo -e "${YELLOW}Copying files to $INSTALL_DIR...${NC}"
cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"

# Create the main executable script
echo -e "${YELLOW}Creating global executable...${NC}"
cat > "$BIN_DIR/ctftools" << 'EOF'
#!/bin/bash

# CTF Tools executable wrapper
if [ -f "/opt/ctftools/setup.sh" ]; then
    cd /opt/ctftools && bash setup.sh "$@"
else
    echo -e "\033[0;31mError: CTF Tools installation not found\033[0m"
    exit 1
fi
EOF

# Make the executable script executable
chmod +x "$BIN_DIR/ctftools"

# Create configuration symlinks
echo -e "${YELLOW}Setting up configuration...${NC}"
if [ -f "$INSTALL_DIR/apps.json" ]; then
    ln -sf "$INSTALL_DIR/apps.json" "$CONFIG_DIR/apps.json"
fi
if [ -f "$INSTALL_DIR/version" ]; then
    ln -sf "$INSTALL_DIR/version" "$CONFIG_DIR/version"
fi

# Create directory symlinks
for dir in scripts core_functions menu_system; do
    if [ -d "$INSTALL_DIR/$dir" ]; then
        ln -sf "$INSTALL_DIR/$dir" "$CONFIG_DIR/$dir"
    fi
done

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${CYAN}You can now run CTF Tools from any directory by typing:${NC} ctftools"
echo ""
echo -e "${YELLOW}Example usage:${NC}"
echo -e "  ctftools                    ${GREEN}# Launch the main CTF Tools menu${NC}"
echo -e "  ctftools --no-update-check  ${GREEN}# Launch without checking for updates${NC}"
