#!/bin/bash

set -e

DAEMON_NAME="caps_lock_daemon"
PLIST_NAME="com.local.capslockdaemon.plist"
INSTALL_DIR="/usr/local/bin"
PLIST_DIR="/Library/LaunchDaemons"

echo "Caps Lock Daemon Installer"
echo "=========================="
echo

# Check if running as root for installation
if [[ $EUID -eq 0 ]]; then
    echo "Please do not run this script as root."
    echo "The script will ask for sudo permissions when needed."
    exit 1
fi

# Check if Xcode command line tools are installed
if ! command -v clang &> /dev/null; then
    echo "Error: Xcode command line tools not found."
    echo "Please install them by running: xcode-select --install"
    exit 1
fi

# Build the daemon
echo "Building the daemon..."
make clean
make

if [[ ! -f "$DAEMON_NAME" ]]; then
    echo "Error: Failed to build the daemon."
    exit 1
fi

echo "Build successful."
echo

# Check if daemon is already running and stop it
if sudo launchctl list | grep -q capslockdaemon; then
    echo "Stopping existing daemon..."
    sudo launchctl unload "$PLIST_DIR/$PLIST_NAME" 2>/dev/null || true
    sleep 1
fi

# Install the daemon
echo "Installing daemon..."
sudo cp "$DAEMON_NAME" "$INSTALL_DIR/"
sudo chmod 755 "$INSTALL_DIR/$DAEMON_NAME"
sudo cp "$PLIST_NAME" "$PLIST_DIR/"
sudo chmod 644 "$PLIST_DIR/$PLIST_NAME"
sudo chown root:wheel "$PLIST_DIR/$PLIST_NAME"

echo "Installation complete."
echo

# Load the daemon
echo "Starting daemon..."
sudo launchctl load "$PLIST_DIR/$PLIST_NAME"

# Check if daemon started successfully
sleep 2
if sudo launchctl list | grep -q capslockdaemon; then
    echo "Daemon started successfully!"
else
    echo "Warning: Daemon may not have started properly."
    echo "Check logs with: tail -f /var/log/caps_lock_daemon.log"
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
echo "   sudo launchctl unload $PLIST_DIR/$PLIST_NAME"
echo "   sudo launchctl load $PLIST_DIR/$PLIST_NAME"
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