# • Environment
# Time in seconds before refreshing git status in prompt
readonly GIT_CACHE_TIMEOUT=2

# Colors for git status indication (using 256-color codes)
readonly GIT_COLOR_CLEAN=10  # Green for clean state
readonly GIT_COLOR_DIRTY=11  # Yellow for dirty state

#
# Core Environment Setup
#

# Default editor configuration
EDITOR="hx"  # Set Helix as the default editor

# Directory Paths
ZSH_LOCAL_BIN="$HOME/.local/bin"          # User-specific executables
ZSH_MISE_SHIMS="$HOME/.local/share/mise/shims"  # mise version manager shims
ZSH_SCRIPTS_DIR="$HOME/.config/shell"      # Shell configuration directory

# ZSH-specific Paths
ZSH_PLUGINS_DIR="$HOME/.zsh/plugins"       # ZSH plugins directory
ZSH_COMPLETIONS_DIR="$HOME/.zsh/completions/:/usr/local/share/zsh/site-functions/"  # Completion scripts
ZSH_HISTORY_FILE="$HOME/.zsh_history"      # Shell history storage
ZSH_COMPDUMP="${ZSH_COMPDUMP:-$HOME/.zcompdump}"  # Completion cache
ZSH_RC="$HOME/.zshrc"                      # Main ZSH configuration file
ZSH_RC_COMPILED="$ZSH_RC.zwc"             # Compiled configuration for faster loading

#
# Path Configuration
#

# Add user-specific paths to PATH
# - Local binaries take precedence over system paths
# - mise shims are included for version-managed tools
PATH="$ZSH_LOCAL_BIN:$ZSH_MISE_SHIMS:$PATH"

#
# History Configuration
#

# Configure history size and location
export HISTSIZE=50000        # Number of commands to keep in memory
export SAVEHIST=50000        # Number of commands to save to disk
export HISTFILE="$ZSH_HISTORY_FILE"  # Location of history file