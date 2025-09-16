#!/bin/bash

# CTF Tools (autosetup) Remote Installer
# This script downloads and installs the CTF Tools system globally
# Usage: curl -fsSL <url>/install.sh | bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/varo6/CTFTools"
INSTALL_DIR="/opt/autosetup"
BIN_DIR="/usr/local/bin"
CONFIG_DIR="/etc/autosetup"
TEMP_DIR=$(mktemp -d)

# Check if we need to re-run with sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}This script requires root privileges.${NC}"
    exec sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/varo6/CTFTools/refs/heads/main/install.sh)"
fi
# Cleanup function
cleanup() {
    echo -e "${YELLOW}Cleaning up temporary files...${NC}"
    rm -rf "$TEMP_DIR"
}

# Set up cleanup on exit
trap cleanup EXIT

# Error handling
set -e
handle_error() {
    local line_number=$1
    echo -e "${RED}An error occurred on line $line_number${NC}"
    echo -e "${YELLOW}Installation failed. Please try again or report this issue.${NC}"
    cleanup
    exit 1
}
trap 'handle_error $LINENO' ERR

# Show banner
show_banner() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}       CTF Tools (autosetup) Installation     ${NC}"
    echo -e "${BLUE}===============================================${NC}"
    echo ""
    echo -e "${GREEN}Installing CTF Tools from: ${REPO_URL}${NC}"
    echo ""
}

# Check dependencies
check_dependencies() {
    echo -e "${YELLOW}Checking dependencies...${NC}"

    local missing_deps=()

    # Check for required commands
    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
    command -v git >/dev/null 2>&1 || missing_deps+=("git")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    command -v unzip >/dev/null 2>&1 || missing_deps+=("unzip")

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Installing missing dependencies: ${missing_deps[*]}${NC}"
        apt update && apt install -y "${missing_deps[@]}"

        if [[ $? -ne 0 ]]; then
            echo -e "${RED}Failed to install dependencies. Please install them manually:${NC}"
            echo -e "${CYAN}apt install ${missing_deps[*]}${NC}"
            exit 1
        fi

        echo -e "${GREEN}Dependencies installed successfully!${NC}"
    else
        echo -e "${GREEN}All dependencies are already installed.${NC}"
    fi
}

# Download repository
download_repo() {
    echo -e "${YELLOW}Downloading CTF Tools repository...${NC}"

    cd "$TEMP_DIR"

    # Try to clone with git first, fall back to downloading zip
    if command -v git >/dev/null 2>&1; then
        git clone --depth 1 "$REPO_URL.git" ctftools 2>/dev/null || {
            echo -e "${YELLOW}Git clone failed, trying wget/curl...${NC}"
            download_zip
        }
    else
        download_zip
    fi

    if [[ ! -d "$TEMP_DIR/ctftools" ]]; then
        echo -e "${RED}Failed to download repository${NC}"
        exit 1
    fi

    echo -e "${GREEN}Repository downloaded successfully!${NC}"
}

# Download repository as zip (fallback)
download_zip() {
    local zip_url="${REPO_URL}/archive/refs/heads/main.zip"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$zip_url" -o ctftools.zip
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$zip_url" -O ctftools.zip
    else
        echo -e "${RED}Neither curl nor wget available for downloading${NC}"
        exit 1
    fi

    unzip -q ctftools.zip
    mv CTFTools-main ctftools 2>/dev/null || mv CTFTools-master ctftools 2>/dev/null || {
        echo -e "${RED}Failed to extract repository${NC}"
        exit 1
    }
}

