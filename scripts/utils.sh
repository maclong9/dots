#!/bin/sh

#!/bin/sh

# POSIX Shell Utility Functions
#
# Provides logging, argument parsing, filesystem helpers,
# and safe symbolic link creation.
#
# Designed for sourcing into other POSIX-compliant shell scripts.
#
# Usage:
#   curl -fsSL \
#       "https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/utils.sh" \
#       -o /tmp/utils.sh && . /tmp/utils.sh
#
# Once sourced, you may call functions such as required

# ANSI Color Codes

# Regular Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Bright Colors
BRIGHT_BLACK='\033[1;30m'
BRIGHT_RED='\033[1;31m'
BRIGHT_GREEN='\033[1;32m'
BRIGHT_YELLOW='\033[1;33m'
BRIGHT_BLUE='\033[1;34m'
BRIGHT_MAGENTA='\033[1;35m'
BRIGHT_CYAN='\033[1;36m'
BRIGHT_WHITE='\033[1;37m'

# Reset
NC='\033[0m' # No Color

# Checks if the system is macOS (auto-detected if unset).
IS_MAC=${IS_MAC:-$([ "$(uname)" = "Darwin" ] && echo true || echo false)}

# Function: parse_args
#
# Parses command-line arguments into environment variables.
#
# Supported flags:
#   --debug          Enable debug logging.
#   --verbose        Enable verbose output.
#   --is-mac         Force IS_MAC=true.
#   --key=value      Set environment variable KEY=VALUE.
#   --flag           Set environment variable FLAG=true.
#
# Usage:
#   parse_args "$@"
#
# Notes:
#   - Relies on `eval` for dynamic var assignment.
#   - Converts flags and key names to uppercase.
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

# Function: count_files
#
# Counts the number of regular files matching a given pattern.
#
# Parameters:
#   $1 - A glob pattern (e.g. "*.txt")
#
# Returns:
#   Integer count of matching regular files.
#
# Usage:
#   count=$(count_files "*.md")
#
# Notes:
#   - Only counts files (not directories or symlinks).
count_files() {
  pattern="$1"
  count=0
  for file in $pattern; do
    [ -f "$file" ] && count=$((count + 1))
  done
  echo $count
}

# Function: safe_symlink
#
# Creates or replaces a symbolic link.
#
# Parameters:
#   $1 - Source file path.
#   $2 - Target symlink path.
#
# Usage:
#   safe_symlink "./dotfiles/.vimrc" "$HOME/.vimrc"
#
# Notes:
#   - Removes existing file or symlink at target location.
safe_symlink() {
  source_file="$1"
  target_file="$2"
  filename=$(basename "$source_file")
  
  log_debug "Processing file: $source_file -> $target_file"
  
  if [ -e "$target_file" ] || [ -L "$target_file" ]; then
    log_debug "Removing existing file/symlink: $target_file"
    rm "$target_file"
  fi
  
  ln -s "$source_file" "$target_file"
  log_success "Symlinked $filename"
  log_debug "Created symlink: $source_file -> $target_file"
}

# Function: ensure_directory
#
# Ensures a directory exists, creating it if necessary.
#
# Parameters:
#   $1 - Path to directory.
#
# Usage:
#   ensure_directory "$HOME/.config/myapp"
#
# Notes:
#   - Uses `mkdir -p`.
ensure_directory() {
  dir="$1"
  log_debug "Creating directory: $dir"
  mkdir -p "$dir"
}

# Logging Utilities

# Function: log_info
#
# Logs an informational message (blue).
#
# Usage:
#   log_info "Starting installation..."
log_info() {
  printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

# Function: log_success
#
# Logs a success message (green).
#
# Usage:
#   log_success "Files synced."
log_success() {
  printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

# Function: log_warning
#
# Logs a warning message (yellow).
#
# Usage:
#   log_warning "File not found, skipping."
log_warning() {
  printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

# Function: log_error
#
# Logs an error message (red).
#
# Usage:
#   log_error "Unable to write to /etc."
log_error() {
  printf "${RED}[ERROR]${NC} %s\n" "$1"
}

# Function: log_debug
#
# Logs a debug message (cyan) only if DEBUG=true.
#
# Usage:
#   log_debug "Resolved path: $path"
log_debug() {
  if [ "$DEBUG" = true ]; then
    printf "${CYAN}[DEBUG]${NC} %s\n" "$1"
  fi
}
