#!/usr/bin/env zsh

# • Performance monitoring

# Load performance monitoring conditionally
[[ -n "$ZSH_PERF_MONITOR" ]] && {
    echo "⚡ ZSH performance monitoring enabled..."
    zmodload zsh/zprof
}

# • Paths & environment

# Define common paths
EDITOR="hx"
ZSH_LOCAL_BIN="$HOME/.local/bin"
ZSH_MISE_SHIMS="$HOME/.local/share/mise/shims"
ZSH_HISTORY_FILE="$HOME/.zsh_history"
ZSH_SCRIPTS_DIR="$HOME/.config/scripts"
ZSH_PLUGINS_DIR="$HOME/.zsh/plugins"
ZSH_COMPLETIONS_DIR="$HOME/.zsh/completions"
ZSH_COMPDUMP="${ZSH_COMPDUMP:-$HOME/.zcompdump}"
ZSH_RC="$HOME/.zshrc"
ZSH_RC_COMPILED="$ZSH_RC.zwc"

# Directory history tracking
typeset -g -a _dir_history
typeset -g _dir_history_index=0

autoload -Uz add-zsh-hook

_track_directory_change() {
    # Don't track if we're navigating via -- or ++
    [[ -n "$_navigating_history" ]] && return
    
    # Add current directory to history
    _dir_history+=("$PWD")
    _dir_history_index=${#_dir_history}
}

add-zsh-hook chpwd _track_directory_change

# Configure PATH and history
PATH="$ZSH_LOCAL_BIN:$ZSH_MISE_SHIMS:$PATH"
export HISTSIZE=50000 SAVEHIST=50000 HISTFILE="$ZSH_HISTORY_FILE"

# • ZSH configuration

# Core options
setopt AUTO_CD AUTO_PUSHD CORRECT EXTENDED_HISTORY  HIST_IGNORE_DUPS  HIST_IGNORE_SPACE \
  HIST_REDUCE_BLANKS INTERACTIVE_COMMENTS PUSHD_IGNORE_DUPS PUSHD_SILENT SHARE_HISTORY

# Load ZSH completions
autoload -Uz compinit bashcompinit
compinit -d "$ZSH_COMPDUMP" -C

# • Loading tools

# Initialize mise lazily only when needed
lazy_mise_init() {
    unset -f lazy_mise_init
    eval "$(mise activate zsh)"
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd lazy_mise_init

# • Scripts & plugins

# Source custom scripts (core utilities and completions only)
[[ -d "$ZSH_SCRIPTS_DIR" ]] && {
    for script in "$ZSH_SCRIPTS_DIR"/{core,completions}/**/*.(sh|zsh)(N); do
        [[ -r "$script" ]] && source "$script"
    done
}

# Source completions
[[ -d "$ZSH_COMPLETIONS_DIR" ]] && fpath+=("$ZSH_COMPLETIONS_DIR")

# Source plugins
[[ -d "$ZSH_PLUGINS_DIR" ]] && {
    plugins=("$ZSH_PLUGINS_DIR"/**/*.plugin.zsh(N))
    (( ${#plugins} )) && for plugin in "${plugins[@]}"; do source "$plugin"; done
}
fpath=("$ZSH_PLUGINS_DIR/plugin/zsh-completions/src" $fpath)

# • Prompt configuration

# Configure git prompt with dynamic colors
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

# • Aliases

# Git
alias g='git'

# File listing
alias ls='sls -cli --human-readable'
alias la='sls -clia --human-readable'
alias lr='sls -clir --human-readable'
alias lar='sls -clira --human-readable'

# Swift tooling
alias sf='swift format --recursive --in-place'
alias sl='swift format lint --recursive'

# Shell tooling
alias shf='find . -name "*.{sh,zsh}" -type f -exec shfmt -w -i 4 -ci {} +'
alias shl='find . -name "*.sh" -type f -exec shellcheck -x -s sh -f gcc {} +'

# Utilities
alias perf='ZSH_PERF_MONITOR=1 zsh'
alias notarised='spctl -a -vvv -t install'
alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'

# • Compilation & cleanup

# Compile .zshrc and completions for performance
[[ ! -f "$ZSH_RC_COMPILED" || "$ZSH_RC" -nt "$ZSH_RC_COMPILED" ]] && zcompile "$ZSH_RC"
[[ -f "$ZSH_COMPDUMP" ]] && zcompile "$ZSH_COMPDUMP"

# Performance monitoring output
[[ -n "$ZSH_PERF_MONITOR" ]] && zprof

zellij -l welcome
