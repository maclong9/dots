#!/bin/sh
# `curl -sSL https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/setup.sh | sh`

git clone https://github.com/maclong9/dots .config

for file in .config/.*; do
  case "$(basename "$file")" in
    "." | ".." | ".git") continue ;;
    *) ln -s "$file" "$HOME/$(basename "$file")" ;;
  esac
done

curl https://mise.run | sh
eval "$("$HOME"/.local/bin/mise activate zsh)"
mise install -y

(crontab -l 2>/dev/null; echo "0 12 * * 1 /Users/maclong/.local/bin/mise upgrade") | crontab -

. "$HOME/.zshrc"

printf "\033[0;32m✓ Configuration Complete\033[0m\n"
printf "You may need to restart your terminal for all changes to take effect.\n"
printf "Make sure to run '\033[0;34mgh auth login\033[0m'\n"
