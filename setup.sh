#!/bin/sh

git clone https://github.com/maclong9/dots .config

for file in .config/.*(.); do
  if [[ $file:t != ".git" && $file:t != "." && $file:t != ".." ]]; then
    ln -s "$file" "$HOME/${file:t}"
  fi
done

curl https://mise.run | sh
eval "$(~/.local/bin/mise activate zsh)"
mise install

source $HOME/.zshrc

printf "\033[0;32m✓ Configuration Complete\033[0m\n"
printf "Make sure to run '\033[0;34mgh auth login"
