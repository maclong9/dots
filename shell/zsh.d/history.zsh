# Initialize global arrays for tracking directory history
typeset -g -a _dir_history       # Array to store directory history
typeset -g _dir_history_index=0  # Current position in directory history

# Load ZSH hook functionality
autoload -Uz add-zsh-hook

# Directory Change Tracking
_track_directory_change() {
    # Skip tracking if currently navigating through history
    [[ -n "$_navigating_history" ]] && return
    
    # Add current working directory to history array
    _dir_history+=("$PWD")
    
    # Update index to point to the newest directory
    _dir_history_index=${#_dir_history}
}

# Register the tracking function to run every time directory changes
add-zsh-hook chpwd _track_directory_change
