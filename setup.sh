#!/bin/bash

# CTF Tools Interactive Installer - Main Script
# Version 1.0.6 - Modular Edition
#
# This is the main entry point for the CTF Tools installer.
# It loads all modular components and starts the main menu system.

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Export for use in other scripts
export SCRIPT_DIR

# Check for core_functions directory in different locations
CORE_FUNCTIONS_DIR="$SCRIPT_DIR/core_functions"
if [[ ! -d "$CORE_FUNCTIONS_DIR" ]]; then
  if [[ -d "/opt/ctftools/core_functions" ]]; then
    CORE_FUNCTIONS_DIR="/opt/ctftools/core_functions"
  elif [[ -d "/etc/ctftools/core_functions" ]]; then
    CORE_FUNCTIONS_DIR="/etc/ctftools/core_functions"
  elif [[ -d "/etc/autosetup/core_functions" ]]; then
    CORE_FUNCTIONS_DIR="/etc/autosetup/core_functions"
  fi
fi
export CORE_FUNCTIONS_DIR

# Check for menu_system directory in different locations
MENU_SYSTEM_DIR="$SCRIPT_DIR/menu_system"
if [[ ! -d "$MENU_SYSTEM_DIR" ]]; then
  if [[ -d "/opt/ctftools/menu_system" ]]; then
    MENU_SYSTEM_DIR="/opt/ctftools/menu_system"
  elif [[ -d "/etc/ctftools/menu_system" ]]; then
    MENU_SYSTEM_DIR="/etc/ctftools/menu_system"
  elif [[ -d "/etc/autosetup/menu_system" ]]; then
    MENU_SYSTEM_DIR="/etc/autosetup/menu_system"
  fi
fi
export MENU_SYSTEM_DIR

# Source all core function modules
if [[ ! -f "$CORE_FUNCTIONS_DIR/colors_utils.sh" || ! -f "$CORE_FUNCTIONS_DIR/app_manager.sh" || ! -f "$CORE_FUNCTIONS_DIR/installer.sh" ]]; then
  echo -e "\033[0;31mError: Required core function modules not found!\033[0m"
  echo -e "\033[1;33mPlease make sure CTF Tools is properly installed.\033[0m"
  echo -e "Searched in: $CORE_FUNCTIONS_DIR"
  exit 1
fi

source "$CORE_FUNCTIONS_DIR/colors_utils.sh"
source "$CORE_FUNCTIONS_DIR/app_manager.sh"
source "$CORE_FUNCTIONS_DIR/installer.sh"

# Source all menu system modules
if [[ ! -f "$MENU_SYSTEM_DIR/main_menu.sh" || ! -f "$MENU_SYSTEM_DIR/install_menu.sh" ]]; then
  echo -e "\033[0;31mError: Required menu system modules not found!\033[0m"
  echo -e "\033[1;33mPlease make sure CTF Tools is properly installed.\033[0m"
  echo -e "Searched in: $MENU_SYSTEM_DIR"
  exit 1
fi

source "$MENU_SYSTEM_DIR/main_menu.sh"
source "$MENU_SYSTEM_DIR/install_menu.sh"

# Initialize the application
initialize_app() {
  # Check if running as root first
  check_root

  # Check for updates (unless skipped)
  if [[ "${SKIP_UPDATE_CHECK:-}" != "1" ]] && [[ "${1:-}" != "--no-update-check" ]]; then
    check_for_updates
  else
    echo -e "${YELLOW}Skipping update check...${NC}"
  fi

  # Load applications from JSON
  load_apps

  # Initialize tool selections
  init_selections

  # Initialization complete - go straight to menu
}

# Main application entry point
main() {
  # Initialize everything
  initialize_app "$@"

  # Start the main menu loop
  main_menu_loop
}

