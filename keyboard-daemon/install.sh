#!/bin/sh

set -e

AGENT_NAME="keyboard_daemon"
PLIST_NAME="com.local.keyboard_agent.plist"
DAEMON_PLIST_NAME="com.local.keyboard_daemon.plist"
INSTALL_DIR="$HOME/.local/bin"
DAEMON_INSTALL_DIR="/usr/local/bin"
PLIST_DIR="$HOME/Library/LaunchAgents"
DAEMON_PLIST_DIR="/Library/LaunchDaemons"

echo "Keyboard Agent Installer"
echo "========================="
echo

# Show usage if help requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [--daemon]"
    echo
    echo "Options:"
    echo "  (no args)  Install as LaunchAgent (user-level service)"
    echo "  --daemon   Install as LaunchDaemon (system-level service, requires sudo)"
    echo "  --help     Show this help message"
    echo
    echo "LaunchAgent vs LaunchDaemon:"
    echo "  LaunchAgent: Runs when user is logged in, uses user permissions"
    echo "  LaunchDaemon: Runs at system startup, uses root permissions"
    echo
    exit 0
fi

# Determine installation type
if [ "$1" = "--daemon" ]; then
    echo "Installing as LaunchDaemon (system-level service)"
    USE_DAEMON=true
    CURRENT_PLIST_NAME="$DAEMON_PLIST_NAME"
    CURRENT_INSTALL_DIR="$DAEMON_INSTALL_DIR"
    CURRENT_PLIST_DIR="$DAEMON_PLIST_DIR"
    REQUIRES_SUDO=true
else
    echo "Installing as LaunchAgent (user-level service)"
    USE_DAEMON=false
    CURRENT_PLIST_NAME="$PLIST_NAME"
    CURRENT_INSTALL_DIR="$INSTALL_DIR"
    CURRENT_PLIST_DIR="$PLIST_DIR"
    REQUIRES_SUDO=false
fi
echo

# Check if Xcode command line tools are installed
if ! command -v clang >/dev/null 2>&1; then
    echo "Error: Xcode command line tools not found."
    echo "Please install them by running: xcode-select --install"
    exit 1
fi

# Build the agent
echo "Building the agent..."
make clean
make

if [ ! -f "$AGENT_NAME" ]; then
    echo "Error: Failed to build the agent."
    exit 1
fi

# Move binary to install location
echo "Moving binary to install location..."
if [ "$REQUIRES_SUDO" = true ]; then
    sudo cp "$AGENT_NAME" "$CURRENT_INSTALL_DIR/"
    sudo chmod 755 "$CURRENT_INSTALL_DIR/$AGENT_NAME"
else
    cp "$AGENT_NAME" "$CURRENT_INSTALL_DIR/"
    chmod 755 "$CURRENT_INSTALL_DIR/$AGENT_NAME"
fi

echo "Build successful."
echo

# Check if agent is already running and stop it
if launchctl list | grep -q keyboard_agent; then
    if [ "$USE_DAEMON" = true ]; then
        echo "Stopping existing daemon..."
    else
        echo "Stopping existing agent..."
    fi
    if [ "$REQUIRES_SUDO" = true ]; then
        sudo launchctl unload "$CURRENT_PLIST_DIR/$CURRENT_PLIST_NAME" 2>/dev/null || true
    else
        launchctl unload "$CURRENT_PLIST_DIR/$CURRENT_PLIST_NAME" 2>/dev/null || true
    fi
    sleep 1
fi
if launchctl list | grep -q keyboard_daemon; then
    if [ "$USE_DAEMON" = true ]; then
        echo "Stopping existing daemon..."
    else
        echo "Stopping existing agent..."
    fi
    if [ "$REQUIRES_SUDO" = true ]; then
        sudo launchctl unload "$CURRENT_PLIST_DIR/$CURRENT_PLIST_NAME" 2>/dev/null || true
    else
        launchctl unload "$CURRENT_PLIST_DIR/$CURRENT_PLIST_NAME" 2>/dev/null || true
    fi
    sleep 1
fi

# Create directories if they don't exist
mkdir -p "$INSTALL_DIR"
if [ "$REQUIRES_SUDO" = true ]; then
    sudo mkdir -p "$CURRENT_INSTALL_DIR"
    sudo mkdir -p "$CURRENT_PLIST_DIR"
    sudo mkdir -p "/var/log"
else
    mkdir -p "$CURRENT_INSTALL_DIR"
    mkdir -p "$CURRENT_PLIST_DIR"
    mkdir -p "$HOME/Library/Logs"
fi

# Install the agent
if [ "$USE_DAEMON" = true ]; then
    echo "Installing daemon..."
else
    echo "Installing agent..."
