#!/bin/sh

set -e # Exit on any error

echo "🚀 Starting macOS development environment setup..."

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/installs/node/latest/bin/:$HOME/.local/share/mise/installs/github-cli/latest/gh_2.74.0_macOS_arm64/bin:$PATH"

# Clone and Symlink Dotfiles
echo "📁 Setting up dotfiles..."
if [ -d "$HOME/.config" ]; then
    echo "Backing up existing .config directory..."
    mv "$HOME/.config" "$HOME/.config.backup.$(date +%s)"
fi

git clone https://github.com/maclong9/dots "$HOME/.config"
cd "$HOME/.config"

for file in .*; do
    case "$file" in
    "." | ".." | ".git" | ".gitignore") continue ;;
    esac
    if [ -e "$HOME/$file" ]; then
        echo "Backing up existing $file..."
        mv "$HOME/$file" "$HOME/$file.backup.$(date +%s)"
    fi
    ln -s "$HOME/.config/$file" "$HOME/$file"
    echo "Linked $file"
done

# Enable Touch ID for `sudo`
echo "🔐 Enabling Touch ID for sudo..."
if [ ! -f /etc/pam.d/sudo_local ]; then
    sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
    sudo sed -i '' '3s/^#//' /etc/pam.d/sudo_local
    echo "Touch ID enabled for sudo"
else
    echo "Touch ID already configured"
fi

# Install Swift List
echo "📦 Installing Swift List..."
sudo mkdir -p /usr/local/bin
download_url=$(curl -s \
    https://api.github.com/repos/maclong9/list/releases/latest |
    grep "browser_download_url.*sls" |
    cut -d\" -f4)

if [ -z "$download_url" ]; then
    echo "⚠️  Could not find download URL for 'sls'. Skipping..."
else
    sudo curl -L "$download_url" -o /usr/local/bin/sls
    sudo chmod +x /usr/local/bin/sls
    echo "✅ Swift List installed"
fi

# Install mise toolse
echo "📦 Installing development tools via mise..."
curl https://mise.run | sh
mise install

# Install Language Servers via npm
echo "🛠️  Installing language servers..."
npm i -g @anthropic-ai/claude-code eslint prettier typescript \
    typescript-language-server vscode-langservers-extracted @tailwindcss/language-server

# Configure GitHub CLI
gh auth login
gh extension install github/gh-copilot

# Setup SSH Key
echo "🔑 Setting up SSH key..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "✅ SSH key generated"
else
    echo "SSH key already exists"
fi

# Copy public key to clipboard
if command -v pbcopy >/dev/null 2>&1; then
    cat ~/.ssh/id_rsa.pub | pbcopy
    echo "📋 SSH public key copied to clipboard"
fi

echo "\n✨ Setup completed successfully!\n"
echo "Next steps:\n"
echo "1. Run 'source ~/.zshrc' or restart your terminal\n"
echo "2. Add your SSH key to GitHub/GitLab/etc.\n"
