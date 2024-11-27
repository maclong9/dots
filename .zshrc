# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/maclong/.zsh/completions:"* ]]; then export FPATH="/Users/maclong/.zsh/completions:$FPATH"; fi
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

## initialise new swift executable
swcli() {
    mkdir $1 
    cd $1
    swift package init --name $1 --type executable 
}

## open previous session or start a new one
vs() { 
    [[ -f ./Session.vim ]] && 
        vim -S Session.vim || 
        vim +Obsession 
}

export NVM_DIR=~/.nvm
 [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
. "/Users/maclong/.deno/env"
# Initialize zsh completions (added by deno install script)
autoload -Uz compinit
compinit [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
