# General Settings
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS SHARE_HISTORY PROMPT_SUBST
autoload -Uz vcs_info compinit && compinit
typeset -gaU fpath=($fpath ~/.local/share/zsh/completions)

# Prompt Configuration
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats $'%F{7} on%F{10} \u200A%b%f'
zstyle ':vcs_info:*' enable git
PROMPT='%F{7}%n %B%F{15}%~%b${vcs_info_msg_0_}
%F{%(?.10.9)}%Bλ%b%f '

# Aliases
alias g="git"
alias cd="z"
alias cdi="zi"
alias ls="sls -cli"
alias mkdir="mkdir -p"
alias sf="swift format --recursive --in-place"
alias sl="swift format lint --recursive"
alias sr="swift run"
alias st="swift test"
alias sb="swift build"
alias sbr="swift build -c release"
alias spu="swift package update"

# Kill Port
kp() { kill -9 $(lsof -ti tcp:$1) }

# Activate tools
eval "$(/Users/mac/.local/bin/mise activate zsh)"
eval "$(zoxide init zsh)"
