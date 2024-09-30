#!/bin/sh
# `curl -sSL https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/setup.sh | sh`

trap '
if [ $? -ne 0 ]; then
  sudo rm -rf "$HOME/.*" "/etc/pam.d/sudo_local"
  (crontab -l 2>/dev/null | sed "2d") | crontab -
fi
' EXIT

caffeinate -s -w $$ &

sudo sed 's/^#auth/auth/' /etc/pam.d/sudo_local.template |
  sudo tee /etc/pam.d/sudo_local > /dev/null

if ! xcode-select -p 2>&1; then
  xcode-select --install
fi

if ! /usr/bin/xcrun clang 2>&1; then
  sudo xcodebuild -license accept
fi

sudo softwareupdate --install --all

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
(crontab -l 2>/dev/null; echo "0 12 * * 1 /usr/sbin/softwareupdate --install --all") | crontab -

printf "\033[0;32m✓ Configuration Complete\033[0m\n\
You may need to restart your terminal for all changes to take effect.\n\
Make sure to run '\033[0;34mgh auth login\033[0m'\n"
