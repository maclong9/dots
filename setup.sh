#!/bin/sh

# curl -sSL https://raw.githubusercontent.com/maclong9/dots/main/setup.sh | sh

git clone https://github.com/maclong9/dots .config

for file in .config/.*(.); do
  if [[ $file:t != ".git" && $file:t != "." && $file:t != ".." ]]; then
    ln -s "$file" "$HOME/${file:t}"
  fi
done

curl https://mise.run | sh
eval "$(~/.local/bin/mise activate zsh)"
mise install

echo "Please enter your ANTHROPIC_API_KEY:"
read api_key
echo "export ANTHROPIC_API_KEY=$api_key" >> ~/.zshenv

source $HOME/.zshrc
