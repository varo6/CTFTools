#!/bin/bash

# Tool Installation Functions Module
# This module handles the actual installation of selected tools

# Install a single tool
install_tool() {
  local tool_name="$1"
  local tool_command="$2"
  echo -e "${YELLOW}Installing $tool_name...${NC}"

  eval "$tool_command"

  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ $tool_name installed successfully!${NC}"
  else
    echo -e "${RED}✗ Failed to install $tool_name${NC}"
  fi
  echo ""
}

# Show selected tools
show_selected() {
  clear_screen_with_header "Selected Tools"
  echo -e "${GREEN}Currently selected tools:${NC}"
  echo ""

  local has_selections=false
  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    if [[ "${SELECTED_TOOLS[i]}" == "true" ]]; then
      printf "  ${GREEN}✓${NC} %-20s - %s\n" "${TOOL_NAMES[i]}" "${TOOL_DESCRIPTIONS[i]}"
      has_selections=true
    fi
  done

  if [[ "$has_selections" == false ]]; then
    echo -e "${YELLOW}No tools selected.${NC}"
  fi

  echo ""
  pause_for_user
}

# Install selected tools
install_selected() {
  local selected_tools=()
  local selected_commands=()

  # Get selected tools using the function from app_manager.sh
  get_selected_tools selected_tools selected_commands

  if [[ ${#selected_tools[@]} -eq 0 ]]; then
    show_error "No tools selected for installation!"
    pause_for_user
    return
  fi

  clear_screen_with_header "Installing Tools"
  echo -e "${BLUE}Installing ${#selected_tools[@]} selected tools...${NC}"
  echo ""

  # Show what will be installed
  echo -e "${YELLOW}Tools to be installed:${NC}"
  for i in "${!selected_tools[@]}"; do
    echo "  - ${selected_tools[i]}"
  done
  echo ""

  # Confirmation prompt
  echo -e "${YELLOW}Do you want to proceed with the installation? (y/N):${NC}"
  read -r install_confirm
  if [[ ! $install_confirm =~ ^[Yy]$ ]]; then
    show_info "Installation cancelled."
    pause_for_user
    return
  fi

  echo ""
  echo -e "${BLUE}Starting installation...${NC}"
  echo ""

  # Install each tool
  local successful_installs=0
  local failed_installs=0

  for i in "${!selected_tools[@]}"; do
    echo -e "${CYAN}[$((i + 1))/${#selected_tools[@]}]${NC}"
    install_tool "${selected_tools[i]}" "${selected_commands[i]}"

    if [[ $? -eq 0 ]]; then
      ((successful_installs++))
    else
      ((failed_installs++))
    fi
  done

  # Installation summary
  print_separator
  echo -e "${GREEN}Installation Summary:${NC}"
  echo -e "  ${GREEN}✓ Successful: $successful_installs${NC}"
  if [[ $failed_installs -gt 0 ]]; then
    echo -e "  ${RED}✗ Failed: $failed_installs${NC}"
  fi
  echo ""

  if [[ $successful_installs -gt 0 ]]; then
    echo -e "${GREEN}Installation process completed!${NC}"
  else
    echo -e "${RED}No tools were installed successfully.${NC}"
  fi
  echo ""

  # Ask if user wants to clear selections
  echo -e "${YELLOW}Clear all selections? (y/N):${NC}"
  read -r clear_confirm
  if [[ $clear_confirm =~ ^[Yy]$ ]]; then
    unmark_all
    show_success "Selections cleared."
  fi

  pause_for_user
}

# Install all tools (for beginner setup)
install_all_tools() {
  clear_screen_with_header "Beginner Setup - Install All Tools"

  echo -e "${YELLOW}This will install all available tools for a complete CTF setup.${NC}"
  echo -e "${YELLOW}This is recommended for beginners who want everything set up quickly.${NC}"
  echo ""

  echo -e "${CYAN}Available tools:${NC}"
  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    echo "  - ${TOOL_NAMES[i]}"
  done
  echo ""

  echo -e "${RED}Warning: This will install ${#TOOL_NAMES[@]} tools and may take a long time.${NC}"
  echo -e "${YELLOW}Do you want to proceed? (y/N):${NC}"
  read -r install_all_confirm

  if [[ ! $install_all_confirm =~ ^[Yy]$ ]]; then
    show_info "Installation cancelled."
    pause_for_user
    return
  fi

  # Mark all tools and install
  mark_all
  install_selected
}

# Quick install function for specific tool categories
quick_install_category() {
  local category="$1"

  case $category in
    "web")
      # Select web-related tools
      echo -e "${BLUE}Installing Web Security Tools...${NC}"
      # This would need to be implemented based on categorization
      ;;
    "binary")
      # Select binary analysis tools
      echo -e "${BLUE}Installing Binary Analysis Tools...${NC}"
      # This would need to be implemented based on categorization
      ;;
    "crypto")
      # Select cryptography tools
      echo -e "${BLUE}Installing Cryptography Tools...${NC}"
      # This would need to be implemented based on categorization
      ;;
    *)
      show_error "Unknown category: $category"
      return 1
      ;;
  esac
}
