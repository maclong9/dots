#!/bin/sh

# • Constants

# Define ANSI color codes
export BLACK='\033[0;30m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[0;37m'

export BRIGHT_BLACK='\033[1;30m'
export BRIGHT_RED='\033[1;31m'
export BRIGHT_GREEN='\033[1;32m'
export BRIGHT_YELLOW='\033[1;33m'
export BRIGHT_BLUE='\033[1;34m'
export BRIGHT_MAGENTA='\033[1;35m'
export BRIGHT_CYAN='\033[1;36m'
export BRIGHT_WHITE='\033[1;37m'
export NC='\033[0m'

# Quickly access whether on macOS or not
IS_MAC=${IS_MAC:-$([ "$(uname)" = "Darwin" ] && echo true || echo false)}

# • Basic utilities

# Logs a message with a specified level to both console and file.
#
# Outputs a formatted message to stdout or stderr with color coding, and also logs
# to a file in /tmp derived from the calling script name (e.g., maintenance.sh -> /tmp/maintenance.log).
#
# - Parameters:
#   - level: Log level (info, success, warning, error, debug).
#   - message: Message to log.
# - Usage:
#   ```sh
#   log info "Starting process..."
#   log debug "Debugging info"  # Only shown if DEBUG=true
#   ```
log() {
    level="$1"
    message="$2"

    if [ -z "$LOG_FILE" ]; then
        script_name=$(basename "${0%.*}" 2>/dev/null || echo "utils")
        LOG_FILE="/tmp/${script_name}.log"
    fi

    # Choose color + uppercase label for console
    case "$level" in
        info)
            color="$BLUE"
            label="INFO"
            ;;
        success)
            color="$GREEN"
            label="SUCCESS"
            ;;
        warning)
            color="$YELLOW"
            label="WARNING"
            ;;
        error)
            color="$RED"
            label="ERROR"
            ;;
        debug)
            color="$CYAN"
            label="DEBUG"
            ;;
        plain)
            color=""
            label=""
            ;;
        *)
            color="$WHITE"
            label="$(printf '%s' "$level" | tr '[:lower:]' '[:upper:]')"
            ;;
    esac

    # Console output (with color + brackets)
    if [ "$level" = "warning" ] || [ "$level" = "error" ] || [ "$level" = "debug" ]; then
        printf "${color}[%s]${NC} %s\n" "$label" "$message" >&2
    elif [ "$level" = "plain" ]; then
        printf "%s\n" "$message"
    else
        printf "${color}[%s]${NC} %s\n" "$label" "$message"
    fi

    # File output (plain uppercase, no ANSI codes, no square brackets)
    if [ "$level" != "debug" ] || [ "$DEBUG" = "true" ]; then
        if [ "$level" = "plain" ]; then
            printf "%s\n" "$message" >>"$LOG_FILE"
        else
            printf "[%s] %s\n" "$label" "$message" >>"$LOG_FILE"
        fi
    fi
}

# Parses command line arguments and sets environment variables.
#
# Converts `--key=value` and `--flag` arguments to uppercase environment variables (e.g., `--debug` becomes `DEBUG=true`).
#
# - Parameters:
#   - args: All command line arguments.
# - Usage:
#   ```sh
#   parse_args "$@"
#   echo $DEBUG  # Outputs: true if --debug was passed
#   ```
parse_args() {
    while [ $# -gt 0 ]; do
        case $1 in
            --*=*)
                key="${1#--}"
                var_name=$(echo "${key%%=*}" | tr '[:lower:]-' '[:upper:]_')
                var_value="${key#*=}"
                eval "${var_name}='${var_value}'"
                shift
                ;;
            --*)
                var_name=$(echo "${1#--}" | tr '[:lower:]-' '[:upper:]_')
                eval "${var_name}=true"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Displays a spinner animation while running a command.
