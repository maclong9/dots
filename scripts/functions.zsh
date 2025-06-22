#!/bin/zsh

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
