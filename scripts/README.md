# Scripts Directory Structure

A clean, organized collection of shell utilities and development tools.

## 📁 Directory Organization

```
scripts/
├── core/                    # Production utilities (sourced by .zshrc)
│   ├── functions.zsh       # Interactive shell functions
│   └── utils.sh           # Core utility functions
├── completions/            # Shell completions (sourced by .zshrc)
│   ├── _functions.zsh     # Completions for custom functions
│   └── _utils.sh          # Completions for utility functions
├── maintenance/            # System maintenance scripts (not sourced)
│   ├── maintenance.sh     # System cleanup and maintenance
│   ├── maintenance.crontab # Cron job configuration
│   └── com.maintenance.cleanup.plist # LaunchAgent plist
└── dev/                    # Development and testing tools (not sourced)
    ├── test_functions.zsh  # Unit tests for functions.zsh
    ├── test_utils.sh      # Unit tests for utils.sh
    └── README_TESTING.md  # Testing documentation
```

## 🔄 Sourcing Strategy

The `.zshrc` configuration follows a **selective sourcing** approach:

```zsh
# Only source core utilities and completions
for script in "$ZSH_SCRIPTS_DIR"/**/*.(sh|zsh); do
    [[ "$script" == *"/core/"* || "$script" == *"/completions/"* ]] && \
    [[ -r "$script" ]] && source "$script"
done
```

### ✅ Sourced Directories
- `core/` - Production utilities available in all shell sessions
- `completions/` - Tab completions for custom functions

### ❌ Excluded Directories
- `maintenance/` - System maintenance scripts (run manually or via cron)
- `dev/` - Development and testing tools (not needed in shell sessions)

## 🎯 Core Utilities

### `core/functions.zsh`
Interactive shell functions for daily use:
- `kp <port>` - Kill process by port number
- `clc` - Copy last command output to clipboard
- `--` - Navigate backward in directory history
- `++` - Navigate forward in directory history

### `core/utils.sh`
POSIX-compliant utility functions:
- `log <level> <message>` - Structured logging
- `parse_args "$@"` - Command-line argument parsing
- `safe_symlink <source> <target>` - Safe symbolic link creation
- `backup_file <file>` - Create timestamped backups
- `spinner <message> <command>` - Animated command execution
- `run_or_fail <command> <error_msg>` - Command execution with error handling

## 🧪 Development Tools

### Running Tests
```bash
# Test core utilities
cd scripts/dev && ./test_utils.sh

# Test shell functions
cd scripts/dev && zsh ./test_functions.zsh

# Run all tests
cd scripts/dev && ./test_utils.sh && zsh ./test_functions.zsh
```

### Test Coverage
- **30 unit tests** covering all core functionality
- **100% pass rate** with comprehensive error handling
- **Isolated test environments** prevent interference

## 🔧 Maintenance

### Manual Execution
```bash
# Run system maintenance
cd scripts/maintenance && ./maintenance.sh

# Debug mode
cd scripts/maintenance && DEBUG=true ./maintenance.sh
```

### Automated Execution
- **Cron job**: Weekly execution via `maintenance.crontab`
- **LaunchAgent**: macOS-specific automation via `com.maintenance.cleanup.plist`

## 📊 Quality Assurance

### CI/CD Integration
- **POSIX compliance** testing with shellcheck
- **Cross-platform** compatibility (macOS, Linux)
- **Security scanning** for vulnerabilities
- **Performance monitoring** and resource usage

### Code Standards
- **KISS principle**: Functions under 50 lines
- **Single responsibility**: Each function has one clear purpose
- **Comprehensive documentation**: Swift-style docstrings
- **Error handling**: Proper validation and failure modes

## 🎨 Architecture Benefits

### Clean Separation
- **Production code** isolated from development tools
- **No accidental sourcing** of test or maintenance scripts
- **Clear dependencies** between components

### Maintainability
- **Modular design** enables easy testing and debugging
- **Logical organization** improves discoverability
- **Consistent patterns** across all components

### Performance
- **Selective sourcing** reduces shell startup time
- **Compiled completions** for faster tab completion
- **Lazy loading** of heavy operations

---

*This directory structure embodies clean architecture principles, ensuring maintainable, testable, and performant shell utilities.*