#
# Shows a rotating spinner with a message while executing a command in the background.
#
# - Parameters:
#   - message: Message to display alongside the spinner.
#   - command: Command and arguments to execute.
# - Returns:
#   - The exit code of the executed command.
# - Usage:
#   ```sh
#   spinner "Processing files..." sleep 2
#   ```
spinner() {
    message="$1"
    shift

    if [ "$DEBUG" = "true" ]; then
        # In debug mode, run command directly without spinner
        printf "%s\n" "$message"
        "$@"
        return $?
    fi

    tmp_out=$(mktemp 2>/dev/null || echo "/tmp/spinner_out_$.log")
    tmp_err=$(mktemp 2>/dev/null || echo "/tmp/spinner_error_$.log")

    printf "%s " "$message"

    # Run command and capture both stdout and stderr
    "$@" >"$tmp_out" 2>"$tmp_err" &
    pid=$!

    chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    i=0
    while kill -0 "$pid" 2>/dev/null; do
        char=$(printf "%s" "$chars" | cut -c$((i % 10 + 1)))
        printf "\r%s %s" "$message" "$char"
        sleep 0.1
        i=$((i + 1))
    done

    wait "$pid"
    exit_code=$?

    if [ "$exit_code" -eq 0 ]; then
        printf "\r%s ✓\n" "$message"
    else
        printf "\r%s ✗\n" "$message"
        # Show errors to stderr for debugging
        if [ -s "$tmp_err" ]; then
            log error "Command failed with output:"
            cat "$tmp_err" >&2
        else
            log error "Command failed with exit code $exit_code (no error output captured)"
        fi
    fi

    rm -f "$tmp_out" "$tmp_err"

    return "$exit_code"
}

# Executes a command with automatic logging and error handling.
#
# Logs the command being executed, runs it, and logs an error if it fails.
# Provides comprehensive command execution with full logging support.
#
# - Parameters:
#   - command: Command string to execute.
#   - error_msg: Error message to log if command fails (optional).
# - Returns:
#   - 0 if command succeeds.
#   - 1 if command fails.
# - Usage:
#   ```sh
#   try_run "mkdir /tmp/test" "create test directory"
#   try_run "ls -la"  # Auto-generates error message
#   ```
try_run() {
    _command="$1"
    _error_msg="${2:-execute command: $_command}"

    log info "Executing: $_command"

    if ! eval "$_command"; then
        # Auto-prepend "Failed to" if not already present
        case "$_error_msg" in
            "Failed to"* | "")
                log error "$_error_msg"
                ;;
            *)
                log error "Failed to $_error_msg"
                ;;
        esac
        return 1
    fi
    return 0
}

# • File management

# Creates a timestamped backup of an existing file or directory.
#
# Copies a file or directory to a backup with a timestamp suffix before modification.
#
# - Parameters:
#   - path: Path to the file or directory to back up.
# - Returns:
#   - The path to the backup file/directory, if created.
# - Usage:
#   ```sh
#   backup_path ~/.zshrc
#   # Creates ~/.zshrc.backup.20241215_143022
#   backup_path ~/.config
#   # Creates ~/.config.backup.20241215_143022
#   ```
backup_path() {
    path="$1"
    backup="${path}.backup.$(date +%Y%m%d_%H%M%S)"

    if [ -e "$path" ] && [ ! -L "$path" ]; then
        if [ -d "$path" ]; then
            cp -r "$path" "$backup"
            log debug "Backed up directory $path to $backup"
        elif [ -f "$path" ]; then
            cp "$path" "$backup"
            log debug "Backed up file $path to $backup"
        fi
        echo "$backup"
    fi
}

# Alias for backup_path for backward compatibility
backup_file() {
    backup_path "$@"
}

# Counts files matching a pattern.
#
# Returns the number of files that match the given pattern. Most useful for bebug statements
# by counting the files that will be affected and printing using `log debug`
#
# - Parameters:
#   - pattern: File pattern/glob to match.
# - Returns:
#   - The number of matching files.
# - Usage:
#   ```sh
#   count=$(count_files "*.txt")
#   echo $count
#   ```
count_files() {
    pattern="$1"
    count=0
    for file in $pattern; do
        [ -f "$file" ] && count=$((count + 1))
    done
    echo $count
}

