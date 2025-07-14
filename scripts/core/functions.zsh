#!/bin/zsh

# • Process management

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

# • Clipboard utilities

# Re-runs the last command and copies its output to the clipboard.
#
# This function captures the last command from your shell history, executes it,
# and then copies a formatted string containing the command and its full output
# (both stdout and stderr) to the system clipboard.
#
# - Returns:
#   - The exit code of the executed command.
# - Usage:
#   ```sh
#   clc
#   ```
clc() {
    # Get the last command from history.
    local last_cmd
    last_cmd=$(fc -ln -1)

    # Check if there is a command to run.
    if [[ -z "$last_cmd" ]]; then
        echo "No previous command to run."
        return 1
    fi

    # Execute the command, capturing stdout and stderr.
    local output
    output=$(eval "$last_cmd" 2>&1)
    local exit_code=$?

    # Format the output and copy it to the clipboard.
    printf "λ %s\n⇣\n%s" "$last_cmd" "$output" | pbcopy

    echo "${BRIGHT_GREEN}✓${NC} Copied last command's output to clipboard."

    return $exit_code
}

# • Directory navigation

# Navigate backward in directory history.
#
# Moves to the previous directory in the navigation history stack,
# similar to a browser's back button.
#
# - Returns:
#   - 0 if navigation was successful.
#   - Prints message if no previous directory exists.
--() {
    if (( _dir_history_index > 1 )); then
        _navigating_history=1
        (( _dir_history_index-- ))
        builtin cd "${_dir_history[$_dir_history_index]}"
        unset _navigating_history
    else
        echo "No previous directory"
    fi
}

# Navigate forward in directory history.
#
# Moves to the next directory in the navigation history stack,
# similar to a browser's forward button.
#
# - Returns:
#   - 0 if navigation was successful.
#   - Prints message if no forward directory exists.
++() {
    if (( _dir_history_index < ${#_dir_history} )); then
        _navigating_history=1
        (( _dir_history_index++ ))
        builtin cd "${_dir_history[$_dir_history_index]}"
        unset _navigating_history
    else
        echo "No forward directory"
    fi
}
