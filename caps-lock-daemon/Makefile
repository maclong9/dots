CC = clang
CFLAGS = -Wall -Wextra -O2 -std=c99
FRAMEWORKS = -framework IOKit -framework CoreFoundation -framework ApplicationServices
TARGET = caps_lock_daemon
SOURCE = caps_lock_daemon.c
INSTALL_PATH = /usr/local/bin
PLIST_SOURCE = com.local.capslockdaemon.plist
PLIST_DEST = /Library/LaunchDaemons/com.local.capslockdaemon.plist

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) $(FRAMEWORKS) -o $(TARGET) $(SOURCE)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	@echo "Installing Caps Lock daemon..."
	sudo cp $(TARGET) $(INSTALL_PATH)/
	sudo chmod 755 $(INSTALL_PATH)/$(TARGET)
	sudo cp $(PLIST_SOURCE) $(PLIST_DEST)
	sudo chmod 644 $(PLIST_DEST)
	sudo chown root:wheel $(PLIST_DEST)
	@echo "Installation complete."
	@echo "To start the daemon, run: sudo launchctl load $(PLIST_DEST)"
	@echo "To enable at boot, the daemon is already configured to start automatically."
	@echo ""
	@echo "IMPORTANT: You may need to grant Input Monitoring permissions:"
	@echo "1. Go to System Preferences > Security & Privacy > Privacy"
	@echo "2. Select 'Input Monitoring' from the left panel"
	@echo "3. Add /usr/local/bin/caps_lock_daemon to the list"

uninstall:
	@echo "Uninstalling Caps Lock daemon..."
	sudo launchctl unload $(PLIST_DEST) 2>/dev/null || true
	sudo rm -f $(INSTALL_PATH)/$(TARGET)
	sudo rm -f $(PLIST_DEST)
	@echo "Uninstallation complete."

start:
	@sudo launchctl list | grep -q capslockdaemon && echo "Daemon already running" || sudo launchctl load $(PLIST_DEST)

stop:
	sudo launchctl unload $(PLIST_DEST)

restart: stop start

status:
	@sudo launchctl list | grep capslockdaemon && echo "Daemon is running" || echo "Daemon not running"

logs:
	@tail -f /var/log/caps_lock_daemon.log
