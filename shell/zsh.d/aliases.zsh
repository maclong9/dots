# • Version Control
alias g='git'  # Short alias for git command

# • File Aliases
alias cat='bat' # Syntax highlighted cat
alias ls='sls -cli --human-readable'    # List files with core info (name, size, date)
alias la='sls -clia --human-readable'   # List all files including hidden ones
alias lr='sls -clir --human-readable'   # Recursive listing of files
alias lar='sls -clira --human-readable' # Recursive listing including hidden files
alias grep='rg' # Modern grep replacement

# • Utility Aliases
alias perf='ZSH_PERF_MONITOR=1 zsh'  # Start ZSH with performance monitoring
alias notarised='spctl -a -vvv -t install'  # Check if an app is notarized by Apple
alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'  # Quick access to iCloud Drive

# • Shell Development Aliases
alias shf='find . -name "*.sh" -type f -exec shfmt -w -i 4 -ci {} +'  # Format shell scripts
alias shl='find . -name "*.sh" -type f -exec shellcheck -x -s sh -f gcc -e SC1090 {} +' # Lint shell scripts
