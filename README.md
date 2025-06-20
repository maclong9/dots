# Modern UNIX Development Environment

A comprehensive, POSIX-compliant dotfiles configuration for productive development on macOS and Linux.

## ✨ Features

- **Shell**: Modern Zsh configuration with git integration and smart completions
- **Editor**: Vim setup with syntax highlighting and productivity enhancements
- **Git**: Comprehensive Git configuration with useful aliases and SSH signing
- **Colors**: Consistent color schemes across Vim, Terminal, and Xcode
- **Scripts**: Utility functions for development workflow automation

## 🚀 Quick Installation

```sh
curl -fsSL https://raw.githubusercontent.com/maclong9/dots/main/setup.sh | sh
```

## 📋 Manual Installation

1. Clone the repository:

```sh
git clone https://github.com/maclong9/dots.git ~/.config
```

2. Run the setup script:

```sh
~/.config/setup.sh
```

3. Restart your terminal

## 🛠 Post-Installation

- Add your SSH key to GitHub/GitLab
- Customize git user information
- Install development tools via scripts/dev-setup.sh

```txt
📁 Structure
├── colors/           # Color schemes for various applications
├── scripts/          # Utility scripts and functions
├── .gitconfig        # Git configuration with aliases
├── .vimrc            # Vim editor configuration
├── .zshrc            # Zsh shell configuration
└── setup.sh          # Automated installation script
```
