#!/bin/sh

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
		"." | ".." | ".git" | ".gitignore") continue ;;
		*) ln -s "$file" "$HOME/$(basename "$file")" ;;
	esac
done

# Install Swift List
sudo mkdir -p /usr/local/bin
download_url=$(curl -s https://api.github.com/repos/maclong9/list/releases/latest | grep "browser_download_url.*sls" | cut -d\" -f4)
if [ -z "$download_url" ]; then
    echo "Error: Could not find download URL for 'sls' in the latest release."
    exit 1
fi
sudo curl -L "$download_url" -o /usr/local/bin/sls
sudo chmod +x /usr/local/bin/sls

# Install Deno
curl -fsSL https://deno.land/install.sh | sh

# Setup SSH Key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
cat ~/.ssh/id_rsa | pbcopy

printf "Run 'source ~/.zshrc' to and add your SSH key where needed"
