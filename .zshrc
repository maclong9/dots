export PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "

# Aliases
alias c="clear"
alias g="git"
alias hg="history | grep"
alias sf="swift format --recursive --in-place"
alias mkdir="mkdir -p"
alias v="vim"

# Kill Port
kp() { 
    kill -9 $(lsof -ti tcp:$1); 
}

# Run `npx` with Deno
nx() { 
    deno run -A npm:$1 ${@:2}; 
}

# Make Directory and Navigate Into
mkcd() { mkdir $1 && cd $1; }

# Open or Create Vim Session
vs() {
    [[ -f ./Session.vim ]] &&
        vim -S Session.vim ||
        vim +Obsession
}

# Setup Deno and Completions
if [[ ":$FPATH:" != *":/Users/maclong/.zsh/completions:"* ]]; then export FPATH="/Users/maclong/.zsh/completions:$FPATH"; fi
. "/Users/maclong/.deno/env"
autoload -Uz compinit

# Configure nvm
export NVM_DIR=~/.nvm
 [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
