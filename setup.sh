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

# shellcheck disable=SC1091
. /tmp/utils.sh || {
    printf "\033[0;31m[ERROR]\033[0m Failed to source utils.sh\n" >&2
    exit 1
}

parse_args "$@"

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

    run_or_fail "sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local" \
        "Failed to copy Touch ID template"

    run_or_fail "sudo sed -i '' 's/^#//' /etc/pam.d/sudo_local" \
        "Failed to modify Touch ID configuration"

    grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local && {
        log success "Touch ID enabled"
        return 0
    }

    log error "Failed to enable Touch ID - configuration not found"
    return 1
}

setup_dotfiles() {
    log info "Installing dotfiles..."

    [ -d "$HOME/.config" ] && {
        backup_dir="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
        log debug "Backing up existing .config directory to $backup_dir"
        run_or_fail "mv \"$HOME/.config\" \"$backup_dir\"" \
            "Failed to backup old .config directory"
        log info "Previous .config backed up to $backup_dir"
    }

    run_or_fail "git clone \"https://github.com/maclong9/dots\" \"$HOME/.config\"" \
        "Failed to clone dotfiles repository"

    log success "Dotfiles cloned"
}

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
        run_or_fail "safe_symlink \"$file\" \"$target_dir/$filename\"" \
            "Failed to symlink $filename"
    done
}

setup_colors() {
    [ ! -d "$HOME/.config/colors" ] && {
        log warning "Colors directory missing, skipping color setup"
        return 0
    }

    log info "Installing colorschemes..."

    run_or_fail "mkdir -p \"$HOME/.vim/colors\"" "Failed to create Vim colors directory"

    if [ "$IS_MAC" = true ]; then
        xcode_dir="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"

        run_or_fail "mkdir -p \"$xcode_dir\"" "Failed to create Xcode colors directory"
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
        run_or_fail "safe_symlink \"$file\" \"$HOME/$filename\"" \
            "Failed to symlink $filename"
    done

    log success "Dotfiles linked"
}

setup_mise() {
    log info "Installing mise and development tools..."

    if command -v mise >/dev/null 2>&1; then
        log success "mise already installed"
    else
        run_or_fail "curl https://mise.run | sh" "Failed to install mise"
    fi

    # Add mise to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"

    # Check if mise.toml exists before trying to trust it
    if [ -f "$HOME/.config/mise.toml" ]; then
        # Change to the .config directory to trust the mise.toml file
        cd "$HOME/.config" || {
            log error "Failed to change to .config directory"
            return 1
        }

        run_or_fail "mise trust -a" "Failed to trust mise.toml"
        run_or_fail "mise install" "Failed to install mise tools"

        # Return to original directory (optional, but good practice)
        cd - >/dev/null || true
    else
        log warning "mise.toml not found, skipping mise tool installation"
    fi

    log success "Development tools installed via mise"
}

setup_maintenance() {
    log info "Setting up system maintenance..."

    # Ensure maintenance script is executable
    run_or_fail "chmod +x \"$HOME/.config/scripts/maintenance/maintenance.sh\"" \
        "Failed to make maintenance script executable"

    if [ "$IS_MAC" = true ]; then
        # Install LaunchAgent for macOS
        launch_agents_dir="$HOME/Library/LaunchAgents"
        run_or_fail "mkdir -p \"$launch_agents_dir\"" \
            "Failed to create LaunchAgents directory"

        run_or_fail "cp \"$HOME/.config/scripts/maintenance/com.maintenance.cleanup.plist\" \
        \"$launch_agents_dir/com.maintenance.cleanup.plist\"" \
            "Failed to install LaunchAgent"

        # Load the LaunchAgent
        launchctl load "$launch_agents_dir/com.maintenance.cleanup.plist" 2>/dev/null ||
            log warning "Failed to load LaunchAgent (may already be loaded)"

        log success "Scheduled maintenance via LaunchAgent (Tuesdays at 11:00 AM)"
    else
        # Install cron job for Linux
        crontab -l 2>/dev/null | grep -v "maintenance.sh" >/tmp/current_cron || true
        cat "$HOME/.config/scripts/maintenance/maintenance.crontab" >>/tmp/current_cron
        run_or_fail "crontab /tmp/current_cron" "Failed to install cron job" || {
            rm -f /tmp/current_cron
            return 1
        }
        rm -f /tmp/current_cron

        log success "Scheduled maintenance via cron (Tuesdays at 11:00 AM)"
    fi

    log info "Run 'scripts/maintenance/maintenance.sh' manually anytime to clean system"
}

setup_ssh() {
    run_or_fail "ssh-keygen -t ed25519 -C \"hello@maclong.uk\" -N \"\" -f ~/.ssh/id_ed25519"
    if [ "$IS_MAC" = true ]; then
        pbcopy < "$HOME/.ssh/id_ed25519.pub"
    else
        cat "$HOME/.ssh/id_ed25519.pub"
    fi
}

run_step() {
    step_name="$1"
    step_function="$2"

    spinner "$step_name" "$step_function" || {
        log error "Failed during $step_name"
        exit 1
    }
}

main() {
    log debug "Arguments: $*"
    log info "Initialising developer environment..."

    [ "$IS_MAC" = true ] && {
        run_step "Installing Xcode command line tools" setup_xcode_tools
        run_step "Configuring Touch ID" setup_touch_id
    }

    run_step "Setting up dotfiles" setup_dotfiles
    run_step "Setting up color schemes" setup_colors
    run_step "Linking dotfiles" link_dotfiles
    run_step "Installing mise and development tools" setup_mise
    run_step "Setting up system maintenance" setup_maintenance
    run_step "Generating SSH key" setup_ssh

    log success "Setup complete!"

    printf "%s\n" \
        "" \
        "Next steps:" \
        "- Restart your shell" \
        "- Setup gh cli" \
        "- Apply your themes" \
        "- Set up signing key on GitHub" \
        "- System maintenance runs weekly (Tuesday at 11:00 AM)"
}

main "$@"
