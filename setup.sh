#!/bin/sh

set -e # Exit on any error
printf "🚀 Starting macOS development environment setup..."
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/installs/node/latest/bin/:$HOME/.local/share/mise/installs/github-cli/latest/gh_2.74.0_macOS_arm64/bin:$PATH"

# Clone and Symlink Dotfiles
git clone https://github.com/maclong9/dots "$HOME/.config"
cd "$HOME/.config"

for file in .*; do
    case "$file" in
    "." | ".." | ".git" | ".gitignore") continue ;;
    esac
    if [ -e "$HOME/$file" ]; then
        printf "Backing up existing $file..."
        mv "$HOME/$file" "$HOME/$file.backup.$(date +%s)"
    fi
    ln -s "$HOME/.config/$file" "$HOME/$file"
    printf "Linked $file"
done

# Enable Touch ID for `sudo`
printf "🔐 Enabling Touch ID for sudo..."
if [ ! -f /etc/pam.d/sudo_local ]; then
    sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
    sudo sed -i '' '3s/^#//' /etc/pam.d/sudo_local
    printf "Touch ID enabled for sudo"
else
    printf "Touch ID already configured"
fi

# Install developer tooling
printf "📦 Installing development tools via mise..."
curl https://mise.run | sh
mise install

# Install Ghostty
echo "Installing Ghostty..."
curl -L "https://release.files.ghostty.org/1.1.3/Ghostty.dmg" -o /tmp/ghostty.dmg
hdiutil attach /tmp/ghostty.dmg -quiet
cp -R "/Volumes/Ghostty/Ghostty.app" /Applications/
hdiutil detach "/Volumes/Ghostty" -quiet
rm /tmp/ghostty.dmg

# Install OrbStack
echo "Installing OrbStack..."
curl -L "https://orbstack.dev/download/stable/latest/arm64" -o /tmp/orbstack.dmg
hdiutil attach /tmp/orbstack.dmg -quiet
cp -R "/Volumes/OrbStack/OrbStack.app" /Applications/
hdiutil detach "/Volumes/OrbStack" -quiet
rm /tmp/orbstack.dmg

# Install App Store apps
mas install 409203825  # Numbers
mas install 409183694  # Keynote
mas install 409201541  # Pages
mas install 634148309  # Logic Pro
mas install 424389933  # Final Cut Pro
mas install 424390742  # Compressor
mas install 434290957  # Motion
mas install 634159523  # MainStage
mas install 1289583905 # Pixelmator Pro
mas install 497799835  # Xcode

# Configure GitHub CLI
gh auth login
gh extension install github/gh-copilot

# Setup SSH Key
printf "🔑 Setting up SSH key..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    printf "✅ SSH key generated"
else
    printf "SSH key already exists"
fi

if command -v pbcopy >/dev/null 2>&1; then
    cat ~/.ssh/id_rsa.pub | pbcopy
    printf "📋 SSH public key copied to clipboard"
fi

printf "\n✨ Setup completed successfully!\n"
printf "Next steps:\n"
printf "1. Run 'source ~/.zshrc' or restart your terminal\n"
printf "2. Add your SSH key to GitHub/GitLab/etc.\n"
