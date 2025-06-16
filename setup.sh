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

# Setup colorschemes from ~/.config/colors
setup_colors() {
	log_info "Setting up colorscheme files..."

	COLORS_DIR="$HOME/.config/colors"
	
	if [ ! -d "$COLORS_DIR" ]; then
		log_warning "Colors directory $COLORS_DIR not found, skipping colorscheme setup"
		return 0
	fi

	# Setup vim colors directory
	mkdir -p "$HOME/.vim/colors"

	# Setup Xcode themes directory (macOS only)
	if [ "$(uname)" = "Darwin" ]; then
		XCODE_THEMES_DIR="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
		mkdir -p "$XCODE_THEMES_DIR"
	fi

	# Process each colorscheme directory
	for colorscheme_dir in "$COLORS_DIR"/*; do
		if [ -d "$colorscheme_dir" ]; then
			colorscheme_name=$(basename "$colorscheme_dir")
			log_info "Processing colorscheme: $colorscheme_name"

			# Symlink vim colorscheme files
			for vim_file in "$colorscheme_dir"/*.vim; do
				if [ -f "$vim_file" ]; then
					vim_filename=$(basename "$vim_file")
					target="$HOME/.vim/colors/$vim_filename"
					
					# Remove existing file/symlink if it exists
					if [ -e "$target" ] || [ -L "$target" ]; then
						rm "$target"
					fi
					
					ln -s "$vim_file" "$target"
					log_success "Symlinked vim colorscheme: $vim_filename"
				fi
			done

			# Symlink Xcode colorscheme files (macOS only)
			if [ "$(uname)" = "Darwin" ]; then
				for xcode_file in "$colorscheme_dir"/*.xccolorscheme; do
					if [ -f "$xcode_file" ]; then
						xcode_filename=$(basename "$xcode_file")
						target="$XCODE_THEMES_DIR/$xcode_filename"
						
						# Remove existing file/symlink if it exists
						if [ -e "$target" ] || [ -L "$target" ]; then
							rm "$target"
						fi
						
						ln -s "$xcode_file" "$target"
						log_success "Symlinked Xcode colorscheme: $xcode_filename"
					fi
				done
			fi
		fi
	done

	log_success "Colorscheme setup complete"
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

	# Setup colorschemes (after config is cloned)
	setup_colors

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
printf "3. Configure colorschemes in your editors\n"