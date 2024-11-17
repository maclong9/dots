export PATH="$PATH:$(find $HOME/.local/share/mise/installs -type d -name bin \
	| tr '\n' ':' | sed 's/:$//')"
export PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "

alias c="clear"
alias g="git"
alias hg="history | grep"
alias mkdir="mkdir -p"
alias v="vim"
alias vs="vim -S Session.vim"

kp() { kill -9 $(lsof -ti tcp:$1); }
nx() { deno run -A npm:$1 ${@:2};  }
