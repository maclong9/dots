#!/bin/sh

# Unit tests for utils.sh functions
# Run with: ./test_utils.sh

set -e

# Test configuration
TEST_DIR="/tmp/utils_test_$$"
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
    
    if [ "$expected" = "$actual" ]; then
        echo "✓ $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ $test_name"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

assert_file_exists() {
    file="$1"
    test_name="$2"
    
    if [ -f "$file" ]; then
        echo "✓ $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ $test_name"
        echo "  File '$file' does not exist"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

assert_dir_exists() {
    dir="$1"
    test_name="$2"
    
    if [ -d "$dir" ]; then
        echo "✓ $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ $test_name"
        echo "  Directory '$dir' does not exist"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

assert_symlink_exists() {
    link="$1"
    test_name="$2"
    
    if [ -L "$link" ]; then
        echo "✓ $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ $test_name"
        echo "  Symlink '$link' does not exist"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

assert_symlink_target() {
    link="$1"
    expected_target="$2"
    test_name="$3"
    
    if [ -L "$link" ]; then
        actual_target=$(readlink "$link")
        if [ "$actual_target" = "$expected_target" ]; then
            echo "✓ $test_name"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo "✗ $test_name"
            echo "  Expected target: '$expected_target'"
            echo "  Actual target:   '$actual_target'"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        echo "✗ $test_name"
        echo "  '$link' is not a symlink"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# Load the functions to test
. "$(dirname "$0")/../core/utils.sh"

# Test log function
test_log_function() {
    echo "Testing log function..."
    
    # Test info logging (check if contains expected text)
    output=$(log info "test message" 2>&1)
    if echo "$output" | grep -q "\[INFO\].*test message"; then
        echo "✓ log info format"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ log info format"
        echo "  Expected: '[INFO] test message' (with colors)"
        echo "  Actual:   '$output'"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    # Test error logging (should go to stderr)
    output=$(log error "error message" 2>&1)
    if echo "$output" | grep -q "\[ERROR\].*error message"; then
        echo "✓ log error format"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ log error format"
        echo "  Expected: '[ERROR] error message' (with colors)"
        echo "  Actual:   '$output'"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    # Test debug logging (should not show unless DEBUG=true)
    output=$(log debug "debug message" 2>&1)
    assert_equals "" "$output" "log debug hidden by default"
    
    # Test debug logging with DEBUG=true
    DEBUG=true
    output=$(log debug "debug message" 2>&1)
    if echo "$output" | grep -q "\[DEBUG\].*debug message"; then
        echo "✓ log debug shown when DEBUG=true"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ log debug shown when DEBUG=true"
        echo "  Expected: '[DEBUG] debug message' (with colors)"
        echo "  Actual:   '$output'"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    DEBUG=false
}

# Test parse_args function
test_parse_args() {
    echo "Testing parse_args function..."
    
    # Test flag parsing
    parse_args --debug
    assert_equals "true" "$DEBUG" "parse_args flag parsing"
    
    # Test key=value parsing
    parse_args --name=test
    assert_equals "test" "$NAME" "parse_args key=value parsing"
    
    # Test mixed parsing
    parse_args --verbose --output=file.txt
    assert_equals "true" "$VERBOSE" "parse_args mixed flags"
    assert_equals "file.txt" "$OUTPUT" "parse_args mixed key=value"
}

# Test count_files function
test_count_files() {
    echo "Testing count_files function..."
    setup_test
    
    # Create test files
    touch file1.txt file2.txt file3.log
    
    # Test counting txt files
    count=$(count_files "*.txt")
    assert_equals "2" "$count" "count_files txt files"
    
    # Test counting all files
    count=$(count_files "*")
    assert_equals "3" "$count" "count_files all files"
    
    # Test counting non-existent files
    count=$(count_files "*.nonexistent")
    assert_equals "0" "$count" "count_files non-existent pattern"
    
    cleanup_test
}

# Test backup_file function
test_backup_file() {
    echo "Testing backup_file function..."
    setup_test
    
    # Create test file
    echo "test content" > test.txt
    
    # Test backup creation
    backup_path=$(backup_file test.txt)
    assert_file_exists "$backup_path" "backup_file creates backup"
    
    # Test backup content
    backup_content=$(cat "$backup_path")
    assert_equals "test content" "$backup_content" "backup_file preserves content"
    
    # Test backup of non-existent file
    backup_path=$(backup_file nonexistent.txt)
    assert_equals "" "$backup_path" "backup_file handles non-existent file"
    
    cleanup_test
}

# Test validate_symlink_source function
test_validate_symlink_source() {
    echo "Testing validate_symlink_source function..."
    setup_test
    
    # Create test source file
    echo "source content" > source.txt
    
    # Test valid source
    absolute_path=$(validate_symlink_source source.txt)
    expected_path="$TEST_DIR/source.txt"
    assert_equals "$expected_path" "$absolute_path" "validate_symlink_source returns absolute path"
    
    # Test invalid source
    if validate_symlink_source nonexistent.txt 2>/dev/null; then
        echo "✗ validate_symlink_source should fail for non-existent file"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    else
        echo "✓ validate_symlink_source fails for non-existent file"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
    
    cleanup_test
}

# Test ensure_target_directory function
test_ensure_target_directory() {
    echo "Testing ensure_target_directory function..."
    setup_test
    
    # Test directory creation
    ensure_target_directory "subdir/file.txt"
    assert_dir_exists "subdir" "ensure_target_directory creates directory"
    
    # Test existing directory
    ensure_target_directory "subdir/another_file.txt"
    assert_dir_exists "subdir" "ensure_target_directory handles existing directory"
    
    cleanup_test
}

# Test backup_existing_file function
test_backup_existing_file() {
    echo "Testing backup_existing_file function..."
    setup_test
    
    # Create test file
    echo "existing content" > existing.txt
    
    # Test backup of existing file
    backup_existing_file existing.txt
    # Should create a backup (can't easily test the exact name due to timestamp)
    backup_count=$(find . -name "existing.txt.backup.*" | wc -l | tr -d ' ')
    assert_equals "1" "$backup_count" "backup_existing_file creates backup"
    
    # Test backup of non-existent file (should not fail)
    backup_existing_file nonexistent.txt
    echo "✓ backup_existing_file handles non-existent file"
    PASS_COUNT=$((PASS_COUNT + 1))
    
    cleanup_test
}

# Test remove_existing_target function
test_remove_existing_target() {
    echo "Testing remove_existing_target function..."
    setup_test
    
    # Create test file
    echo "target content" > target.txt
    
    # Test file removal
    remove_existing_target target.txt
    if [ -f target.txt ]; then
        echo "✗ remove_existing_target should remove file"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    else
        echo "✓ remove_existing_target removes file"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
    
    # Test symlink removal
    echo "source content" > source.txt
    ln -s source.txt symlink.txt
    remove_existing_target symlink.txt
    if [ -L symlink.txt ]; then
        echo "✗ remove_existing_target should remove symlink"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    else
        echo "✓ remove_existing_target removes symlink"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
    
    cleanup_test
}

# Test create_and_verify_symlink function
test_create_and_verify_symlink() {
    echo "Testing create_and_verify_symlink function..."
    setup_test
    
    # Create source file
    echo "source content" > source.txt
    source_path="$TEST_DIR/source.txt"
    
    # Test symlink creation
    create_and_verify_symlink "$source_path" link.txt
    assert_symlink_exists link.txt "create_and_verify_symlink creates symlink"
    assert_symlink_target link.txt "$source_path" "create_and_verify_symlink points to correct target"
    
    cleanup_test
}

# Test complete safe_symlink function
test_safe_symlink() {
    echo "Testing safe_symlink function..."
    setup_test
    
    # Create source file
    echo "source content" > source.txt
    
    # Test complete symlink process
    safe_symlink source.txt target.txt
    assert_symlink_exists target.txt "safe_symlink creates symlink"
    
    # Test content through symlink
    content=$(cat target.txt)
    assert_equals "source content" "$content" "safe_symlink preserves content access"
    
    # Test backup of existing file
    echo "existing content" > existing_target.txt
    safe_symlink source.txt existing_target.txt
    assert_symlink_exists existing_target.txt "safe_symlink replaces existing file"
    
    # Check backup was created
    backup_count=$(find . -name "existing_target.txt.backup.*" | wc -l | tr -d ' ')
    assert_equals "1" "$backup_count" "safe_symlink creates backup of existing file"
    
    cleanup_test
}

# Test run_or_fail function
test_run_or_fail() {
    echo "Testing run_or_fail function..."
    setup_test
    
    # Test successful command
    if run_or_fail "echo 'success'" "test command"; then
        echo "✓ run_or_fail succeeds with valid command"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ run_or_fail should succeed with valid command"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    # Test failing command
    if run_or_fail "false" "test failure" 2>/dev/null; then
        echo "✗ run_or_fail should fail with invalid command"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    else
        echo "✓ run_or_fail fails with invalid command"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
    
    cleanup_test
}

# Main test runner
main() {
    echo "Running utils.sh unit tests..."
    echo "================================"
    
    # Run all tests
    test_log_function
    test_parse_args
    test_count_files
    test_backup_file
    test_validate_symlink_source
    test_ensure_target_directory
    test_backup_existing_file
    test_remove_existing_target
    test_create_and_verify_symlink
    test_safe_symlink
    test_run_or_fail
    
    # Summary
    echo "================================"
    echo "Test Results:"
    echo "  Total tests: $TEST_COUNT"
    echo "  Passed: $PASS_COUNT"
    echo "  Failed: $FAIL_COUNT"
    
    if [ $FAIL_COUNT -eq 0 ]; then
        echo "All tests passed! ✓"
        exit 0
    else
        echo "Some tests failed! ✗"
        exit 1
    fi
}

# Run tests
main