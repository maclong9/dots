PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "
# General Settings
autoload -Uz compinit
compinit
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS SHARE_HISTORY

# Aliases
alias g="git"
alias hg="history 1 | grep"
alias ls="sls -cli"
alias mkdir="mkdir -p"
alias sf="swift format --recursive --in-place"
alias v="vim"
alias remove="/bin/rm"

# Kill Port
kp() { kill -9 $(lsof -ti tcp:$1) }

# Make Directory and Navigate Into
mkcd() { mkdir $1 && cd $1; }

# Run `npx` with Deno
nx() { deno run -A npm:$1 ${@:2} }

# Safely move to trash
rm() { mv $1 ~/.Trash }
