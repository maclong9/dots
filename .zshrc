# Load ZSH completions and configure options
autoload -Uz compinit && compinit -C
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS SHARE_HISTORY HIST_IGNORE_DUPS \
   HIST_IGNORE_SPACE HIST_VERIFY HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS EXTENDED_HISTORY

# Configure PATH and history
PATH="$HOME/.local/bin/:$HOME/.local/share/mise/shims/:$PATH"
export HISTSIZE=50000 SAVEHIST=50000 HISTFILE="$HOME/.zsh_history"

# Initialize mise
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

# Source custom scripts
if [ -d "$HOME/.config/scripts" ]; then
    for script in "$HOME/.config/scripts"/**/*.{sh,zsh}(N); do
        [[ "$script" != *"/maintenance/"* ]] && [[ -r "$script" ]] && . "$script"
    done
fi

# Compile .zshrc for performance
[[ ! -f "$HOME/.zshrc.zwc" || "$HOME/.zshrc" -nt "$HOME/.zshrc.zwc" ]] &&
    zcompile "$HOME/.zshrc"

# Configure git prompt
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %B%F{10}(%b)%f'
precmd() { vcs_info; PROMPT="%F{7}%n %B%F{15}%~%b${vcs_info_msg_0_}
%F{%(?.10.9)}%Bλ%b%f "; }

# Define aliases for common commands
alias clc='fc -ln -1 > /tmp/last_cmd.log && CMD=$(< /tmp/last_cmd.log) && eval "$CMD" \
> /tmp/last_out.log 2>&1 && { echo "λ $CMD"; echo "⇣"; cat /tmp/last_out.log; } | pbcopy'
alias g='git'
alias ls='sls -cli'
alias la='sls -clia'
alias sf="swift format --recursive --in-place"
alias sl="swift format lint --recursive"
alias shf="find . -name \"*.sh\" -type f -exec shfmt -w -i 4 -ci {} +"
