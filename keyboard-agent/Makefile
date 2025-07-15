CC = clang
CFLAGS = -Wall -Wextra -O2 -std=c99
FRAMEWORKS = -framework IOKit -framework CoreFoundation -framework ApplicationServices
TARGET = keyboard_agent
SOURCE = keyboard_agent.c
INSTALL_PATH = $(HOME)/.local/bin
PLIST_SOURCE = com.local.keyboard_agent.plist
PLIST_DEST = $(HOME)/Library/LaunchAgents/com.local.keyboard_agent.plist

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) $(FRAMEWORKS) -o $(TARGET) $(SOURCE)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	@echo "Installing Keyboard agent..."
	@mkdir -p $(INSTALL_PATH)
	@mkdir -p $(dir $(PLIST_DEST))
	@mkdir -p /tmp
	cp $(TARGET) $(INSTALL_PATH)/
	chmod 755 $(INSTALL_PATH)/$(TARGET)
	cp $(PLIST_SOURCE) $(PLIST_DEST)
	@echo "Installation complete."
	@echo "To start the agent, run: launchctl load $(PLIST_DEST)"
	@echo "The agent will start automatically on login."
	@echo ""
	@echo "IMPORTANT: You may need to grant Input Monitoring permissions:"
	@echo "1. Go to System Preferences > Security & Privacy > Privacy"
	@echo "2. Select 'Input Monitoring' from the left panel"
	@echo "3. Add $(INSTALL_PATH)/keyboard_agent to the list"

uninstall:
	@echo "Uninstalling Keyboard agent..."
	launchctl unload $(PLIST_DEST) 2>/dev/null || true
	rm -f $(INSTALL_PATH)/$(TARGET)
	rm -f $(PLIST_DEST)
	@echo "Uninstallation complete."

start:
	@launchctl list | grep -q keyboard_agent && echo "Agent already running" || launchctl load $(PLIST_DEST)

stop:
	launchctl unload $(PLIST_DEST)

restart: stop start

status:
	@launchctl list | grep keyboard_agent && echo "Agent is running" || echo "Agent not running"

logs:
	@tail -f /tmp/keyboard_agent.log