# Install files
install_files() {
    echo -e "${YELLOW}Installing files...${NC}"

    # Remove old installations
    if [[ -d "$INSTALL_DIR" ]]; then
        echo -e "${YELLOW}Removing previous installation...${NC}"
        rm -rf "$INSTALL_DIR"
    fi

    if [[ -d "$CONFIG_DIR" ]]; then
        rm -rf "$CONFIG_DIR"
    fi

    # Create installation directories
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"

    # Copy all files from the repository to the installation directory
    cp -r "$TEMP_DIR/ctftools"/* "$INSTALL_DIR/"

    # Set proper permissions
    chmod +x "$INSTALL_DIR/setup.sh"
    chmod +x "$INSTALL_DIR"/*.sh

    # Make scripts executable
    find "$INSTALL_DIR/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    find "$INSTALL_DIR/core_functions" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    find "$INSTALL_DIR/menu_system" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

    echo -e "${GREEN}Files installed successfully!${NC}"
}

# Create global executable
create_executable() {
    echo -e "${YELLOW}Creating global executable 'autosetup'...${NC}"

    # Remove old executable if it exists
    if [[ -f "$BIN_DIR/autosetup" ]]; then
        rm -f "$BIN_DIR/autosetup"
    fi

    # Also remove old ctftools executable for clean migration
    if [[ -f "$BIN_DIR/ctftools" ]]; then
        rm -f "$BIN_DIR/ctftools"
    fi

    # Create the main executable script
    cat > "$BIN_DIR/autosetup" << 'EOF'
#!/bin/bash

# CTF Tools (autosetup) executable wrapper
if [ -f "/opt/autosetup/setup.sh" ]; then
    cd /opt/autosetup && bash setup.sh "$@"
else
    echo -e "\033[0;31mError: CTF Tools installation not found at /opt/autosetup\033[0m"
    echo -e "\033[1;33mPlease reinstall with: curl -fsSL <installation-url> | sudo bash\033[0m"
    exit 1
fi
EOF

    # Make the executable script executable
    chmod +x "$BIN_DIR/autosetup"

    echo -e "${GREEN}Global executable created successfully!${NC}"
}

# Setup configuration
setup_config() {
    echo -e "${YELLOW}Setting up configuration...${NC}"

    # Create configuration symlinks
    if [[ -f "$INSTALL_DIR/apps.json" ]]; then
        ln -sf "$INSTALL_DIR/apps.json" "$CONFIG_DIR/apps.json"
    fi

    if [[ -f "$INSTALL_DIR/version" ]]; then
        ln -sf "$INSTALL_DIR/version" "$CONFIG_DIR/version"
    fi

    # Create directory symlinks
    for dir in scripts core_functions menu_system; do
        if [[ -d "$INSTALL_DIR/$dir" ]]; then
            ln -sf "$INSTALL_DIR/$dir" "$CONFIG_DIR/$dir"
        fi
    done

    echo -e "${GREEN}Configuration setup complete!${NC}"
}

# Verify installation
verify_installation() {
    echo -e "${YELLOW}Verifying installation...${NC}"

    # Check if autosetup command works
    if command -v autosetup >/dev/null 2>&1; then
        echo -e "${GREEN}✓ autosetup command is available globally${NC}"
    else
        echo -e "${RED}✗ autosetup command not found in PATH${NC}"
        return 1
    fi

    # Check if main files exist
    if [[ -f "$INSTALL_DIR/setup.sh" ]]; then
        echo -e "${GREEN}✓ Main setup script found${NC}"
    else
        echo -e "${RED}✗ Main setup script missing${NC}"
        return 1
    fi

    # Check version
    if [[ -f "$INSTALL_DIR/version" ]]; then
        local version=$(cat "$INSTALL_DIR/version")
        echo -e "${GREEN}✓ Version $version installed${NC}"
    else
        echo -e "${YELLOW}? Version file not found${NC}"
    fi

    echo -e "${GREEN}Installation verification completed!${NC}"
}

# Handle script interruption gracefully
handle_interrupt() {
    echo ""
    echo -e "${YELLOW}Installation interrupted by user.${NC}"
    cleanup
    exit 130
}

# Set up signal handlers
trap handle_interrupt SIGINT SIGTERM

# Main installation function
main() {
    show_banner
    check_dependencies
    download_repo
    install_files
    create_executable
    setup_config
    verify_installation

    echo ""
    echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
    echo ""
    echo -e "${CYAN}You can now run CTF Tools from any directory by typing:${NC}"
    echo -e "${YELLOW}  autosetup${NC}"
    echo ""
    echo -e "${CYAN}Example usage:${NC}"
    echo -e "  ${YELLOW}autosetup${NC}                    ${GREEN}# Launch the main CTF Tools menu${NC}"
    echo -e "  ${YELLOW}autosetup --no-update-check${NC}  ${GREEN}# Launch without checking for updates${NC}"
    echo ""
    echo -e "${BLUE}For more information, visit: https://trustlab.upct.es${NC}"
    echo ""
}

# Run main installation
main "$@"
