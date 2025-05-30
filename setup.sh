#!/bin/sh

set -eu

cd && sudo passwd mac

printf "Updating XBPS..."
sudo xbps-install -Suy xbps

printf "Installing core development tools..."
sudo xbps-install -y base-devel curl gcc git github-cli nodejs python3 python3-pip rustup unzip vim zsh

printf "Installing common linters and formatters..."

# Python
sudo xbps-install -y flake8 python3-mypy black python3-isort python3-lsp-server

# JavaScript/TypeScript (and Deno optional)
curl -fsSL https://deno.land/install.sh | sh
sudo npm install -g eslint prettier typescript typescript-language-server

# Rust
rustup-init -y --profile default
"$HOME"/.cargo/bin/rustup component add rustfmt clippy

# C/C++
sudo xbps-install -y clang-tools-extra

# Setup personal dotfiles
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
ssh-keygen -t rsa -b 4096 -f "$HOME"/.ssh/id_rsa -N ""
cat "$HOME"/.ssh/id_rsa.pub

mkdir "$HOME"/work

printf "Development container setup completed.\n"
printf "Run 'source "$HOME"/.zshrc' to and add your SSH key where needed\n"
