# macOS Keyboard agent

A lightweight C agent that provides enhanced keyboard functionality on macOS:

## Caps Lock Behavior
- **Quick press** (<500ms): Sends Escape key
- **Hold** (≥500ms): Acts as Control key  
- **Combo** (Caps + other key): Acts as Control key

## Right-Option App Launching
- **Right-Option + G**: Launch Ghosty.app
- **Right-Option + S**: Launch Safari.app
- **Right-Option + N**: Launch Notes.app
- **Right-Option + R**: Launch Reminders.app
- **Right-Option + M**: Launch Music.app
- **Right-Option + T**: Launch Terminal.app
- **Right-Option + X**: Launch Xcode.app

## Right-Option Scrolling
- **Right-Option + H**: Scroll left
- **Right-Option + J**: Scroll down
- **Right-Option + K**: Scroll up
- **Right-Option + L**: Scroll right

## Features

- Low-level IOKit HID integration for reliable key interception
- Precise timing detection using mach kernel timing
- Virtual key injection and scroll event generation via Core Graphics Events
- App launching via system commands
- Runs as system Launchagent with user privileges
- Comprehensive logging and error handling

## Installation

1. Navigate to this directory:
   ```sh
   cd keyboard_agent
   ```

2. Build and install the agent:
   ```sh
   make install
   ```

3. Grant Input Monitoring permissions:
   - Open System Preferences > Security & Privacy > Privacy
   - Select "Input Monitoring" 
   - Add `~/.local/bin/keyboard_agent` to the list

4. Start the agent:
   ```sh
   make start
   ```

## Usage Commands

```sh
make install    # Build and install agent
make start      # Start the agent
make stop       # Stop the agent  
make restart    # Restart the agent
make status     # Check agent status
make logs       # View agent logs
make uninstall  # Remove agent completely
```

## Files

- `keyboard_agent.c` - Main agent source code
- `com.local.keyboard_agent.plist` - Launchagent configuration
- `Makefile` - Build and management commands

## Technical Details

- Uses IOKit HID Manager for keyboard event interception
- Implements mach_absolute_time() for precise timing measurements
- CGEventCreateKeyboardEvent() for virtual key injection
- CGEventCreateScrollWheelEvent() for scroll event generation
- Uses system() calls for app launching
- Runs as system Launchagent for system-wide keyboard access
- Logs to `/var/log/keyboard_agent.log` and syslog

## Troubleshooting

- **agent not starting**: Check permissions and Input Monitoring access
- **Keys not working**: Verify agent is running with `make status`
- **App launching not working**: Ensure applications are installed and accessible
- **Scrolling not working**: Check for conflicting scroll settings in System Preferences
- **Permission denied**: Ensure agent has Input Monitoring permissions
- **Build errors**: Install Xcode command line tools: `xcode-select --install`

> [!NOTE]
> If everything seems in order and it's still not working try running `make uninstall` and then `make install && make start` this should reset everything correctly.

## Compatibility

- macOS 10.12+ (Sierra and later)
- Requires Input Monitoring permissions (macOS 10.15+)
- Compatible with external and built-in keyboards
