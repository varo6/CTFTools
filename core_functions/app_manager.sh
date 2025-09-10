#!/bin/bash

# App Loading and Management Functions Module
# This module handles loading apps from JSON and managing selections

# Arrays to store tool information
declare -a TOOL_NAMES
declare -a TOOL_DESCRIPTIONS
declare -a TOOL_COMMANDS
declare -a SELECTED_TOOLS

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

# Validate input for tool numbers
is_valid_tool_number() {
  local input="$1"
  local tool_count=${#TOOL_NAMES[@]}
  [[ "$input" =~ ^[0-9]+$ ]] && [[ "$input" -ge 1 ]] && [[ "$input" -le "$tool_count" ]]
}

# Get selected tools and commands
get_selected_tools() {
  local -n selected_tools_ref=$1
  local -n selected_commands_ref=$2

  selected_tools_ref=()
  selected_commands_ref=()

  # Collect selected tools
  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    if [[ "${SELECTED_TOOLS[i]}" == "true" ]]; then
      selected_tools_ref+=("${TOOL_NAMES[i]}")
      selected_commands_ref+=("${TOOL_COMMANDS[i]}")
    fi
  done
}

# Get tool info by index
get_tool_info() {
  local tool_index="$1"
  local -n tool_name_ref=$2
  local -n tool_desc_ref=$3
  local -n tool_cmd_ref=$4

  if [[ $tool_index -ge 0 && $tool_index -lt ${#TOOL_NAMES[@]} ]]; then
    tool_name_ref="${TOOL_NAMES[$tool_index]}"
    tool_desc_ref="${TOOL_DESCRIPTIONS[$tool_index]}"
    tool_cmd_ref="${TOOL_COMMANDS[$tool_index]}"
    return 0
  else
    return 1
  fi
}

# Get total tool count
get_tool_count() {
  echo "${#TOOL_NAMES[@]}"
}
