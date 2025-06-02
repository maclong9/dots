# General Settings
PROMPT="%F{white}%n@%m %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "
autoload -Uz compinit && compinit
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS SHARE_HISTORY

# Aliases
alias g="git"
alias ls="sls -cli"
alias la="sls -clia"
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

# Make Directory and Navigate Into
mkcd() { mkdir $1 && cd $1; }
