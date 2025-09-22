# • Version Control
alias g='git'  # Short alias for git command
              # Usage: g status, g commit, etc.

#
# File Listing Aliases
#

# All aliases use 'sls' (enhanced ls) with human-readable sizes
alias ls='sls -cli --human-readable'    # List files with core info (name, size, date)
alias la='sls -clia --human-readable'   # List all files including hidden ones
alias lr='sls -clir --human-readable'   # Recursive listing of files
alias lar='sls -clira --human-readable' # Recursive listing including hidden files

#
# Utility Aliases
#

alias perf='ZSH_PERF_MONITOR=1 zsh'  # Start ZSH with performance monitoring
                                    # Useful for debugging slow shell startup

alias notarised='spctl -a -vvv -t install'  # Check if an app is notarized by Apple
                                          # Usage: notarised /Applications/App.app

alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'  # Quick access to iCloud Drive

#
# Shell Development Aliases
#

alias shf='find . -name "*.sh" -type f -exec shfmt -w -i 4 -ci {} +'  # Format shell scripts
                                                                     # Uses 4-space indent and indent case statements

alias shl='find . -name "*.sh" -type f -exec shellcheck -x -s sh -f gcc {} +'  # Lint shell scripts
                                                                              # Uses strict POSIX sh mode and gcc error format