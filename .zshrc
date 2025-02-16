# Setup Completions
autoload -U compinit
compinit -i

# Aliases
alias g='git'
alias hg='history | grep'
alias mkdir='mkdir -p'

# Kill Port
kp() { 
	kill -9 $(lsof -ti tcp:$1); 
}

# Setup CLI Tools
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
