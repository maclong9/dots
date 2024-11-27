#!/bin/sh
# `curl -sSL https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/setup.sh | sh`

# restore system to previous state if non-zero exit code
trap 'cleanup' EXIT
cleanup() {
	if [ $? -ne 0 ]; then
		sudo rm -rf "$HOME"/.config "$HOME"/.gitconfig "$HOME"/.gitignore \
		"$HOME"/.vim "$HOME"/.vimrc "$HOME"/.zshrc /etc/pam.d/sudo_local
		(crontab -l 2>/dev/null | sed '$d;$d') | crontab -
	fi
}

# check if running on macOS
if [ "$(uname -s)" = "Darwin" ]; then
	# enable Touch ID for `sudo`
	sudo sed 's/^#auth/auth/' /etc/pam.d/sudo_local.template | \
		sudo tee /etc/pam.d/sudo_local > /dev/null
	
	# install developer tools
	if ! xcode-select -p >/dev/null 2>&1; then
		xcode-select --install
	fi
	
	# accept developer tools license
	if ! /usr/bin/xcrun clang >/dev/null 2>&1; then
		sudo xcodebuild -license accept
	fi
fi

# clone configuration files and symlink to home directory
git clone https://github.com/maclong9/dots .config
for file in .config/.*; do
	case "$(basename "$file")" in
		"." | ".." | ".git") continue ;;
		*) ln -s "$file" "$HOME/$(basename "$file")" ;;
	esac
done

# install tooling
curl -fsSL https://deno.land/install.sh | sh
source "$HOME/.deno/env"

set -- tailwindcss-language-server \
	typescript-language-server \
	vscode-langservers-extracted@4.10.0/vscode-css-language-server \
	vscode-langservers-extracted@4.10.0/vscode-eslint-language-server \
	vscode-langservers-extracted@4.10.0/vscode-html-language-server \
	vscode-langservers-extracted@4.10.0/vscode-json-language-server \
	vscode-langservers-extracted@4.10.0/vscode-markdown-language-server 

for server in "$@" do
	"$HOME/.deno/bin/deno" install -g "npm:$server"
done

# setup cron tasks
(crontab -l 2>/dev/null; echo "0 10 * * * $HOME/.save-the-world.sh") | crontab -

printf "Configuration complete\n"
