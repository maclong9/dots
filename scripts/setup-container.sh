#!/bin/sh

# Container-specific setup script
echo "Setting up Container-specific configurations..."
cd && sudo passwd mac

# Update xbps and install core tools
printf "Installing core tools...\n"
sudo xbps-install -Syu base-devel curl ffmpeg git github-cli helix jq unzip wget zsh

# Symlink to Home Directory
cd "/Users/mac/.config"
for file in .*; do
    case "$file" in
        "." | ".." | ".git" | ".gitconfig" | ".gitignore") continue ;;
    esac
    [ -e "$HOME/$file" ] && rm -rf "$HOME/$file"
    ln -s "/Users/mac/.config/$file" "$HOME/$file"
done
ln -s /Users/mac/.config "$HOME"/.config
cp /Users/mac/.config/.gitconfig "$HOME"/.gitconfig

sudo chsh mac -s /usr/bin/zsh

# C
printf "Installing C/C++ tools...\n"
sudo xbps-install -y clang-tools-extra cmake make ccls

# Python
printf "Installing Python tools...\n"
sudo xbps-install -y python3 python3-pip python3-lsp-server black python3-isort

# JavaScript/TypeScript/Deno
printf "Installing JS/TS/Deno tools...\n"
sudo xbps-install -y nodejs
curl -fsSL https://deno.land/install.sh | sh -s -- -y
sudo npm install -g @anthropic-ai/claude-code eslint prettier typescript typescript-language-server vscode-langservers-extracted @tailwindcss/language-server

# Rust
printf "Installing Rust tools...\n"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile default
"$HOME"/.cargo/bin/rustup component add rustfmt clippy

# PHP
printf "Installing PHP tools...\n"
sudo xbps-install -y php composer
composer global require phpactor/phpactor

# Ruby
printf "Installing Ruby tools...\n"
sudo xbps-install -y ruby ruby-devel
gem install solargraph

# Go
printf "Installing Go tools...\n"
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest

# Shell tooling
printf "Installing shell tools...\n"
go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Additional language servers and tools
printf "Installing additional language servers...\n"
sudo npm install -g yaml-language-server dockerfile-language-server-nodejs bash-language-server

# LaTeX tools
printf "Installing LaTeX tools...\n"
sudo xbps-install -y texlive texlive-latexextra texlive-fontsextra texlive-pictures perl-File-HomeDir zathura zathura-pdf-mupdf
sudo npm install -g @unified-latex/unified-latex-lint digestif

# Database tools
printf "Installing database tools...\n"
sudo xbps-install -y postgresql sqlite mariadb-client redis

# Docker and container tools
printf "Installing container tools...\n"
sudo xbps-install -y docker docker-compose podman

# Git and ZSH Environment Configuration
mkdir -p "$HOME"/work
cp /Users/mac/.gitconfig "$HOME"/.gitconfig
sed -i 's/maclong9@icloud\.com/mac@wearequantum.co.uk/g' "$HOME/.gitconfig"
printf 'export PATH="$HOME/.deno/bin:$HOME/.cargo/bin:$PATH"' > "$HOME/.zprofile"

printf "\nDevelopment container setup completed.\n"
printf "Run 'source ~/.zshrc' and add your SSH key where needed\n"
