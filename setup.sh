#!/bin/sh

# Fail fast if basic commands missing
for cmd in git curl ln mkdir; do
  command -v "$cmd" >/dev/null 2>&1 || {
    printf "%s\n" "$cmd required" >&2
    exit 1
  }
done

if ! curl -fsSL "https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/utils.sh" -o /tmp/utils.sh; then
  printf "Failed to download utils.sh\n" >&2
  exit 1
fi

if ! . /tmp/utils.sh; then
  printf "Failed to source utils.sh\n" >&2
  exit 1
fi

parse_args "$@"

process_colorscheme_files() {
  [ ! -d "$1" ] && return 0

  count=$(count_files "$1/$2") || return 1
  scheme=$(basename "$1")

  if [ "$count" -gt 0 ]; then
    log debug "Found $count $4 files in $scheme"
    for file in "$1"/$2; do
      [ -f "$file" ] || continue
      spinner "Symlinking $4 file $(basename "$file")" safe_symlink "$file" "$3/$(basename "$file)" || return 1
    done
  else
    log debug "No $4 files in $scheme"
  fi

  return 0
}

setup_colors() {
  [ ! -d "$HOME/.config/colors" ] && {
    log warning "Colors directory missing, skipping color setup"
    return 0
  }

  log info "Installing colorschemes..."

  spinner "Creating Vim colors directory" ensure_directory "$HOME/.vim/colors" || return 1
  if [ "$IS_MAC" = true ]; then
    spinner "Creating Xcode colors directory" ensure_directory "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes" || return 1
  fi

  for scheme_dir in "$HOME/.config/colors"/*; do
    [ -d "$scheme_dir" ] || continue

    log info "Processing scheme: $(basename "$scheme_dir")"
    process_colorscheme_files "$scheme_dir" "*.vim" "$HOME/.vim/colors" "vim" || return 1

    if [ "$IS_MAC" = true ]; then
      process_colorscheme_files "$scheme_dir" "*.xccolortheme" "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes" "Xcode" || return 1
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

  spinner "Configuring Touch ID" sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local || return 1
  sudo sed -i '' 's/^#//' /etc/pam.d/sudo_local || return 1

  if grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local; then
    log success "Touch ID enabled"
  else
    log error "Failed to enable Touch ID"
    return 1
  fi
  return 0
}

create_dev_directories() {
  log info "Creating development directories..."

  for dir in "$HOME/Developer/personal" "$HOME/Developer/clients" "$HOME/Developer/study" "$HOME/Developer/work"; do
    spinner "Creating directory $dir" ensure_directory "$dir" || return 1
  done

  log success "Development directories created"
  return 0
}

setup_dotfiles() {
  log info "Installing dotfiles..."

  rm -rf "$HOME/.config" || {
    log error "Failed to remove old .config directory"
    return 1
  }

  log debug "Cloning repository https://github.com/maclong9/dots"
  spinner "Cloning dotfiles repository" git clone "https://github.com/maclong9/dots" "$HOME/.config" || {
    log error "Failed to clone dotfiles repository"
    return 1
  }

  log success "Dotfiles cloned"
  return 0
}

link_dotfiles() {
  log info "Linking dotfiles from .config to home..."

  for file in "$HOME/.config"/.*; do
    [ -f "$file" ] || continue
    [ "$(basename "$file")" = ".git" ] && continue

    spinner "Symlinking $(basename "$file")" safe_symlink "$file" "$HOME/$(basename "$file")" || return 1
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
  if ! ssh-keygen -t ed25519 -C "hello@maclong.uk" -f "$key" -N ""; then
    log error "SSH key generation failed"
    return 1
  fi

  eval "$(ssh-agent -s)" || {
    log warning "Failed to start ssh-agent"
  }

  printf "%s\n" \
    "Host github.com" \
    "  AddKeysToAgent yes" \
    "  UseKeychain yes" \
    "  IdentityFile ~/.ssh/id_ed25519" \
    > "$HOME/.ssh/config" || {
      log warning "Failed to write SSH config"
    }

  if [ "$IS_MAC" = true ]; then
    if ! cat "$key.pub" | pbcopy; then
      log warning "Failed to copy SSH public key to clipboard"
      return 1
    fi
    log success "SSH public key copied to clipboard"
  else
    log success "SSH key generated"
    log info "Public key contents:"
    cat "$key.pub"
  fi

  return 0
}

main() {
  log debug "Arguments: $*"
  log info "Initialising developer environment..."

  spinner "Creating development directories" create_dev_directories || exit 1
  spinner "Setting up dotfiles" setup_dotfiles || exit 1
  spinner "Setting up color schemes" setup_colors || exit 1
  spinner "Linking dotfiles" link_dotfiles || exit 1
  spinner "Setting up SSH configuration" setup_ssh || exit 1
  if [ "$IS_MAC" = true ]; then
    spinner "Configuring Touch ID" setup_touch_id || exit 1
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
