# macOS Caps Lock Daemon

A lightweight C daemon that remaps Caps Lock behavior on macOS:
- **Quick press** (<500ms): Sends Escape key
- **Hold** (≥500ms): Acts as Control key  
- **Combo** (Caps + other key): Acts as Control key

## Features

- Low-level IOKit HID integration for reliable key interception
- Precise timing detection using mach kernel timing
- Virtual key injection via Core Graphics Events
- Runs as user LaunchAgent (no root privileges required)
- Comprehensive logging and error handling

## Installation

1. Navigate to this directory:
   ```sh
   cd caps-lock-daemon
   ```

2. Run the installation script (no sudo required):
   ```sh
   ./install.sh
   ```

3. Grant Input Monitoring permissions:
   - Open System Preferences > Security & Privacy > Privacy
   - Select "Input Monitoring" 
   - Add `~/.local/bin/caps_lock_daemon` to the list

4. Restart the daemon:
   ```sh
   make restart
   ```

## Usage Commands

```sh
make install    # Build and install daemon
make start      # Start the daemon
make stop       # Stop the daemon  
make restart    # Restart the daemon
make status     # Check daemon status
make logs       # View daemon logs
make uninstall  # Remove daemon completely
```

## Files

- `caps_lock_daemon.c` - Main daemon source code
- `com.local.capslockdaemon.plist` - LaunchAgent configuration
- `Makefile` - Build and management commands
- `install.sh` - Automated installation script

## Technical Details

- Uses IOKit HID Manager for keyboard event interception
- Implements mach_absolute_time() for precise timing measurements
- CGEventCreateKeyboardEvent() for virtual key injection
- Runs as user LaunchAgent for system-wide keyboard access
- Logs to `~/Library/Logs/caps_lock_daemon.log` and syslog

## Troubleshooting

- **Daemon not starting**: Check permissions and Input Monitoring access
- **Keys not working**: Verify daemon is running with `make status`
- **Permission denied**: Ensure daemon has Input Monitoring permissions
- **Build errors**: Install Xcode command line tools: `xcode-select --install`

## Compatibility

- macOS 10.12+ (Sierra and later)
- Requires Input Monitoring permissions (macOS 10.15+)
- Compatible with external and built-in keyboards
