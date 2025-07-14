# Testing Framework for Shell Utilities

This directory contains unit tests for the shell utilities in this configuration repository.

## Test Files

### `test_utils.sh`
Unit tests for the functions in `utils.sh`:
- `log()` - Logging with different levels
- `parse_args()` - Command-line argument parsing
- `count_files()` - File counting utility
- `backup_file()` - File backup functionality
- `validate_symlink_source()` - Source file validation
- `ensure_target_directory()` - Directory creation
- `backup_existing_file()` - Existing file backup
- `remove_existing_target()` - Target cleanup
- `create_and_verify_symlink()` - Symlink creation and verification
- `safe_symlink()` - Complete symlink process
- `run_or_fail()` - Command execution with error handling

### `test_functions.zsh`
Unit tests for the functions in `functions.zsh`:
- `kp()` - Kill process by port
- `clc()` - Copy last command output to clipboard
- `--()` - Navigate backward in directory history
- `++()` - Navigate forward in directory history

## Running Tests

### Prerequisites
- POSIX-compliant shell (sh, bash, dash)
- Zsh (for functions.zsh tests)
- Standard Unix utilities (find, grep, wc, etc.)

### Running Utils Tests
```bash
cd /Users/mac/.config/scripts
./test_utils.sh
```

### Running Functions Tests
```bash
cd /Users/mac/.config/scripts
zsh ./test_functions.zsh
```

### Running All Tests
```bash
cd /Users/mac/.config/scripts
./test_utils.sh && zsh ./test_functions.zsh
```

## Test Results

The test suite validates:
- ✅ **Function correctness** - All functions work as documented
- ✅ **Error handling** - Functions handle invalid inputs gracefully
- ✅ **File operations** - Symlinks, backups, and directory creation work properly
- ✅ **Argument parsing** - Command-line arguments are processed correctly
- ✅ **Logging functionality** - Log messages are formatted correctly
- ✅ **Documentation compliance** - Functions have proper parameter and usage documentation

## Integration with CI/CD

These unit tests complement the existing comprehensive integration tests in `.github/workflows/shell-tests.yml`, which test:
- POSIX compliance across different shells
- macOS and Linux compatibility
- Security scanning
- Code formatting
- Complete dotfiles setup process

## Test Coverage

The unit tests focus on individual function behavior, while the CI/CD tests ensure:
- Cross-platform compatibility
- Security best practices
- Integration with the broader system
- Performance and resource usage

## Adding New Tests

When adding new functions to `utils.sh` or `functions.zsh`:

1. Add corresponding test cases to the appropriate test file
2. Follow the existing naming convention: `test_function_name()`
3. Include tests for:
   - Normal operation
   - Error conditions
   - Edge cases
   - Parameter validation

## Test Architecture

The tests use a simple assertion framework with:
- `assert_equals()` - Compare expected vs actual values
- `assert_file_exists()` - Check file existence
- `assert_dir_exists()` - Check directory existence
- `assert_symlink_exists()` - Check symlink existence
- `assert_symlink_target()` - Verify symlink target
- `assert_contains()` - Check substring presence
- `assert_command_exists()` - Verify command availability

Each test runs in isolation with proper setup and cleanup to ensure no interference between tests.