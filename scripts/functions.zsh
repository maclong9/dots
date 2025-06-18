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
#   ```
dev() {
  local target="$HOME/Developer"
  case "$1" in
    p|personal) target="$target/personal" ;;
    c|clients) target="$target/clients" ;;
    s|study) target="$target/study" ;;
    w|work) target="$target/work" ;;
    *) target="$target/${1:-}" ;;
  esac
  shift
  [ $# -gt 0 ] && target="$target/$*"
  if [ -d "$target" ]; then
    cd "$target"
  else
    echo "Directory not found: $target"
    return 1
  fi
}

# Navigates to development project directories.
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
#   dev personal project1
#   dev p
#   ```
dev() {
  local target="$HOME/Developer"
  case "$1" in
    p|personal) target="$target/personal" ;;
    c|clients) target="$target/clients" ;;
    s|study) target="$target/study" ;;
    w|work) target="$target/work" ;;
    *) target="$target/${1:-}" ;;
  esac
  shift
  [ $# -gt 0 ] && target="$target/$*"
  if [ -d "$target" ]; then
    cd "$target"
  else
    echo "Directory not found: $target"
    return 1
  fi
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
    local pid=$(lsof -ti tcp:$1)
    if [[ -n "$pid" ]]; then
        kill -9 $pid && echo "Killed process on port $1"
    else
        echo "No process found on port $1"
    fi
}
