#!/bin/sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Debug flag - default to false
DEBUG=false

# Parse command line arguments
for arg in "$@"; do
	case $arg in
		--debug)
			DEBUG=true
			shift
			;;
		*)
			# Unknown option
			;;
	esac
done

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

log_debug() {
	if [ "$DEBUG" = true ]; then
		printf "${CYAN}[DEBUG]${NC} %s\n" "$1"
	fi
}

# Setup colorschemes from ~/.config/colors
setup_colors() {
	log_info "Setting up colorscheme files..."
	log_debug "Colors directory should be at: $HOME/.config/colors"

	COLORS_DIR="$HOME/.config/colors"
	
	if [ ! -d "$COLORS_DIR" ]; then
		log_warning "Colors directory $COLORS_DIR not found, skipping colorscheme setup"
		log_debug "Checked path: $COLORS_DIR"
		return 0
	fi

	log_debug "Found colors directory: $COLORS_DIR"

	# Setup vim colors directory
	log_debug "Creating vim colors directory: $HOME/.vim/colors"
	mkdir -p "$HOME/.vim/colors"

	# Setup Xcode themes directory (macOS only)
	if [ "$(uname)" = "Darwin" ]; then
		XCODE_THEMES_DIR="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
		log_debug "Creating Xcode themes directory: $XCODE_THEMES_DIR"
		mkdir -p "$XCODE_THEMES_DIR"
	fi

	# Count colorscheme directories
	colorscheme_count=0
	for colorscheme_dir in "$COLORS_DIR"/*; do
		if [ -d "$colorscheme_dir" ]; then
			colorscheme_count=$((colorscheme_count + 1))
		fi
	done
	log_debug "Found $colorscheme_count colorscheme directories"

	# Process each colorscheme directory
	for colorscheme_dir in "$COLORS_DIR"/*; do
		if [ -d "$colorscheme_dir" ]; then
			colorscheme_name=$(basename "$colorscheme_dir")
			log_info "Processing colorscheme: $colorscheme_name"
			log_debug "Processing directory: $colorscheme_dir"

			# Count vim files
			vim_file_count=0
			for vim_file in "$colorscheme_dir"/*.vim; do
				if [ -f "$vim_file" ]; then
					vim_file_count=$((vim_file_count + 1))
				fi
			done
			log_debug "Found $vim_file_count vim colorscheme files in $colorscheme_name"

			# Symlink vim colorscheme files
			for vim_file in "$colorscheme_dir"/*.vim; do
				if [ -f "$vim_file" ]; then
					vim_filename=$(basename "$vim_file")
					target="$HOME/.vim/colors/$vim_filename"
					
					log_debug "Processing vim file: $vim_file -> $target"
					
					# Remove existing file/symlink if it exists
					if [ -e "$target" ] || [ -L "$target" ]; then
						log_debug "Removing existing file/symlink: $target"
						rm "$target"
					fi
					
					ln -s "$vim_file" "$target"
					log_success "Symlinked vim colorscheme: $vim_filename"
					log_debug "Created symlink: $vim_file -> $target"
				fi
			done

			# Symlink Xcode colorscheme files (macOS only)
			if [ "$(uname)" = "Darwin" ]; then
				# Count Xcode files (check both extensions)
				xcode_file_count=0
				for xcode_file in "$colorscheme_dir"/*.xccolorscheme "$colorscheme_dir"/*.xccolortheme; do
					if [ -f "$xcode_file" ]; then
						xcode_file_count=$((xcode_file_count + 1))
					fi
				done
				log_debug "Found $xcode_file_count Xcode colorscheme files in $colorscheme_name"

				# Process both possible extensions
				for xcode_file in "$colorscheme_dir"/*.xccolorscheme "$colorscheme_dir"/*.xccolortheme; do
					if [ -f "$xcode_file" ]; then
						xcode_filename=$(basename "$xcode_file")
						target="$XCODE_THEMES_DIR/$xcode_filename"
						
						log_debug "Processing Xcode file: $xcode_file -> $target"
						
						# Remove existing file/symlink if it exists
						if [ -e "$target" ] || [ -L "$target" ]; then
							log_debug "Removing existing file/symlink: $target"
							rm "$target"
						fi
						
						ln -s "$xcode_file" "$target"
						log_success "Symlinked Xcode colorscheme: $xcode_filename"
						log_debug "Created symlink: $xcode_file -> $target"
					fi
				done
				
				# Log if no Xcode files were found for this colorscheme
				if [ $xcode_file_count -eq 0 ]; then
					log_debug "No Xcode colorscheme files found in $colorscheme_name"
				fi
			fi
		fi
	done

	log_success "Colorscheme setup complete"
	log_debug "Processed $colorscheme_count colorscheme directories"
}

# macOS-specific setup function
setup_macos() {
	log_info "Running macOS-specific setup..."
	log_debug "Detected macOS system: $(sw_vers -productName) $(sw_vers -productVersion)"

	SUDO_LOCAL_FILE="/etc/pam.d/sudo_local"
	SUDO_LOCAL_TEMPLATE="/etc/pam.d/sudo_local.template"
	
	log_debug "Checking sudo_local file: $SUDO_LOCAL_FILE"
	log_debug "Template file: $SUDO_LOCAL_TEMPLATE"

	# Ensure Touch ID for sudo isn't already configured
	if [ -f "$SUDO_LOCAL_FILE" ] && grep -q "^auth.*pam_tid.so" "$SUDO_LOCAL_FILE" 2>/dev/null; then
		log_success "Touch ID for sudo already configured"
		log_debug "Found existing Touch ID configuration in $SUDO_LOCAL_FILE"
	else
		log_debug "Touch ID not configured, setting up..."
		
		# Check if template exists
		if [ ! -f "$SUDO_LOCAL_TEMPLATE" ]; then
			log_error "Template file $SUDO_LOCAL_TEMPLATE not found"
			log_debug "Unable to proceed with Touch ID setup"
			return 1
		fi
		
		log_debug "Copying template to sudo_local file"
		# Copy template to sudo_local and uncomment the Touch ID line
		sudo cp "$SUDO_LOCAL_TEMPLATE" "$SUDO_LOCAL_FILE"
		log_debug "Uncommenting Touch ID line in sudo_local"
        sudo sed -i '' 's/^#//' "$SUDO_LOCAL_FILE"

		# Verify the configuration was applied
		if grep -q "^auth.*pam_tid.so" "$SUDO_LOCAL_FILE" 2>/dev/null; then
			log_success "Touch ID enabled for sudo"
			log_debug "Verified Touch ID configuration in $SUDO_LOCAL_FILE"
		else
			log_error "Failed to enable Touch ID for sudo"
			log_debug "Touch ID configuration verification failed"
			return 1
		fi
	fi
	log_success "macOS-specific setup complete"
}

# Create development directories 
create_dev_directories() {
	log_info "Creating directory structure..."
	log_debug "Creating developer directories"
	
	directories="$HOME/Developer/personal $HOME/Developer/freelance $HOME/Developer/study $HOME/Developer/work"
	directory_count=0
	
	# Process each directory using word splitting
	for dir in $directories; do
		log_debug "Creating directory: $dir"
		mkdir -p "$dir"
		directory_count=$((directory_count + 1))
	done
	
	log_debug "Created $directory_count developer directories"
}

# Main setup function
setup_development_environment() {
	log_info "Starting development environment setup..."
	log_debug "Home directory: $HOME"
	log_debug "Current user: $(whoami)"

	# Create directory structure
	create_dev_directories

	# Clone dotfiles repository to ~/.config
	log_info "Cloning dotfiles repository..."
	log_debug "Checking for existing git repository at: $HOME/.config/.git"
	
	if [ ! -d "$HOME/.config/.git" ]; then
		log_debug "Cloning dotfiles from: https://github.com/maclong9/dots"
		git clone https://github.com/maclong9/dots "$HOME/.config"
		log_success "Dotfiles repository cloned to ~/.config"
	else
		log_success "Dotfiles repository already exists in ~/.config"
		log_debug "Git repository already exists at $HOME/.config"
	fi

	# Setup colorschemes (after config is cloned)
	setup_colors

	# Create symbolic links for configuration files
	log_info "Creating symbolic links for configuration files..."
	log_debug "Searching for dotfiles in: $HOME/.config"

	log_debug "Found dotfiles to symlink"

	# Symlink all hidden dotfiles from ~/.config to ~/
	find "$HOME/.config" -maxdepth 1 -name ".*" -type f | while read -r config_file; do
	    filename=$(basename "$config_file")

     	    # Skip navigation and git
	    case "$filename" in
	        "." | ".." | ".git")
	            log_debug "Skipping: $filename"
	            continue
	            ;;
	    esac
	    
	    target="$HOME/$filename"
	    log_debug "Processing dotfile: $config_file -> $target"
	    
	    # Clear the path for new connections
	    if [ -e "$target" ] || [ -L "$target" ]; then
	        log_debug "Removing existing file/symlink: $target"
	        rm "$target"
	    fi
	    
	    # Forge the link
	    ln -s "$config_file" "$target"
	    log_success "Symlinked $filename"
	    log_debug "Created symlink: $config_file -> $target"
	done

	# Configure ssh key
	log_debug "Checking for existing SSH key: $HOME/.ssh/id_ed25519"
	if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
		log_debug "Generating new SSH key with email: hello@maclong.uk"
		ssh-keygen -t ed25519 -C "hello@maclong.uk" -f ~/.ssh/id_ed25519 -N ""
		log_debug "Starting SSH agent"
		eval "$(ssh-agent -s)"
		
		log_debug "Creating SSH config file"
		printf "
		Host github.com
		  AddKeysToAgent yes
		  UseKeychain yes
		  IdentityFile ~/.ssh/id_ed25519
		
		" >"$HOME/.ssh/config"
		
		# Copy to clipboard if on macOS, otherwise display key
		if [ "$(uname)" = "Darwin" ]; then
			log_debug "Copying SSH public key to clipboard (macOS)"
			cat "$HOME/.ssh/id_ed25519.pub" | pbcopy
			log_success "ssh key generated and copied to clipboard"
		else
			log_success "ssh key generated"
			log_info "Public key:"
			cat "$HOME/.ssh/id_ed25519.pub"
			log_debug "Displayed public key (non-macOS system)"
		fi
	else
		log_debug "SSH key already exists: $HOME/.ssh/id_ed25519"
	fi
 
	log_success "Development environment setup complete!"
}

# Main execution
log_debug "Debug logging enabled"
log_debug "Operating system: $(uname)"
log_debug "Script arguments: $*"

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

log_debug "Script execution completed"
