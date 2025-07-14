#!/bin/sh

set -e

AGENT_NAME="keyboard_agent"
PLIST_NAME="com.local.keyboard_agent.plist"
INSTALL_DIR="$HOME/.local/bin"
PLIST_DIR="$HOME/Library/LaunchAgents"

echo "Keyboard Agent Installer"
echo "========================="
echo

# This script installs the agent as a LaunchAgent (user-level service)

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

echo "Build successful."
echo

# Check if agent is already running and stop it
if launchctl list | grep -q keyboard_agent; then
    echo "Stopping existing agent..."
    launchctl unload "$PLIST_DIR/$PLIST_NAME" 2>/dev/null || true
    sleep 1
fi

# Create directories if they don't exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$PLIST_DIR"
mkdir -p "$HOME/Library/Logs"

# Install the agent
echo "Installing agent..."
cp "$AGENT_NAME" "$INSTALL_DIR/"
chmod 755 "$INSTALL_DIR/$AGENT_NAME"
cp "$PLIST_NAME" "$PLIST_DIR/"

echo "Installation complete."
echo

# Load the agent
echo "Starting agent..."
launchctl load "$PLIST_DIR/$PLIST_NAME"

# Check if agent started successfully
sleep 2
if launchctl list | grep -q keyboard_agent; then
    echo "Agent started successfully!"
else
    echo "Warning: Agent may not have started properly."
    echo "Check logs with: tail -f $HOME/Library/Logs/keyboard_agent.log"
fi

echo
echo "IMPORTANT SETUP INSTRUCTIONS:"
echo "=============================="
echo
echo "The agent requires Input Monitoring permissions to function."
echo "Please follow these steps:"
echo
echo "1. Open System Preferences (or System Settings on newer macOS)"
echo "2. Go to Security & Privacy > Privacy (or Privacy & Security)"
echo "3. Select 'Input Monitoring' from the left panel"
echo "4. Click the lock icon to make changes (enter your password)"
echo "5. Click the '+' button and navigate to:"
echo "   $INSTALL_DIR/$AGENT_NAME"
echo "6. Add the agent to the list and ensure it's checked"
echo
echo "After granting permissions, restart the agent:"
echo "   launchctl unload $PLIST_DIR/$PLIST_NAME"
echo "   launchctl load $PLIST_DIR/$PLIST_NAME"
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
