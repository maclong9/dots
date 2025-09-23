#!/bin/zsh

# Add completion functions to fpath
fpath=($HOME/.config/shell/completions $fpath)

# Source shared libraries and ZSH configuration files in order
for file in $HOME/.config/shell/lib/* $HOME/.config/shell/zsh.d/*; do
    [[ -r "$file" ]] && source "$file"
done

# Initialize completions
autoload -Uz compinit bashcompinit
compinit -d "${ZSH_COMPDUMP:-$HOME/.zcompdump}"
bashcompinit

# Source local zshrc
[[ -f ~/.zshrc.local ]] && . "$HOME/.zshrc.local"
