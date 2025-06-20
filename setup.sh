#!/bin/sh

set -e
trap 'log error "Setup failed at line $LINENO"' ERR

# Error if basic commands missing
for cmd in git curl ln mkdir; do
	command -v "$cmd" > /dev/null 2>&1 || {
		printf "ERROR: %s required but not found\n" "$cmd" >&2
		exit 1
	}
done

# Download and source utilities
curl -fsSL \
	"https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/utils.sh" \
	-o /tmp/utils.sh || {
	printf "\033[0;31m[ERROR]\033[0m Failed to download utils.sh\n" >&2
	exit 1
}

. /tmp/utils.sh || {
	printf "\033[0;31m[ERROR]\033[0m Failed to source utils.sh\n" >&2
	exit 1
}

parse_args "$@"

process_colorscheme_files() {
	local scheme_dir="$1" pattern="$2" target_dir="$3" file_type="$4"

	[ ! -d "$scheme_dir" ] && return 0

	local count scheme filename
	count=$(count_files "$scheme_dir/$pattern") || {
		log error "Failed to count files in $scheme_dir"
		return 1
	}

	scheme=$(basename "$scheme_dir")
	log debug "Found $count $file_type files in $scheme"

	[ "$count" -eq 0 ] && return 0

	for file in "$scheme_dir"/$pattern; do
		[ -f "$file" ] || continue
		filename=$(basename "$file")
		log info "Symlinking $file_type file $filename"
		safe_symlink "$file" "$target_dir/$filename" || {
			log error "Failed to symlink $filename"
			return 1
		}
	done
}

