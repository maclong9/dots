#!/bin/sh
# `curl -sSL https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/setup.sh | sh`

trap 'cleanup' EXIT

cleanup() {
  if [ $? -ne 0 ]; then
    sudo rm -rf "$HOME"/.config "$HOME"/.gitconfig "$HOME"/.gitignore \
      "$HOME"/.vim "$HOME"/.vimrc "$HOME"/.zshrc
    (crontab -l 2>/dev/null | sed '$d;$d') | crontab -
  fi
}

# stop machine from sleeping while script runs
if [ "$(uname -s)" = "Darwin" ]; then caffeinate -s -w $$ & fi

# enable TouchID for `sudo`
sudo sed 's/^#auth/auth/' /etc/pam.d/sudo_local.template |
  sudo tee /etc/pam.d/sudo_local > /dev/null

# install Xcode & cli tools, accept license and update
if  [ "$(uname -s)" = "Darwin" ]; then
  if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
  fi
  
  if ! /usr/bin/xcrun clang >/dev/null 2>&1; then
    sudo xcodebuild -license accept
  fi
  
  sudo softwareupdate --install --all
fi

# clone configuration files and symlink to home directory
git clone https://github.com/maclong9/dots .config
for file in .config/.*; do
  case "$(basename "$file")" in
    "." | ".." | ".git") continue ;;
    *) ln -s "$file" "$HOME/$(basename "$file")" ;;
  esac
done

# setup vim Xcode colorscheme
git clone https://github.com/arzg/vim-colors-xcode.git
cp -r vim-colors-xcode/{autoload,colors,doc} ~/.vim
rm -rf vim-colors-xcode

# install mise and runtimes
curl https://mise.run | sh
eval "$("$HOME"/.local/bin/mise activate zsh)"
mise install -y

# cron for updating runtimes
(crontab -l 2>/dev/null; echo "0 10 * * 1 /Users/maclong/.local/bin/mise upgrade") | crontab -

printf "Configuration complete\nMake sure to authenticate the GitHub cli\n"
