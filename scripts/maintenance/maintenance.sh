#!/bin/sh

# System maintenance script for cleaning caches and temporary files

# Load utilities
# shellcheck disable=SC1091
. ../utils.sh

# Calculate sizes before and after cleanup
calculate_size() {
	path="$1"
	[ -d "$path" ] || return 1

	if command -v du >/dev/null 2>&1; then
		du -sh "$path" 2>/dev/null | cut -f1
	else
		echo "0B"
	fi
}

# Clean directory contents but preserve the directory
clean_directory() {
	dir="$1"
	name="$2"

	[ ! -d "$dir" ] && return 0

	size_before=$(calculate_size "$dir")

	if [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
		log info "Cleaning $name ($size_before)"
		rm -rf "${dir:?}"/* "$dir"/.* 2>/dev/null || true
		log success "Cleaned $name"
	else
		log debug "$name already clean"
	fi
}

# Clean individual files matching patterns
clean_files() {
	pattern="$1"
	name="$2"

	count=0
	for file in $pattern; do
		[ -f "$file" ] && {
			rm -f "$file" 2>/dev/null && count=$((count + 1))
		}
	done

	[ "$count" -gt 0 ] && log success "Cleaned $count $name files"
}

# macOS specific cleanup
cleanup_macos() {
	log info "Running macOS-specific cleanup..."

	# User caches
	clean_directory "$HOME/Library/Caches" "user caches"
	clean_directory "$HOME/Library/Application Support/CrashReporter" "crash reports"
	clean_directory "$HOME/Library/Logs" "user logs"
	clean_directory "$HOME/Library/WebKit" "WebKit cache"
	clean_directory "$HOME/Library/Safari/LocalStorage" "Safari local storage"
	clean_directory "$HOME/Library/Safari/Databases" "Safari databases"
	clean_directory "$HOME/Library/Containers/com.apple.Safari/Data/Library/Caches" "Safari container caches"

	# Development caches
	clean_directory "$HOME/Library/Developer/Xcode/DerivedData" "Xcode derived data"
	clean_directory "$HOME/Library/Developer/CoreSimulator/Caches" "iOS Simulator caches"
	clean_directory "$HOME/Library/Caches/com.apple.dt.Xcode" "Xcode caches"

	# System temporary files
	clean_files "/tmp/*" "temporary"
	clean_files "$HOME/.Trash/*" "trash"
	clean_files "$HOME/**/.DS_Store" "DS_Store files"

	# Download folder cleanup (files older than 30 days)
	if [ -d "$HOME/Downloads" ]; then
		find "$HOME/Downloads" -type f -mtime +30 -delete 2>/dev/null || true
		log success "Cleaned old Downloads"
	fi

	# Clear system caches (requires sudo)
	if [ "$(id -u)" -eq 0 ] || sudo -n true 2>/dev/null; then
		log info "Cleaning system caches (requires admin privileges)"
		sudo rm -rf /System/Library/Caches/* 2>/dev/null || true
		sudo rm -rf /Library/Caches/* 2>/dev/null || true
		sudo rm -rf /private/var/folders/*/C/* 2>/dev/null || true
		log success "Cleaned system caches"
	else
		log warning "Skipping system cache cleanup (requires sudo)"
	fi
}

# Linux specific cleanup
cleanup_linux() {
	log info "Running Linux-specific cleanup..."

	# User caches
	clean_directory "$HOME/.cache" "user cache"
	clean_directory "$HOME/.local/share/Trash" "trash"
	clean_directory "$HOME/.thumbnails" "thumbnails"

	# Browser caches
	clean_directory "$HOME/.cache/google-chrome" "Chrome cache"
	clean_directory "$HOME/.cache/chromium" "Chromium cache"
	clean_directory "$HOME/.cache/mozilla/firefox" "Firefox cache"
	clean_directory "$HOME/.config/google-chrome/Default/Application Cache" "Chrome app cache"

	# Development caches
	clean_directory "$HOME/.npm/_cacache" "npm cache"
	clean_directory "$HOME/.cache/yarn" "Yarn cache"
	clean_directory "$HOME/.cache/pip" "pip cache"
	clean_directory "$HOME/.cargo/registry/cache" "Cargo cache"
	clean_directory "$HOME/.gradle/caches" "Gradle caches"
	clean_directory "$HOME/.m2/repository" "Maven repository"
	clean_files "$HOME/**/node_modules/.cache" "Node.js module cache"

	# System temporary files
	clean_files "/tmp/*" "temporary"
	clean_files "/var/tmp/*" "variable temporary"

	# Log files (requires sudo)
	if [ "$(id -u)" -eq 0 ] || sudo -n true 2>/dev/null; then
		log info "Cleaning system logs (requires admin privileges)"
		sudo find /var/log -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true
		sudo journalctl --vacuum-time=7d 2>/dev/null || true
		log success "Cleaned system logs"
	else
		log warning "Skipping system log cleanup (requires sudo)"
	fi

	# Package manager caches
	if command -v apt >/dev/null 2>&1; then
		if sudo -n true 2>/dev/null; then
			sudo apt clean 2>/dev/null && log success "Cleaned apt cache"
		fi
	fi
}

# Universal cleanup for both platforms
cleanup_universal() {
	log info "Running universal cleanup..."

	# Git cleanup in development directories
	if [ -d "$HOME/Developer" ]; then
		log info "Cleaning Git repositories..."
		find "$HOME/Developer" -name ".git" -type d -execdir sh -c '
            git gc --aggressive --prune=now 2>/dev/null || true
            git remote prune origin 2>/dev/null || true
        ' \; 2>/dev/null || true
		log success "Cleaned Git repositories"
	fi

	# Clean shell history duplicates
	if [ -f "$HOME/.zsh_history" ]; then
		awk '!seen[$0]++' "$HOME/.zsh_history" >/tmp/zsh_history_clean
		mv /tmp/zsh_history_clean "$HOME/.zsh_history"
		log success "Cleaned zsh history duplicates"
	fi
}

# Show disk usage summary
show_disk_usage() {
	log info "Disk usage summary:"

	if command -v df >/dev/null 2>&1; then
		df -h / 2>/dev/null | tail -1 | while read -r used avail capacity; do
			log info "Root filesystem: $used used, $avail available ($capacity full)"
		done
	fi

	if [ "$IS_MAC" = true ] && command -v df >/dev/null 2>&1; then
		df -h /System/Volumes/Data 2>/dev/null | tail -1 | while read -r used avail capacity; do
			log info "Data volume: $used used, $avail available ($capacity full)"
		done
	fi
}

main() {
	log info "Starting system maintenance..."
	show_disk_usage

	# Run platform-specific cleanup
	if [ "$IS_MAC" = true ]; then
		cleanup_macos
	else
		cleanup_linux
	fi

	# Run universal cleanup
	cleanup_universal

	log success "System maintenance completed!"
	show_disk_usage

	# Restart services that benefit from cache clearing
	log info "Restarting services..."
	if [ "$IS_MAC" = true ]; then
		# Restart Finder and Dock
		killall Finder 2>/dev/null || true
		killall Dock 2>/dev/null || true
		log success "Restarted Finder and Dock"
	fi
}

main "$@"
