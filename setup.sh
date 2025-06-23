#!/bin/sh

# Error if basic commands missing
for cmd in git curl ln mkdir; do
    command -v "$cmd" >/dev/null 2>&1 || {
        printf "ERROR: %s required but not found\n" "$cmd" >&2
        exit 1
    }
done

# Download and source utilities
url="https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/utils.sh"
curl -fsSL "$url" -o /tmp/utils.sh || {
    printf "\033[0;31m[ERROR]\033[0m Failed to download utils.sh\n" >&2
    exit 1
}

. /tmp/utils.sh || {
    printf "\033[0;31m[ERROR]\033[0m Failed to source utils.sh\n" >&2
    exit 1
}

parse_args "$@"

process_colorscheme_files() {
    scheme_dir="$1"
    pattern="$2"
    target_dir="$3"
    file_type="$4"

    [ ! -d "$scheme_dir" ] && return 0

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
        run_or_fail "safe_symlink \"$file\" \"$target_dir/$filename\"" "Failed to symlink $filename"
    done
}

setup_xcode_tools() {
    log info "Installing Xcode command line tools..."

    # Check if command line tools are already installed
    if xcode-select -p >/dev/null 2>&1; then
        log success "Xcode command line tools already installed"
        return 0
    fi

    # Install command line tools
    run_or_fail "xcode-select --install" "Failed to install Xcode command line tools"

    # Wait for installation to complete
    log info "Waiting for Xcode command line tools installation to complete..."
    until xcode-select -p >/dev/null 2>&1; do
        sleep 5
    done

    log success "Xcode command line tools installed"
}

