#!/bin/sh

# MARK: - Constants

# Defines ANSI color codes and system detection variables.
#
# Sets up color codes for logging and determines if the system is macOS.
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

IS_MAC=${IS_MAC:-$([ "$(uname)" = "Darwin" ] && echo true || echo false)}

# MARK: - Functions

# Logs a message with a specified level.
#
# Outputs a formatted message to stdout or stderr based on the log level, with appropriate color coding.
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
    case "$level" in
        info) printf "${BLUE}[INFO]${NC} %s\n" "$message" ;;
        success) printf "${GREEN}[SUCCESS]${NC} %s\n" "$message" ;;
        warning) printf "${YELLOW}[WARNING]${NC} %s\n" "$message" >&2 ;;
        error) printf "${RED}[ERROR]${NC} %s\n" "$message" >&2 ;;
        debug)
            if [ "$DEBUG" = "true" ]; then
                printf "${CYAN}[DEBUG]${NC} %s\n" "$message" >&2
            fi
            ;;
    esac
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

# Executes a command with automatic error logging and failure handling.
#
# Evaluates a command string and logs an error message if the command fails.
# Returns 1 on command failure to allow for proper error propagation.
#
# - Parameters:
#   - command: Command string to execute.
#   - error_msg: Error message to log if command fails.
# - Returns:
#   - 0 if command succeeds.
#   - 1 if command fails.
# - Usage:
#   ```sh
#   run_or_fail "mkdir /tmp/test" "Failed to create test directory"
#   run_or_fail "git clone repo.git" "Failed to clone repository" || return 1
#   ```
run_or_fail() {
    command="$1"
    error_msg="$2"

    eval "$command" || {
        log error "$error_msg"
        return 1
    }
}

# Creates a timestamped backup of an existing file.
#
# Copies a file to a backup with a timestamp suffix before modification.
#
# - Parameters:
#   - file: Path to the file to back up.
# - Returns:
#   - The path to the backup file, if created.
# - Usage:
#   ```sh
#   backup_file ~/.vimrc
#   # Creates ~/.vimrc.backup.20241215_143022
#   ```
backup_file() {
    file="$1"
    backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"

    if [ -f "$file" ] && [ ! -L "$file" ]; then
        cp "$file" "$backup"
        log debug "Backed up $file to $backup"
        echo "$backup"
    fi
}

# Counts files matching a pattern.
#
# Returns the number of files that match the given pattern.
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

# Creates symbolic links safely with backup and cleanup.
#
# Backs up existing files, removes old symlinks, and creates new symbolic links.
#
# - Parameters:
#   - source_file: Source file path (target of symlink).
#   - target_file: Destination path (where symlink will be created).
# - Usage:
#   ```sh
#   safe_symlink "$PWD/.vimrc" "$HOME/.vimrc"
#   ```
safe_symlink() {
    source_file="$1"
    target_file="$2"
    filename=$(basename "$source_file")

    log debug "Processing file: $source_file -> $target_file"

    # Validate source file exists
    if [ ! -f "$source_file" ]; then
        log error "Source file does not exist: $source_file"
        return 1
    fi

    # Get absolute path of source file
    source_file=$(cd "$(dirname "$source_file")" && pwd)/$(basename "$source_file")

    # Ensure target directory exists
    target_dir=$(dirname "$target_file")
    if [ ! -d "$target_dir" ]; then
        log debug "Creating target directory: $target_dir"
        if ! mkdir -p "$target_dir"; then
            log error "Failed to create target directory: $target_dir"
            return 1
        fi
    fi

    # Backup existing regular file (not symlink)
    if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
        backup_file "$target_file" >/dev/null
        log debug "Backed up existing file: $target_file"
    fi

    # Remove existing file or symlink
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        log debug "Removing existing file/symlink: $target_file"
        if ! rm "$target_file"; then
            log error "Failed to remove existing file: $target_file"
            return 1
        fi
    fi

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

    log success "Symlinked $filename"
    log debug "Successfully created symlink: $source_file -> $target_file"
    return 0
}

# Creates directory and parent directories if they don't exist.
#
# Equivalent to `mkdir -p`, creates the full directory path.
#
# - Parameters:
#   - dir: Directory path to create.
# - Usage:
#   ```sh
#   ensure_directory "$HOME/.config/colors"
#   ```
ensure_directory() {
    dir="$1"
    log debug "Creating directory: $dir"
    mkdir -p "$dir"
}

# Downloads a file from a URL with progress indication.
#
# Uses `curl` or `wget` to download files with fallback support.
#
# - Parameters:
#   - url: URL to download from.
#   - dest: destination path.
# - Returns:
#   - 0 on success.
#   - 1 if neither `curl` nor `wget` is available.
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
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$dest"
    else
        log error "Neither curl nor wget available"
        return 1
    fi
}

# Verifies file integrity using SHA-256 checksum.
#
# Compares a file's checksum against an expected value.
#
# - Parameters:
#   - file: File path to verify.
#   - expected: Expected SHA-256 checksum.
# - Returns:
#   - 0 if checksum matches or no checksum tool is available.
#   - 1 if checksum does not match.
# - Usage:
#   ```sh
#   verify_checksum "/tmp/file" "abc123def456..."
#   ```
verify_checksum() {
    file="$1"
    expected="$2"
    actual

    if command -v shasum >/dev/null 2>&1; then
        actual=$(shasum -a 256 "$file" | cut -d' ' -f1)
    elif command -v sha256sum >/dev/null 2>&1; then
        actual=$(sha256sum "$file" | cut -d' ' -f1)
    else
        log warning "No checksum tool available, skipping verification"
        return 0
    fi

    if [ "$actual" = "$expected" ]; then
        log success "Checksum verified for $(basename "$file")"
        return 0
    else
        log error "Checksum mismatch for $(basename "$file")"
        log error "Expected: $expected"
        log error "Actual:   $actual"
        return 1
    fi
}

# Creates standard development directory structure.
#
# Sets up organized project directories under `~/Developer`.
#
# - Parameters:
#   - None
# - Usage:
#   ```sh
#   create_dev_directories
#   ```
create_dev_directories() {
    base_dir="$HOME/Developer"
    dirs="personal clients study work"

    for dir in $dirs; do
        ensure_directory "$base_dir/$dir"
        log success "Created directory: $base_dir/$dir"
    done
}
