#!/bin/bash

# Main Menu System Module
# This module provides the main navigation menu for the CTF Tools installer

# Show main menu
show_main_menu() {
  clear_screen_with_header "CTF Tools - TrustLAB ⭐"

  echo -e "${GREEN}Welcome to the CTF Tools Installer!${NC}"
  echo -e "${CYAN}Select an option from the menu below:${NC}"
  echo ""

  echo -e "${YELLOW}Main Sections:${NC}"
  echo -e "  ${BLUE}1)${NC} ${GREEN}Beginner Setup${NC}      - Quick setup for newcomers"
  echo -e "  ${BLUE}2)${NC} ${GREEN}Categories${NC}          - Browse tools by category"
  echo -e "  ${BLUE}3)${NC} ${GREEN}Install Tools${NC}       - Select and install specific tools"
  echo -e "  ${BLUE}4)${NC} ${GREEN}Setup Tools${NC}         - Configure installed tools"
  echo -e "  ${BLUE}5)${NC} ${GREEN}Support Us!${NC}         - How to support this project"
  echo ""

  echo -e "${YELLOW}System Options:${NC}"
  echo -e "  ${BLUE}u)${NC} Update system packages"
  echo -e "  ${BLUE}c)${NC} Check for updates"
  echo -e "  ${BLUE}q)${NC} Quit"
  echo ""
}

# Handle main menu selection
handle_main_menu_selection() {
  local choice="$1"

  case $choice in
    1)
      show_beginner_setup_menu
      ;;
    2)
      show_categories_menu
      ;;
    3)
      show_install_tools_menu
      ;;
    4)
      show_setup_tools_menu
      ;;
    5)
      show_support_menu
      ;;
    u|U)
      clear_screen_with_header "System Update"
      update_system
      pause_for_user
      ;;
    c|C)
      clear_screen_with_header "Update Check"
      check_for_updates
      pause_for_user
      ;;
    q|Q)
      echo -e "${GREEN}Thank you for using CTF Tools! Goodbye!${NC}"
      exit 0
      ;;
    *)
      show_error "Invalid option! Please try again."
      sleep 0.3
      ;;
  esac
}

# Categories menu - loads categories.sh
show_categories_menu() {
  # Source the categories script
  local categories_script="$(dirname "${BASH_SOURCE[0]}")/categories.sh"

  if [[ -f "$categories_script" ]]; then
    source "$categories_script"
    categories_main_loop
  else
    clear_screen_with_header "Tool Categories"
    echo -e "${RED}Error: Categories script not found!${NC}"
    echo -e "${YELLOW}Expected location: $categories_script${NC}"
    echo ""
    pause_for_user
  fi
}

# Beginner setup menu
show_beginner_setup_menu() {
  clear_screen_with_header "Beginner Setup"

  echo -e "${GREEN}Welcome to CTF Tools!${NC}"
  echo -e "${CYAN}This section helps newcomers get started quickly.${NC}"
  echo ""

  echo -e "${YELLOW}Setup Options:${NC}"
  echo -e "  ${BLUE}1)${NC} ${GREEN}Install Beginner Tools${NC}     - Install essential tools (edit + eza)"
  echo ""

  echo -e "  ${BLUE}i)${NC} What tools are included?"
  echo -e "  ${BLUE}b)${NC} Back to main menu"
  echo ""

  echo -n "Enter your choice: "
  read -r beginner_choice

  case $beginner_choice in
    1)
      install_beginner_tools
      ;;
    i|I)
      show_tools_info
      ;;
    b|B)
      return
      ;;
    *)
      show_error "Invalid option!"
      sleep 0.3
      show_beginner_setup_menu
      ;;
  esac
}

# Setup tools menu (placeholder)
show_setup_tools_menu() {
  clear_screen_with_header "Setup Tools"

  echo -e "${YELLOW}Configure your installed tools:${NC}"
  echo ""

  echo -e "${BLUE}Configuration Options:${NC}"
  echo -e "  ${GREEN}1)${NC} Configure GDB with GEF/PWNDBG"
  echo -e "  ${GREEN}2)${NC} Setup Development Environment"
  echo -e "  ${GREEN}3)${NC} Configure Neovim/Editor Settings"
  echo -e "  ${GREEN}4)${NC} Network Configuration"
  echo -e "  ${GREEN}5)${NC} Custom Aliases and Functions"
  echo ""

  echo -e "${RED}[Coming Soon]${NC} Tool configuration features are under development."
  echo -e "${YELLOW}Most tools are automatically configured during installation.${NC}"
  echo ""

  pause_for_user
}