setup_colors() {
    [ ! -d "$HOME/.config/colors" ] && {
        log warning "Colors directory missing, skipping color setup"
        return 0
    }

    log info "Installing colorschemes..."

    run_or_fail "ensure_directory \"$HOME/.vim/colors\"" "Failed to create Vim colors directory"

    if [ "$IS_MAC" = true ]; then
        xcode_dir="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"

        run_or_fail "ensure_directory \"$xcode_dir\"" "Failed to create Xcode colors directory"
    fi

    # Count and check scheme directories
    for scheme_dir in "$HOME/.config/colors"/*; do
        [ -d "$scheme_dir" ] && break
    done
    [ ! -d "$scheme_dir" ] && {
        log warning "No colorscheme directories found"
        return 0
    }

    for scheme_dir in "$HOME/.config/colors"/*; do
        [ -d "$scheme_dir" ] || continue

        scheme_name="$(basename "$scheme_dir")"
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
            xcode_themes="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"

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

    [ -f /etc/pam.d/sudo_local ] &&
        grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local && {
        log success "Touch ID already enabled"
        return 0
    }

    [ ! -f /etc/pam.d/sudo_local.template ] && {
        log error "Missing template: /etc/pam.d/sudo_local.template"
        return 1
    }

    run_or_fail "sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local" "Failed to copy Touch ID template"

    run_or_fail "sudo sed -i '' 's/^#//' /etc/pam.d/sudo_local" "Failed to modify Touch ID configuration"

    grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local && {
        log success "Touch ID enabled"
        return 0
    }

    log error "Failed to enable Touch ID - configuration not found"
    return 1
}

create_dev_directories() {
    log info "Creating development directories..."

    dirs="$HOME/Developer/personal $HOME/Developer/clients $HOME/Developer/study $HOME/Developer/work"

    for dir in $dirs; do
        run_or_fail "ensure_directory \"$dir\"" "Failed to create directory $dir"
    done

    log success "Development directories created"
}

setup_dotfiles() {
    log info "Installing dotfiles..."

    [ -d "$HOME/.config" ] && {
        backup_dir="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
        log debug "Backing up existing .config directory to $backup_dir"
        run_or_fail "mv \"$HOME/.config\" \"$backup_dir\"" "Failed to backup old .config directory"
        log info "Previous .config backed up to $backup_dir"
    }

    run_or_fail "git clone \"https://github.com/maclong9/dots\" \"$HOME/.config\"" "Failed to clone dotfiles repository"

    log success "Dotfiles cloned"
}

link_dotfiles() {
    log info "Linking dotfiles from .config to home..."

    [ ! -d "$HOME/.config" ] && {
        log error ".config directory does not exist"
        return 1
    }

    # Check for dotfiles
    for file in "$HOME/.config"/.*; do
        [ -f "$file" ] || continue
        case "$(basename "$file")" in
            . | .. | .git) continue ;;
            *) break ;;
        esac
    done
    [ ! -f "$file" ] || case "$(basename "$file")" in
        . | .. | .git) {
            log warning "No dotfiles found in .config directory"
            return 0
        } ;;
    esac

    for file in "$HOME/.config"/.*; do
        [ -f "$file" ] || continue
        filename="$(basename "$file")"
        case "$filename" in
            . | .. | .git) continue ;;
        esac

        log info "Symlinking $filename"
        run_or_fail "safe_symlink \"$file\" \"$HOME/$filename\"" "Failed to symlink $filename"
    done

    log success "Dotfiles linked"
}

setup_ssh() {
    key="$HOME/.ssh/id_ed25519"

    [ -f "$key" ] && {
        log debug "SSH key already exists"
        return 0
    }

    log info "Generating new SSH key..."

    if ! ensure_directory "$HOME/.ssh"; then
        log error "Failed to setup .ssh directory"
        return 1
    fi
    if ! chmod 700 "$HOME/.ssh"; then
        log error "Failed to setup .ssh directory"
        return 1
    fi

    run_or_fail "ssh-keygen -t ed25519 -C \"hello@maclong.uk\" -f \"$key\" -N \"\"" "SSH key generation failed"

    # Start ssh-agent
    eval "$(ssh-agent -s)" >/dev/null 2>&1 ||
        log warning "Failed to start ssh-agent"

    # Write SSH config
    cat >"$HOME/.ssh/config" <<'EOF' || log warning "Failed to write SSH config"
Host github.com
	AddKeysToAgent yes
	IdentityFile ~/.ssh/id_ed25519
EOF

    if [ "$IS_MAC" = true ]; then
        if pbcopy <"$key.pub"; then
            log success "SSH public key copied to clipboard"
        else
            log warning "Failed to copy SSH public key to clipboard"
        fi
    else
        log success "SSH key generated"
    fi
}

build_container() {
    log info "Installing container tool..."

    [ ! -f "$HOME/.config/Dockerfile" ] && {
        log warning "Dockerfile not found, skipping container build"
        log success "Container tool installed"
        return 0
    }

    run_or_fail "container system start --enable-kernel-install" "Failed to start container vm"

    # Required for now, remove once `container` doesn't require
    run_or_fail "softwareupdate --install-rosetta --agree-to-license" "Failed to install Rosetta 2"

    run_or_fail "container build -t dev-container -f \"$HOME/.config/Dockerfile\"" "Failed to build container image"

    run_or_fail "container create -m 4024M --name dev-container dev-container" "Failed to create container"

    log success "Container setup complete"
}

setup_maintenance() {
    log info "Setting up system maintenance..."

    # Ensure maintenance script is executable
    run_or_fail "chmod +x \"$HOME/.config/scripts/maintenance/maintenance.sh\"" "Failed to make maintenance script executable"

    if [ "$IS_MAC" = true ]; then
        # Install LaunchAgent for macOS
        launch_agents_dir="$HOME/Library/LaunchAgents"
        run_or_fail "ensure_directory \"$launch_agents_dir\"" "Failed to create LaunchAgents directory"

        run_or_fail "cp \"$HOME/.config/scripts/maintenance/com.maintenance.cleanup.plist\" \"$launch_agents_dir/com.maintenance.cleanup.plist\"" "Failed to install LaunchAgent"

        # Load the LaunchAgent
        launchctl load "$launch_agents_dir/com.maintenance.cleanup.plist" 2>/dev/null ||
            log warning "Failed to load LaunchAgent (may already be loaded)"

        log success "Scheduled maintenance via LaunchAgent (Sundays at 2:00 AM)"
    else
        # Install cron job for Linux
        crontab -l 2>/dev/null | grep -v "maintenance.sh" >/tmp/current_cron || true
        cat "$HOME/.config/scripts/maintenance/maintenance.crontab" >>/tmp/current_cron
        run_or_fail "crontab /tmp/current_cron" "Failed to install cron job" || {
            rm -f /tmp/current_cron
            return 1
        }
        rm -f /tmp/current_cron

        log success "Scheduled maintenance via cron (Sundays at 2:00 AM)"
    fi

    log info "Run 'scripts/maintenance/maintenance.sh' manually anytime to clean system"
}

run_step() {
    step_name="$1"
    step_function="$2"

    spinner "$step_name" "$step_function" || {
        log error "Failed during $step_name"
        exit 1
    }
}

setup_mise() {
    log info "Installing mise and development tools..."

    if command -v mise >/dev/null 2>&1; then
        log success "mise already installed"
    else
        run_or_fail "curl https://mise.run | sh" "Failed to install mise"
    fi

    # Install tools from mise.toml
    run_or_fail "$HOME/.local/bin/mise install" "Failed to install mise tools"
    log success "Development tools installed via mise"
}

main() {
    log debug "Arguments: $*"
    log info "Initialising developer environment..."

    [ "$IS_MAC" = true ] && {
        run_step "Installing Xcode command line tools" setup_xcode_tools
        run_step "Installing mise and development tools" setup_mise
    }

    run_step "Creating development directories" create_dev_directories
    run_step "Setting up dotfiles" setup_dotfiles
    run_step "Setting up color schemes" setup_colors
    run_step "Linking dotfiles" link_dotfiles
    run_step "Setting up SSH configuration" setup_ssh
    run_step "Setting up system maintenance" setup_maintenance

    [ "$IS_MAC" = true ] && {
        run_step "Setting up container environment" build_container
        run_step "Configuring Touch ID" setup_touch_id
    }

    log success "Setup complete!"

    # Display SSH public key for non-macOS systems
    [ "$IS_MAC" = false ] && [ -f "$HOME/.ssh/id_ed25519.pub" ] && {
        printf "\n%s\n" "SSH public key contents:"
        cat "$HOME/.ssh/id_ed25519.pub" || log warning "Failed to display SSH public key"
        printf "\n"
    }

    printf "%s\n" \
        "" \
        "Next steps:" \
        "- Restart your shell" \
        "- Add your SSH key to services" \
        "- Apply your themes" \
        "- Start your development container as needed" \
        "- System maintenance runs weekly (Mondays at 11:00 AM)"
}

main "$@"
