#!/bin/sh

# macOS Development Environment Setup Script
# Configures development tools, applications, and dotfiles

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

log_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

# Check if we're on macOS
if [ "$(uname)" != "Darwin" ]; then
    log_error "This script is designed for macOS only"
    exit 1
fi

log_info "Starting macOS development environment setup..."

# Create directory structure
log_info "Creating directory structure..."
mkdir -p "$HOME/.local/share/zsh"
mkdir -p "$HOME/Developer/personal"
mkdir -p "$HOME/Developer/clients"
mkdir -p "$HOME/Developer/study" 
mkdir -p "$HOME/Developer/work"

SUDO_LOCAL_FILE="/etc/pam.d/sudo_local"
SUDO_LOCAL_TEMPLATE="/etc/pam.d/sudo_local.template"

# Ensure Touch ID for sudo isn't already configured
if [ -f "$SUDO_LOCAL_FILE" ] && grep -q "^auth.*pam_tid.so" "$SUDO_LOCAL_FILE" 2>/dev/null; then
    log_success "Touch ID for sudo already configured"
else
    # Copy template to sudo_local and uncomment the Touch ID line
    sudo cp "$SUDO_LOCAL_TEMPLATE" "$SUDO_LOCAL_FILE"
    sudo sed -i '' 's/^#auth.*sufficient.*pam_tid\.so/auth       sufficient     pam_tid.so/' "$SUDO_LOCAL_FILE"
        
    # Verify the configuration was applied
    if grep -q "^auth.*pam_tid.so" "$SUDO_LOCAL_FILE" 2>/dev/null; then
        log_success "Touch ID enabled for sudo"
    else
        log_error "Failed to enable Touch ID for sudo"
        return 1
    fi
fi

# Install mise
if ! command -v mise > /dev/null 2>&1; then
    log_info "Installing mise..."
    curl https://mise.run | sh
    log_success "mise installed"
else
    log_success "mise already installed"
fi

# Install applications via DMG
log_info "Installing applications..."

# Install Ghostty
if [ ! -d "/Applications/Ghostty.app" ]; then
    log_info "Installing Ghostty..."
    curl -L -o /tmp/Ghostty.dmg https://release.files.ghostty.org/1.1.3/Ghostty.dmg
    hdiutil attach /tmp/Ghostty.dmg -quiet
    cp -R "/Volumes/Ghostty/Ghostty.app" /Applications/
    hdiutil detach "/Volumes/Ghostty" -quiet
    rm /tmp/Ghostty.dmg
    log_success "Ghostty installed"
else
    log_success "Ghostty already installed"
fi

# Install OrbStack
if [ ! -d "/Applications/OrbStack.app" ]; then
    log_info "Installing OrbStack..."
    curl -L -o /tmp/OrbStack.dmg https://orbstack.dev/download/stable/latest/arm64
    hdiutil attach /tmp/OrbStack.dmg -quiet
    cp -R "/Volumes/Install OrbStack v1.11.3/OrbStack.app" /Applications/
    hdiutil detach "/Volumes/Install OrbStack v1.11.3" -quiet
    rm /tmp/OrbStack.dmg
    log_success "OrbStack installed"
else
    log_success "OrbStack already installed"
fi

# Install Zsh plugins
log_info "Installing Zsh plugins..."

# Define plugins with their repositories
plugins="
zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions
zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting
zsh-autocomplete:https://github.com/marlonrichert/zsh-autocomplete
zsh-completions:https://github.com/zsh-users/zsh-completions
zsh-you-should-use:https://github.com/MichaelAquilina/zsh-you-should-use
"

# Install each plugin
for plugin_line in $plugins; do
    # Skip empty lines
    [ -z "$plugin_line" ] && continue
    
    # Extract plugin name and repository URL
    plugin_name="${plugin_line%%:*}"
    repo_url="${plugin_line##*:}"
    plugin_dir="$HOME/.local/share/zsh/$plugin_name"
    
    if [ ! -d "$plugin_dir" ]; then
        git clone "$repo_url" "$plugin_dir"
        log_success "$plugin_name installed"
    else
        log_success "$plugin_name already installed"
    fi
done

# Clone dotfiles repository to ~/.config
log_info "Cloning dotfiles repository..."
if [ ! -d "$HOME/.config/.git" ]; then
    git clone https://github.com/maclong9/dots "$HOME/.config"
    log_success "Dotfiles repository cloned to ~/.config"
else
    log_success "Dotfiles repository already exists in ~/.config"
fi

# Create symbolic links for configuration files
log_info "Creating symbolic links for configuration files..."

# Symlink dotfiles from ~/.config to ~/
config_files=".zshrc .vimrc"

for file in $config_files; do
    if [ -f "$HOME/.config/$file" ]; then
        # Remove existing file/symlink if it exists
        if [ -e "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
            rm "$HOME/$file"
        fi
        
        # Create symlink
        ln -s "$HOME/.config/$file" "$HOME/$file"
        log_success "Symlinked $file"
    else
        log_warning "$file not found in ~/.config"
    fi
done

# Install tools via mise
log_info "Installing development tools with mise..."
if [ -f "$HOME/.local/bin/mise" ]; then
    export PATH="$HOME/.local/bin:$PATH"
    mise install
    mkdir -p "$HOME/.local/share/zsh/completions"
    mise completion zsh > "$HOME/.local/share/zsh/completions/_mise"
    log_success "Development tools installed"
else
    log_warning "mise.toml not found, skipping tool installation"
fi

# Configure ssh key
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "hello@maclong.uk" -f ~/.ssh/id_ed25519 -N ""
    eval "$(ssh-agent -s)"
    printf "
    Host github.com
      AddKeysToAgent yes
      UseKeychain yes
      IdentityFile ~/.ssh/id_ed25519
    
    " > "$HOME/.ssh/config"
    cat "$HOME/.ssh/id_ed25519.pub" | pbcopy
    log_success "ssh key generated"
fi

# Re-clone repository with `jj`
export PATH="$HOME/.local/share/mise/shims:$PATH"
jj git clone https://github.com/maclong9/dots "$HOME/config"
rm -rf "$HOME/.config"
mv "$HOME/config" "$HOME/.config"


log_success "Setup complete!\n"
printf "Next steps:\n"
printf "1. Restart your terminal or run: source ~/.zshrc\n"
printf "2. Set up SSH keys on remote\n"
