# 🖥️ Development Environment

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![Last Commit](https://img.shields.io/github/last-commit/maclong9/dots)
[![Shell Script Testing](https://github.com/maclong9/dots/actions/workflows/shell-tests.yml/badge.svg)](https://github.com/maclong9/dots/actions/workflows/shell-tests.yml)

A comprehensive, POSIX-compliant dotfiles configuration for productive development on UNIX systems.

## 🚀 Installation

### Recommended (Secure Two-Step Installation)

```sh
# Download the setup script
curl -fsSL --proto '=https' --tlsv1.2 \
  https://raw.githubusercontent.com/maclong9/dots/main/setup.sh \
  -o /tmp/setup.sh

# Review the script (recommended)
less /tmp/setup.sh

# Run the setup script
sh /tmp/setup.sh

# Clean up
rm /tmp/setup.sh
```

### Quick Installation (Advanced Users)

⚠️ **Security Warning**: This method executes code directly without inspection.

```sh
curl -fsSL --proto '=https' --tlsv1.2 \
  https://raw.githubusercontent.com/maclong9/dots/main/setup.sh | sh
```

## ✨ Features

- **Shell**: Modern ZSH configuration with git integration, utilities and completions
- **Editor**: Helix setup with syntax highlighting, LSP, and productivity enhancements
- **Git**: Comprehensive configuration with useful aliases and SSH signing
- **Colors**: Consistent color schemes across Helix, Terminal, and Xcode
- **Scripts**: Utility functions for development workflow automation
- **Maintenance**: Weekly scheduled system and tooling maintenance
- **Tools**: Command line tooling managed with `mise`
