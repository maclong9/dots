# • Tools
[[ ! -f "$ZSH_RC_COMPILED" || "$ZSH_RC" -nt "$ZSH_RC_COMPILED" ]] && zcompile "$ZSH_RC"
[[ -f "$ZSH_COMPDUMP" ]] && zcompile "$ZSH_COMPDUMP"

# Initialize mise
eval "$(mise activate zsh)"

# Initialize zoxide
eval "$(zoxide init zsh)" || echo "Warning: zoxide activation failed" >&2