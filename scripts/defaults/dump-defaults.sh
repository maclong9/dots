#!/bin/sh
# dump-defaults.sh
# Dumps macOS settings to "$HOME/.config/scripts/defaults/settings"

OUT_DIR="$HOME/.config/scripts/defaults/settings"
mkdir -p "$OUT_DIR"

DOMAINS="
com.apple.dock
com.apple.finder
com.apple.controlcenter
NSGlobalDomain
com.apple.universalaccess
com.apple.systempreferences
com.apple.preference.displays
com.apple.screensaver
com.apple.HIToolbox
com.apple.driver.AppleBluetoothMultitouch.trackpad
com.apple.preference.security
"

for domain in $DOMAINS; do
  file="$(echo "$domain" | tr '.' '-')".plist
  echo "Dumping $domain..."
  defaults export "$domain" "$OUT_DIR/$file" 2>/dev/null
done

echo "Done. Files saved to: $OUT_DIR"

