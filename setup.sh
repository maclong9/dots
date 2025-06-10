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
		sudo sed -i '' 's/^#auth.*sufficient.*pam_tid\.so/auth       sufficient     pam_tid.so/' "$SUDO_LOCAL_FILE"

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
	mkdir -p "$HOME/Developer/clients"
	mkdir -p "$HOME/Developer/study"
	mkdir -p "$HOME/Developer/work"

	# Install Zsh plugins
	log_info "Installing Zsh plugins..."

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
