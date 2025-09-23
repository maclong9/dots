# • Directory Navigation
setopt AUTO_CD            # Change directory without typing 'cd' when path is given
setopt AUTO_PUSHD        # Make cd push old directory onto directory stack
setopt PUSHD_IGNORE_DUPS # Don't push duplicate directories onto the stack
setopt PUSHD_SILENT      # Don't print directory stack after pushd/popd

# • Command Behavior
setopt CORRECT           # Try to correct spelling of commands
setopt INTERACTIVE_COMMENTS  # Allow comments in interactive shell

# • History Management
setopt EXTENDED_HISTORY  # Save timestamp and duration for each command
setopt HIST_IGNORE_DUPS  # Don't save duplicate commands in history
setopt HIST_IGNORE_SPACE # Don't save commands that start with space
setopt HIST_REDUCE_BLANKS # Remove unnecessary blanks from commands
setopt SHARE_HISTORY     # Share history between all sessions

# • Completion System Configuration

# Add custom completion paths to fpath if directory exists
[[ -d "$ZSH_COMPLETIONS_DIR" ]] && fpath+=("$ZSH_COMPLETIONS_DIR" "$HOME/.zsh/completions")

# Add plugin completions to fpath
fpath=("$ZSH_PLUGINS_DIR/plugin/zsh-completions/src" $fpath)

# • Initialize the completion system
autoload -Uz compinit bashcompinit  # Load completion initialization functions
compinit -d "$ZSH_COMPDUMP" -C      # Initialize completions, use cached dump file
