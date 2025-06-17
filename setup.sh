#!/bin/sh
set -e

# Ensure required tools exist
for cmd in git curl ln mkdir; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "$cmd required" >&2
    exit 1
  }
done

# Load shared functions and env variables
if ! curl -fsSL "https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/utils.sh" -o /tmp/utils.sh || ! . /tmp/utils.sh; then
  echo "Failed to load utils.sh" >&2
  exit 1
fi

parse_args "$@"

process_colorscheme_files() {
  [ ! -d "$1" ] && return

  count=$(count_files "$1/$2")
  scheme=$(basename "$1")

  if [ "$count" -gt 0 ]; then
    log_debug "Found $count $4 files in $scheme"
    for file in "$1"/$2; do
      [ -f "$file" ] && safe_symlink "$file" "$3/$(basename "$file")"
    done
  else
    log_debug "No $4 files in $scheme"
  fi
}

setup_colors() {
  [ ! -d "$HOME/.config/colors" ] && {
    log_warning "Colors directory missing, skipping color setup"
    return
  }

  log_info "Installing colorschemes..."

  ensure_directory "$HOME/.vim/colors"
  [ "$IS_MAC" = true ] && ensure_directory "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"

  for scheme_dir in "$HOME/.config/colors"/*; do
    [ -d "$scheme_dir" ] || continue

    log_info "Processing scheme: $(basename "$scheme_dir")"
    process_colorscheme_files "$scheme_dir" "*.vim" "$HOME/.vim/colors" "vim"
    [ "$IS_MAC" = true ] && process_colorscheme_files "$scheme_dir" "*.xccolortheme" "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes" "Xcode"
  done

  log_success "Color setup complete"
}

setup_touch_id() {
  log_info "Configuring Touch ID for sudo..."

  if [ -f /etc/pam.d/sudo_local ] && grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local; then
    log_success "Touch ID already enabled"
    return
  fi

  [ ! -f /etc/pam.d/sudo_local.template ] && {
    log_error "Missing template: /etc/pam.d/sudo_local.template"
    return 1
  }

  sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
  sudo sed -i '' 's/^#//' /etc/pam.d/sudo_local

  grep -q "^auth.*pam_tid.so" /etc/pam.d/sudo_local \
    && log_success "Touch ID enabled" \
    || {
      log_error "Failed to enable Touch ID"
      return 1
    }
}

create_dev_directories() {
  log_info "Creating development directories..."

  for dir in "$HOME/Developer/personal" "$HOME/Developer/clients" "$HOME/Developer/study" "$HOME/Developer/work"; do
    ensure_directory "$dir"
  done

  log_debug "Development directories created"
}

setup_dotfiles() {
  log_info "Installing dotfiles..."

  rm -rf "$HOME/.config"
  log_debug "Cloning repository https://github.com/maclong9/dots"
  git clone "https://github.com/maclong9/dots" "$HOME/.config"
  log_success "Dotfiles cloned"
}

link_dotfiles() {
  log_info "Linking dotfiles from .config to home..."

  find "$HOME/.config" -maxdepth 1 -name ".*" -type f | while IFS= read -r file; do
    name=$(basename "$file")
    case "$name" in .|..|.git) continue ;; esac
    safe_symlink "$file" "$HOME/$name"
  done
}

setup_ssh() {
  key="$HOME/.ssh/id_ed25519"

  [ -f "$key" ] && {
    log_debug "SSH key already exists"
    return
  }

  log_info "Generating new SSH key..."
  ssh-keygen -t ed25519 -C "hello@maclong.uk" -f "$key" -N ""
  eval "$(ssh-agent -s)"

  printf "Host github.com\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519\n" > "$HOME/.ssh/config"

  if [ "$IS_MAC" = true ]; then
    cat "$key.pub" | pbcopy
    log_success "SSH public key copied to clipboard"
  else
    log_success "SSH key generated"
    log_info "Public key contents:"
    cat "$key.pub"
  fi
}

main() {
  log_debug "Arguments: $*"
  log_info "Starting bootstrap process..."

  create_dev_directories
  setup_dotfiles
  setup_colors
  link_dotfiles
  setup_ssh
  [ "$IS_MAC" = true ] && setup_touch_id

  log_success "Setup complete!"
  printf "\nNext steps:\n- Restart your shell\n- Add your SSH key to services\n- Apply your themes\n"
}

main "$@"
