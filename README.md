# POSIX Compliant UNIX System Configuration Files

This repository contains my personal dotfiles and scripts for setting up a productive, POSIX-compliant UNIX or macOS development environment. The setup is optimized for portability, clarity, and ease-of-use.

## Quick Start

To bootstrap a new environment (macOS recommended):

```sh
curl -fsSl https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/setup.sh | sh
```

> **Note:** it’s highly recommended to utilize [containers](https://github.com/apple/container/tree/main) for development.

---

## Contents

- `.gitconfig` — Git configuration with useful aliases and SSH signing.
- `.vimrc` — Modern Vim configuration with UI, productivity, and color enhancements.
- `.zshrc` — Z shell configuration, prompt, aliases, and functions.
- `setup.sh` — Automated setup script for environment initialization.
- `colors/` — Custom colorschemes for Vim (also Terminal.app and Xcode if on macOS).

---

## Next Steps After Setup

1. Restart your terminal or run: `source ~/.zshrc`
2. Set up SSH keys on remote (add the public key to GitHub).
3. Configure colorschemes in your editors as needed.

---

## License

MIT
