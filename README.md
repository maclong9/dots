# POSIX Compliant UNIX System Configuration Files

This repository contains my personal dotfiles and scripts for configuring a productive, POSIX-compliant UNIX or macOS development environment. The setup prioritizes portability, clarity, and ease of use.

## Quick Start

To bootstrap a new environment (macOS recommended):

```sh
curl -fsSL https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/setup.sh | sh
```
> **Note:** It’s recommended to use [containers](https://github.com/apple/container/tree/main) for development.

---

## Main Files and Directories

- **`.gitconfig`** — Git configuration with useful aliases and SSH signing.
- **`.vimrc`** — Modern Vim configuration for UI, productivity, and color enhancements.
- **`.zshrc`** — Z shell config: prompts, aliases, and functions.
- **`setup.sh`** — Automated script for environment initialization.
- **`colors/`** — Custom color schemes for Vim (and Terminal.app/Xcode on macOS).
- **`scripts/`** — Collection of shell scripts for various tasks and automation. Each script is POSIX-compliant and intended to improve workflow efficiency.

---

## Next Steps After Setup

1. Restart your terminal or run: `source ~/.zshrc`
2. Set up SSH keys for remote use (add your public key to GitHub).
3. Configure color schemes in your editors as needed.
