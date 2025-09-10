#!/bin/bash

# Install Tools Menu System Module
# This module provides the tool selection and installation interface

# Display checkbox menu for tool selection
show_checkbox_menu() {
  clear_screen_with_header "Install Tools - Selection Menu"
  echo -e "${GREEN}Select tools to install (toggle with number + Enter):${NC}"
  echo ""

  # Display tools in two columns for better layout
  local tool_count=${#TOOL_NAMES[@]}
  local mid=$((tool_count / 2))

  for ((i = 0; i < mid; i++)); do
    local index1=$i
    local index2=$((i + mid))

    local checkbox1=$(get_checkbox "$index1")
    local line1=$(printf "%s %2d) %-18s" "$checkbox1" "$((index1 + 1))" "${TOOL_NAMES[index1]}")

    if [[ $index2 -lt $tool_count ]]; then
      local checkbox2=$(get_checkbox "$index2")
      local line2=$(printf "%s %2d) %-18s" "$checkbox2" "$((index2 + 1))" "${TOOL_NAMES[index2]}")
      printf "  %s    %s\n" "$line1" "$line2"
    else
      printf "  %s\n" "$line1"
    fi
  done

  # Handle odd number of tools
  if [[ $((tool_count % 2)) -eq 1 ]]; then
    local last_index=$((tool_count - 1))
    local checkbox=$(get_checkbox "$last_index")
    printf "  %s %2d) %-18s\n" "$checkbox" "$((last_index + 1))" "${TOOL_NAMES[last_index]}"
  fi

  local selected_count=$(count_selected)
  echo ""
  echo -e "${CYAN}Selected: ${selected_count}/${tool_count} tools${NC}"
  echo ""
  show_install_menu_options
}

# Show menu options for install tools
show_install_menu_options() {
  echo -e "${YELLOW}Commands:${NC}"
  echo "  [number] - Toggle tool selection"
  echo "  a        - Mark all tools"
  echo "  n        - Unmark all tools"
  echo "  s        - Show selected tools"
  echo "  i        - Install selected tools"
  echo "  d        - Show tool details"
  echo "  u        - Update system packages"
  echo "  b        - Back to main menu"
  echo "  q        - Quit"
  echo ""
}

# Show detailed information about tools
show_tool_details() {
  clear_screen_with_header "Tool Details"

  echo -e "${GREEN}Detailed information about available tools:${NC}"
  echo ""

  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    echo -e "${BLUE}$((i + 1)). ${TOOL_NAMES[i]}${NC}"
    echo -e "   ${CYAN}Description:${NC} ${TOOL_DESCRIPTIONS[i]}"
    echo -e "   ${MAGENTA}Command:${NC} ${TOOL_COMMANDS[i]}"
    echo ""
  done

  pause_for_user
}

# Quick selection options
show_quick_selection_menu() {
  clear_screen_with_header "Quick Selection"

  echo -e "${YELLOW}Quick selection options:${NC}"
  echo ""
  echo -e "  ${BLUE}1)${NC} Essential CTF Tools"
  echo -e "  ${BLUE}2)${NC} Binary Analysis Tools"
  echo -e "  ${BLUE}3)${NC} Web Security Tools"
  echo -e "  ${BLUE}4)${NC} Network Tools"
  echo -e "  ${BLUE}5)${NC} All Tools"
  echo -e "  ${BLUE}6)${NC} Clear All Selections"
  echo ""
  echo -e "  ${BLUE}b)${NC} Back to tool selection"
  echo ""

  echo -n "Enter your choice: "
  read -r quick_choice

  case $quick_choice in
    1)
      select_essential_tools
      ;;
    2)
      select_binary_tools
      ;;
    3)
      select_web_tools
      ;;
    4)
      select_network_tools
      ;;
    5)
      mark_all
      show_success "All tools selected!"
      sleep 0.3
      ;;
    6)
      unmark_all
      show_success "All selections cleared!"
      sleep 0.3
      ;;
    b|B)
      return
      ;;
    *)
      show_error "Invalid option!"
      sleep 0.3
      show_quick_selection_menu
      ;;
  esac
}

