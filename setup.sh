#!/bin/sh
# macOS Development Environment Setup Script

# Prompt for sudo password at the start
get_sudo_password() {
	printf "\033[1;34m→\033[0m \033[1;37mEnter your sudo password:\033[0m "
	stty -echo
	read -r SUDO_PASSWORD
	stty echo
	echo
}

# Function to run sudo commands with the stored password
run_sudo() {
	echo "$SUDO_PASSWORD" | sudo -S sh -c "$1"
}

# Spinner function with new frames
spinner() {
	pid="$1"
	delay=0.1
	frames="⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏"
	i=0
	printf "\033[?25l"
	while ps a | awk '{print $1}' | grep -q "$pid"; do
		frame=$(echo "$frames" | cut -d' ' -f$((i + 1)))
		printf "\033[1;33m%s\033[0m " "$frame"
		i=$((i + 1))
		if [ $i -ge 10 ]; then i=0; fi
		sleep $delay
		printf "\b\b"
	done
	printf "\033[?25h"
	printf " \b"
}

# Run command with spinner
run_with_spinner() {
	cmd="$1"
	msg="$2"
	printf "\033[1;34m→\033[0m \033[1;37m%s\033[0m " "$msg"
	if eval "$cmd" >/dev/null 2>&1; then
		printf "\033[1;32m✔\033[0m\n"
	else
		printf "\033[1;31m✗\033[0m\n"
		eval "$cmd"
		exit 1
	fi
}

# Cleanup function
cleanup() {
	if [ $? -ne 0 ]; then
		printf "\033[1;31m✗\033[0m \033[1;37mSetup failed, restoring system state\033[0m\n"
		cd "$HOME" || exit
		run_sudo "rm -rf .config .gitconfig .gitignore .zshrc /etc/pam.d/sudo_local"
		(crontab -l 2>/dev/null | grep -v "backup\|update") | crontab -
		exit 1
	fi
}

trap cleanup EXIT

# Main setup
get_sudo_password

# Clone and symlink configuration files
run_with_spinner "git clone https://github.com/maclong9/dots .config" "Cloning configuration files"
for file in .config/.*; do
	case "$(basename "$file")" in
	"." | ".." | ".git") continue ;;
	*) ln -sf "$file" "${HOME}/$(basename "$file")" ;;
	esac
done

# macOS specific setup
if [ "$(uname -s)" = "Darwin" ]; then
	run_with_spinner "true" "Configuring macOS settings"

	# Enable Touch ID for sudo
	if [ ! -f "/etc/pam.d/sudo_local" ]; then
		run_with_spinner 'run_sudo "sed '\''s/^#auth/auth/'\'' /etc/pam.d/sudo_local.template > /etc/pam.d/sudo_local"' "Enabling Touch ID for sudo"
	fi

	# Install Xcode command line tools if needed
	if ! xcode-select -p >/dev/null 2>&1; then
		run_with_spinner "xcode-select --install" "Installing Xcode command line tools"
		until xcode-select -p >/dev/null 2>&1; do
			sleep 1
		done
	fi

	# Accept Xcode license if needed
	if ! /usr/bin/xcrun clang >/dev/null 2>&1; then
		run_with_spinner 'run_sudo "xcodebuild -license accept"' "Accepting Xcode license"
	fi
fi

# Install development tools
run_with_spinner "true" "Installing development tools"

# Install Homebrew if needed
if ! command -v /opt/homebrew/bin/brew >/dev/null 2>&1; then
	run_with_spinner "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\" && eval \"$(/opt/homebrew/bin/brew shellenv)\"" "Installing Homebrew"
fi

# Install commandline tools
run_with_spinner "/opt/homebrew/bin/brew install gh helix node orbstack starship zoxide" "Installing applications and tools"

# Install language servers
run_with_spinner "/opt/homebrew/bin/npm install -g @tailwindcss/language-server emmet-ls svelte-language-server typescript-language-server vercel vscode-langservers-extracted" "Installing web tooling"

# Install macOS Applications
if [ "$(uname -s)" = "Darwin" ]; then
	run_with_spinner "/opt/homebrew/bin/brew install mas && /opt/homebrew/bin/brew install --cask ghostty homerow hyperkey onyx && /opt/homebrew/bin/mas install 1527619437 1662217862 1596283165 634148309 424389933 634159523 497799835 434290957 424390742 1289583905" "Installing macOS applications"
fi

# GitHub CLI authentication
printf "\033[1;34m→\033[0m \033[1;37mAuthenticating with GitHub CLI\033[0m\n"
/opt/homebrew/bin/gh auth login -s delete_repo

printf "\033[1;32m✔\033[0m \033[1;37mConfiguration complete\033[0m\n"
