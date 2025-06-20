#!/bin/sh

set -e
trap 'log error "Setup failed at line $LINENO"' ERR

# Fail fast if basic commands missing
for cmd in git curl ln mkdir; do
  command -v "$cmd" >/dev/null 2>&1 || {
    printf "ERROR: %s required but not found\n" "$cmd" >&2
    exit 1
  }
done

if ! curl -fsSL "https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/utils.sh" -o /tmp/utils.sh; then
  printf "ERROR: Failed to download utils.sh\n" >&2
  exit 1
fi

if ! . /tmp/utils.sh; then
  printf "ERROR: Failed to source utils.sh\n" >&2
  exit 1
fi

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

  if [ "$count" -gt 0 ]; then
    log debug "Found $count $file_type files in $scheme"
    for file in "$scheme_dir"/$pattern; do
      [ -f "$file" ] || continue

      filename=$(basename "$file")
      log info "Symlinking $file_type file $filename"

      if ! safe_symlink "$file" "$target_dir/$filename"; then
        log error "Failed to symlink $filename"
        return 1
      fi
    done
  else
    log debug "No $file_type files in $scheme"
  fi

  return 0
}

setup_colors() {
  if [ ! -d "$HOME/.config/colors" ]; then
    log warning "Colors directory missing, skipping color setup"
    return 0
  fi

  log info "Installing colorschemes..."
  log debug "Colors directory: $HOME/.config/colors"

  if ! spinner "Creating Vim colors directory" ensure_directory "$HOME/.vim/colors"; then
    log error "Failed to create Vim colors directory"
    return 1
  fi

  if [ "$IS_MAC" = true ]; then
    if ! spinner "Creating Xcode colors directory" ensure_directory "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"; then
      log error "Failed to create Xcode colors directory"
      return 1
    fi
  fi

  # Check if there are any scheme directories
  scheme_count=0
  for scheme_dir in "$HOME/.config/colors"/*; do
    [ -d "$scheme_dir" ] && scheme_count=$((scheme_count + 1))
  done

  if [ "$scheme_count" -eq 0 ]; then
    log warning "No colorscheme directories found in $HOME/.config/colors"
    return 0
  fi

  log debug "Found $scheme_count colorscheme directories"

  for scheme_dir in "$HOME/.config/colors"/*; do
    [ -d "$scheme_dir" ] || continue

    scheme_name=$(basename "$scheme_dir")
    log info "Processing scheme: $scheme_name"
    log debug "Scheme directory: $scheme_dir"

    # List files in the scheme directory for debugging
    if [ "$DEBUG" = true ]; then
      log debug "Files in $scheme_name:"
      ls -la "$scheme_dir" >&2
    fi

    if ! process_colorscheme_files "$scheme_dir" "*.vim" "$HOME/.vim/colors" "vim"; then
      log error "Failed to process vim colorscheme files for $scheme_name"
      return 1
    fi

    if [ "$IS_MAC" = true ]; then
      if ! process_colorscheme_files "$scheme_dir" "*.xccolortheme" "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes" "Xcode"; then
        log error "Failed to process Xcode colorscheme files for $scheme_name"
        return 1
      fi
    fi
  done

  log success "Color setup complete"
  return 0
}

setup_touch_id() {
  log info "Configuring Touch ID for sudo..."

  if [ -f /etc/pam.d/sudo_local ] && grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local; then
    log success "Touch ID already enabled"
    return 0
  fi

  [ ! -f /etc/pam.d/sudo_local.template ] && {
    log error "Missing template: /etc/pam.d/sudo_local.template"
    return 1
  }

  if ! spinner "Configuring Touch ID" sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local; then
    log error "Failed to copy Touch ID template"
    return 1
  fi

  if ! sudo sed -i '' 's/^#//' /etc/pam.d/sudo_local; then
    log error "Failed to modify Touch ID configuration"
    return 1
  fi

  if grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local; then
    log success "Touch ID enabled"
  else
    log error "Failed to enable Touch ID - configuration not found"
    return 1
  fi
  return 0
}

create_dev_directories() {
  log info "Creating development directories..."

  for dir in "$HOME/Developer/personal" "$HOME/Developer/clients" "$HOME/Developer/study" "$HOME/Developer/work"; do
    if ! spinner "Creating directory $dir" ensure_directory "$dir"; then
      log error "Failed to create directory $dir"
      return 1
    fi
  done

  log success "Development directories created"
  return 0
}

setup_dotfiles() {
  log info "Installing dotfiles..."

  if [ -d "$HOME/.config" ]; then
    log debug "Removing existing .config directory"
    if [ "$DEBUG" = true ]; then
      log debug "Running: rm -rf \"$HOME/.config\""
      if ! rm -rf "$HOME/.config"; then
        log error "Failed to remove old .config directory"
        return 1
      fi
    else
      if ! rm -rf "$HOME/.config"; then
        log error "Failed to remove old .config directory"
        return 1
      fi
    fi
  fi

  log debug "Cloning repository https://github.com/maclong9/dots"
  if [ "$DEBUG" = true ]; then
    log debug "Running: git clone https://github.com/maclong9/dots \"$HOME/.config\""
    if ! git clone "https://github.com/maclong9/dots" "$HOME/.config"; then
      log error "Failed to clone dotfiles repository"
      return 1
    fi
  else
    if ! spinner "Cloning dotfiles repository" git clone "https://github.com/maclong9/dots" "$HOME/.config"; then
      log error "Failed to clone dotfiles repository"
      return 1
    fi
  fi

  log success "Dotfiles cloned"
  return 0
}

link_dotfiles() {
  log info "Linking dotfiles from .config to home..."

  # Check if .config directory exists and has dotfiles
  if [ ! -d "$HOME/.config" ]; then
    log error ".config directory does not exist"
    return 1
  fi

  # Count dotfiles first to provide better feedback
  dotfile_count=0
  for file in "$HOME/.config"/.*; do
    # Skip if not a file
    [ -f "$file" ] || continue
    # Skip .git directory
    filename=$(basename "$file")
    [ "$filename" = ".git" ] && continue
    # Skip . and ..
    [ "$filename" = "." ] && continue
    [ "$filename" = ".." ] && continue

    dotfile_count=$((dotfile_count + 1))
  done

  if [ "$dotfile_count" -eq 0 ]; then
    log warning "No dotfiles found in .config directory"
    return 0
  fi

  log debug "Found $dotfile_count dotfiles to link"

  for file in "$HOME/.config"/.*; do
    # Skip if not a file
    [ -f "$file" ] || continue

    filename=$(basename "$file")
    # Skip .git directory
    [ "$filename" = ".git" ] && continue
    # Skip . and ..
    [ "$filename" = "." ] && continue
    [ "$filename" = ".." ] && continue

    target="$HOME/$filename"

    log info "Symlinking $filename"
    if ! safe_symlink "$file" "$target"; then
      log error "Failed to symlink $filename from $file to $target"
      return 1
    fi
  done

  log success "Dotfiles linked"
  return 0
}

setup_ssh() {
  key="$HOME/.ssh/id_ed25519"

  if [ -f "$key" ]; then
    log debug "SSH key already exists"
    return 0
  fi

  log info "Generating new SSH key..."

  # Ensure .ssh directory exists
  if ! ensure_directory "$HOME/.ssh"; then
    log error "Failed to create .ssh directory"
    return 1
  fi

  if ! chmod 700 "$HOME/.ssh"; then
    log error "Failed to set .ssh directory permissions"
    return 1
  fi

  log debug "Running: ssh-keygen -t ed25519 -C \"hello@maclong.uk\" -f \"$key\" -N \"\""
  if [ "$DEBUG" = true ]; then
    if ! ssh-keygen -t ed25519 -C "hello@maclong.uk" -f "$key" -N ""; then
      log error "SSH key generation failed"
      return 1
    fi
  else
    if ! ssh-keygen -t ed25519 -C "hello@maclong.uk" -f "$key" -N "" >/dev/null 2>&1; then
      log error "SSH key generation failed"
      return 1
    fi
  fi

  if [ "$DEBUG" = true ]; then
    log debug "Starting ssh-agent"
    if ! eval "$(ssh-agent -s)"; then
      log warning "Failed to start ssh-agent"
    fi
  else
    if ! eval "$(ssh-agent -s)" >/dev/null 2>&1; then
      log warning "Failed to start ssh-agent"
    fi
  fi

  log debug "Writing SSH config"
  if ! cat > "$HOME/.ssh/config" << 'EOF'
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
  then
    log warning "Failed to write SSH config"
  fi

  if [ "$IS_MAC" = true ]; then
    log debug "Copying SSH public key to clipboard"
    if ! cat "$key.pub" | pbcopy; then
      log warning "Failed to copy SSH public key to clipboard"
      log info "SSH public key contents:"
      cat "$key.pub" || {
        log error "Failed to display SSH public key"
        return 1
      }
    else
      log success "SSH public key copied to clipboard"
    fi
  else
    log success "SSH key generated"
    log info "SSH public key contents:"
    if ! cat "$key.pub"; then
      log error "Failed to display SSH public key"
      return 1
    fi
  fi

  return 0
}

main() {
  log debug "Arguments: $*"
  log info "Initialising developer environment..."

  if ! spinner "Creating development directories" create_dev_directories; then
    log error "Failed during development directories creation"
    exit 1
  fi

  if ! spinner "Setting up dotfiles" setup_dotfiles; then
    log error "Failed during dotfiles setup"
    exit 1
  fi

  if ! spinner "Setting up color schemes" setup_colors; then
    log error "Failed during color schemes setup"
    exit 1
  fi

  if ! spinner "Linking dotfiles" link_dotfiles; then
    log error "Failed during dotfiles linking"
    exit 1
  fi

  if ! spinner "Setting up SSH configuration" setup_ssh; then
    log error "Failed during SSH setup"
    exit 1
  fi

  if [ "$IS_MAC" = true ]; then
    if ! spinner "Configuring Touch ID" setup_touch_id; then
      log error "Failed during Touch ID configuration"
      exit 1
    fi
  fi

  log success "Setup complete!"
  printf "%s\n" \
    "" \
    "Next steps:" \
    "- Restart your shell" \
    "- Add your SSH key to services" \
    "- Apply your themes"
}

main "$@"