# Select essential tools
select_essential_tools() {
  unmark_all
  local essential_tools=("gdb w/ gef" "pwntools" "nmap" "checksec" "Ghidra")

  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    for essential in "${essential_tools[@]}"; do
      if [[ "${TOOL_NAMES[i]}" == "$essential" ]]; then
        SELECTED_TOOLS[i]="true"
        break
      fi
    done
  done

  show_success "Essential tools selected!"
  sleep 0.3
}

# Select binary analysis tools
select_binary_tools() {
  unmark_all
  local binary_tools=("gdb w/ gef" "Ghidra" "ROPGadget" "checksec")

  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    for binary in "${binary_tools[@]}"; do
      if [[ "${TOOL_NAMES[i]}" == "$binary" ]]; then
        SELECTED_TOOLS[i]="true"
        break
      fi
    done
  done

  show_success "Binary analysis tools selected!"
  sleep 0.3
}

# Select web security tools
select_web_tools() {
  unmark_all
  local web_tools=("Burpsuite" "nmap")

  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    for web in "${web_tools[@]}"; do
      if [[ "${TOOL_NAMES[i]}" == "$web" ]]; then
        SELECTED_TOOLS[i]="true"
        break
      fi
    done
  done

  show_success "Web security tools selected!"
  sleep 0.3
}

# Select network tools
select_network_tools() {
  unmark_all
  local network_tools=("nmap")

  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    for network in "${network_tools[@]}"; do
      if [[ "${TOOL_NAMES[i]}" == "$network" ]]; then
        SELECTED_TOOLS[i]="true"
        break
      fi
    done
  done

  show_success "Network tools selected!"
  sleep 0.3
}

# Handle install menu selection
handle_install_menu_selection() {
  local choice="$1"

  case $choice in
    [0-9]|[0-9][0-9])
      if is_valid_tool_number "$choice"; then
        local index=$((choice - 1))
        toggle_selection "$index"
        # Brief feedback
        if [[ "${SELECTED_TOOLS[index]}" == "true" ]]; then
          echo -e "${GREEN}✓ ${TOOL_NAMES[index]} selected${NC}"
        else
          echo -e "${YELLOW}${TOOL_NAMES[index]} deselected${NC}"
        fi
        sleep 0.2
      else
        show_error "Invalid tool number!"
        sleep 0.3
      fi
      ;;
    a|A)
      mark_all
      show_success "All tools selected!"
      sleep 0.3
      ;;
    n|N)
      unmark_all
      show_success "All tools deselected!"
      sleep 0.3
      ;;
    s|S)
      show_selected
      ;;
    i|I)
      install_selected
      ;;
    d|D)
      show_tool_details
      ;;
    r|R)
      show_quick_selection_menu
      ;;
    u|U)
      clear_screen_with_header "System Update"
      update_system
      pause_for_user
      ;;
    b|B)
      return 0  # Return to main menu
      ;;
    q|Q)
      echo -e "${GREEN}Goodbye!${NC}"
      exit 0
      ;;
    *)
      show_error "Invalid command! Please try again."
      sleep 0.3
      ;;
  esac

  return 1  # Continue in install menu
}

# Show install tools menu with enhanced options
show_install_tools_menu() {
  while true; do
    show_checkbox_menu
    echo -e "${MAGENTA}Additional Options:${NC}"
    echo "  r        - Quick selection presets"
    echo ""
    echo -n "Enter command: "
    read -r choice

    # Handle the selection
    if handle_install_menu_selection "$choice"; then
      break  # Return to main menu
    fi
  done
}

# Install confirmation with summary
confirm_installation() {
  local selected_tools=()
  local selected_commands=()
  get_selected_tools selected_tools selected_commands

  if [[ ${#selected_tools[@]} -eq 0 ]]; then
    show_error "No tools selected for installation!"
    return 1
  fi

  clear_screen_with_header "Installation Confirmation"
  echo -e "${YELLOW}You are about to install the following tools:${NC}"
  echo ""

  for i in "${!selected_tools[@]}"; do
    echo -e "  ${GREEN}✓${NC} ${selected_tools[i]}"
  done

  echo ""
  echo -e "${CYAN}Total tools to install: ${#selected_tools[@]}${NC}"
  echo ""
  echo -e "${RED}Warning: This process may take several minutes depending on your internet connection.${NC}"
  echo ""
  echo -e "${YELLOW}Do you want to proceed with the installation? (y/N):${NC}"
  read -r install_confirm

  if [[ $install_confirm =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}
