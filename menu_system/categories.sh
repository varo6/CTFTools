#!/bin/bash

# Categories Menu System Module
# This module provides category-based tool selection and installation

# Category definitions with their corresponding tools
declare -A CATEGORY_TOOLS

# Initialize category mappings
init_categories() {
  # Web Security Tools
  CATEGORY_TOOLS["web"]="Burpsuite nmap"

  # Binary Analysis & Reverse Engineering
  CATEGORY_TOOLS["binary"]="gdb w/ gef Ghidra ROPGadget checksec pwntools"

  # Network Security & Scanning
  CATEGORY_TOOLS["network"]="nmap"

  # Cryptography Tools
  CATEGORY_TOOLS["crypto"]="hashcat RsaCtfTool"

  # Forensics Tools
  CATEGORY_TOOLS["forensics"]=""

  # Steganography Tools
  CATEGORY_TOOLS["stego"]="steghide zsteg outguess stegsolve audacity sonic-visualiser foremost ghex"
}

# Show categories menu
show_categories_menu() {
  clear_screen_with_header "Tool Categories"

  echo -e "${YELLOW}Browse and install tools by category:${NC}"
  echo ""

  echo -e "${BLUE}Available Categories:${NC}"
  echo -e "  ${GREEN}1)${NC} Web Security Tools"
  echo -e "  ${GREEN}2)${NC} Binary Analysis & Reverse Engineering"
  echo -e "  ${GREEN}3)${NC} Network Security & Scanning"
  echo -e "  ${GREEN}4)${NC} Cryptography Tools"
  echo -e "  ${GREEN}5)${NC} Forensics Tools"
  echo -e "  ${GREEN}6)${NC} Steganography Tools"
  echo ""

  echo -e "${YELLOW}Options:${NC}"
  echo -e "  ${BLUE}a)${NC} Install all categories"
  echo -e "  ${BLUE}s)${NC} Show category details"
  echo -e "  ${BLUE}b)${NC} Back to main menu"
  echo -e "  ${BLUE}q)${NC} Quit"
  echo ""

  echo -n "Enter your choice: "
  read -r category_choice

  handle_category_selection "$category_choice"
}

# Handle category selection
handle_category_selection() {
  local choice="$1"

  case $choice in
    1)
      install_category "web" "Web Security Tools"
      ;;
    2)
      install_category "binary" "Binary Analysis & Reverse Engineering"
      ;;
    3)
      install_category "network" "Network Security & Scanning"
      ;;
    4)
      install_category "crypto" "Cryptography Tools"
      ;;
    5)
      install_category "forensics" "Forensics Tools"
      ;;
    6)
      install_category "stego" "Steganography Tools"
      ;;
    a|A)
      install_all_categories
      ;;
    s|S)
      show_category_details
      ;;
    b|B)
      return 0
      ;;
    q|Q)
      echo -e "${GREEN}Goodbye!${NC}"
      exit 0
      ;;
    *)
      show_error "Invalid option! Please try again."
      sleep 0.3
      show_categories_menu
      ;;
  esac

  show_categories_menu
}

# Install tools from a specific category
install_category() {
  local category_key="$1"
  local category_name="$2"
  local tools="${CATEGORY_TOOLS[$category_key]}"

  if [[ -z "$tools" ]]; then
    clear_screen_with_header "$category_name"
    echo -e "${YELLOW}No tools available in this category yet.${NC}"
    echo -e "${CYAN}This category is under development.${NC}"
    echo ""
    pause_for_user
    return
  fi

  clear_screen_with_header "$category_name"

  # Convert tools string to array
  read -ra tools_array <<< "$tools"

  echo -e "${GREEN}Tools in this category:${NC}"
  echo ""

  # Display tools with descriptions
  for tool in "${tools_array[@]}"; do
    for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
      if [[ "${TOOL_NAMES[i]}" == "$tool" ]]; then
        echo -e "  ${BLUE}•${NC} ${TOOL_NAMES[i]} - ${TOOL_DESCRIPTIONS[i]}"
        break
      fi
    done
  done

  echo ""
  echo -e "${CYAN}Total tools: ${#tools_array[@]}${NC}"
  echo ""

  echo -e "${YELLOW}Do you want to install all tools in this category? (y/N):${NC}"
  read -r install_confirm

  if [[ $install_confirm =~ ^[Yy]$ ]]; then
    # Clear current selections and mark category tools
    unmark_all
    local tools_selected=0

    for tool in "${tools_array[@]}"; do
      for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
        if [[ "${TOOL_NAMES[i]}" == "$tool" ]]; then
          SELECTED_TOOLS[i]="true"
          ((tools_selected++))
          break
        fi
      done
    done

    if [[ $tools_selected -gt 0 ]]; then
      echo ""
      echo -e "${GREEN}Selected $tools_selected tools from $category_name${NC}"
      echo -e "${YELLOW}Starting installation...${NC}"
      echo ""
      install_selected
    else
      show_error "No matching tools found for installation!"
      pause_for_user
    fi
  else
    show_info "Installation cancelled."
    pause_for_user
  fi
}

