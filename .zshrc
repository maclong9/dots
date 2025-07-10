# Define common paths
ZSH_LOCAL_BIN="$HOME/.local/bin"
ZSH_MISE_SHIMS="$HOME/.local/share/mise/shims"
ZSH_HISTORY_FILE="$HOME/.zsh_history"
ZSH_SCRIPTS_DIR="$HOME/.config/scripts"
ZSH_PLUGINS_DIR="$HOME/.zsh/plugins"
ZSH_COMPLETIONS_DIR="$HOME/.zsh/completions"
ZSH_COMPDUMP="${ZSH_COMPDUMP:-$HOME/.zcompdump}"
ZSH_RC="$HOME/.zshrc"
ZSH_RC_COMPILED="$ZSH_RC.zwc"

# Load performance monitoring conditionally
[[ -n "$ZSH_PERF_MONITOR" ]] && {
    echo "⚡ ZSH performance monitoring enabled..."
    zmodload zsh/zprof
}

# Load ZSH completions and configure options
autoload -Uz compinit
compinit -d "$ZSH_COMPDUMP" -C
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS SHARE_HISTORY HIST_IGNORE_DUPS \
   HIST_IGNORE_SPACE HIST_VERIFY HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS EXTENDED_HISTORY

# Configure PATH and history
PATH="$ZSH_LOCAL_BIN:$ZSH_MISE_SHIMS:$PATH"
export HISTSIZE=50000 SAVEHIST=50000 HISTFILE="$ZSH_HISTORY_FILE"

# Initialize mise lazily only when needed
lazy_mise_init() {
    unset -f lazy_mise_init
    eval "$(mise activate zsh)"
}
# Hook to first directory change instead of every prompt
autoload -Uz add-zsh-hook
add-zsh-hook chpwd lazy_mise_init

# Source custom scripts (excluding maintenance) - cache script list
[[ -d "$ZSH_SCRIPTS_DIR" ]] && {
    # Use a more efficient glob pattern
    local scripts=("$ZSH_SCRIPTS_DIR"/**/*.(sh|zsh)(N))
    for script in "${scripts[@]}"; do
        [[ "$script" != *"/maintenance/"* && -r "$script" ]] && source "$script"
    done
}

# Source completions
[[ -d "$ZSH_COMPLETIONS_DIR" ]] && fpath+=("$ZSH_COMPLETIONS_DIR")

# Source plugins
[[ -d "$ZSH_PLUGINS_DIR" ]] && {
    plugins=("$ZSH_PLUGINS_DIR"/**/*.plugin.zsh(N))
    (( ${#plugins} )) && for plugin in "${plugins[@]}"; do source "$plugin"; done
}

# Compile .zshrc and completions for performance
[[ ! -f "$ZSH_RC_COMPILED" || "$ZSH_RC" -nt "$ZSH_RC_COMPILED" ]] && zcompile "$ZSH_RC"
[[ -f "$ZSH_COMPDUMP" ]] && zcompile "$ZSH_COMPDUMP"

# Configure git prompt with dynamic colors - cache git operations
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true

# Cache git status to avoid repeated calls
_git_status_cache=""
_git_status_cache_time=0

precmd() {
    local current_time=$(date +%s)
    
    # Only check git status every 2 seconds
    if (( current_time - _git_status_cache_time > 2 )); then
        vcs_info
        
        # Set git status color based on repository state
        if [[ -n ${vcs_info_msg_0_} ]] && git rev-parse --is-inside-work-tree &>/dev/null; then
            local color=$(git diff-index --quiet HEAD -- 2>/dev/null && echo "10" || echo "11")
            zstyle ':vcs_info:git:*' formats " %B%F{$color}(%b)%f"
            zstyle ':vcs_info:git:*' actionformats " %B%F{$color}(%b|%a)%f"
            vcs_info
            _git_status_cache="${vcs_info_msg_0_}"
        else
            _git_status_cache=""
        fi
        _git_status_cache_time=$current_time
    fi
    
    PROMPT="%F{7}%n %B%F{15}%~%b${_git_status_cache}
%F{%(?.10.9)}%Bλ%b%f "
}

# Define aliases for common commands
alias g='git'
alias ls='sls -cli --human-readable'
alias la='sls -clia --human-readable'
alias sf='swift format --recursive --in-place'
alias sl='swift format lint --recursive'
alias shf='find . -name "*.{sh,zsh}" -type f -exec shfmt -w -i 4 -ci {} +'
alias shl='find . -name "*.sh" -type f -exec shellcheck -x -s sh -f gcc {} +'
alias perf='ZSH_PERF_MONITOR=1 zsh'
alias notarised='spctl -a -vvv -t install'

# Performance monitoring output
[[ -n "$ZSH_PERF_MONITOR" ]] && zprof
