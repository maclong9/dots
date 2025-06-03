#!/bin/sh

set -e  # Exit on any error

echo "🚀 Starting macOS development environment setup..."

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
    https://api.github.com/repos/maclong9/list/releases/latest | \
    grep "browser_download_url.*sls" | \
    cut -d\" -f4)

if [ -z "$download_url" ]; then
    echo "⚠️  Could not find download URL for 'sls'. Skipping..."
else
    sudo curl -L "$download_url" -o /usr/local/bin/sls
    sudo chmod +x /usr/local/bin/sls
    echo "✅ Swift List installed"
fi

# Check if MacPorts is already installed
if command -v port >/dev/null 2>&1; then
    echo "📦 MacPorts already installed, updating..."
    sudo port selfupdate
else
    echo "📦 Fetching latest MacPorts release..."
    
    # Get latest release info from GitHub API
    latest_release=$(curl -s https://api.github.com/repos/macports/macports-base/releases/latest)
    latest_version=$(echo "$latest_release" | grep '"tag_name":' | cut -d'"' -f4 | sed 's/^v//')
    
    if [ -z "$latest_version" ]; then
        echo "❌ Failed to fetch latest MacPorts version"
        exit 1
    fi
    
    echo "📦 Latest MacPorts version: $latest_version"
    
    # Detect macOS version dynamically
    macos_version=$(sw_vers -productVersion)
    major_version=$(echo "$macos_version" | cut -d. -f1)
    
    case "$major_version" in
        "15") pkg_version="15-Sequoia" ;;
        "14") pkg_version="14-Sonoma" ;;
        "13") pkg_version="13-Ventura" ;;
        "12") pkg_version="12-Monterey" ;;
        *) 
            echo "⚠️  Unsupported macOS version: $macos_version"
            echo "Please install MacPorts manually from https://www.macports.org/install.php"
            exit 1
            ;;
    esac
    
    # Construct download URL and filename
    pkg_file="MacPorts-${latest_version}-${pkg_version}.pkg"
    download_url="https://github.com/macports/macports-base/releases/download/v${latest_version}/${pkg_file}"
    
    echo "📦 Downloading ${pkg_file}..."
    curl -L -O "$download_url"
    
    if [ ! -f "$pkg_file" ]; then
        echo "❌ Failed to download MacPorts package"
        echo "URL attempted: $download_url"
        exit 1
    fi
    
    echo "📦 Installing MacPorts..."
    sudo installer -pkg "$pkg_file" -target /
    rm -f "$pkg_file"
    
    # Configure MacPorts for parallel builds
    sudo sed -i '' 's/^#buildmakejobs.*$/buildmakejobs    0/' /opt/local/etc/macports/macports.conf
    
    # Add MacPorts to PATH for current session
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
    
    sudo port selfupdate
fi

# Install MacPorts packages
echo "📦 Installing development tools via MacPorts..."
sudo port install colima deno docker docker-compose ffmpeg gh helix nodejs22 npm10 shellcheck shfmt

# Install Language Servers via npm
echo "🛠️  Installing language servers..."
sudo npm i -g @anthropic-ai/claude-code eslint pnpm prettier typescript \
    typescript-language-server vscode-langservers-extracted @tailwindcss/language-server

# Setup SSH Key
echo "🔑 Setting up SSH key..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "✅ SSH key generated"
else
    echo "SSH key already exists"
fi

# Configure GitHub CLI
gh auth login
gh extension install github/gh-copilot

# Copy public key to clipboard
if command -v pbcopy >/dev/null 2>&1; then
    cat ~/.ssh/id_rsa.pub | pbcopy
    echo "📋 SSH public key copied to clipboard"
fi

echo "\n✨ Setup completed successfully!\n"
echo "Next steps:\n"
echo "1. Run 'source ~/.zshrc' or restart your terminal\n"
echo "2. Add your SSH key to GitHub/GitLab/etc.\n"
