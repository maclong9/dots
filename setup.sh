#!/bin/sh

# Error if basic commands missing
for cmd in git curl ln mkdir; do
    command -v "$cmd" >/dev/null 2>&1 || {
        printf "ERROR: %s required but not found\n" "$cmd" >&2
        exit 1
    }
done

# Download and source utilities
url="https://raw.githubusercontent.com/maclong9/dots/main/shell/lib/utils.sh"
utils_temp="/tmp/utils.sh"

# Download with timeout and user agent
curl -fsSL --max-time 30 --user-agent "setup-script/1.0" "$url" -o "$utils_temp" || {
    printf "\033[0;31m[ERROR]\033[0m Failed to download utils.sh (check network connection)\n" >&2
    exit 1
}

# shellcheck disable=SC1091
. "$utils_temp" || {
    printf "\033[0;31m[ERROR]\033[0m Failed to source utils.sh\n" >&2
    exit 1
}

parse_args "$@"

setup_xcode_tools() {
    log info "Installing Xcode command line tools..."

    # Check if command line tools are already installed
    # xcode-select -p returns the developer directory path if tools are installed
    if xcode-select -p >/dev/null 2>&1; then
        log success "Xcode command line tools already installed"
        return 0
    fi

    # Install command line tools
    try_run "xcode-select --install" "install Xcode command line tools"

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

    try_run "sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local" \
        "copy Touch ID template"

    try_run "sudo sed -i '' '/pam_tid\.so/s/^[[:space:]]*#//' /etc/pam.d/sudo_local" \
        "modify Touch ID configuration"

    try_run "grep -q \"^auth.*pam_tid.so\" /etc/pam.d/sudo_local" && {
        log success "Touch ID enabled"
        return 0
    }

    log error "enable Touch ID - configuration not found"
    return 1
}

setup_dotfiles() {
    log info "Installing dotfiles..."

    # Check git availability
    if ! command_exists git; then
        log error "git not found - please install git first"
        return 1
    fi

    # Handle existing .config directory
    if [ -d "$HOME/.config" ]; then
        # Check if it's already our dotfiles repo
        if [ -d "$HOME/.config/.git" ] && git -C "$HOME/.config" remote get-url origin 2>/dev/null | grep -q "maclong9/dots"; then
            log info "Dotfiles already cloned, updating..."
            try_run "git -C \"$HOME/.config\" pull" \
                "update existing dotfiles repository"
        else
            # Back up existing .config directory
            backup_dir="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
            try_run "mv \"$HOME/.config\" \"$backup_dir\"" \
                "backup existing .config directory"
            log info "Previous .config backed up to $backup_dir"
            
            try_run "git clone \"https://github.com/maclong9/dots\" \"$HOME/.config\"" \
                "clone dotfiles repository (check network connection and GitHub access)"
        fi
    else
        try_run "git clone \"https://github.com/maclong9/dots\" \"$HOME/.config\"" \
            "clone dotfiles repository (check network connection and GitHub access)"
    fi

    [ -d "$HOME/.config" ] || {
        log error "Dotfiles clone failed - .config not created"
        return 1
    }

    # ZSH Plugins
    ensure_dir "$HOME/.zsh/plugins" || die 1 "Failed to create ZSH plugins directory (check home directory permissions)"
    # Syntax Highlighting
    try_run "git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        $HOME/.zsh/plugins/zsh-syntax-highlighting" \
        "clone syntax highlighting (check network connection)"
    # Completions
    try_run "git clone https://github.com/zsh-users/zsh-completions.git \
        $HOME/.zsh/plugins/zsh-completions" \
        "clone zsh completions (check network connection)"
    # Autosuggestions
    try_run "git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        $HOME/.zsh/plugins/zsh-autosuggestions" \
        "clone zsh autosuggestions (check network connection)"
    # Autocomplete
    try_run "git clone https://github.com/marlonrichert/zsh-autocomplete.git \
        $HOME/.zsh/plugins/zsh-autocomplete" \
        "clone zsh autocomplete (check network connection)"

    log success "Dotfiles cloned"
}

link_dotfiles() {
    log info "Linking dotfiles from .config to home..."

    [ ! -d "$HOME/.config" ] && {
        log error ".config directory does not exist"
        return 1
    }

    for file in "$HOME/.config"/.*; do
        [ -f "$file" ] || continue
        filename="$(basename "$file")"
        case "$filename" in
            . | .. | .git) continue ;;
        esac

        log info "Symlinking $filename"
        try_run "safe_symlink \"$file\" \"$HOME/$filename\"" \
            "symlink $filename"
    done

    log success "Dotfiles linked"
}

setup_homebrew() {
    log info "Installing Homebrew..."

    if command_exists brew; then
        log success "Homebrew already installed"
    else
        # Install Homebrew in non-interactive mode
        export NONINTERACTIVE=1
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for this session
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Skip Brewfile installation in CI environments
    if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ] || [ -n "${RUNNER_OS:-}" ]; then
        log info "CI environment detected, skipping Brewfile installation"
        log info "Brewfile contains GUI applications and private taps not suitable for CI"
    elif [ -f "$HOME/.config/Brewfile" ]; then
        log info "Installing applications from Brewfile..."
        cd "$HOME/.config" || {
            log error "change to .config directory"
            return 1
        }

        try_run "brew bundle --file=Brewfile" "install applications from Brewfile"

        # Return to original directory
        cd - >/dev/null || true
    else
        log warning "Brewfile not found, skipping brew bundle install"
    fi

    log success "Homebrew setup complete"
}

