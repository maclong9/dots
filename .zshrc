export PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "

alias c="clear"
alias g="git"
alias hg="history | grep"
alias mkdir="mkdir -p"
alias v="vim"

kp() { kill -9 $(lsof -ti tcp:$1); }
nx() { deno run -A npm:$1 ${@:2}; }
mkcd() { mkdir $1 && cd $1; }
swcli() { mkdir $1 && cd $1 && swift package init --name $1 --type executable }
vs() { 
    [[ -f ./Session.vim ]] && 
        vim -S Session.vim || 
        vim +Obsession 
}

# deno completions
if [[ ":$FPATH:" != *":/Users/maclong/.zsh/completions:"* ]]; then
    export FPATH="/Users/maclong/.zsh/completions:$FPATH"
fi

# nvm source and completions
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
. "/Users/maclong/.deno/env"