setup_colors() {
	[ ! -d "$HOME/.config/colors" ] && {
		log warning "Colors directory missing, skipping color setup"
		return 0
	}

	log info "Installing colorschemes..."

	spinner "Creating Vim colors directory" \
		ensure_directory "$HOME/.vim/colors" || {
		log error "Failed to create Vim colors directory"
		return 1
	}

	if [ "$IS_MAC" = true ]; then
		local xcode_dir="$HOME/Library/Developer/Xcode/UserData"
		xcode_dir="$xcode_dir/FontAndColorThemes"

		spinner "Creating Xcode colors directory" \
			ensure_directory "$xcode_dir" || {
			log error "Failed to create Xcode colors directory"
			return 1
		}
	fi

	# Count scheme directories
	local scheme_count=0
	for scheme_dir in "$HOME/.config/colors"/*; do
		[ -d "$scheme_dir" ] && scheme_count=$((scheme_count + 1))
	done

	[ "$scheme_count" -eq 0 ] && {
		log warning "No colorscheme directories found"
		return 0
	}

	log debug "Found $scheme_count colorscheme directories"

	for scheme_dir in "$HOME/.config/colors"/*; do
		[ -d "$scheme_dir" ] || continue

		local scheme_name=$(basename "$scheme_dir")
		log info "Processing scheme: $scheme_name"

		[ "$DEBUG" = true ] && {
			log debug "Files in $scheme_name:"
			ls -la "$scheme_dir" >&2
		}

		process_colorscheme_files "$scheme_dir" "*.vim" \
			"$HOME/.vim/colors" "vim" || {
			log error "Failed to process vim colorscheme files for $scheme_name"
			return 1
		}

		[ "$IS_MAC" = true ] && {
			local xcode_themes="$HOME/Library/Developer/Xcode/UserData"
			xcode_themes="$xcode_themes/FontAndColorThemes"

			process_colorscheme_files "$scheme_dir" "*.xccolortheme" \
				"$xcode_themes" "Xcode" || {
				log error "Failed to process Xcode colorscheme files for $scheme_name"
				return 1
			}
		}
	done

	log success "Color setup complete"
}

setup_touch_id() {
	log info "Configuring Touch ID for sudo..."

	[ -f /etc/pam.d/sudo_local ] \
		&& grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local && {
		log success "Touch ID already enabled"
		return 0
	}

	[ ! -f /etc/pam.d/sudo_local.template ] && {
		log error "Missing template: /etc/pam.d/sudo_local.template"
		return 1
	}

	spinner "Configuring Touch ID" \
		sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local || {
		log error "Failed to copy Touch ID template"
		return 1
	}

	sudo sed -i '' 's/^#//' /etc/pam.d/sudo_local || {
		log error "Failed to modify Touch ID configuration"
		return 1
	}

	grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local && {
		log success "Touch ID enabled"
		return 0
	}

	log error "Failed to enable Touch ID - configuration not found"
	return 1
}

create_dev_directories() {
	log info "Creating development directories..."

	local dirs="$HOME/Developer/personal $HOME/Developer/clients"
	dirs="$dirs $HOME/Developer/study $HOME/Developer/work"

	for dir in $dirs; do
		spinner "Creating directory $dir" ensure_directory "$dir" || {
			log error "Failed to create directory $dir"
			return 1
		}
	done

	log success "Development directories created"
}

setup_dotfiles() {
	log info "Installing dotfiles..."

	[ -d "$HOME/.config" ] && {
		log debug "Removing existing .config directory"
		rm -rf "$HOME/.config" || {
			log error "Failed to remove old .config directory"
			return 1
		}
	}

	spinner "Cloning dotfiles repository" \
		git clone "https://github.com/maclong9/dots" "$HOME/.config" || {
		log error "Failed to clone dotfiles repository"
		return 1
	}

	log success "Dotfiles cloned"
}

link_dotfiles() {
	log info "Linking dotfiles from .config to home..."

	[ ! -d "$HOME/.config" ] && {
		log error ".config directory does not exist"
		return 1
	}

	# Count dotfiles
	local dotfile_count=0
	for file in "$HOME/.config"/.*; do
		[ -f "$file" ] || continue
		local filename=$(basename "$file")
		case "$filename" in
			. | .. | .git) continue ;;
			*) dotfile_count=$((dotfile_count + 1)) ;;
		esac
	done

	[ "$dotfile_count" -eq 0 ] && {
		log warning "No dotfiles found in .config directory"
		return 0
	}

	log debug "Found $dotfile_count dotfiles to link"

	for file in "$HOME/.config"/.*; do
		[ -f "$file" ] || continue
		local filename=$(basename "$file")
		case "$filename" in
			. | .. | .git) continue ;;
		esac

		log info "Symlinking $filename"
		safe_symlink "$file" "$HOME/$filename" || {
			log error "Failed to symlink $filename"
			return 1
		}
	done

	log success "Dotfiles linked"
}

setup_ssh() {
	local key="$HOME/.ssh/id_ed25519"

	[ -f "$key" ] && {
		log debug "SSH key already exists"
		return 0
	}

	log info "Generating new SSH key..."

	ensure_directory "$HOME/.ssh" && chmod 700 "$HOME/.ssh" || {
		log error "Failed to setup .ssh directory"
		return 1
	}

	spinner "Generating SSH key" \
		ssh-keygen -t ed25519 -C "hello@maclong.uk" -f "$key" -N "" || {
		log error "SSH key generation failed"
		return 1
	}

	# Start ssh-agent
	eval "$(ssh-agent -s)" > /dev/null 2>&1 \
		|| log warning "Failed to start ssh-agent"

	# Write SSH config
	cat > "$HOME/.ssh/config" << 'EOF' || log warning "Failed to write SSH config"
Host github.com
	AddKeysToAgent yes
	UseKeychain yes
	IdentityFile ~/.ssh/id_ed25519
EOF

	if [ "$IS_MAC" = true ]; then
		if cat "$key.pub" | pbcopy; then
			log success "SSH public key copied to clipboard"
		else
			log warning "Failed to copy SSH public key to clipboard"
			log info "SSH public key contents:"
			cat "$key.pub" || {
				log error "Failed to display SSH public key"
				return 1
			}
		fi
	else
		log success "SSH key generated"
		log info "SSH public key contents:"
		cat "$key.pub" || {
			log error "Failed to display SSH public key"
			return 1
		}
	fi
}

build_container() {
	log info "Installing container tool..."

	local base_url="https://github.com/apple/container/releases/download"
	local pkg_url="$base_url/0.1.0/container-0.1.0-installer-signed.pkg"
	local pkg_file="container-installer.pkg"

	log debug "Downloading package from $pkg_url"

	spinner "Downloading container package" \
		curl -L -o "$pkg_file" "$pkg_url" || {
		log error "Failed to download container package"
		return 1
	}

	spinner "Installing container package" \
		sudo installer -pkg "$pkg_file" -target / || {
		log error "Failed to install container package"
		rm -f "$pkg_file"
		return 1
	}

	rm -f "$pkg_file" \
		|| log warning "Failed to remove downloaded package file"

	[ ! -f "$HOME/.config/Dockerfile" ] && {
		log warning "Dockerfile not found, skipping container build"
		log success "Container tool installed"
		return 0
	}

	log debug "Building container from $HOME/.config/Dockerfile"

	spinner "Starting container vm" \
		container system start --enable-kernel-install || {
		log error "Failed to start container vm"
		return 1
	}

	# Required for now, remove once `container` doesn't require
	spinner "Install Rosetta 2 x86 emulation" \
		softwareupdate --install-rosetta --agree-to-license || {
		log error "Failed to install Rosetta 2"
		return 1
	}

	spinner "Building dev container image" \
		container build -t dev-container -f "$HOME/.config/Dockerfile" || {
		log error "Failed to build container image"
		return 1
	}

 	spinner "Creating dev container" \
  		container create -m 4024M --name dev-container dev-container || {
    		log error "Failed to create container"
      		return 1
	}

	log success "Container setup complete"
}

run_step() {
	local step_name="$1"
	local step_function="$2"

	spinner "$step_name" "$step_function" || {
		log error "Failed during $step_name"
		exit 1
	}
}

main() {
	log debug "Arguments: $*"
	log info "Initialising developer environment..."

	run_step "Creating development directories" create_dev_directories
	run_step "Setting up dotfiles" setup_dotfiles
	run_step "Setting up color schemes" setup_colors
	run_step "Linking dotfiles" link_dotfiles
	run_step "Setting up SSH configuration" setup_ssh

	[ "$IS_MAC" = true ] && {
		run_step "Setting up container environment" build_container
		run_step "Configuring Touch ID" setup_touch_id
	}

	log success "Setup complete!"
	printf "%s\n" \
		"" \
		"Next steps:" \
		"- Restart your shell" \
		"- Add your SSH key to services" \
		"- Apply your themes" \
		"- Start your development container"
}

main "$@"