fi
# Set permissions on the binary
if [ "$USE_DAEMON" = true ] && [ "$REQUIRES_SUDO" = true ]; then
    sudo chmod 755 "$CURRENT_INSTALL_DIR/$AGENT_NAME"
    sudo cp "$CURRENT_PLIST_NAME" "$CURRENT_PLIST_DIR/"
else
    chmod 755 "$CURRENT_INSTALL_DIR/$AGENT_NAME"
    if [ "$REQUIRES_SUDO" = true ]; then
        sudo cp "$CURRENT_PLIST_NAME" "$CURRENT_PLIST_DIR/"
    else
        cp "$CURRENT_PLIST_NAME" "$CURRENT_PLIST_DIR/"
    fi
fi

echo "Installation complete."
echo

# Load the agent
if [ "$USE_DAEMON" = true ]; then
    echo "Starting daemon..."
else
    echo "Starting agent..."
fi
if [ "$REQUIRES_SUDO" = true ]; then
    sudo launchctl load "$CURRENT_PLIST_DIR/$CURRENT_PLIST_NAME"
else
    launchctl load "$CURRENT_PLIST_DIR/$CURRENT_PLIST_NAME"
fi

# Check if agent started successfully
sleep 2
if [ "$USE_DAEMON" = true ]; then
    CHECK_NAME="keyboard_daemon"
    LOG_PATH="/var/log/keyboard_daemon.log"
else
    CHECK_NAME="keyboard_agent"
    LOG_PATH="$HOME/Library/Logs/keyboard_daemon.log"
fi

if launchctl list | grep -q "$CHECK_NAME"; then
    if [ "$USE_DAEMON" = true ]; then
        echo "Daemon started successfully!"
    else
        echo "Agent started successfully!"
    fi
else
    if [ "$USE_DAEMON" = true ]; then
        echo "Warning: Daemon may not have started properly."
    else
        echo "Warning: Agent may not have started properly."
    fi
    echo "Check logs with: tail -f $LOG_PATH"
fi

echo
echo "IMPORTANT SETUP INSTRUCTIONS:"
echo "=============================="
echo
if [ "$USE_DAEMON" = true ]; then
    echo "The daemon requires Input Monitoring permissions to function."
else
    echo "The agent requires Input Monitoring permissions to function."
fi
echo "Please follow these steps:"
echo
echo "1. Open System Preferences (or System Settings on newer macOS)"
echo "2. Go to Security & Privacy > Privacy (or Privacy & Security)"
echo "3. Select 'Input Monitoring' from the left panel"
echo "4. Click the lock icon to make changes (enter your password)"
echo "5. Click the '+' button and navigate to:"
echo "   $CURRENT_INSTALL_DIR/$AGENT_NAME"
if [ "$USE_DAEMON" = true ]; then
    echo "6. Add the daemon to the list and ensure it's checked"
else
    echo "6. Add the agent to the list and ensure it's checked"
fi
echo
if [ "$USE_DAEMON" = true ]; then
    echo "After granting permissions, restart the daemon:"
else
    echo "After granting permissions, restart the agent:"
fi
if [ "$REQUIRES_SUDO" = true ]; then
    echo "   sudo launchctl unload $CURRENT_PLIST_DIR/$CURRENT_PLIST_NAME"
    echo "   sudo launchctl load $CURRENT_PLIST_DIR/$CURRENT_PLIST_NAME"
else
    echo "   launchctl unload $CURRENT_PLIST_DIR/$CURRENT_PLIST_NAME"
    echo "   launchctl load $CURRENT_PLIST_DIR/$CURRENT_PLIST_NAME"
fi
echo
echo "Usage:"
echo "------"
echo "Caps Lock:"
echo "• Quick press Caps Lock: Sends Escape"
echo "• Hold Caps Lock (>500ms): Acts as Control"
echo "• Caps Lock + other key: Acts as Control"
echo ""
echo "Right-Option App Launching:"
echo "• Right-Option + G: Launch Ghosty"
echo "• Right-Option + S: Launch Safari"
echo "• Right-Option + N: Launch Notes"
echo "• Right-Option + R: Launch Reminders"
echo "• Right-Option + M: Launch Music"
echo "• Right-Option + T: Launch Terminal"
echo "• Right-Option + X: Launch Xcode"
echo ""
echo "Right-Option Scrolling:"
echo "• Right-Option + H: Scroll left"
echo "• Right-Option + J: Scroll down"
echo "• Right-Option + K: Scroll up"
echo "• Right-Option + L: Scroll right"
echo
echo "Management commands:"
echo "• Start:   make start"
echo "• Stop:    make stop"
echo "• Restart: make restart"
echo "• Status:  make status"
echo "• Logs:    make logs"
echo "• Remove:  make uninstall"
echo
