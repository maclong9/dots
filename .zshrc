#!/usr/bin/env zsh

# Add completion functions to fpath
fpath=($HOME/.config/shell/completions $fpath)

# Source shared libraries and ZSH configuration files in order
for file in $HOME/.config/shell/lib/*.sh $HOME/.config/shell/zsh/*.zsh; do
    [[ -r "$file" ]] && source "$file"
done

# Initialize completions
autoload -Uz compinit bashcompinit
compinit -d "${ZSH_COMPDUMP:-$HOME/.zcompdump}"
bashcompinit

# Source local zshrc
[[ -f ~/.zshrc.local ]] && . "$HOME/.zshrc.local"
