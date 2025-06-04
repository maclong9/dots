# General Settings
PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "
typeset -gaU fpath=($fpath ~/.local/share/zsh/completions)
autoload -Uz compinit && compinit
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS SHARE_HISTORY

# Aliases
alias g="git"
alias cd="z"
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
