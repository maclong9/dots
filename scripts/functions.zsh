#!/bin/bash
# Navigates to iCloud directories.
#
# Changes directory to the specified iCloud path or the iCloud root if no path is provided.
#
# - Parameters:
#   - path: Optional path relative to iCloud root.
# - Returns:
#   - 0 on success.
#   - 1 if the directory does not exist.
# - Usage:
#   ```sh
#   cdi Documents
#   cdi
#   ```
cdi() {
    local target="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
    [ $# -gt 0 ] && target="$target/$*"
    if [ -d "$target" ]; then
        cd "$target" || return 1
    else
        echo "Directory not found: $target"
        return 1
    fi
}

# Navigates to development directories (shorthand for cdd).
#
# Changes directory to the specified development directory under `~/Developer`, supporting deeper subdirectories.
#
# - Parameters:
#   - dir: Directory name or shorthand (p/personal, c/clients, s/study, w/work).
#   - subdirs: Optional subdirectories to navigate deeper.
# - Returns:
#   - 0 on success.
#   - 1 if the directory does not exist.
# - Usage:
#   ```sh
#   cdd personal project1
#   cdd p
#   dev personal project1  # alias for cdd
#   ```
cdd() {
    local target="$HOME/Developer"
    case "$1" in
        p | personal) target="$target/personal" ;;
        c | clients) target="$target/clients" ;;
        s | study) target="$target/study" ;;
        w | work) target="$target/work" ;;
        *) target="$target/${1:-}" ;;
    esac
    shift
    [ $# -gt 0 ] && target="$target/$*"
    if [ -d "$target" ]; then
        cd "$target" || return 1
    else
        echo "Directory not found: $target"
        return 1
    fi
}

# Alias for cdd - navigates to development project directories.
#
# This is an alias for the cdd function to maintain compatibility.
dev() {
    cdd "$@"
}

# Kills a process running on a specified port.
#
# Terminates the process listening on the given TCP port.
#
# - Parameters:
#   - port: Port number to check.
# - Returns:
#   - 0 if a process was killed or no process was found.
#   - 1 if no port was provided.
# - Usage:
#   ```sh
#   kp 3000
#   ```
kp() {
    [[ -z "$1" ]] && {
        echo "Usage: kp <port>"
        return 1
    }
    local pid
    pid=$(lsof -ti tcp:"$1")
    if [[ -n "$pid" ]]; then
        kill -9 "$pid" && echo "Killed process on port $1"
    else
        echo "No process found on port $1"
    fi
}
