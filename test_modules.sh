#!/bin/bash

# Test Script for CTF Tools Modular System
# This script verifies that all modules load correctly and key functions work

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result function
test_result() {
    local test_name="$1"
    local result="$2"

    ((TESTS_RUN++))

    if [[ "$result" == "0" ]]; then
        echo -e "${GREEN}✓ PASS${NC} - $test_name"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC} - $test_name"
        ((TESTS_FAILED++))
    fi
}

# Function exists check
function_exists() {
    declare -f "$1" > /dev/null
    return $?
}

echo "================================================"
echo "CTF Tools - Module Loading Test Suite"
echo "================================================"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Testing module loading from: $SCRIPT_DIR"
echo ""

# Test 1: Load colors_utils.sh
echo "Testing core_functions/colors_utils.sh..."
if source "$SCRIPT_DIR/core_functions/colors_utils.sh" 2>/dev/null; then
    test_result "Load colors_utils.sh" 0
else
    test_result "Load colors_utils.sh" 1
fi

# Test 2: Load app_manager.sh
echo "Testing core_functions/app_manager.sh..."
if source "$SCRIPT_DIR/core_functions/app_manager.sh" 2>/dev/null; then
    test_result "Load app_manager.sh" 0
else
    test_result "Load app_manager.sh" 1
fi

# Test 3: Load installer.sh
echo "Testing core_functions/installer.sh..."
if source "$SCRIPT_DIR/core_functions/installer.sh" 2>/dev/null; then
    test_result "Load installer.sh" 0
else
    test_result "Load installer.sh" 1
fi

# Test 4: Load main_menu.sh
echo "Testing menu_system/main_menu.sh..."
if source "$SCRIPT_DIR/menu_system/main_menu.sh" 2>/dev/null; then
    test_result "Load main_menu.sh" 0
else
    test_result "Load main_menu.sh" 1
fi

# Test 5: Load install_menu.sh
echo "Testing menu_system/install_menu.sh..."
if source "$SCRIPT_DIR/menu_system/install_menu.sh" 2>/dev/null; then
    test_result "Load install_menu.sh" 0
else
    test_result "Load install_menu.sh" 1
fi

echo ""
echo "Testing key functions..."

# Test 6: Color functions exist
function_exists "show_success"
test_result "show_success function exists" $?

function_exists "show_error"
test_result "show_error function exists" $?

function_exists "clear_screen_with_header"
test_result "clear_screen_with_header function exists" $?

# Test 7: App manager functions exist
function_exists "load_apps"
test_result "load_apps function exists" $?

function_exists "init_selections"
test_result "init_selections function exists" $?

function_exists "toggle_selection"
test_result "toggle_selection function exists" $?

# Test 8: Installer functions exist
function_exists "install_tool"
test_result "install_tool function exists" $?

function_exists "install_selected"
test_result "install_selected function exists" $?

# Test 9: Menu functions exist
function_exists "show_main_menu"
test_result "show_main_menu function exists" $?

function_exists "main_menu_loop"
test_result "main_menu_loop function exists" $?

function_exists "show_checkbox_menu"
test_result "show_checkbox_menu function exists" $?

echo ""
echo "Testing functionality..."

# Test 10: Color output works
echo "Testing color output..."
if show_success "Test success message" >/dev/null 2>&1; then
    test_result "Color output functions work" 0
else
    test_result "Color output functions work" 1
fi

# Test 11: JSON file exists
if [[ -f "$SCRIPT_DIR/apps.json" ]]; then
    test_result "apps.json file exists" 0
else
    test_result "apps.json file exists" 1
fi

# Test 12: JSON is valid (if jq is available)
if command -v jq >/dev/null 2>&1; then
    if jq empty "$SCRIPT_DIR/apps.json" 2>/dev/null; then
        test_result "apps.json is valid JSON" 0
    else
        test_result "apps.json is valid JSON" 1
    fi
else
    echo -e "${YELLOW}⚠ SKIP${NC} - apps.json validation (jq not available)"
fi

# Test 13: Scripts directory exists
if [[ -d "$SCRIPT_DIR/scripts" ]]; then
    test_result "scripts directory exists" 0
else
    test_result "scripts directory exists" 1
fi

# Test 14: Main setup.sh loads without syntax errors
echo "Testing main setup.sh syntax..."
if bash -n "$SCRIPT_DIR/setup.sh" 2>/dev/null; then
    test_result "setup.sh syntax is valid" 0
else
    test_result "setup.sh syntax is valid" 1
fi

# Test 15: Variables are properly initialized
if [[ -n "$CURRENT_VERSION" ]]; then
    test_result "CURRENT_VERSION variable is set" 0
else
    test_result "CURRENT_VERSION variable is set" 1
fi

# Test 16: Try loading apps (if JSON exists and jq is available)
if [[ -f "$SCRIPT_DIR/apps.json" ]] && command -v jq >/dev/null 2>&1; then
    echo "Testing app loading..."
    if load_apps 2>/dev/null; then
        test_result "load_apps function works" 0

        # Test if arrays were populated
        if [[ ${#TOOL_NAMES[@]} -gt 0 ]]; then
            test_result "TOOL_NAMES array populated (${#TOOL_NAMES[@]} tools)" 0
        else
            test_result "TOOL_NAMES array populated" 1
        fi
    else
        test_result "load_apps function works" 1
    fi
else
    echo -e "${YELLOW}⚠ SKIP${NC} - App loading test (missing jq or apps.json)"
fi

echo ""
echo "================================================"
echo "TEST SUMMARY"
echo "================================================"
echo -e "Tests Run:    ${BLUE}$TESTS_RUN${NC}"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    echo -e "${GREEN}The modular system is working correctly.${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}❌ SOME TESTS FAILED!${NC}"
    echo -e "${YELLOW}Please check the failed tests above.${NC}"
    exit 1
fi
