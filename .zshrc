# Load ZSH completions.
autoload -Uz compinit && compinit -C

PATH="$HOME/.local/bin/:$HOME/.local/share/mise/shims/:$PATH"

# Initialize mise for tool version management
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

# Source custom functions and completions dynamically
find "$HOME/.config/scripts" -not -path "$HOME/.config/scripts/maintenance/*" \
    \( -name "*.sh" -o -name "*.zsh" \) | while read -r script; do
    [ -r "$script" ] && . "$script"
done

# Configure ZSH options for behavior and history.
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY
setopt HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS EXTENDED_HISTORY

# Configure history settings.
export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE="$HOME/.zsh_history"

# Compile .zshrc for performance if newer than compiled version.
if [[ ! -f "$HOME/.zshrc.zwc" || "$HOME/.zshrc" -nt "$HOME/.zshrc.zwc" ]]; then
    zcompile "$HOME/.zshrc"
fi

# Load version control system info
autoload -Uz vcs_info

# Enable git support
zstyle ':vcs_info:*' enable git

# Configure git branch display formats
zstyle ':vcs_info:git:*' formats ' %B%F{10}⎇ %b%f'
zstyle ':vcs_info:git:*' actionformats ' %B%F{10}⎇ %b|%a%f'

# Format with change indicators
zstyle ':vcs_info:git:*' formats ' %B%F{10}(%b)%f'

precmd() {
    vcs_info
    PROMPT="%F{7}%n %B%F{15}%~%b${vcs_info_msg_0_}
%F{%(?.10.9)}%Bλ%b%f "
}

# Define aliases for common commands.
alias clc='fc -ln -1 > /tmp/last_cmd.log && CMD=$(< /tmp/last_cmd.log) && eval "$CMD" \
> /tmp/last_out.log 2>&1 && { echo "λ $CMD"; echo "⇣"; cat /tmp/last_out.log; } | pbcopy'
alias g='git'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -la'
alias ls='ls --color=auto'
alias sf="swift format --recursive --in-place"
alias sl="swift format lint --recursive"
alias vg='vim ~/.gitconfig'
alias vv='vim ~/.vimrc'
alias vz='vim ~/.zshrc'
