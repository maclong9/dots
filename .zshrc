#!/bin/zsh

# Add completion functions to fpath
fpath=($HOME/.config/shell/completions $fpath)

# Source shared libraries and ZSH configuration files in order
for file in "$HOME"/.config/shell/lib/* "$HOME"/.config/shell/zsh.d/*; do
    [[ -r "$file" ]] && source "$file"
done

# Source local zshrc
[[ -f ~/.zshrc.local ]] && . "$HOME/.zshrc.local"

# bun completions
[ -s "/Users/mac/.bun/_bun" ] && source "/Users/mac/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