# Install all categories
install_all_categories() {
  clear_screen_with_header "Install All Categories"

  echo -e "${YELLOW}This will install tools from all available categories:${NC}"
  echo ""

  local total_tools=0

  for category in "web" "binary" "network" "crypto" "forensics" "stego"; do
    local tools="${CATEGORY_TOOLS[$category]}"
    if [[ -n "$tools" ]]; then
      read -ra tools_array <<< "$tools"
      echo -e "${BLUE}${category^} category:${NC} ${#tools_array[@]} tools"
      total_tools=$((total_tools + ${#tools_array[@]}))
    fi
  done

  echo ""
  echo -e "${CYAN}Total tools to install: $total_tools${NC}"
  echo ""
  echo -e "${RED}Warning: This will install a large number of tools and may take considerable time.${NC}"
  echo ""
  echo -e "${YELLOW}Do you want to proceed? (y/N):${NC}"
  read -r install_all_confirm

  if [[ $install_all_confirm =~ ^[Yy]$ ]]; then
    # Clear selections and mark all category tools
    unmark_all
    local tools_selected=0

    for category in "web" "binary" "network" "crypto" "forensics" "stego"; do
      local tools="${CATEGORY_TOOLS[$category]}"
      if [[ -n "$tools" ]]; then
        read -ra tools_array <<< "$tools"
        for tool in "${tools_array[@]}"; do
          for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
            if [[ "${TOOL_NAMES[i]}" == "$tool" ]]; then
              SELECTED_TOOLS[i]="true"
              ((tools_selected++))
              break
            fi
          done
        done
      fi
    done

    if [[ $tools_selected -gt 0 ]]; then
      echo ""
      echo -e "${GREEN}Selected $tools_selected tools from all categories${NC}"
      echo -e "${YELLOW}Starting installation...${NC}"
      echo ""
      install_selected
    else
      show_error "No matching tools found for installation!"
      pause_for_user
    fi
  else
    show_info "Installation cancelled."
    pause_for_user
  fi
}

# Show detailed information about all categories
show_category_details() {
  clear_screen_with_header "Category Details"

  echo -e "${GREEN}Detailed information about tool categories:${NC}"
  echo ""

  local categories=("web:Web Security Tools" "binary:Binary Analysis & Reverse Engineering" "network:Network Security & Scanning" "crypto:Cryptography Tools" "forensics:Forensics Tools" "stego:Steganography Tools")

  for category_info in "${categories[@]}"; do
    IFS=':' read -r key name <<< "$category_info"
    local tools="${CATEGORY_TOOLS[$key]}"

    echo -e "${BLUE}$name:${NC}"

    if [[ -n "$tools" ]]; then
      read -ra tools_array <<< "$tools"
      for tool in "${tools_array[@]}"; do
        for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
          if [[ "${TOOL_NAMES[i]}" == "$tool" ]]; then
            echo -e "  ${YELLOW}•${NC} ${TOOL_NAMES[i]} - ${TOOL_DESCRIPTIONS[i]}"
            break
          fi
        done
      done
      echo -e "  ${CYAN}Total: ${#tools_array[@]} tools${NC}"
    else
      echo -e "  ${RED}No tools available (under development)${NC}"
    fi
    echo ""
  done

  pause_for_user
}

# Main categories loop
categories_main_loop() {
  init_categories

  while true; do
    show_categories_menu
  done
}

# If script is run directly, start the categories loop
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  categories_main_loop
fi
