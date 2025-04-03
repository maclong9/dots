#!/bin/sh
# System Configuration
# usage: 
#   source <(curl https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/setup.sh)

# Restore System to Previous State If Non-Zero Exit Code
trap 'cleanup' EXIT
cleanup() {
	if [ $? -ne 0 ]; then
		sudo rm -rf "$HOME"/.config "$HOME"/.gitconfig "$HOME"/.vimrc \
  			"$HOME"/.zshrc /etc/pam.d/sudo_local /usr/local/bin
		(crontab -l 2>/dev/null | sed '$d;$d') | crontab -
	fi
}

# Check If Running on macOS
if [ "$(uname -s)" = "Darwin" ]; then
	# Enable Touch ID for `sudo`
	sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
	sudo sed -i '' '3s/^#//' /etc/pam.d/sudo_local

	# Install Developer Tools
	! xcode-select -p >/dev/null 2>&1 && xcode-select --install
	! /usr/bin/xcrun clang >/dev/null 2>&1 && sudo xcodebuild -license accept
fi

# Clone Configuration Files and Symlink to Home Directory
git clone https://github.com/maclong9/dots .config
for file in .config/.*; do
	case "$(basename "$file")" in
		"." | ".." | ".git") continue ;;
		*) ln -s "$file" "$HOME/$(basename "$file")" ;;
	esac
done

# SSH Setup
ssh-keygen -t ed25519 -C "maclong9@icloud.com" -f "$HOME/.ssh/id_ed25519" -N ""
eval "$(ssh-agent -s)"
mkdir ~/.ssh
printf 'Host github.com\n\tAddKeysToAgent yes\n\tIdentityFile ~/.ssh/id_ed25519' > ~/.ssh/config
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub | pbcopy

# Install Swift List
sudo mkdir /usr/local/bin 
sudo curl -L https://github.com/maclong9/list/releases/download/v1.1.1/sls -o /usr/local/bin/sls
sudo chmod +x /usr/local/bin/sls

# Deno
curl -fsSL https://deno.land/install.sh | sh;

printf "Run 'source ~/.zshrc' to and add your SSH key where needed"
