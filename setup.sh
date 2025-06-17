#!/bin/sh
set -e

# Ensure required tooling exists
for cmd in git curl ln mkdir; do
  command -v $cmd >/dev/null 2>&1 || { echo "$cmd required"; exit 1; }
done

# Load common functions and environment variables
if ! curl -fsSL "https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/utils.sh" \
    -o /tmp/utils.sh || ! . /tmp/utils.sh; then
    echo "Failed to load utils.sh" >&2
    exit 1
fi

# Parse args and define core paths and constants
parse_args "$@"
COLORS_DIR="$HOME/.config/colors"
VIM_COLORS_DIR="$HOME/.vim/colors"
XCODE_THEMES_DIR="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
DOTFILES_REPO="https://github.com/maclong9/dots"
DEV_DIRECTORIES="$HOME/Developer/personal $HOME/Developer/clients $HOME/Developer/study $HOME/Developer/work"

# Symlink all matching files from color scheme directory
process_colorscheme_files() {
  colors_dir="$1"; pattern="$2"; target="$3"; type="$4"
  count=$(count_files "$colors_dir/$pattern")
  name=$(basename "$colors_dir")
  if [ "$count" -gt 0 ]; then
    log_debug "Found $count $type files in $name"
    for f in "$colors_dir"/$pattern; do
      [ -f "$f" ] && safe_symlink "$f" "$target/$(basename "$f")"
    done
  else
    log_debug "No $type files in $name"
  fi
}

# Install editor and IDE color schemes
setup_colors() {
  log_info "Installing colorschemes..."
  [ ! -d "$COLORS_DIR" ] && {
    log_warning "No colors dir, skipping"
    return
  }
  ensure_directory "$VIM_COLORS_DIR"
  [ "$IS_MAC" = true ] && ensure_directory "$XCODE_THEMES_DIR"

  for dir in "$COLORS_DIR"/*; do
    [ ! -d "$dir" ] && continue
    name=$(basename "$dir")
    log_info "Scheme: $name"
    process_colorscheme_files "$dir" "*.vim" "$VIM_COLORS_DIR" vim
    [ "$IS_MAC" = true ] && \
      process_colorscheme_files "$dir" \
        "*.xccolortheme" "$XCODE_THEMES_DIR" Xcode
  done
  log_success "Color setup done"
}

# Enable Touch ID authentication for sudo
setup_touch_id() {
  log_info "Configuring Touch ID for sudo..."
  sudo_local=/etc/pam.d/sudo_local
  tmpl=/etc/pam.d/sudo_local.template

  if [ -f "$sudo_local" ] && \
     grep -q "^auth.*pam_tid.so" "$sudo_local"; then
    log_success "Touch ID already enabled"
    return
  fi

  [ ! -f "$tmpl" ] && {
    log_error "Template $tmpl missing"
    return 1
  }

  sudo cp "$tmpl" "$sudo_local"
  sudo sed -i '' 's/^#//' "$sudo_local"

  if grep -q "^auth.*pam_tid.so" "$sudo_local"; then
    log_success "Touch ID enabled"
  else
    log_error "Failed to enable Touch ID"
    return 1
  fi
}

# Create personal dev directory structure
create_dev_directories() {
  log_info "Creating dev directories..."
  for d in $DEV_DIRECTORIES; do
    ensure_directory "$d"
  done
  log_debug "Dev dirs created"
}

# Clone dotfiles if not already present
setup_dotfiles() {
  log_info "Installing dotfiles..."
  rm -rf "$HOME/.config"
  log_debug "Cloning $DOTFILES_REPO"
  git clone "$DOTFILES_REPO" "$HOME/.config"
  log_success "Dotfiles cloned"
}

# Symlink dotfiles from .config to $HOME
link_dotfiles() {
  log_info "Linking config dotfiles..."
  find "$HOME/.config" -maxdepth 1 -name ".*" -type f |
    while IFS= read -r cf; do
      fn=$(basename "$cf")
      case "$fn" in .|..|.git) continue ;; esac
      safe_symlink "$cf" "$HOME/$fn"
    done
}

# Generate and configure SSH key if missing
setup_ssh() {
  key="$HOME/.ssh/id_ed25519"
  [ -f "$key" ] && {
    log_debug "SSH key exists"
    return
  }
  log_info "Generating SSH key..."
  ssh-keygen -t ed25519 -C "hello@maclong.uk" \
    -f "$key" -N ""
  eval "$(ssh-agent -s)"
  printf "Host github.com\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519\n" \
    > "$HOME/.ssh/config"
  if [ "$IS_MAC" = true ]; then
    cat "$key.pub" | pbcopy
    log_success "SSH key in clipboard"
  else
    log_success "SSH key generated"
    log_info "Pub key:"
    cat "$key.pub"
  fi
}

# Main bootstrap sequence
main() {
  log_debug "Args: $*"
  log_info "Bootstrapping dev env..."
  create_dev_directories
  setup_dotfiles
  setup_colors
  link_dotfiles
  setup_ssh
  [ "$IS_MAC" = true ] && setup_touch_id

  log_success "Setup done!"
  printf "\nNext: restart shell, add SSH key, apply themes.\n"
}

main "$@"

