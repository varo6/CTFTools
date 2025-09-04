#!/bin/bash

# Interactive Tool Installer for Kali Linux with JSON Configuration
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Version checking
CURRENT_VERSION="1.0.0"
REPO_URL_FOR_VERSION="https://raw.githubusercontent.com/varo6/CTFTools/refs/heads/main/"

check_for_updates() {
  echo -e "${YELLOW}Checking for updates...${NC}"
  # The version file might have a newline, so we remove it
  LATEST_VERSION=$(curl -sSL "${REPO_URL_FOR_VERSION}version" | tr -d '\n')

  if [ -z "$LATEST_VERSION" ]; then
    echo -e "${RED}Could not check for updates. Please check your internet connection.${NC}"
    return
  fi

  if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
    echo -e "${GREEN}A new version ($LATEST_VERSION) is available!${NC}"
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
    echo -e "${GREEN}You are running the latest version.${NC}"
  fi
  sleep 1 # Give user time to read the message
}

# Clear screen function
clear_screen() {
  clear
  echo -e "${BLUE}===============================================${NC}"
  echo -e "${BLUE}    Kali Linux Interactive Tool Installer${NC}"
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

# Update system
update_system() {
  echo -e "${YELLOW}Updating package lists...${NC}"
  sudo apt update
  echo -e "${GREEN}Package lists updated!${NC}"
  echo ""
}

# Check if jq is installed, install if not
check_jq() {
  if ! command -v jq &>/dev/null; then
    echo -e "${YELLOW}Installing jq for JSON parsing...${NC}"
    sudo apt install -y jq
    if [[ $? -ne 0 ]]; then
      echo -e "${RED}Failed to install jq. Please install it manually.${NC}"
      exit 1
    fi
  fi
}

# Load apps from JSON file
load_apps() {
  local json_file="apps.json"

  if [[ ! -f "$json_file" ]]; then
    echo -e "${RED}Error: $json_file not found in the current directory!${NC}"
    exit 1
  fi

  # Check if JSON is valid
  if ! jq empty "$json_file" 2>/dev/null; then
    echo -e "${RED}Error: Invalid JSON format in $json_file${NC}"
    exit 1
  fi

  # Parse JSON and populate arrays
  mapfile -t TOOL_NAMES < <(jq -r '.[].name' "$json_file")
  mapfile -t TOOL_DESCRIPTIONS < <(jq -r '.[].description' "$json_file")
  mapfile -t TOOL_COMMANDS < <(jq -r '.[].command' "$json_file")

  if [[ ${#TOOL_NAMES[@]} -eq 0 ]]; then
    echo -e "${RED}Error: No tools found in $json_file${NC}"
    exit 1
  fi

  echo -e "${GREEN}Loaded ${#TOOL_NAMES[@]} tools from $json_file${NC}"
}

# Array to track selected tools
declare -a SELECTED_TOOLS

# Initialize all tools as unselected
init_selections() {
  SELECTED_TOOLS=()
  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    SELECTED_TOOLS[i]="false"
  done
}

# Toggle tool selection
toggle_selection() {
  local tool_index="$1"
  if [[ "${SELECTED_TOOLS[$tool_index]}" == "true" ]]; then
    SELECTED_TOOLS[$tool_index]="false"
  else
    SELECTED_TOOLS[$tool_index]="true"
  fi
}

# Mark all tools
mark_all() {
  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    SELECTED_TOOLS[i]="true"
  done
}

# Unmark all tools
unmark_all() {
  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    SELECTED_TOOLS[i]="false"
  done
}

# Get checkbox symbol
get_checkbox() {
  local tool_index="$1"
  if [[ "${SELECTED_TOOLS[$tool_index]}" == "true" ]]; then
    echo -e "${GREEN}[✓]${NC}"
  else
    echo -e "${RED}[ ]${NC}"
  fi
}

# Count selected tools
count_selected() {
  local count=0
  for ((i = 0; i < ${#SELECTED_TOOLS[@]}; i++)); do
    if [[ "${SELECTED_TOOLS[i]}" == "true" ]]; then
      ((count++))
    fi
  done
  echo "$count"
}

# Display checkbox menu
show_checkbox_menu() {
  clear_screen
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
  echo -e "${YELLOW}Commands:${NC}"
  echo "  [number] - Toggle tool selection"
  echo "  a        - Mark all tools"
  echo "  n        - Unmark all tools"
  echo "  i        - Install selected tools"
  echo "  u        - Update system packages"
  echo "  s        - Show selected tools"
  echo "  q        - Quit"
  echo ""
}

# Show selected tools
show_selected() {
  clear_screen
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
  echo "Press Enter to continue..."
  read -r
}

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

# Install selected tools
install_selected() {
  local selected_tools=()
  local selected_commands=()

  # Collect selected tools
  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    if [[ "${SELECTED_TOOLS[i]}" == "true" ]]; then
      selected_tools+=("${TOOL_NAMES[i]}")
      selected_commands+=("${TOOL_COMMANDS[i]}")
    fi
  done

  if [[ ${#selected_tools[@]} -eq 0 ]]; then
    echo -e "${RED}No tools selected for installation!${NC}"
    echo "Press Enter to continue..."
    read -r
    return
  fi

  clear_screen
  echo -e "${BLUE}Installing ${#selected_tools[@]} selected tools...${NC}"
  echo ""

  # Show what will be installed
  echo -e "${YELLOW}Tools to be installed:${NC}"
  for i in "${!selected_tools[@]}"; do
    echo "  - ${selected_tools[i]}"
  done
  echo ""

  echo -e "${YELLOW}Proceed with installation? (y/N):${NC}"
  read -r confirm

  if [[ $confirm =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}Starting installation...${NC}"
    echo ""

    for i in "${!selected_tools[@]}"; do
      install_tool "${selected_tools[i]}" "${selected_commands[i]}"
    done

    echo -e "${GREEN}Installation process completed!${NC}"
    echo ""

    # Ask if user wants to clear selections
    echo -e "${YELLOW}Clear all selections? (y/N):${NC}"
    read -r clear_confirm
    if [[ $clear_confirm =~ ^[Yy]$ ]]; then
      unmark_all
      echo -e "${GREEN}Selections cleared.${NC}"
    fi
  else
    echo -e "${YELLOW}Installation cancelled.${NC}"
  fi

  echo "Press Enter to continue..."
  read -r
}

# Validate input
is_valid_tool_number() {
  local input="$1"
  local tool_count=${#TOOL_NAMES[@]}
  [[ "$input" =~ ^[0-9]+$ ]] && [[ "$input" -ge 1 ]] && [[ "$input" -le "$tool_count" ]]
}

# Main interactive loop
main() {
  check_for_updates
  check_root
  check_jq
  load_apps
  init_selections

  while true; do
    show_checkbox_menu
    echo -n "Enter command: "
    read -r choice

    case $choice in
    [0-9] | [0-9][0-9])
      if is_valid_tool_number "$choice"; then
        local index=$((choice - 1))
        toggle_selection "$index"
        # Brief feedback
        if [[ "${SELECTED_TOOLS[index]}" == "true" ]]; then
          echo -e "${GREEN}✓ ${TOOL_NAMES[index]} selected${NC}"
        else
          echo -e "${YELLOW}${TOOL_NAMES[index]} deselected${NC}"
        fi
        sleep 0.5
      else
        echo -e "${RED}Invalid tool number!${NC}"
        sleep 1
      fi
      ;;
    a | A)
      mark_all
      echo -e "${GREEN}All tools selected!${NC}"
      sleep 0.8
      ;;
    n | N)
      unmark_all
      echo -e "${YELLOW}All tools deselected!${NC}"
      sleep 0.8
      ;;
    s | S)
      show_selected
      ;;
    i | I)
      install_selected
      ;;
    u | U)
      clear_screen
      update_system
      echo "Press Enter to continue..."
      read -r
      ;;
    q | Q)
      echo -e "${GREEN}Goodbye!${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid command! Please try again.${NC}"
      sleep 1
      ;;
    esac
  done
}

# Run the script
main
