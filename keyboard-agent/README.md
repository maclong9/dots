# ⌨️ macOS Keyboard Agent

A lightweight C agent that enhances keyboard functionality on macOS with precise timing and low-level system integration.

## ✨ Features

### Caps Lock Enhancement
- **Quick press** (<500ms): Sends Escape key
- **Hold** (≥500ms): Acts as Control key  
- **Combo** (Caps + other key): Acts as Control key

### App Launching (Right-Option + Key)
- **S**: Launch Safari.app
- **N**: Launch Notes.app
- **R**: Launch Reminders.app
- **M**: Launch Music.app
- **T**: Launch Terminal.app
- **X**: Launch Xcode.app

### Vim-Style Scrolling (Right-Option + Key)
- **H**: Scroll left
- **J**: Scroll down
- **K**: Scroll up
- **L**: Scroll right

## 🔧 Technical Implementation

- **IOKit HID integration** for reliable key interception
- **Mach kernel timing** for precise timing detection
- **Core Graphics Events** for virtual key injection and scroll generation
- **LaunchAgent architecture** runs with user privileges
- **Comprehensive logging** to `/var/log/keyboard_agent.log` and syslog

## 🚀 Installation

1. **Navigate to directory**:
   ```sh
   cd keyboard_agent
   ```

2. **Build and install**:
   ```sh
   make install
   ```

3. **Grant permissions**:
   - Open System Preferences > Security & Privacy > Privacy
   - Select "Input Monitoring" 
   - Add `~/.local/bin/keyboard_agent` to the list

4. **Start the agent**:
   ```sh
   make start
   ```

## 🛠️ Management Commands

```sh
make install    # Build and install agent
make start      # Start the agent
make stop       # Stop the agent  
make restart    # Restart the agent
make status     # Check agent status
make logs       # View agent logs
make uninstall  # Remove agent completely
```

## 📁 Project Files

- `keyboard_agent.c` - Main agent source code with IOKit integration
- `com.local.keyboard_agent.plist` - LaunchAgent configuration for system integration
- `Makefile` - Build automation and management commands

## 🔍 Troubleshooting

| Issue | Solution |
|-------|----------|
| Agent not starting | Check Input Monitoring permissions |
| Keys not working | Verify agent is running: `make status` |
| Apps not launching | Ensure applications are installed |
| Scrolling issues | Check System Preferences for conflicts |
| Build errors | Install Xcode tools: `xcode-select --install` |

> **Reset everything**: `make uninstall && ./install.sh`

## 💻 Compatibility

- **macOS**: 10.12+ (Sierra and later)
- **Permissions**: Input Monitoring required (macOS 10.15+)
- **Hardware**: Compatible with external and built-in keyboards
