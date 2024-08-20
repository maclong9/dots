#!/bin/sh

# Clone the dotfiles repository
git clone https://github.com/maclong9/dots .config

# Create symlinks for dotfiles
for file in .config/.*(.); do
  if [[ $file:t != ".git" && $file:t != ".gitignore" && $file:t != "." && $file:t != ".." ]]; then
    ln -s "$file" "$HOME/${file:t}"
  fi
done

# Install mise
curl https://mise.run | sh
eval "$(~/.local/bin/mise activate zsh)"
mise install

# Source .zshrc
source $HOME/.zshrc
