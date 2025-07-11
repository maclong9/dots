#!/bin/sh

set -e

DAEMON_NAME="caps_lock_daemon"
PLIST_NAME="com.local.capslockdaemon.plist"
INSTALL_DIR="$HOME/.local/bin"
PLIST_DIR="$HOME/Library/LaunchAgents"

echo "Caps Lock Daemon Installer"
echo "=========================="
echo

# This script installs the daemon as a LaunchAgent (user-level service)

# Check if Xcode command line tools are installed
if ! command -v clang >/dev/null 2>&1; then
    echo "Error: Xcode command line tools not found."
    echo "Please install them by running: xcode-select --install"
    exit 1
fi

# Build the daemon
echo "Building the daemon..."
make clean
make

if [ ! -f "$DAEMON_NAME" ]; then
    echo "Error: Failed to build the daemon."
    exit 1
fi

echo "Build successful."
echo

# Check if daemon is already running and stop it
if launchctl list | grep -q capslockdaemon; then
    echo "Stopping existing daemon..."
    launchctl unload "$PLIST_DIR/$PLIST_NAME" 2>/dev/null || true
    sleep 1
fi

# Create directories if they don't exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$PLIST_DIR"
mkdir -p "$HOME/Library/Logs"

# Install the daemon
echo "Installing daemon..."
cp "$DAEMON_NAME" "$INSTALL_DIR/"
chmod 755 "$INSTALL_DIR/$DAEMON_NAME"
cp "$PLIST_NAME" "$PLIST_DIR/"

echo "Installation complete."
echo

# Load the daemon
echo "Starting daemon..."
launchctl load "$PLIST_DIR/$PLIST_NAME"

# Check if daemon started successfully
sleep 2
if launchctl list | grep -q capslockdaemon; then
    echo "Daemon started successfully!"
else
    echo "Warning: Daemon may not have started properly."
    echo "Check logs with: tail -f $HOME/Library/Logs/caps_lock_daemon.log"
fi

echo
echo "IMPORTANT SETUP INSTRUCTIONS:"
echo "=============================="
echo
echo "The daemon requires Input Monitoring permissions to function."
echo "Please follow these steps:"
echo
echo "1. Open System Preferences (or System Settings on newer macOS)"
echo "2. Go to Security & Privacy > Privacy (or Privacy & Security)"
echo "3. Select 'Input Monitoring' from the left panel"
echo "4. Click the lock icon to make changes (enter your password)"
echo "5. Click the '+' button and navigate to:"
echo "   $INSTALL_DIR/$DAEMON_NAME"
echo "6. Add the daemon to the list and ensure it's checked"
echo
echo "After granting permissions, restart the daemon:"
echo "   launchctl unload $PLIST_DIR/$PLIST_NAME"
echo "   launchctl load $PLIST_DIR/$PLIST_NAME"
echo
echo "Usage:"
echo "------"
echo "• Quick press Caps Lock: Sends Escape"
echo "• Hold Caps Lock (>500ms): Acts as Control"
echo "• Caps Lock + other key: Acts as Control"
echo
echo "Management commands:"
echo "• Start:   make start"
echo "• Stop:    make stop"
echo "• Restart: make restart"
echo "• Status:  make status"
echo "• Logs:    make logs"
echo "• Remove:  make uninstall"
echo
