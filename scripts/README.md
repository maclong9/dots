# 📜 Scripts Collection

Shell utilities and development tools organized for maintainability and performance.

## 📁 Directory Structure

```
scripts/
├── core/                             # Production utilities (sourced by .zshrc)
│   ├── functions.zsh                   # Interactive shell functions
│   └── utils.sh                        # Core utility functions
├── completions/                      # Shell completions (sourced by .zshrc)
│   ├── _functions.zsh                  # Completions for custom functions
│   └── _utils.sh                       # Completions for utility functions
├── maintenance/                      # System maintenance scripts (not sourced)
│   ├── maintenance.sh                  # System cleanup and maintenance
│   ├── maintenance.crontab             # Cron job configuration
│   └── com.maintenance.cleanup.plist   # LaunchAgent plist
└── dev/                              # Development and testing tools (not sourced)
    ├── test_functions.zsh              # Unit tests for functions.zsh
    └── test_utils.sh                   # Unit tests for utils.sh
```

## 🎯 Core Functions

### Interactive Shell Functions (`core/functions.zsh`)
- `kp <port>` - Kill process by port number
- `clc` - Copy last command output to clipboard
- `--` - Navigate backward in directory history
- `++` - Navigate forward in directory history

### Utility Functions (`core/utils.sh`)
POSIX-compliant helpers for scripts and automation:
- `log <level> <message>` - Structured logging with timestamps
- `parse_args "$@"` - Command-line argument parsing
- `safe_symlink <source> <target>` - Safe symbolic link creation with validation
- `backup_file <file>` - Create timestamped backups before modifications
- `spinner <message> <command>` - Animated command execution with status
- `run_or_fail <command> <error_msg>` - Command execution with proper error handling

## 🧪 Testing

```bash
# Test core utilities
cd scripts/dev && ./test_utils.sh

# Test shell functions  
cd scripts/dev && zsh ./test_functions.zsh

# Run all tests
cd scripts/dev && ./test_utils.sh && zsh ./test_functions.zsh
```

## 🔧 Maintenance

### Manual Execution
```bash
# Run system maintenance
cd scripts/maintenance && ./maintenance.sh

# Debug mode
cd scripts/maintenance && DEBUG=true ./maintenance.sh
```

### Automated Execution
Weekly automation configured via:
- **Cron job**: `maintenance.crontab` for cross-platform scheduling
- **LaunchAgent**: `com.maintenance.cleanup.plist` for macOS integration

## 🏗️ Architecture

### Design Principles
- **Clean separation**: Production code isolated from development tools
- **Selective sourcing**: Only production utilities loaded in shell startup
- **POSIX compliance**: Cross-platform compatibility (macOS, Linux)
- **Single responsibility**: Each function has one clear purpose

### Quality Standards  
- Functions under 50 lines following KISS principle
- Comprehensive error handling and validation
- Swift-style documentation for all functions
- Shellcheck compliance for security and best practices

