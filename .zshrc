#!/bin/zsh

# Add completion functions to fpath
fpath=($HOME/.config/shell/completions $fpath)

# Source shared libraries and ZSH configuration files in order
# Note: compinit is initialized in shell/zsh.d/options.zsh
for file in "$HOME"/.config/shell/lib/* "$HOME"/.config/shell/zsh.d/*; do
    [[ -r "$file" ]] && source "$file"
done

# Source local zshrc
[[ -f ~/.zshrc.local ]] && . "$HOME/.zshrc.local"
