#!/bin/sh

git clone https://github.com/maclong9/dots .config

for file in .config/.*; do
  case "$(basename "$file")" in
    "." | ".." | ".git") continue ;;
    *)
      ln -s "$file" "$HOME/$(basename "$file")"
      ;;
  esac
done

curl https://mise.run | sh
eval "$("$HOME"/.local/bin/mise activate zsh)"
mise install

(crontab -l 2>/dev/null; \
  echo "0 12 * * 1 mise upgrade && zplug update") | \
  crontab -

. "$HOME/.zshrc"

printf "\033[0;32m✓ Configuration Complete\033[0m\n"
printf "Make sure to run '\033[0;34mgh auth login\033[0m'\n"
