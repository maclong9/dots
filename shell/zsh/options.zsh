# • Shell Options
# Directory Navigation
#

setopt AUTO_CD            # Change directory without typing 'cd' when path is given
                         # Example: '/usr/local' instead of 'cd /usr/local'

setopt AUTO_PUSHD        # Make cd push old directory onto directory stack
                         # Allows using pushd/popd for directory navigation history

setopt PUSHD_IGNORE_DUPS # Don't push duplicate directories onto the stack
                         # Keeps stack clean and manageable

setopt PUSHD_SILENT      # Don't print directory stack after pushd/popd
                         # Reduces noise in terminal output

#
# Command Behavior
#

setopt CORRECT           # Try to correct spelling of commands
                         # Prompts with suggestion: 'zhs' -> 'zsh?'

setopt INTERACTIVE_COMMENTS  # Allow comments in interactive shell
                           # Useful for documenting complex commands in-line

#
# History Management
#

setopt EXTENDED_HISTORY  # Save timestamp and duration for each command
                         # Format: ': <start time>:<elapsed>;<command>'

setopt HIST_IGNORE_DUPS  # Don't save duplicate commands in history
                         # Only ignores if command is identical to previous

setopt HIST_IGNORE_SPACE # Don't save commands that start with space
                         # Useful for commands you don't want in history

setopt HIST_REDUCE_BLANKS # Remove unnecessary blanks from commands
                         # 'echo    hello    world' -> 'echo hello world'

setopt SHARE_HISTORY     # Share history between all sessions
                         # Commands from other terminals are available immediately

#
# Completion System Configuration
#

# Add custom completion paths to fpath if directory exists
[[ -d "$ZSH_COMPLETIONS_DIR" ]] && fpath+=("$ZSH_COMPLETIONS_DIR" "$HOME/.zsh/completions")

# Add plugin completions to fpath
fpath=("$ZSH_PLUGINS_DIR/plugin/zsh-completions/src" $fpath)

# Initialize the completion system
autoload -Uz compinit bashcompinit  # Load completion initialization functions
compinit -d "$ZSH_COMPDUMP" -C      # Initialize completions, use cached dump file