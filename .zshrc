# Zsh Configuration
# Modern shell setup with plugins, completions, and custom prompt

PATH="$HOME/.local/bin/:$HOME/.local/share/mise/shims/:$PATH"

# Initialize mise for tool management
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

# Zsh options
setopt AUTO_CD              # Automatically cd into directories
setopt CORRECT              # Correct typos in commands
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shells
setopt SHARE_HISTORY        # Share history between sessions
setopt HIST_IGNORE_DUPS     # Don't record duplicate commands
setopt HIST_IGNORE_SPACE    # Don't record commands starting with space
setopt HIST_VERIFY          # Show command before executing from history

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Load zsh plugins
ZSH_PLUGINS_DIR="$HOME/.local/share/zsh"

# zsh-completions 
if [[ -d "$ZSH_PLUGINS_DIR/zsh-completions" ]]; then
    fpath=("$ZSH_PLUGINS_DIR/zsh-completions/src" $fpath)
fi

# Initialize completion system
autoload -Uz compinit
compinit

# zsh-autosuggestions
if [[ -f "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# zsh-you-should-use
if [[ -f "$ZSH_PLUGINS_DIR/zsh-you-should-use/you-should-use.plugin.zsh" ]]; then
    source "$ZSH_PLUGINS_DIR/zsh-you-should-use/you-should-use.plugin.zsh"
fi

# zsh-autocomplete
if [[ -f "$ZSH_PLUGINS_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]]; then
    source "$ZSH_PLUGINS_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
    bindkey              '^I'         menu-complete
    bindkey "$terminfo[kcbt]" reverse-menu-complete
    bindkey -M emacs \
        "^[p"   .history-search-backward \
        "^[n"   .history-search-forward \
        "^P"    .up-line-or-history \
        "^[OA"  .up-line-or-history \
        "^[[A"  .up-line-or-history \
        "^N"    .down-line-or-history \
        "^[OB"  .down-line-or-history \
        "^[[B"  .down-line-or-history \
        "^R"    .history-incremental-search-backward \
        "^S"    .history-incremental-search-forward \
        #
    bindkey -a \
        "^P"    .up-history \
        "^N"    .down-history \
        "k"     .up-line-or-history \
        "^[OA"  .up-line-or-history \
        "^[[A"  .up-line-or-history \
        "j"     .down-line-or-history \
        "^[OB"  .down-line-or-history \
        "^[[B"  .down-line-or-history \
        "/"     .vi-history-search-backward \
        "?"     .vi-history-search-forward \
        #
fi

# jj completions
if command -v jj >/dev/null 2>&1; then
    source <(COMPLETE=zsh jj)
fi

# mise completions
if command -v mise >/dev/null 2>&1; then
    source "$HOME/.local/share/zsh/completions/_mise"
fi

# zoxide setup
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# zsh-syntax-highlighting (must be loaded last)
if [[ -f "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Git integration for prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats $'%F{7} on%F{10}  %b%f'
zstyle ':vcs_info:*' enable git

# Enable prompt substitution
setopt PROMPT_SUBST

# Custom prompt
PROMPT='%F{7}%n %B%F{15}%~%b
%F{%(?.10.9)}%Bλ%b%f '

# Aliases
alias cat="bat"            
alias cd="z"
alias cdi="zi"
alias jgp="jj git push"
alias jd="jj describe -m"
alias la="sls -clia"          
alias ls="sls -cli"        
alias sf="swift format --recursive --in-place"
alias sl="swift format lint --recursive"

# Utility functions
# Kill process on specific port
kp() {
    if [[ -z "$1" ]]; then
        echo "Usage: kp <port>"
        return 1
    fi
    local pid=$(lsof -ti tcp:$1)
    if [[ -n "$pid" ]]; then
        kill -9 $pid
        echo "Killed process on port $1"
    else
        echo "No process found on port $1"
    fi
}

# Set bookmark to revision
jbs() {
    jj bookmark set $1 -r $2
}
