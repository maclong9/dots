# Define common paths
ZSH_HOME="$HOME"
ZSH_LOCAL_BIN="$ZSH_HOME/.local/bin"
ZSH_MISE_SHIMS="$ZSH_HOME/.local/share/mise/shims"
ZSH_HISTORY_FILE="$ZSH_HOME/.zsh_history"
ZSH_SCRIPTS_DIR="$ZSH_HOME/.config/scripts"
ZSH_COMPDUMP="${ZSH_COMPDUMP:-$ZSH_HOME/.zcompdump}"
ZSH_RC="$ZSH_HOME/.zshrc"
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

# Compile .zshrc and completions for performance
[[ ! -f "$ZSH_RC_COMPILED" || "$ZSH_RC" -nt "$ZSH_RC_COMPILED" ]] && zcompile "$ZSH_RC"
zcompile "$ZSH_COMPDUMP"

# Configure git prompt
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %B%F{10}(%b)%f'
precmd() {
    vcs_info
    PROMPT="%F{7}%n %B%F{15}%~%b${vcs_info_msg_0_}
%F{%(?.10.9)}%Bλ%b%f "
}

# Define aliases for common commands
alias clc='fc -ln -1 > /tmp/last_cmd.log && CMD=$(< /tmp/last_cmd.log) && eval "$CMD" \
> /tmp/last_out.log 2>&1 && { echo "λ $CMD"; echo "⇣"; cat /tmp/last_out.log; } | pbcopy'
alias g='git'
alias ls='sls -cli --human-readable'
alias la='sls -clia --human-readable'
alias sf="swift format --recursive --in-place"
alias sl="swift format lint --recursive"
alias shf="find . -name \"*.sh\" -type f -exec shfmt -w -i 4 -ci {} +"

# Conditional performance monitoring
if [[ -n "$ZSH_PERF_MONITOR" ]]; then
    zprof
fi