# Handle script interruption gracefully
cleanup() {
  echo ""
  echo -e "${YELLOW}Installation interrupted by user.${NC}"
  echo -e "${GREEN}Thank you for using CTF Tools!${NC}"
  exit 130
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Error handling
set -e
handle_error() {
  local line_number=$1
  echo -e "${RED}An error occurred on line $line_number${NC}"
  echo -e "${YELLOW}Please report this issue if it persists.${NC}"
  exit 1
}
trap 'handle_error $LINENO' ERR

# Dependency check
check_dependencies() {
  local missing_deps=()

  # Check for required commands
  command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
  command -v curl >/dev/null 2>&1 || missing_deps+=("curl")

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo -e "${RED}Missing required dependencies:${NC}"
    for dep in "${missing_deps[@]}"; do
      echo -e "  - $dep"
    done
    echo ""
    echo -e "${YELLOW}Installing missing dependencies...${NC}"
    sudo apt update && sudo apt install -y "${missing_deps[@]}"

    if [[ $? -ne 0 ]]; then
      echo -e "${RED}Failed to install dependencies. Please install them manually.${NC}"
      exit 1
    fi

    echo -e "${GREEN}Dependencies installed successfully!${NC}"
    sleep 1
  fi
}

# Pre-flight checks
preflight_checks() {
  echo -e "${YELLOW}Performing pre-flight checks...${NC}"

  # Check dependencies
  check_dependencies

  # Get the directory where this script is located
  local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Load version number from file
  if [[ -f "$SCRIPT_DIR/version" ]]; then
    CURRENT_VERSION=$(cat "$SCRIPT_DIR/version")
  elif [[ -f "/opt/ctftools/version" ]]; then
    CURRENT_VERSION=$(cat "/opt/ctftools/version")
  elif [[ -f "/etc/ctftools/version" ]]; then
    CURRENT_VERSION=$(cat "/etc/ctftools/version")
  elif [[ -f "/etc/autosetup/version" ]]; then
    CURRENT_VERSION=$(cat "/etc/autosetup/version")
  else
    CURRENT_VERSION="unknown"
  fi

  # Check if scripts directory exists
  local SCRIPTS_DIR="$SCRIPT_DIR/scripts"
  # Also check system installation paths as fallback
  if [[ ! -d "$SCRIPTS_DIR" ]]; then
    if [[ -d "/opt/ctftools/scripts" ]]; then
      SCRIPTS_DIR="/opt/ctftools/scripts"
    elif [[ -d "/etc/ctftools/scripts" ]]; then
      SCRIPTS_DIR="/etc/ctftools/scripts"
    elif [[ -d "/etc/autosetup/scripts" ]]; then
      SCRIPTS_DIR="/etc/autosetup/scripts"
    fi
  fi

  if [[ ! -d "$SCRIPTS_DIR" ]]; then
    echo -e "${RED}Error: scripts directory not found!${NC}"
    echo -e "${YELLOW}Attempted locations:${NC}"
    echo -e " - Script directory: $SCRIPTS_DIR"
    echo -e " - System locations: /opt/ctftools/scripts, /etc/ctftools/scripts, /etc/autosetup/scripts"
    exit 1
  fi

  # Export the scripts directory path for use in other parts of the program
  export SCRIPTS_DIR

  echo -e "${GREEN}All checks passed!${NC}"
  sleep 1
}

# Show startup banner
show_banner() {
  clear
  echo -e "${BLUE}===============================================${NC}"
  echo -e "${BLUE}          CTF Tools Interactive Installer     ${NC}"
  echo -e "${BLUE}                   Version ${CURRENT_VERSION}                ${NC}"
  echo -e "${BLUE}===============================================${NC}"
  echo ""
  echo -e "${GREEN}Welcome to the ultimate CTF tools installer!${NC}"
  echo -e "${CYAN}This tool will help you set up a complete CTF environment.${NC}"
  echo ""
  sleep 0.5
}

# Show usage information
show_usage() {
  echo "CTF Tools Interactive Installer v${CURRENT_VERSION}"
  echo ""
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --no-update-check    Skip the automatic update check"
  echo "  --help, -h          Show this help message"
  echo ""
  echo "Environment Variables:"
  echo "  SKIP_UPDATE_CHECK=1  Skip the automatic update check"
  echo ""
}

# Handle command line arguments
handle_args() {
  for arg in "$@"; do
    case $arg in
      --help|-h)
        show_usage
        exit 0
        ;;
      --no-update-check)
        # This is handled in initialize_app
        ;;
      *)
        echo -e "${RED}Unknown option: $arg${NC}"
        echo "Use --help for usage information."
        exit 1
        ;;
    esac
  done
}

# Entry point with full initialization
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Handle command line arguments
  handle_args "$@"

  # Show banner
  show_banner

  # Run pre-flight checks
  preflight_checks

  # Start main application
  main "$@"
fi
