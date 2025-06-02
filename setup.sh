#!/bin/sh
# Detect platform and run appropriate setup script
if [ "$(uname -s)" = "Darwin" ]; then
	echo "Detected macOS - running macOS setup..."
	curl -fsSl https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/setup-macos.sh | sh
elif [ "$(uname -s)" = "Linux" ]; then
	echo "Detected Linux - running Linux setup..."
	curl curl -fsSl https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/setup-container.sh | sh
else
	echo "Unsupported platform: $(uname -s)"
	exit 1
fi

# Install Swift List
sudo mkdir -p /usr/local/bin
download_url=$(curl -s \
	https://api.github.com/repos/maclong9/list/releases/latest | 
	grep "browser_download_url.*sls" |
	cut -d\" -f4)
if [ -z "$download_url" ]; then
    echo "Error: Could not find download URL for 'sls' in the latest release."
    exit 1
fi
sudo curl -L "$download_url" -o /usr/local/bin/sls
sudo chmod +x /usr/local/bin/sls

# Setup SSH Key and copy to clipboard
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
cat ~/.ssh/id_rsa.pub | pbcopy

printf "Setup completed! Run 'source ~/.zshrc' and add your SSH key where needed\n"
