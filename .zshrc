export PATH="$HOME/.deno/bin:$PATH"
export PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "

# Aliases
alias c="clear"
alias g="git"
alias hg="history | grep"
alias sf="swift format --recursive --in-place"
alias mkdir="mkdir -p"
alias v="vim"

# Functions
kp() { kill -9 $(lsof -ti tcp:$1); }
nx() { deno run -A npm:$1 ${@:2}; }
mkcd() { mkdir $1 && cd $1; }
swcli() { mkdir $1 && cd $1 && swift package init --name $1 --type executable }
vs() { 
    [[ -f ./Session.vim ]] && 
        vim -S Session.vim || 
        vim +Obsession 
}
export NVM_DIR=~/.nvm
 [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
