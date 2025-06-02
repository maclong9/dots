#!/bin/sh
# macOS-specific setup script
echo "Setting up macOS-specific configurations..."

# Clone dotfiles
git clone https://github.com/maclong9/dots "$HOME/.config"

# Symlink to Home Directory
for file in "$HOME"/.config/.*; do
    base="$(basename "$file")"
    case "$base" in
        "." | ".." | ".*" | ".git" | ".gitignore") continue ;;
    esac

    target="$HOME/$base"
    [ -e "$target" ] && rm -rf "$target"
    ln -s "$(pwd)/$file" "$target"
done

# Enable Touch ID for `sudo`
sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
sudo sed -i '' '3s/^#//' /etc/pam.d/sudo_local

# Install latest Helix from GitHub releases
echo "Installing latest Helix from GitHub releases..."
HELIX_VERSION=$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
echo "Latest Helix version: $HELIX_VERSION"

# Download and install Helix
curl -LO "https://github.com/helix-editor/helix/releases/download/$HELIX_VERSION/helix-$HELIX_VERSION-aarch64-macos.tar.xz"
tar -xf helix-$HELIX_VERSION-aarch64-macos.tar.xz

# Install binary and runtime to /usr/local/bin
sudo cp helix-$HELIX_VERSION-aarch64-macos/hx /usr/local/bin/
sudo cp -r helix-$HELIX_VERSION-aarch64-macos/runtime /usr/local/bin/

# Clean up
rm -rf helix-$HELIX_VERSION-aarch64-macos.tar.xz helix-$HELIX_VERSION-aarch64-macos/

# Verify installation
echo "Helix installed successfully:"
hx --version

# Install latest GitHub CLI from GitHub releases
echo "Installing latest GitHub CLI from GitHub releases..."
GH_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
echo "Latest GitHub CLI version: $GH_VERSION"

# Download and install GitHub CLI
curl -LO "https://github.com/cli/cli/releases/download/$GH_VERSION/gh_${GH_VERSION#v}_macOS_arm64.tar.gz"
tar -xzf gh_${GH_VERSION#v}_macOS_arm64.tar.gz

# Install binary to /usr/local/bin
sudo cp gh_${GH_VERSION#v}_macOS_arm64/bin/gh /usr/local/bin/

# Clean up
rm -rf gh_${GH_VERSION#v}_macOS_arm64.tar.gz gh_${GH_VERSION#v}_macOS_arm64/

# Verify installation
echo "GitHub CLI installed successfully:"
gh --version

gh auth login
gh extension install github/gh-copilot

# Destroy and recreate orb instance to ensure clean state
echo "Removing previous containers..."
orb delete void -f
orb create void

# Wait for the background process to complete
echo "Waiting for orb create to complete..."
wait

# Execute orb curl inside the orb void instance
infocmp -x xterm-ghostty | orb tic -x -
orb exec sh -c "curl -fsSL https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/setup.sh | sh"

echo "macOS setup completed. SSH key copied to clipboard."
