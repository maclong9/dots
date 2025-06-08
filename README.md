# macOS Development Configuration

A streamlined macOS development environment using standard `.config` directory structure with `mise` for tool management.

## Quick Start

## Automated

```sh
curl -fsSl https://raw.githubusercontent.com/maclong9/dots/refs/heads/main/setup.sh | sh
```

## Manually
1. **Clone this repository:**
   ```sh
   git clone https://github.com/maclong9/dots ~/.config
   cd ~/.config
   ```

2. **Run the setup script:**
   ```sh
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Restart your terminal** or run:
   ```sh
   source ~/.zshrc
   ```

## What Gets Installed

### Applications (via DMG)
- **Ghostty** - Modern terminal emulator
- **OrbStack** - Docker Desktop alternative for macOS

### Development Tools (via mise)
- **Deno** - Modern JavaScript/TypeScript runtime
- **Jujitsu (jj)** - Next-generation version control
- **GitHub CLI (gh)** - GitHub command-line interface
- **Helix (hx)** - Modal text editor with LSP support
- **bat** - Enhanced `cat` command
- **shellcheck** - Shell script linter
- **shfmt** - Shell formatter
- **Node.js 20** with npm packages:
  - `@anthropic-ai/claude-code` - AI coding assistant
  - `eslint`, `prettier` - Code linting and formatting
  - `typescript` and language server
  - `@tailwindcss/language-server`

### Swift Package Manager Tools
- **maclong9/list** - UNIX `ls` clone written in Swift

### Shell Configuration
- **ZSH** with plugins:
  - `zsh-autosuggestions` - Command suggestions
  - `zsh-syntax-highlighting` - Syntax highlighting
  - `zsh-autocomplete` - Tab completion
  - `zsh-completions` - Additional completions

## Directory Structure

```
~/Developer/
├── personal/     # Personal projects
├── clients/      # Freelance client work
├── study/        # Learning projects
└── work/         # Work repositories
```

## Key Features

### Helix Editor
- **Readline-style keybindings** in insert mode
- **LSP support** for multiple languages
- **Relative line numbers** and modern UI
- **Window navigation** with Ctrl+hjkl

### Jujutsu Version Control
- **SSH signing** enabled by default
- **Conditional configuration** for work repositories

### ZSH Shell
- **Custom prompt** with Git integration
- **Comprehensive aliases** for development
- **Plugin management** with local installations
