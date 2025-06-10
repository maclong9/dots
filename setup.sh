#!/bin/sh

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

# Download vesper theme files
setup_vesper_themes() {
	log_info "Setting up vesper theme files..."

	# Base URL for the gist
	BASE_URL="https://gist.githubusercontent.com/maclong9/23b0fcf52d3d8c15345839cf6cd6b540/raw/9425cc252f8eaa4f762a39dba8f253be884facf4"

	# Create vim colors directory
	mkdir -p "$HOME/.vim/colors"

	# Download vesper.vim to ~/.vim/colors/
	log_info "Downloading vesper.vim theme..."
	if curl -fsSL "$BASE_URL/vesper.vim" -o "$HOME/.vim/colors/vesper.vim"; then
		log_success "Downloaded vesper.vim to ~/.vim/colors/"
	else
		log_error "Failed to download vesper.vim"
		return 1
	fi

	# macOS-specific theme files
	if [ "$(uname)" = "Darwin" ]; then
		# Download vesper.terminal to home directory (Terminal.app will find it there)
		log_info "Downloading vesper.terminal theme..."
		if curl -fsSL "$BASE_URL/vesper.terminal" -o "$HOME/vesper.terminal"; then
			log_success "Downloaded vesper.terminal to ~/vesper.terminal"
			log_info "To use: Open Terminal.app > Preferences > Profiles > Import and select ~/vesper.terminal"
		else
			log_error "Failed to download vesper.terminal"
		fi

		# Create Xcode themes directory and download vesper.xccolorscheme
		XCODE_THEMES_DIR="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
		mkdir -p "$XCODE_THEMES_DIR"
		
		log_info "Downloading vesper.xccolorscheme theme..."
		if curl -fsSL "$BASE_URL/vesper.xcccolortheme" -o "$XCODE_THEMES_DIR/vesper.xccolorscheme"; then
			log_success "Downloaded vesper.xccolorscheme to Xcode themes directory"
			log_info "To use: Open Xcode > Preferences > Themes and select Vesper"
		else
			log_error "Failed to download vesper.xccolorscheme"
		fi
	fi

	log_success "Vesper theme setup complete"
}

# macOS-specific setup function
setup_macos() {
	log_info "Running macOS-specific setup..."

	SUDO_LOCAL_FILE="/etc/pam.d/sudo_local"
	SUDO_LOCAL_TEMPLATE="/etc/pam.d/sudo_local.template"

	# Ensure Touch ID for sudo isn't already configured
	if [ -f "$SUDO_LOCAL_FILE" ] && grep -q "^auth.*pam_tid.so" "$SUDO_LOCAL_FILE" 2>/dev/null; then
		log_success "Touch ID for sudo already configured"
	else
		# Copy template to sudo_local and uncomment the Touch ID line
		sudo cp "$SUDO_LOCAL_TEMPLATE" "$SUDO_LOCAL_FILE"
        sudo sed -i '' 's/^#//' "$SUDO_LOCAL_FILE"

		# Verify the configuration was applied
		if grep -q "^auth.*pam_tid.so" "$SUDO_LOCAL_FILE" 2>/dev/null; then
			log_success "Touch ID enabled for sudo"
		else
			log_error "Failed to enable Touch ID for sudo"
			return 1
		fi
	fi
	log_success "macOS-specific setup complete"
}

# Main setup function
setup_development_environment() {
	log_info "Starting development environment setup..."

	# Create directory structure
	log_info "Creating directory structure..."
	mkdir -p "$HOME/.local/share/zsh"
	mkdir -p "$HOME/Developer/personal"
	mkdir -p "$HOME/Developer/freelance"
	mkdir -p "$HOME/Developer/study"
	mkdir -p "$HOME/Developer/work"

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

	# Symlink all hidden dotfiles from ~/.config to ~/
	find "$HOME/.config" -maxdepth 1 -name ".*" -type f | while read -r config_file; do
	    filename=$(basename "$config_file")

     	    # Skip navigagtion and git
	    case "$filename" in
	        "." | ".." | ".git")
	            continue
	            ;;
	    esac
	    
	    target="$HOME/$filename"
	    
	    # Clear the path for new connections
	    if [ -e "$target" ] || [ -L "$target" ]; then
	        rm "$target"
	    fi
	    
	    # Forge the link
	    ln -s "$config_file" "$target"
	    log_success "Symlinked $filename"
	done

	# Configure ssh key
	if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
		ssh-keygen -t ed25519 -C "hello@maclong.uk" -f ~/.ssh/id_ed25519 -N ""
		eval "$(ssh-agent -s)"
		printf "
		Host github.com
		  AddKeysToAgent yes
		  UseKeychain yes
		  IdentityFile ~/.ssh/id_ed25519
		
		" >"$HOME/.ssh/config"
		
		# Copy to clipboard if on macOS, otherwise display key
		if [ "$(uname)" = "Darwin" ]; then
			cat "$HOME/.ssh/id_ed25519.pub" | pbcopy
			log_success "ssh key generated and copied to clipboard"
		else
			log_success "ssh key generated"
			log_info "Public key:"
			cat "$HOME/.ssh/id_ed25519.pub"
		fi
	fi

	# Setup vesper themes
	setup_vesper_themes
 
	log_success "Development environment setup complete!"
}

# Main execution
if [ "$(uname)" = "Darwin" ]; then
	log_info "Detected macOS - running full setup"
	setup_macos
	setup_development_environment
else
	log_info "Detected non-macOS system - running cross-platform setup"
	setup_development_environment
fi

log_success "Setup complete!\n"
printf "Next steps:\n"
printf "1. Restart your terminal or run: source ~/.zshrc\n"
printf "2. Set up SSH keys on remote\n"
printf "3. Import vesper.terminal theme in Terminal.app preferences (macOS only)\n"
printf "4. Select Vesper theme in Xcode preferences (macOS only)\n"
