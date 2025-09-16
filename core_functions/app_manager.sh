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
  # Try to find apps.json in multiple locations
  local json_file

  # First try the current directory
  if [[ -f "apps.json" ]]; then
    json_file="apps.json"

  # Then try based on the script's location
  elif [[ -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../apps.json" ]]; then
    json_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../apps.json"

  # Try the global installation locations
  elif [[ -f "/opt/ctftools/apps.json" ]]; then
    json_file="/opt/ctftools/apps.json"
  elif [[ -f "/etc/ctftools/apps.json" ]]; then
    json_file="/etc/ctftools/apps.json"

  # Legacy location as last resort
  elif [[ -f "/etc/autosetup/apps.json" ]]; then
    json_file="/etc/autosetup/apps.json"

  # If we still can't find it, report the error
  else
    echo -e "${RED}Error: apps.json not found!${NC}"
    echo -e "${YELLOW}Attempted locations:${NC}"
    echo -e " - Current directory: $(pwd)/apps.json"
    echo -e " - Script directory: $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../apps.json"
    echo -e " - Global location 1: /opt/ctftools/apps.json"
    echo -e " - Global location 2: /etc/ctftools/apps.json"
    echo -e " - Legacy location: /etc/autosetup/apps.json"
    echo -e "${YELLOW}Make sure CTF Tools is properly installed.${NC}"
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
  # Parse commands but replace any references to scripts/ with the correct path
  mapfile -t RAW_COMMANDS < <(jq -r '.[].command' "$json_file")

  # Determine scripts directory
  local scripts_dir
  if [[ -n "$SCRIPTS_DIR" ]]; then
    # Use environment variable if set
    scripts_dir="$SCRIPTS_DIR"
  elif [[ -d "$(dirname "$json_file")/../scripts" ]]; then
    # Try relative to JSON file
    scripts_dir="$(dirname "$json_file")/../scripts"
  elif [[ -d "/opt/ctftools/scripts" ]]; then
    # Try global installation location
    scripts_dir="/opt/ctftools/scripts"
  elif [[ -d "/etc/ctftools/scripts" ]]; then
    # Try config location
    scripts_dir="/etc/ctftools/scripts"
  elif [[ -d "/etc/autosetup/scripts" ]]; then
    # Try legacy system location
    scripts_dir="/etc/autosetup/scripts"
  elif [[ -d "scripts" ]]; then
    # Try current directory
    scripts_dir="$(pwd)/scripts"
  else
    # Default to same directory
    scripts_dir="scripts"
  fi

  # Replace script references with absolute paths
  TOOL_COMMANDS=()
  for cmd in "${RAW_COMMANDS[@]}"; do
    # Replace "scripts/" with the full path to scripts directory
    cmd="${cmd//scripts\//$scripts_dir\/}"
    TOOL_COMMANDS+=("$cmd")
  done

  if [[ ${#TOOL_NAMES[@]} -eq 0 ]]; then
    echo -e "${RED}Error: No tools found in $json_file${NC}"
    exit 1
  fi

  echo -e "${GREEN}Loaded ${#TOOL_NAMES[@]} tools from $json_file${NC}"

  # Export the json_file path so that other parts of the script can use it
  JSON_FILE_PATH="$json_file"
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
