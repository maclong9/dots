# General Settings
PROMPT="%F{white}%n@%m %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "
autoload -Uz compinit && compinit
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS SHARE_HISTORY

# Aliases
alias g="git"
alias mkdir="mkdir -p"
alias dig="deno install -gArf"
alias v="vim"

# Kill Port
kp() { kill -9 $(lsof -ti tcp:$1) }

# Run `npx` with `deno`
nx() { deno run npm:$1; }

# Make Directory and Navigate Into
mkcd() { mkdir $1 && cd $1; }

. "$HOME"/.cargo/env
. "$HOME"/.deno/env
