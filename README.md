# UNIX Development Environment

A comprehensive, POSIX-compliant dotfiles configuration for productive development on
UNIX Operating Systems.

## ✨ Features

- **Shell**: Modern ZSH configuration with git integration and smart completions
- **Editor**: Helix setup with syntax highlighting, lsp and productivity enhancements
- **Git**: Comprehensive Git configuration with useful aliases and SSH signing
- **Colors**: Consistent color schemes across Helix, Terminal, and Xcode
- **Scripts**: Utility functions for development workflow automation
- **Maintenance** Weekly scheduled system maintenance for cleaning system/development caches
- **Tools**: Install frequently used developer tooling with `mise`

## 🚀 Quick Installation

```sh
curl -fsSL https://raw.githubusercontent.com/maclong9/dots/main/setup.sh | sh
```

## 🛠 Post-Installation

- Restart your terminal or run `source "$HOME/.zshrc"`.
- Add your SSH key to remote.
- Configure color schemes in your editors as needed.
- Run your development container as required using `dev-start` and `dev-exec`.