setup_mise() {
    log info "Installing mise and development tools..."

    if command_exists mise; then
        log success "mise already installed"
    else
        curl https://mise.run | sh
    fi

    # Add mise to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"

    # Generate mise completions
    ensure_dir "$HOME/.config/shell/completions" || die 1 "Failed to create completions directory"
    try_run "mise completion zsh > \"$HOME/.config/shell/completions/_mise\"" \
        "generate mise zsh completions"

    # Check if mise config exists before trying to trust it
    if [ -f "$HOME/.config/mise/config.toml" ]; then
        # Change to the .config directory to trust the mise.toml file
        cd "$HOME/.config" || {
            log error "change to .config directory"
            return 1
        }

        try_run "mise trust -a" "trust mise configuration file"
        try_run "mise install" "install mise tools (check network and tool availability)"

        # Return to original directory (optional, but good practice)
        cd - >/dev/null || true
    else
        log warning "mise config not found, skipping mise tool installation"
    fi

    log success "Development tools installed via mise"
}

setup_maintenance() {
    log info "Setting up system maintenance..."

    # Ensure maintenance script is executable
    try_run "chmod +x \"$HOME/.config/shell/maintenance/maintenance.sh\"" \
        "make maintenance script executable"

    if [ "$IS_MAC" = true ]; then
        launch_daemon_dir="/Library/LaunchDaemons"
        plist_name="com.mac.maintenance.cleanup.plist"
        source_plist="$HOME/.config/shell/maintenance/com.maintenance.cleanup.plist"

        # Install the LaunchDaemon with proper permissions
        try_run "sudo cp \"$source_plist\" \"$launch_daemon_dir/$plist_name\"" "Copy plist to LaunchDaemons"
        try_run "sudo chown root:wheel \"$launch_daemon_dir/$plist_name\"" "Ensure plist is owned by root"
        try_run "sudo chmod 644 \"$launch_daemon_dir/$plist_name\"" "Set correct permissions on plist file"

        try_run "sudo launchctl bootstrap system $launch_daemon_dir/$plist_name" "Load the LaunchDaemon"
        log success "Scheduled maintenance via LaunchDaemon (Tuesdays at 11:00 AM with root privileges)"
        log info "LaunchDaemon installed at: $launch_daemon_dir/$plist_name"
    else
        # Linux cron setup
        crontab -l 2>/dev/null | grep -v "maintenance.sh" >/tmp/current_cron || true

        if [ -f "$HOME/.config/shell/maintenance/maintenance.crontab" ]; then
            cat "$HOME/.config/shell/maintenance/maintenance.crontab" >>/tmp/current_cron
        else
            echo "0 11 * * 2 $HOME/.config/shell/maintenance/maintenance.sh" >>/tmp/current_cron
        fi

        try_run "crontab /tmp/current_cron" "install cron job (check crontab permissions)" || {
            rm -f /tmp/current_cron
            return 1
        }
        rm -f /tmp/current_cron

        log success "Scheduled maintenance via cron (Tuesdays at 11:00 AM)"
    fi

    log info "Run '$HOME/.config/shell/maintenance/maintenance.sh' manually anytime to clean system"
}

setup_ssh() {
    try_run "ssh-keygen -t ed25519 -C \"hello@maclong.uk\" -N \"\" -f ~/.ssh/id_ed25519" \
        "generate SSH key (check ~/.ssh directory permissions)"
    if [ "$IS_MAC" = true ]; then
        pbcopy <"$HOME/.ssh/id_ed25519.pub"
    else
        cat "$HOME/.ssh/id_ed25519.pub"
    fi
}

# shellcheck disable=SC1091
install_swift() {
    curl -O "https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz" &&
        tar zxf "swiftly-$(uname -m).tar.gz" &&
        ./swiftly init --quiet-shell-followup &&
        . "${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}/env.sh" &&
        hash -r
    rm -rf swiftly*.tar.gz
}

run_step() {
    step_name="$1"
    step_function="$2"

    spinner "$step_name" "$step_function" || die 1 "Failed during $step_name"
}

main() {
    log debug "Arguments: $*"
    log info "Initialising developer environment..."

    if [ "$IS_MAC" = true ]; then
        run_step "Installing Xcode command line tools" setup_xcode_tools
        run_step "Configuring Touch ID" setup_touch_id
    else
        run_step "Installing swift via swiftly" install_swift
    fi

    run_step "Setting up dotfiles" setup_dotfiles
    run_step "Linking dotfiles" link_dotfiles

    if [ "$IS_MAC" = true ]; then
        run_step "Installing Homebrew and applications" setup_homebrew
    fi

    run_step "Setting up system maintenance" setup_maintenance
    run_step "Generating SSH key" setup_ssh
    run_step "Installing mise and development tools" setup_mise

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
