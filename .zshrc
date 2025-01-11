export PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "

autoload -Uz compinit
compinit

# Aliases
alias c="clear"
alias g="git"
alias hg="history | grep"
alias sf="swift format --recursive --in-place"
alias mkdir="mkdir -p"

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

# Create New SvelteKit Project
cs() {
    local tmp_file=$(mktemp)
    curl -Ss https://gist.githubusercontent.com/maclong9/de559a23c06949a8c95e548112a6567f/raw/238d766296131982609e5ce822061b6075db31e6/create-sveltekit.sh > "$tmp_file"
    chmod +x "$tmp_file"
    "$tmp_file" "$1"
    rm "$tmp_file"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