# Validates source file and returns its absolute path.
#
# Checks if source file exists and converts relative path to absolute path.
#
# - Parameters:
#   - source_file: Path to the source file to validate.
# - Returns:
#   - 0 on success, outputs absolute path to stdout.
#   - 1 if source file doesn't exist.
validate_symlink_source() {
    source_file="$1"

    if [ ! -f "$source_file" ]; then
        log error "Source file does not exist: $source_file"
        return 1
    fi

    # Get absolute path of source file
    absolute_path=$(cd "$(dirname "$source_file")" && pwd)/$(basename "$source_file")
    echo "$absolute_path"
    return 0
}

# Ensures target directory exists, creating it if necessary.
#
# Creates the parent directory structure for the target file.
#
# - Parameters:
#   - target_file: Path where symlink will be created.
# - Returns:
#   - 0 on success.
#   - 1 if directory creation fails.
ensure_target_directory() {
    target_file="$1"
    target_dir=$(dirname "$target_file")

    if [ ! -d "$target_dir" ]; then
        log debug "Creating target directory: $target_dir"
        if ! mkdir -p "$target_dir"; then
            log error "Failed to create target directory: $target_dir"
            return 1
        fi
    fi
    return 0
}

# Backs up existing regular file if it's not a symlink.
#
# Creates a timestamped backup of the existing file before symlinking.
#
# - Parameters:
#   - target_file: Path to potentially backup.
# - Returns:
#   - 0 always (backup is optional).
backup_existing_file() {
    target_file="$1"

    if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
        backup_file "$target_file" >/dev/null
        log debug "Backed up existing file: $target_file"
    fi
    return 0
}

# Removes existing file or symlink at target location.
#
# Cleans up the target location before creating new symlink.
#
# - Parameters:
#   - target_file: Path to clean up.
# - Returns:
#   - 0 on success.
#   - 1 if removal fails.
remove_existing_target() {
    target_file="$1"

    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        log debug "Removing existing file/symlink: $target_file"
        if ! rm "$target_file"; then
            log error "Failed to remove existing file: $target_file"
            return 1
        fi
    fi
    return 0
}

# Creates symlink and verifies it was created correctly.
#
# Creates the symbolic link and validates it points to the correct target.
#
# - Parameters:
#   - source_file: Absolute path to source file.
#   - target_file: Path where symlink will be created.
# - Returns:
#   - 0 on success.
#   - 1 if creation or verification fails.
create_and_verify_symlink() {
    source_file="$1"
    target_file="$2"

    # Create the symlink
    log debug "Creating symlink: $source_file -> $target_file"
    if ! ln -s "$source_file" "$target_file"; then
        log error "Failed to create symlink from $source_file to $target_file"
        return 1
    fi

    # Verify the symlink was created successfully
    if [ ! -L "$target_file" ]; then
        log error "Symlink was not created: $target_file"
        return 1
    fi

    # Verify the symlink points to the correct target
    if [ "$(readlink "$target_file")" != "$source_file" ]; then
        log error "Symlink points to wrong target. Expected: $source_file, Got: $(readlink "$target_file")"
        return 1
    fi

    return 0
}

# Creates symbolic links safely with backup and cleanup.
#
# Backs up existing files, removes old symlinks, and creates new symbolic links.
# This function orchestrates the entire symlinking process through smaller helper functions.
#
# - Parameters:
#   - source_file: Source file path (target of symlink).
#   - target_file: Destination path (where symlink will be created).
# - Returns:
#   - 0 on success.
#   - 1 if any step fails.
# - Usage:
#   ```sh
#   safe_symlink "$PWD/.zshrc" "$HOME/.zshrc"
#   ```
safe_symlink() {
    source_file="$1"
    target_file="$2"
    filename=$(basename "$source_file")

    log debug "Processing file: $source_file -> $target_file"

    # Validate source file and get absolute path
    source_file=$(validate_symlink_source "$source_file") || return 1

    # Ensure target directory exists
    ensure_target_directory "$target_file" || return 1

    # Backup existing file if needed
    backup_existing_file "$target_file" || return 1

    # Remove existing target
    remove_existing_target "$target_file" || return 1

    # Create and verify symlink
    create_and_verify_symlink "$source_file" "$target_file" || return 1

    log success "Symlinked $filename"
    log debug "Successfully created symlink: $source_file -> $target_file"
    return 0
}

