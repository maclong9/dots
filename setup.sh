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
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/zsh"
mkdir -p "$HOME/Developer/personal"
mkdir -p "$HOME/Developer/clients"
mkdir -p "$HOME/Developer/study" 
mkdir -p "$HOME/Developer/work"

# Install mise
if ! command -v mise > /dev/null 2>&1; then
    log_info "Installing mise..."
    curl https://mise.run | sh
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
    cp -R "/Volumes/OrbStack/OrbStack.app" /Applications/
    hdiutil detach "/Volumes/OrbStack" -quiet
    rm /tmp/OrbStack.dmg
    log_success "OrbStack installed"
else
    log_success "OrbStack already installed"
fi

# Install Zsh plugins
log_info "Installing Zsh plugins..."

# zsh-autosuggestions
if [ ! -d "$HOME/.local/share/zsh/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.local/share/zsh/zsh-autosuggestions"
    log_success "zsh-autosuggestions installed"
else
    log_success "zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$HOME/.local/share/zsh/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.local/share/zsh/zsh-syntax-highlighting"
    log_success "zsh-syntax-highlighting installed"
else
    log_success "zsh-syntax-highlighting already installed"
fi

# zsh-autocomplete
if [ ! -d "$HOME/.local/share/zsh/zsh-autocomplete" ]; then
    git clone https://github.com/marlonrichert/zsh-autocomplete "$HOME/.local/share/zsh/zsh-autocomplete"
    log_success "zsh-autocomplete installed"
else
    log_success "zsh-autocomplete already installed"
fi

# zsh-completions
if [ ! -d "$HOME/.local/share/zsh/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions "$HOME/.local/share/zsh/zsh-completions"
    log_success "zsh-completions installed"
else
    log_success "zsh-completions already installed"
fi

# Clone dotfiles repository to ~/.config
log_info "Cloning dotfiles repository..."
if [ ! -d "$HOME/.config/.git" ]; then
    git clone https://github.com/maclong9/dots "$HOME/.config"
    log_success "Dotfiles repository cloned to ~/.config"
else
    log_success "Dotfiles repository already exists in ~/.config"
fi

# Clone other repositories
log_info "Cloning repositories..."

# Personal repositories
cd "$HOME/Developer/personal"
personal_repos="web-ui list portfolio"
for repo in $personal_repos; do
    if [ ! -d "$repo" ]; then
        log_info "Cloning %s..." "$repo"
        git clone "https://github.com/maclong9/$repo"
    else
        log_success "%s already exists" "$repo"
    fi
done

# Study repositories
cd "$HOME/Developer/study"
study_repos="comp-sci"
for repo in $study_repos; do
    if [ ! -d "$repo" ]; then
        log_info "Cloning %s..." "$repo"
        git clone "https://github.com/maclong9/$repo"
    else
        log_success "%s already exists" "$repo"
    fi
done

# Return to home directory
cd "$HOME"

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
        log_success "Symlinked %s" "$file"
    else
        log_warning "%s not found in ~/.config" "$file"
    fi
done

# Install tools via mise
log_info "Installing development tools with mise..."
if [ -f "$HOME/.config/mise.toml" ]; then
    # Source mise if it's just been installed
    if [ -f "$HOME/.local/bin/mise" ]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    mise install
    log_success "Development tools installed"
else
    log_warning "mise.toml not found, skipping tool installation"
fi

log_success "Setup complete!\n"
printf "Next steps:\n"
printf "1. Restart your terminal or run: source ~/.zshrc\n"
printf "2. Configure Git with your details:\n"
printf "   git config --global user.name 'Your Name'\n"
printf "   git config --global user.email 'your.email@example.com'\n"
printf "3. Set up SSH keys for GitHub if needed\n\n"
printf "Installed applications:\n"
printf "- Ghostty (Terminal)\n"
printf "- OrbStack (Docker alternative)\n\n"
printf "Development tools available via mise:\n"
printf "- Node.js 20\n"
printf "- Deno\n"
printf "- Jujitsu (jj)\n"
printf "- GitHub CLI (gh)\n"
printf "- Helix editor (hx)\n"
printf "- Various other tools\n\n"
printf "Directory structure:\n"
printf "- ~/.config: dotfiles repository (maclong9/dots)\n"
printf "- ~/Developer/personal: web-ui, list, portfolio\n"
printf "- ~/Developer/clients: (empty, for freelance clients)\n"
printf "- ~/Developer/study: comp-sci\n"
printf "- ~/Developer/work: (empty, for work repositories)\n"
