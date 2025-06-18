#!/bin/sh
set -e


for cmd in git curl ln mkdir; do
  command -v "$cmd" >/dev/null 2>&1 || {
    printf "%s\n" "$cmd required" >&2
    exit 1
  }
done

if curl -fsSL "https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/utils.sh" -o /tmp/utils.sh; then
  . /tmp/utils.sh
else
  printf "%s\n" "Failed to load utils.sh" >&2
  exit 1
fi


parse_args "$@"


process_colorscheme_files() {
  [ ! -d "$1" ] && return

  count=$(count_files "$1/$2")
  scheme=$(basename "$1")

  if [ "$count" -gt 0 ]; then
    log debug "Found $count $4 files in $scheme"
    for file in "$1"/$2; do
      [ -f "$file" ] && \
        spinner "Symlinking $4 file $(basename "$file")" safe_symlink "$file" "$3/$(basename "$file")"
    done
  else
    log debug "No $4 files in $scheme"
  fi
}

setup_colors() {
  [ ! -d "$HOME/.config/colors" ] && {
    log warning "Colors directory missing, skipping color setup"
    return
  }

  log info "Installing colorschemes..."

  spinner "Creating Vim colors directory" ensure_directory "$HOME/.vim/colors"
  [ "$IS_MAC" = true ] && \
    spinner "Creating Xcode colors directory" ensure_directory "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"

  for scheme_dir in "$HOME/.config/colors"/*; do
    [ -d "$scheme_dir" ] || continue

    log info "Processing scheme: $(basename "$scheme_dir")"
    process_colorscheme_files "$scheme_dir" "*.vim" \
      "$HOME/.vim/colors" "vim"
    [ "$IS_MAC" = true ] && \
      process_colorscheme_files "$scheme_dir" "*.xccolortheme" \
      "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes" "Xcode"
  done

  log success "Color setup complete"
}

setup_touch_id() {
  log info "Configuring Touch ID for sudo..."

  if grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local; then
      log success "Touch ID enabled"
    else
      log error "Failed to enable Touch ID"
      return 1
    fi


  [ ! -f /etc/pam.d/sudo_local.template ] && {
    log error "Missing template: /etc/pam.d/sudo_local.template"
    return 1
  }

  spinner "Configuring Touch ID" sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
  sudo sed -i '' 's/^#//' /etc/pam.d/sudo_local

  grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local && \
    log success "Touch ID enabled" || {
      log error "Failed to enable Touch ID"
      return 1
    }
}

create_dev_directories() {
  log info "Creating development directories..."

  for dir in \
    "$HOME/Developer/personal" \
    "$HOME/Developer/clients" \
    "$HOME/Developer/study" \
    "$HOME/Developer/work"
  do
    spinner "Creating directory $dir" ensure_directory "$dir"
  done

  log success "Development directories created"
}

setup_dotfiles() {
  log info "Installing dotfiles..."

  rm -rf "$HOME/.config"
  log debug "Cloning repository https://github.com/maclong9/dots"
  spinner "Cloning dotfiles repository" git clone "https://github.com/maclong9/dots" "$HOME/.config" || {
    log error "Failed to clone dotfiles repository"
    exit 1
  }
  log success "Dotfiles cloned"
}

link_dotfiles() {
  log info "Linking dotfiles from .config to home..."
  find "$HOME/.config" -maxdepth 1 -name ".*" -type f -not -name '.git' -exec sh -c '
    spinner "Symlinking $(basename "{}")" safe_symlink "{}" "$HOME/$(basename "{}")"
  '
  log success "Dotfiles linked"
}

setup_ssh() {
  key="$HOME/.ssh/id_ed25519"

  [ -f "$key" ] && {
    log debug "SSH key already exists"
    return
  }

  log info "Generating new SSH key..."
  spinner "Generating SSH key" ssh-keygen -t ed25519 -C "hello@maclong.uk" -f "$key" -N ""
  eval "$(ssh-agent -s)"

  printf "%s\n" \
    "Host github.com" \
    "  AddKeysToAgent yes" \
    "  UseKeychain yes" \
    "  IdentityFile ~/.ssh/id_ed25519" \
    > "$HOME/.ssh/config"

  if [ "$IS_MAC" = true ]; then
    pbcopy < "$key.pub"
    log success "SSH public key copied to clipboard"
  else
    log success "SSH key generated"
    log info "Public key contents:"
    cat "$key.pub"
  fi
}

main() {
  log debug "Arguments: $*"
  log info "Starting bootstrap process..."

  spinner "Creating development directories" create_dev_directories
  spinner "Setting up dotfiles" setup_dotfiles
  spinner "Setting up color schemes" setup_colors
  spinner "Linking dotfiles" link_dotfiles
  spinner "Setting up SSH configuration" setup_ssh
  [ "$IS_MAC" = true ] && spinner "Configuring Touch ID" setup_touch_id

  log success "Setup complete!"
  printf "%s\n" \
    "" \
    "Next steps:" \
    "- Restart your shell" \
    "- Add your SSH key to services" \
    "- Apply your themes"
}

main "$@"
