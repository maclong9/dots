# • Tools
[[ ! -f "$ZSH_RC_COMPILED" || "$ZSH_RC" -nt "$ZSH_RC_COMPILED" ]] && zcompile "$ZSH_RC"
[[ -f "$ZSH_COMPDUMP" ]] && zcompile "$ZSH_COMPDUMP"

# Initialize Homebrew
if [ "$IS_MAC" = true ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Initialize zoxide (override zinit's 'zi' command)
eval "$(zoxide init zsh --no-cmd)" || echo "Warning: zoxide activation failed" >&2
alias z='__zoxide_z'
alias zi='__zoxide_zi'
