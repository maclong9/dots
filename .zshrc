# General Settings
PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "
autoload -Uz compinit && compinit
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS SHARE_HISTORY

# Aliases
alias g="git"
alias hg="history 1 | grep"
alias ls="sls -cli"
alias mkdir="mkdir -p"
alias dig="deno install -gArf"
alias remove="/bin/rm"
alias sf="swift format --recursive --in-place"
alias sl="swift format lint --recursive"
alias v="vim"

# Kill Port
kp() { kill -9 $(lsof -ti tcp:$1) }

# Make Directory and Navigate Into
mkcd() { mkdir $1 && cd $1; }

# Safely move to trash
rm() { mv $1 ~/.Trash }