# Support menu
show_support_menu() {
  clear_screen_with_header "Support Us!"

  echo -e "${GREEN}Thank you for using CTF Tools!${NC}"
  echo -e "${CYAN}Here's how you can support this project:${NC}"
  echo ""

  echo -e "${YELLOW}Ways to Support:${NC}"
  echo -e "  ${BLUE}⭐${NC} Star us on GitHub"
  echo -e "  ${BLUE}🐛${NC} Report bugs and issues"
  echo -e "  ${BLUE}💡${NC} Suggest new features"
  echo -e "  ${BLUE}📝${NC} Contribute code or documentation"
  echo -e "  ${BLUE}📢${NC} Share with your friends and colleagues"
  echo ""

  echo -e "${GREEN}Project Information:${NC}"
  echo -e "  Repository: ${CYAN}https://github.com/varo6/CTFTools${NC}"
  echo -e "  Version: ${YELLOW}$CURRENT_VERSION${NC}"
  echo ""

  echo -e "${MAGENTA}Created with ❤️ for the CTF community${NC}"
  echo ""

  pause_for_user
}

# Show tools information
show_tools_info() {
  clear_screen_with_header "Beginner Tools Information"

  echo -e "${GREEN}Tools included in beginner setup:${NC}"
  echo ""

  # Define beginner tools
  local beginner_tools=("edit" "eza")

  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    for beginner in "${beginner_tools[@]}"; do
      if [[ "${TOOL_NAMES[i]}" == "$beginner" ]]; then
        printf "  ${BLUE}•${NC} %-20s - %s\n" "${TOOL_NAMES[i]}" "${TOOL_DESCRIPTIONS[i]}"
        break
      fi
    done
  done

  echo ""
  echo -e "${CYAN}Total beginner tools: ${#beginner_tools[@]}${NC}"
  echo ""
  echo -e "${YELLOW}Why these tools?${NC}"
  echo -e "• ${GREEN}edit${NC} - Essential terminal text editor for quick file editing"
  echo -e "• ${GREEN}eza${NC} - Modern ls replacement with better output and colors"
  echo ""
  echo -e "${CYAN}For more tools, use the 'Install Tools' section from the main menu.${NC}"
  echo ""

  pause_for_user
}

# Install beginner tools only
install_beginner_tools() {
  clear_screen_with_header "Installing Beginner Tools"

  echo -e "${YELLOW}Installing beginner tools...${NC}"
  echo ""

  # Define beginner tools
  local beginner_tools=("edit" "eza")

  echo -e "${CYAN}Beginner tools to be installed:${NC}"
  for tool in "${beginner_tools[@]}"; do
    echo "  - $tool"
  done
  echo ""

  # Mark only beginner tools
  unmark_all
  local tools_matched=0
  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    for beginner in "${beginner_tools[@]}"; do
      if [[ "${TOOL_NAMES[i]}" == "$beginner" ]]; then
        SELECTED_TOOLS[i]="true"
        ((tools_matched++))
        break
      fi
    done
  done

  install_selected
}
# Install selected beginner tools
install_selected_beginner_tools() {
  local -n tools_ref=$1
  local -n selected_ref=$2
  local tools_to_install=()

  # Get selected tools
  for ((i = 0; i < ${#tools_ref[@]}; i++)); do
    if [[ "${selected_ref[i]}" == "true" ]]; then
      tools_to_install+=("${tools_ref[i]}")
    fi
  done

  if [[ ${#tools_to_install[@]} -eq 0 ]]; then
    show_error "No tools selected for installation!"
    pause_for_user
    return
  fi

  clear_screen_with_header "Installing Selected Beginner Tools"
  echo -e "${BLUE}Installing ${#tools_to_install[@]} selected tools...${NC}"
  echo ""

  echo -e "${YELLOW}Tools to be installed:${NC}"
  for tool in "${tools_to_install[@]}"; do
    echo "  - $tool"
  done
  echo ""

  echo -e "${YELLOW}Do you want to proceed? (y/N):${NC}"
  read -r install_confirm
  if [[ ! $install_confirm =~ ^[Yy]$ ]]; then
    show_info "Installation cancelled."
    pause_for_user
    return
  fi

  # Mark the tools in the main selection system and install
  unmark_all
  for tool_to_install in "${tools_to_install[@]}"; do
    for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
      if [[ "${TOOL_NAMES[i]}" == "$tool_to_install" ]]; then
        SELECTED_TOOLS[i]="true"
        break
      fi
    done
  done

  install_selected
}

# Main menu loop
main_menu_loop() {
  while true; do
    show_main_menu
    echo -n "Enter your choice: "
    read -r main_choice
    handle_main_menu_selection "$main_choice"
  done
}
