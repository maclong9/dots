# UNIX Development Environment

A comprehensive, POSIX-compliant dotfiles configuration for productive development on UNIX Operating Systems.

https://github.com/user-attachments/assets/080a296c-dffe-44b7-a1af-c0d61105c8ac

## ✨ Features

- **Shell**: Modern ZSH configuration with git integration and smart completions
- **Terminal**: Ghostty setup for a fast, GPU-accelerated terminal experience
- **Editor**: Helix setup with syntax highlighting, lsp and productivity enhancements
- **Git**: Comprehensive Git configuration with useful aliases and SSH signing
- **Colors**: Consistent color schemes across Helix, Terminal, and Xcode
- **Scripts**: Utility functions for development workflow automation
- **Maintenance**: Weekly scheduled system and tooling maintenance
- **Tools**: Install frequently used developer tooling with `mise`
- **Caps Lock Daemon**: Custom C daemon for dual Caps Lock functionality (Escape on tap, Control on hold)

## 🚀 Quick Installation

```sh
curl -fsSL https://raw.githubusercontent.com/maclong9/dots/main/setup.sh | sh
```

## 🛠 Post-Installation

- Restart your terminal or run `source "$HOME/.zshrc"`.
- Add your SSH key to remote.
- Configure color schemes in your editors as needed.

## 🔧 Additional Tools

### Caps Lock Daemon

A custom C daemon that provides dual functionality for the Caps Lock key:
- **Quick press** (<500ms): Sends Escape key
- **Hold** (≥500ms): Acts as Control key
- **Combo** (Caps + other key): Acts as Control key

Located in [`caps-lock-daemon/`](caps-lock-daemon/) with full installation instructions.
