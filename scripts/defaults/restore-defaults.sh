#!/bin/sh
# restore-defaults.sh
# Restores settings from "$HOME/.config/scripts/defaults/settings"

IN_DIR="$HOME/.config/scripts/defaults/settings"

for file in "$IN_DIR"/*.plist; do
  [ -f "$file" ] || continue
  domain="$(basename "$file" .plist | tr '-' '.')"
  echo "Importing $domain..."
  defaults import "$domain" "$file"
done

# Restart affected services
killall Dock 2>/dev/null
killall Finder 2>/dev/null
killall SystemUIServer 2>/dev/null

echo "Defaults restored from: $IN_DIR"

