# • Directory History
# Initialize global arrays for tracking directory history
typeset -g -a _dir_history       # Array to store directory history
typeset -g _dir_history_index=0  # Current position in directory history

# Load ZSH hook functionality
autoload -Uz add-zsh-hook

#
# Directory Change Tracking
#

# Function: _track_directory_change
# Purpose: Tracks directory changes for navigation history
# Behavior: 
# - Adds each new directory to history when changing directories
# - Skips tracking when using history navigation commands (-- or ++)
# - Updates current index to point to latest directory
_track_directory_change() {
    # Skip tracking if currently navigating through history
    # This prevents duplicate entries when using -- or ++ commands
    [[ -n "$_navigating_history" ]] && return
    
    # Add current working directory to history array
    _dir_history+=("$PWD")
    
    # Update index to point to the newest directory
    # ${#_dir_history} returns the size of the array
    _dir_history_index=${#_dir_history}
}

# Register the tracking function to run every time directory changes
# The chpwd hook is called by ZSH after every directory change
add-zsh-hook chpwd _track_directory_change