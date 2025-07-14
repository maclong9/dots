CC = clang
CFLAGS = -Wall -Wextra -O2 -std=c99
FRAMEWORKS = -framework IOKit -framework CoreFoundation -framework ApplicationServices
TARGET = keyboard_daemon
SOURCE = keyboard_daemon.c
INSTALL_PATH = $(HOME)/.local/bin
PLIST_SOURCE = com.local.keyboard_daemon.plist
PLIST_DEST = $(HOME)/Library/LaunchAgents/com.local.keyboard_daemon.plist

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) $(FRAMEWORKS) -o $(TARGET) $(SOURCE)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	@echo "Installing Keyboard daemon..."
	@mkdir -p $(INSTALL_PATH)
	@mkdir -p $(HOME)/Library/LaunchAgents
	@mkdir -p $(HOME)/Library/Logs
	cp $(TARGET) $(INSTALL_PATH)/
	chmod 755 $(INSTALL_PATH)/$(TARGET)
	cp $(PLIST_SOURCE) $(PLIST_DEST)
	@echo "Installation complete."
	@echo "To start the daemon, run: launchctl load $(PLIST_DEST)"
	@echo "The daemon will start automatically on login."
	@echo ""
	@echo "IMPORTANT: You may need to grant Input Monitoring permissions:"
	@echo "1. Go to System Preferences > Security & Privacy > Privacy"
	@echo "2. Select 'Input Monitoring' from the left panel"
	@echo "3. Add $(INSTALL_PATH)/keyboard_daemon to the list"

uninstall:
	@echo "Uninstalling Keyboard daemon..."
	launchctl unload $(PLIST_DEST) 2>/dev/null || true
	rm -f $(INSTALL_PATH)/$(TARGET)
	rm -f $(PLIST_DEST)
	@echo "Uninstallation complete."

start:
	@launchctl list | grep -q keyboard_daemon && echo "Daemon already running" || launchctl load $(PLIST_DEST)

stop:
	launchctl unload $(PLIST_DEST)

restart: stop start

status:
	@launchctl list | grep keyboard_daemon && echo "Daemon is running" || echo "Daemon not running"

logs:
	@tail -f $(HOME)/Library/Logs/keyboard_daemon.log
