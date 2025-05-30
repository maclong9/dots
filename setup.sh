#!/bin/sh

set -eu

cd && sudo passwd mac

printf "Updating XBPS...\n"
sudo xbps-install -Suy xbps

printf "Installing core tools...\n"
sudo xbps-install -y base-devel curl git github-cli jq unzip vim wget zsh

# Shell tooling
printf "Installing shell tools...\n"
sudo xbps-install -y go
go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Python
printf "Installing Python tools...\n"
sudo xbps-install -y python3 python3-pip python3-lsp-server black python3-isort ruff

# JavaScript/TypeScript/Deno
printf "Installing JS/TS/Deno tools...\n"
sudo xbps-install -y nodejs
curl -fsSL https://deno.land/install.sh | sh -s -- -y
sudo npm install -g eslint prettier typescript typescript-language-server vscode-langservers-extracted ktlint

# Rust
printf "Installing Rust tools...\n"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile default
"$HOME"/.cargo/bin/rustup component add rustfmt clippy

# C/C++
printf "Installing C/C++ tools...\n"
sudo xbps-install -y clang-tools-extra cmake make ccls

# Kotlin
printf "Installing Kotlin tools...\n"
sudo xbps-install -y kotlin-bin
wget -q https://github.com/fwcd/kotlin-language-server/releases/latest/download/server.zip -O /tmp/kotlin-ls.zip
mkdir -p "$HOME"/.local/share/kotlin-language-server
unzip -q /tmp/kotlin-ls.zip -d "$HOME"/.local/share/kotlin-language-server
rm /tmp/kotlin-ls.zip

# PHP
printf "Installing PHP tools...\n"
sudo xbps-install -y php php-composer
composer global require phpactor/phpactor

# Ruby
printf "Installing Ruby tools...\n"
sudo xbps-install -y ruby ruby-devel bundler
gem install solargraph

# Go
printf "Installing Go tools...\n"
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Additional language servers and tools
printf "Installing additional language servers...\n"
sudo npm install -g yaml-language-server dockerfile-language-server-nodejs bash-language-server

# Database tools
printf "Installing database tools...\n"
sudo xbps-install -y postgresql-client sqlite mariadb-client redis

# Docker and container tools
printf "Installing container tools...\n"
sudo xbps-install -y docker docker-compose podman

# Setup personal dotfiles
printf "Setting up dotfiles...\n"
rm -rf "$HOME"/.config
git clone https://github.com/maclong9/dots "$HOME"/.config
cd "$HOME"/.config && git switch container
for file in "$HOME"/.config/.*; do
    case "$(basename "$file")" in
        "." | ".." | ".git" | ".gitignore") continue ;;
        *) rm -rf "$HOME/$(basename "$file")" &&
           ln -s "$file" "$HOME/$(basename "$file")" ;;
    esac
done
chsh -s /usr/bin/zsh mac

# Setup SSH Key
printf "Setting up SSH key...\n"
ssh-keygen -t ed25519 -f "$HOME"/.ssh/id_ed25519 -N ""
printf "\nYour SSH public key:\n"
cat "$HOME"/.ssh/id_ed25519.pub

mkdir -p "$HOME"/work

printf "\nDevelopment container setup completed.\n"
printf "Run 'source ~/.zshrc' and add your SSH key where needed\n"
