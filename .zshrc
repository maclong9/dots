#!/bin/zsh

# Add completion functions to fpath
fpath=($HOME/.config/shell/completions $fpath)

# Source shared libraries and ZSH configuration files
for file in "$HOME"/.config/shell/lib/* "$HOME"/.config/shell/zsh.d/*; do
    [[ -r "$file" ]] && source "$file"
done

# Source local zshrc
[[ -f ~/.zshrc.local ]] && . "$HOME/.zshrc.local"
