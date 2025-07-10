# Define common paths
ZSH_LOCAL_BIN="$HOME/.local/bin"
ZSH_MISE_SHIMS="$HOME/.local/share/mise/shims"
ZSH_HISTORY_FILE="$HOME/.zsh_history"
ZSH_SCRIPTS_DIR="$HOME/.config/scripts"
ZSH_PLUGINS_DIR="$HOME/.zsh/plugins"
ZSH_COMPDUMP="${ZSH_COMPDUMP:-$HOME/.zcompdump}"
ZSH_RC="$HOME/.zshrc"
ZSH_RC_COMPILED="$ZSH_RC.zwc"

# Load performance monitoring conditionally
if [[ -n "$ZSH_PERF_MONITOR" ]]; then
    echo "⚡ ZSH performance monitoring enabled..."
    zmodload zsh/zprof
fi

# Load ZSH completions and configure options
autoload -Uz compinit
compinit -d "$ZSH_COMPDUMP" -C
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS SHARE_HISTORY HIST_IGNORE_DUPS \
   HIST_IGNORE_SPACE HIST_VERIFY HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS EXTENDED_HISTORY

# Configure PATH and history
PATH="$ZSH_LOCAL_BIN:$ZSH_MISE_SHIMS:$PATH"
export HISTSIZE=50000 SAVEHIST=50000 HISTFILE="$ZSH_HISTORY_FILE"

# Initialize mise
lazy_mise_init() {
  unset -f lazy_mise_init
  eval "$(mise activate zsh)"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd lazy_mise_init

# Source custom scripts
if [ -d "$ZSH_SCRIPTS_DIR" ]; then
    for script in "$ZSH_SCRIPTS_DIR"/**/*.{sh,zsh}(N); do
        [[ "$script" != *"/maintenance/"* ]] && [[ -r "$script" ]] && . "$script"
    done
fi

# Source plugins
if [ -d "$ZSH_PLUGINS_DIR" ]; then
    for plugin in "$ZSH_PLUGINS_DIR"/**/*.plugin.zsh; do
        source "$plugin"
    done
fi

# Compile .zshrc and completions for performance
[[ ! -f "$ZSH_RC_COMPILED" || "$ZSH_RC" -nt "$ZSH_RC_COMPILED" ]] && zcompile "$ZSH_RC"
zcompile "$ZSH_COMPDUMP"

# Configure git prompt with status-based colors
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats ' %B%F{%1v}(%b%u%c)%f'
zstyle ':vcs_info:git:*' actionformats ' %B%F{%1v}(%b|%a%u%c)%f'

precmd() {
    vcs_info
    
    # Determine git status color
    if [[ -n ${vcs_info_msg_0_} ]]; then
        # Check if we're in a git repository
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            # Check if working directory is clean
            if git diff-index --quiet HEAD -- 2>/dev/null; then
                # Clean repository - bright green
                zstyle ':vcs_info:git:*' formats ' %B%F{10}(%b)%f'
                zstyle ':vcs_info:git:*' actionformats ' %B%F{10}(%b|%a)%f'
            else
                # Dirty repository - yellow/orange
                zstyle ':vcs_info:git:*' formats ' %B%F{11}(%b)%f'
                zstyle ':vcs_info:git:*' actionformats ' %B%F{11}(%b|%a)%f'
            fi
        fi
        vcs_info
    fi
    
    PROMPT="%F{7}%n %B%F{15}%~%b${vcs_info_msg_0_}
%F{%(?.10.9)}%Bλ%b%f "
}

# Define aliases for common commands
alias g='git'
alias ls='sls -cli --human-readable'
alias la='sls -clia --human-readable'
alias sf='swift format --recursive --in-place'
alias sl='swift format lint --recursive'
alias shf='find . -name "*.sh" -type f -exec shfmt -w -i 4 -ci {} +'
alias perf='ZSH_PERF_MONITOR=1 zsh'

# Conditional performance monitoring
if [[ -n "$ZSH_PERF_MONITOR" ]]; then
    zprof
fi
