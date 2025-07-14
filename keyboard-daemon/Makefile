CC = clang
CFLAGS = -Wall -Wextra -O2 -std=c99
FRAMEWORKS = -framework IOKit -framework CoreFoundation -framework ApplicationServices
TARGET = keyboard_daemon
SOURCE = keyboard_daemon.c
INSTALL_PATH = /usr/local/bin
PLIST_SOURCE = com.local.keyboard_daemon.plist
PLIST_DEST = /Library/LaunchDaemons/com.local.keyboard_daemon.plist

all: $(TARGET)

$(TARGET): $(SOURCE)
	@sudo mkdir -p $(INSTALL_PATH)
	$(CC) $(CFLAGS) $(FRAMEWORKS) -o $(TARGET) $(SOURCE)

clean:
	sudo rm -f $(INSTALL_PATH)/$(TARGET)

install: $(TARGET)
	@echo "Installing Keyboard daemon..."
	@sudo mkdir -p $(dir $(PLIST_DEST))
	@sudo mkdir -p /var/log
	sudo cp $(TARGET) $(INSTALL_PATH)/
	sudo chmod 755 $(INSTALL_PATH)/$(TARGET)
	sudo cp $(PLIST_SOURCE) $(PLIST_DEST)
	@echo "Installation complete."
	@echo "To start the daemon, run: sudo launchctl load $(PLIST_DEST)"
	@echo "The daemon will start automatically on boot."
	@echo ""
	@echo "IMPORTANT: You may need to grant Input Monitoring permissions:"
	@echo "1. Go to System Preferences > Security & Privacy > Privacy"
	@echo "2. Select 'Input Monitoring' from the left panel"
	@echo "3. Add $(INSTALL_PATH)/keyboard_daemon to the list"

uninstall:
	@echo "Uninstalling Keyboard daemon..."
	sudo launchctl unload $(PLIST_DEST) 2>/dev/null || true
	sudo rm -f $(INSTALL_PATH)/$(TARGET)
	sudo rm -f $(PLIST_DEST)
	@echo "Uninstallation complete."

start:
	@sudo launchctl list | grep -q keyboard_daemon && echo "Daemon already running" || sudo launchctl load $(PLIST_DEST)

stop:
	sudo launchctl unload $(PLIST_DEST)

restart: stop start

status:
	@sudo launchctl list | grep keyboard_daemon && echo "Daemon is running" || echo "Daemon not running"

logs:
	@sudo tail -f /var/log/keyboard_daemon.log
