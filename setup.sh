#!/bin/sh
set -e

# Ensure required tools exist
REQUIRED_CMDS="git curl ln mkdir"
for cmd in $REQUIRED_CMDS; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "$cmd required" >&2
    exit 1
  }
done

# Load shared functions and env variables
UTILS_URL="https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/scripts/utils.sh"
UTILS_TMP="/tmp/utils.sh"
if ! curl -fsSL "$UTILS_URL" -o "$UTILS_TMP" || ! . "$UTILS_TMP"; then
  echo "Failed to load utils.sh" >&2
  exit 1
fi

# Parse arguments
parse_args "$@"

# Symlink matching files from colorscheme directory
process_colorscheme_files() {
  colors_dir="$1"
  pattern="$2"
  target_dir="$3"
  file_type="$4"

  count=$(count_files "$colors_dir/$pattern")
  dir_name=$(basename "$colors_dir")

  if [ "$count" -gt 0 ]; then
    log_debug "Found $count $file_type files in $dir_name"
    for file in "$colors_dir"/$pattern; do
      [ -f "$file" ] && safe_symlink "$file" "$target_dir/$(basename "$file")"
    done
  else
    log_debug "No $file_type files in $dir_name"
  fi
}

# Setup color schemes for editors and IDEs
setup_colors() {
  COLORS_DIR="$HOME/.config/colors"
  VIM_COLORS_DIR="$HOME/.vim/colors"
  XCODE_THEMES_DIR="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"

  log_info "Installing colorschemes..."

  if [ ! -d "$COLORS_DIR" ]; then
    log_warning "Colors directory missing, skipping color setup"
    return
  fi

  ensure_directory "$VIM_COLORS_DIR"
  if [ "$IS_MAC" = true ]; then
    ensure_directory "$XCODE_THEMES_DIR"
  fi

  for scheme_dir in "$COLORS_DIR"/*; do
    [ ! -d "$scheme_dir" ] && continue

    scheme_name=$(basename "$scheme_dir")
    log_info "Processing scheme: $scheme_name"

    process_colorscheme_files "$scheme_dir" "*.vim" "$VIM_COLORS_DIR" "vim"
    if [ "$IS_MAC" = true ]; then
      process_colorscheme_files "$scheme_dir" "*.xccolortheme" "$XCODE_THEMES_DIR" "Xcode"
    fi
  done

  log_success "Color setup complete"
}

# Enable Touch ID authentication for sudo (macOS only)
setup_touch_id() {
  log_info "Configuring Touch ID for sudo..."

  sudo_local="/etc/pam.d/sudo_local"
  sudo_template="/etc/pam.d/sudo_local.template"

  if [ -f "$sudo_local" ] && grep -q "^auth.*pam_tid.so" "$sudo_local"; then
    log_success "Touch ID already enabled"
    return
  fi

  if [ ! -f "$sudo_template" ]; then
    log_error "Missing template: $sudo_template"
    return 1
  fi

  sudo cp "$sudo_template" "$sudo_local"
  sudo sed -i '' 's/^#//' "$sudo_local"

  if grep -q "^auth.*pam_tid.so" "$sudo_local"; then
    log_success "Touch ID enabled"
  else
    log_error "Failed to enable Touch ID"
    return 1
  fi
}

# Create development directories
create_dev_directories() {
  DEV_DIRS="$HOME/Developer/personal $HOME/Developer/clients $HOME/Developer/study $HOME/Developer/work"

  log_info "Creating development directories..."

  for dir_path in $DEV_DIRS; do
    ensure_directory "$dir_path"
  done

  log_debug "Development directories created"
}

# Clone dotfiles repository if not present
setup_dotfiles() {
  DOTFILES_REPO="https://github.com/maclong9/dots"

  log_info "Installing dotfiles..."

  rm -rf "$HOME/.config"
  log_debug "Cloning repository $DOTFILES_REPO"
  git clone "$DOTFILES_REPO" "$HOME/.config"
  log_success "Dotfiles cloned"
}

# Symlink dotfiles from ~/.config to $HOME
link_dotfiles() {
  log_info "Linking dotfiles from .config to home..."

  find "$HOME/.config" -maxdepth 1 -name ".*" -type f | while IFS= read -r config_file; do
    filename=$(basename "$config_file")
    case "$filename" in
      .|..|.git) continue ;;
    esac
    safe_symlink "$config_file" "$HOME/$filename"
  done
}

# Generate SSH key if missing and add to ssh-agent
setup_ssh() {
  ssh_key="$HOME/.ssh/id_ed25519"

  if [ -f "$ssh_key" ]; then
    log_debug "SSH key already exists"
    return
  fi

  log_info "Generating new SSH key..."
  ssh-keygen -t ed25519 -C "hello@maclong.uk" -f "$ssh_key" -N ""

  eval "$(ssh-agent -s)"

  printf "Host github.com\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519\n" > "$HOME/.ssh/config"

  if [ "$IS_MAC" = true ]; then
    cat "$ssh_key.pub" | pbcopy
    log_success "SSH public key copied to clipboard"
  else
    log_success "SSH key generated"
    log_info "Public key contents:"
    cat "$ssh_key.pub"
  fi
}

# Main bootstrap function
main() {
  log_debug "Arguments: $*"
  log_info "Starting bootstrap process..."

  create_dev_directories
  setup_dotfiles
  setup_colors
  link_dotfiles
  setup_ssh

  if [ "$IS_MAC" = true ]; then
    setup_touch_id
  fi

  log_success "Setup complete!"
  printf "\nNext steps:\n- Restart your shell\n- Add your SSH key to services\n- Apply your themes\n"
}

main "$@"
