export PATH="$PATH:$(find $HOME/.local/share/mise/installs -type d -name bin \
  | tr '\n' ':' | sed 's/:$//')"
export PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "

alias g="git"
alias hg="history | grep"
alias mkdir="mkdir -p"

kp() { kill -9 $(lsof -ti tcp:$1); }
nx() { deno run -A npm:$1 ${@:2};  }

eval "$(zoxide init zsh)"
eval "$(~/.local/bin/mise activate zsh)"
