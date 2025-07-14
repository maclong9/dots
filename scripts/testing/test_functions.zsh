#!/bin/zsh

# Unit tests for functions.zsh
# Run with: zsh ./test_functions.zsh

set -e

# Test configuration
TEST_DIR="/tmp/functions_test_$$"
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Test utilities
setup_test() {
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    TEST_COUNT=$((TEST_COUNT + 1))
}

cleanup_test() {
    cd /
    rm -rf "$TEST_DIR"
}

assert_equals() {
    expected="$1"
    actual="$2"
    test_name="$3"
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✓ $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ $test_name"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

assert_contains() {
    haystack="$1"
    needle="$2"
    test_name="$3"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "✓ $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ $test_name"
        echo "  Expected '$haystack' to contain '$needle'"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

assert_command_exists() {
    command="$1"
    test_name="$2"
    
    if command -v "$command" >/dev/null 2>&1; then
        echo "✓ $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ $test_name"
        echo "  Command '$command' does not exist"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# Load the functions to test
source "$(dirname "$0")/../core/functions.zsh"

# Test kp function
test_kp_function() {
    echo "Testing kp function..."
    
    # Test kp without arguments
    output=$(kp 2>&1)
    assert_contains "$output" "Usage: kp <port>" "kp shows usage without arguments"
    
    # Test kp with non-existent port
    output=$(kp 99999 2>&1)
    assert_contains "$output" "No process found on port 99999" "kp handles non-existent port"
}

# Test clc function
test_clc_function() {
    echo "Testing clc function..."
    
    # Test clc function exists
    assert_command_exists "clc" "clc function is defined"
    
    # Test clc with no history (simulate no previous command)
    # This is hard to test without mocking, so we'll just check if the function exists
    if type clc >/dev/null 2>&1; then
        echo "✓ clc function is callable"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ clc function is not callable"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# Test directory navigation functions
test_directory_navigation() {
    echo "Testing directory navigation functions..."
    
    # Test -- function exists
    assert_command_exists "--" "-- function is defined"
    
    # Test ++ function exists
    assert_command_exists "++" "++ function is defined"
    
    # Initialize directory history variables if not set
    if [[ -z "$_dir_history" ]]; then
        _dir_history=()
        _dir_history_index=0
    fi
    
    # Test navigation without history
    output=$(-- 2>&1)
    assert_contains "$output" "No previous directory" "-- shows message with no history"
    
    output=$(++ 2>&1)
    assert_contains "$output" "No forward directory" "++ shows message with no history"
}

# Test function parameter documentation
test_function_documentation() {
    echo "Testing function documentation..."
    
    # Read the functions file and check for documentation patterns
    functions_file="$(dirname "$0")/../core/functions.zsh"
    
    if [[ -f "$functions_file" ]]; then
        # Check for parameter documentation
        if grep -q "Parameters:" "$functions_file"; then
            echo "✓ Functions have parameter documentation"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo "✗ Functions missing parameter documentation"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
        
        # Check for usage examples
        if grep -q "Usage:" "$functions_file"; then
            echo "✓ Functions have usage examples"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo "✗ Functions missing usage examples"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
        
        # Check for return value documentation
        if grep -q "Returns:" "$functions_file"; then
            echo "✓ Functions have return value documentation"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo "✗ Functions missing return value documentation"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        echo "✗ Functions file not found"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# Test process management functionality
test_process_management() {
    echo "Testing process management functionality..."
    
    # Test that lsof command is available (required for kp function)
    if command -v lsof >/dev/null 2>&1; then
        echo "✓ lsof command is available"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ lsof command is not available"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    # Test that kill command is available
    if command -v kill >/dev/null 2>&1; then
        echo "✓ kill command is available"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ kill command is not available"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# Test clipboard functionality
test_clipboard_functionality() {
    echo "Testing clipboard functionality..."
    
    # Test that pbcopy command is available (required for clc function)
    if command -v pbcopy >/dev/null 2>&1; then
        echo "✓ pbcopy command is available"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ pbcopy command is not available (expected on macOS)"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    # Test that fc command is available (required for clc function)
    if command -v fc >/dev/null 2>&1; then
        echo "✓ fc command is available"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ fc command is not available"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# Test function names follow conventions
test_naming_conventions() {
    echo "Testing naming conventions..."
    
    functions_file="$(dirname "$0")/../core/functions.zsh"
    
    # Check that function names are descriptive
    if [[ -f "$functions_file" ]]; then
        # Look for function definitions
        function_names=$(grep -E "^[a-zA-Z_][a-zA-Z0-9_]*\\(\\)" "$functions_file" | sed 's/().*//')
        
        for func_name in $function_names; do
            # Check if function name is not just abbreviations
            if [[ ${#func_name} -gt 1 ]]; then
                echo "✓ Function name '$func_name' is descriptive"
                PASS_COUNT=$((PASS_COUNT + 1))
            else
                echo "✗ Function name '$func_name' could be more descriptive"
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
        done
    fi
}

# Main test runner
main() {
    echo "Running functions.zsh unit tests..."
    echo "=================================="
    
    # Run all tests
    test_kp_function
    test_clc_function
    test_directory_navigation
    test_function_documentation
    test_process_management
    test_clipboard_functionality
    test_naming_conventions
    
    # Summary
    echo "=================================="
    echo "Test Results:"
    echo "  Total tests: $TEST_COUNT"
    echo "  Passed: $PASS_COUNT"
    echo "  Failed: $FAIL_COUNT"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo "All tests passed! ✓"
        exit 0
    else
        echo "Some tests failed! ✗"
        exit 1
    fi
}

# Run tests
main