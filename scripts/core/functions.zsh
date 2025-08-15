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

# • Command execution utilities

# Execute command with prefixed output.
#
# Runs a command and prefixes its output with a visual separator
# to clearly distinguish between the prompt and command output.
#
# - Parameters:
#   - ...: Command and arguments to execute.
# - Returns:
#   - The exit code of the executed command.
# - Usage:
#   ```sh
#   run ls -la
#   run git status
#   ```
run() {
    [[ $# -eq 0 ]] && {
        echo "Usage: run <command> [args...]"
        return 1
    }
    
    echo "%F{8}->%f"
    eval "$@"
}

# Search shell command history (full saved history).
#
# Greps through the persistent history file ($HISTFILE) for a search term,
# rather than the limited in-memory history list.
#
# - Parameters:
#   - ...: Search pattern(s) to pass to grep.
# - Returns:
#   - 0 if matches are found.
#   - Non-zero if no matches.
# - Usage:
#   ```sh
#   hg npm
#   hg ssh user@
#   ```
hg() {
    grep --color=auto -i "$@" "$HISTFILE"
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

# Copy file from ssh server to local
#
# Creates a copy of a file located on a remote server,
# locally on the system.
#
# - Parameters:
#   - addr: the address of the remote host
#   - path: the path of the file on the remote server
#   - output: the output path on your local machine, defaults to .$path
#   - -i: specify custom SSH key (optional, defaults to ~/.ssh/id_ed25519)
# - Returns:
#   - 0 if successful.
#   - Prints message if error
remote_copy() {
    local ssh_key="$HOME/.ssh/id_ed25519"
    local addr=""
    local remote_path=""
    local output_path=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i)
                ssh_key="$2"
                shift 2
                ;;
            *)
                if [[ -z "$addr" ]]; then
                    addr="$1"
                elif [[ -z "$remote_path" ]]; then
                    remote_path="$1"
                elif [[ -z "$output_path" ]]; then
                    output_path="$1"
                fi
                shift
                ;;
        esac
    done
    
    [[ -z "$addr" || -z "$remote_path" ]] && {
        echo "Usage: remote_copy [-i key_file] <addr> <path> [output]"
        return 1
    }
    
    # If no output path provided, use basename of remote path in current directory
    if [[ -z "$output_path" ]]; then
        output_path="./$(basename "$remote_path")"
    fi
    
    scp -i "$ssh_key" "$addr:$remote_path" "$output_path"
}

