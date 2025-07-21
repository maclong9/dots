#!/bin/sh

# Error if basic commands missing
for cmd in git curl ln mkdir; do
    command -v "$cmd" >/dev/null 2>&1 || {
        printf "ERROR: %s required but not found\n" "$cmd" >&2
        exit 1
    }
done

# Download and source utilities
url="https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/core/utils.sh"
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
    run_or_fail "xcode-select --install" "install Xcode command line tools"

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
        "copy Touch ID template"

    run_or_fail "sudo sed -i '' '/pam_tid\.so/s/^[[:space:]]*#//' /etc/pam.d/sudo_local" \
        "modify Touch ID configuration"

    run_or_fail "grep -q \"^auth.*pam_tid.so\" /etc/pam.d/sudo_local" && {
        log success "Touch ID enabled"
        return 0
    }

    log error "enable Touch ID - configuration not found"
    return 1
}

setup_dotfiles() {
    log info "Installing dotfiles..."

    # Check git availability
    if ! command -v git >/dev/null 2>&1; then
        log error "git not found - please install git first"
        return 1
    fi

    # Test basic connectivity to GitHub
    if ! curl -s --connect-timeout 5 "https://api.github.com" >/dev/null; then
        log warning "Cannot reach GitHub - check network connection and proxy settings"
        log info "Proceeding anyway, git clone will provide specific error if needed"
    fi

    [ -d "$HOME/.config" ] && {
        backup_dir="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
        log debug "Backing up existing .config directory to $backup_dir"
        run_or_fail "mv \"$HOME/.config\" \"$backup_dir\"" \
            "backup old .config directory (check permissions)"
        log info "Previous .config backed up to $backup_dir"
    }

    run_or_fail "git clone \"https://github.com/maclong9/dots\" \"$HOME/.config\"" \
        "clone dotfiles repository (check network connection and GitHub access)"

    # ZSH Plugins
    run_or_fail "mkdir -p $HOME/.zsh/plugins" "create ZSH plugins directory (check home directory permissions)"
    # Syntax Highlighting
    run_or_fail "git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    $HOME/.zsh/plugins/zsh-syntax-highlighting" "clone fast syntax highlighting (check network connection)"
    # Completions
    run_or_fail "git clone https://github.com/zsh-users/zsh-completions.git \
    $HOME/.zsh/plugins/zsh-completions"

    log success "Dotfiles cloned"
}

process_colorscheme_files() {
    scheme_dir="$1"
    pattern="$2"
    target_dir="$3"
    file_type="$4"

    [ ! -d "$scheme_dir" ] && return 0

    count=$(count_files "$scheme_dir/$pattern") || {
        log error "count files in $scheme_dir"
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
            "symlink $filename"
    done
}

setup_colors() {
    [ ! -d "$HOME/.config/colors" ] && {
        log warning "Colors directory missing, skipping color setup"
        return 0
    }

    log info "Installing colorschemes..."

    if [ "$IS_MAC" = true ]; then
        xcode_dir="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"

        run_or_fail "mkdir -p \"$xcode_dir\"" "create Xcode colors directory"
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

        [ "$IS_MAC" = true ] && {
            xcode_themes="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"

            process_colorscheme_files "$scheme_dir" "*.xccolortheme" \
                "$xcode_themes" "Xcode" || {
                log error "process Xcode colorscheme files for $scheme_name"
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
            "symlink $filename"
    done

    log success "Dotfiles linked"
}

setup_mise() {
    log info "Installing mise and development tools..."

    if command -v mise >/dev/null 2>&1; then
        log success "mise already installed"
    else
        run_or_fail "curl https://mise.run | sh" "install mise (check network connection and curl availability)"
    fi

    # Add mise to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"

    # Check if mise.toml exists before trying to trust it
    if [ -f "$HOME/.config/mise.toml" ]; then
        # Change to the .config directory to trust the mise.toml file
        cd "$HOME/.config" || {
            log error "change to .config directory"
            return 1
        }

        run_or_fail "mise trust -a" "trust mise.toml configuration file"
        run_or_fail "mise install" "install mise tools (check network and tool availability)"

        # Return to original directory (optional, but good practice)
        cd - >/dev/null || true
    else
        log warning "mise.toml not found, skipping mise tool installation"
    fi

    "$HOME/.local/share/mise/shims/gh" auth login
    "$HOME/.local/share/mise/shims/gh" extension install github/gh-copilot
    
    log success "Development tools installed via mise"
}

setup_maintenance() {
    log info "Setting up system maintenance..."

    # Ensure maintenance script is executable
    run_or_fail "chmod +x \"$HOME/.config/scripts/maintenance/maintenance.sh\"" \
        "make maintenance script executable"

    if [ "$IS_MAC" = true ]; then
        launch_daemon_dir="/Library/LaunchDaemons"
        plist_name="com.mac.maintenance.cleanup.plist"
        source_plist="$HOME/.config/scripts/maintenance/com.maintenance.cleanup.plist"

        # Install the LaunchDaemon with proper permissions
        run_or_fail "sudo cp \"$source_plist\" \"$launch_daemon_dir/$plist_name\"" "Copy plist to LaunchDaemons"
        run_or_fail "sudo chown root:wheel \"$launch_daemon_dir/$plist_name\"" "Ensure plist is owned by root"
        run_or_fail "sudo chmod 644 \"$launch_daemon_dir/$plist_name\"" "Set correct permissions on plist file"

        run_or_fail "sudo launchctl bootstrap system $launch_daemon_dir/$plist_name" "Load the LaunchDaemon"
        log success "Scheduled maintenance via LaunchDaemon (Tuesdays at 11:00 AM with root privileges)"
        log info "LaunchDaemon installed at: $launch_daemon_dir/$plist_name"
    else
        # Linux cron setup (no sudo needed)
        crontab -l 2>/dev/null | grep -v "maintenance.sh" >/tmp/current_cron || true

        if [ -f "$HOME/.config/scripts/maintenance/maintenance.crontab" ]; then
            cat "$HOME/.config/scripts/maintenance/maintenance.crontab" >>/tmp/current_cron
        else
            echo "0 11 * * 2 $HOME/.config/scripts/maintenance/maintenance.sh" >>/tmp/current_cron
        fi

        run_or_fail "crontab /tmp/current_cron" "install cron job (check crontab permissions)" || {
            rm -f /tmp/current_cron
            return 1
        }
        rm -f /tmp/current_cron

        log success "Scheduled maintenance via cron (Tuesdays at 11:00 AM)"
    fi

    log info "Run '$HOME/.config/scripts/maintenance/maintenance.sh' manually anytime to clean system"
}

setup_ssh() {
    run_or_fail "ssh-keygen -t ed25519 -C \"hello@maclong.uk\" -N \"\" -f ~/.ssh/id_ed25519" \
        "generate SSH key (check ~/.ssh directory permissions)"
    if [ "$IS_MAC" = true ]; then
        pbcopy <"$HOME/.ssh/id_ed25519.pub"
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