# Downloads a file from a URL with progress indication
#
# Uses `curl` to download files
#
# - Parameters:
#   - url: URL to download from.
#   - dest: destination path.
# - Returns:
#   - 0 on success.
#   - 1 if `curl` is not available.
# - Usage:
#   ```sh
#   download_file "https://example.com/file" "/tmp/file"
#   ```
download_file() {
    url="$1"
    dest="$2"
    filename=$(basename "$dest")

    log debug "Downloading $filename from $url"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    else
        log error "Neither curl unavailable"
        return 1
    fi
}

# • Process management

# Logs an error message and exits the script with the specified exit code.
#
# Provides a standardized way to handle fatal errors across scripts.
#
# - Parameters:
#   - exit_code: Exit code to use (default: 1).
#   - message: Error message to log.
# - Returns:
#   - Never returns (exits script).
# - Usage:
#   ```sh
#   die 3 "Database connection failed"
#   die "Configuration file not found"  # Uses exit code 1
#   ```
die() {
    _exit_code=1
    if [ "$#" -gt 1 ]; then
        _exit_code="$1"
        shift
    fi
    log error "$*"
    exit "$_exit_code"
}

# Checks if a command or program exists in the system PATH.
#
# Uses command -v to check for command availability in a POSIX-compliant way.
#
# - Parameters:
#   - command_name: Name of the command to check for.
# - Returns:
#   - 0 if command exists.
#   - 1 if command not found.
# - Usage:
#   ```sh
#   if command_exists git; then
#       echo "Git is available"
#   fi
#   ```
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Safely changes to a directory with error handling.
#
# Changes to the specified directory and exits with error message if the change fails.
#
# - Parameters:
#   - directory: Path to change to.
# - Returns:
#   - 0 on success.
#   - Exits script with code 1 if directory change fails.
# - Usage:
#   ```sh
#   safe_cd "/path/to/directory"
#   ```
safe_cd() {
    if ! cd "$1"; then
        log error "Failed to change directory to: $1"
        exit 1
    fi
}

# Creates a directory if it doesn't already exist.
#
# Uses mkdir -p to create the directory and any necessary parent directories.
#
# - Parameters:
#   - directory: Path to create.
# - Returns:
#   - 0 on success.
#   - 1 if directory creation fails.
# - Usage:
#   ```sh
#   ensure_dir "/path/to/new/directory"
#   ```
ensure_dir() {
    if [ ! -d "$1" ]; then
        if ! mkdir -p "$1"; then
            log error "Failed to create directory: $1"
            return 1
        fi
        log debug "Created directory: $1"
    fi
    return 0
}

# Acquires a lock file to prevent concurrent script execution.
#
# Creates a lock file at the specified path. If the lock file already exists,
# the function exits with an error message.
#
# - Parameters:
#   - lock_file: Path to the lock file.
#   - script_name: Name of the script (for error messages).
# - Returns:
#   - 0 on success.
#   - Exits script with code 5 if lock already exists.
# - Usage:
#   ```sh
#   acquire_lock "/tmp/myscript.lock" "myscript.sh"
#   ```
acquire_lock() {
    _lock_file="$1"
    _script_name="${2:-script}"

    if [ -f "$_lock_file" ]; then
        log error "Previous $_script_name still running. Lock file exists: $_lock_file"
        exit 5
    fi

    if ! touch "$_lock_file"; then
        log error "Failed to create lock file: $_lock_file"
        exit 1
    fi
    log debug "Acquired lock file: $_lock_file"
}

# Releases a lock file created by acquire_lock.
#
# Removes the lock file if it exists. Logs a warning if removal fails
# but does not exit the script.
#
# - Parameters:
#   - lock_file: Path to the lock file to remove.
# - Returns:
#   - 0 always (non-fatal operation).
# - Usage:
#   ```sh
#   release_lock "/tmp/myscript.lock"
#   ```
release_lock() {
    _lock_file="$1"

    if [ -f "$_lock_file" ]; then
        if ! rm -f "$_lock_file"; then
            log warning "Failed to remove lock file: $_lock_file"
        else
            log debug "Released lock file: $_lock_file"
        fi
    fi
}
