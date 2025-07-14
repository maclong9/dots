#!/bin/sh

# System maintenance script for cleaning caches and temporary files

# Ensure HOME is set for launchd environment
HOME="/Users/mac"

# Add timestamp to all output - append to log files like debug script
echo "=== Maintenance run started at $(date) ===" >>/tmp/maintenance.log

# shellcheck disable=SC1091
. "$HOME/.config/scripts/core/utils.sh"

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

# Get size in bytes for calculations
calculate_size_bytes() {
    path="$1"
    [ -d "$path" ] || return 1

    if command -v du >/dev/null 2>&1; then
        du -sb "$path" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

# Format bytes to human readable
format_bytes() {
    bytes="$1"
    if command -v numfmt >/dev/null 2>&1; then
        numfmt --to=iec-i --suffix=B "$bytes" 2>/dev/null || echo "${bytes}B"
    else
        echo "${bytes}B"
    fi
}

# Clean directory contents but preserve the directory
clean_directory() {
    dir="$1"
    name="$2"

    [ ! -d "$dir" ] && return 0

    size_before=$(calculate_size "$dir")
    size_before_bytes=$(calculate_size_bytes "$dir")

    if [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
        log info "Cleaning $name ($size_before)"
        echo "  → Cleaning $name: $size_before" >>/tmp/maintenance.log

        # List items being cleaned
        item_count=0
        # Use find instead of glob expansion to handle special characters
        find "$dir" -mindepth 1 -maxdepth 1 2>/dev/null | while read -r item; do
            [ -e "$item" ] && {
                echo "    - $(basename "$item")" >>/tmp/maintenance.log
                item_count=$((item_count + 1))
            }
        done

        # Get actual count for the main script
        item_count=$(find "$dir" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)

        rm -rf "${dir:?}"/* "$dir"/.* 2>/dev/null || true

        size_after_bytes=$(calculate_size_bytes "$dir")
        saved_bytes=$((size_before_bytes - size_after_bytes))
        saved_formatted=$(format_bytes "$saved_bytes")

        log success "Cleaned $name ($item_count items, saved $saved_formatted)"
        echo "  ✓ Cleaned $name: $item_count items, saved $saved_formatted" >>/tmp/maintenance.log
    else
        log debug "$name already clean"
        echo "  → $name already clean" >>/tmp/maintenance.log
    fi
}

# Clean individual files matching patterns
clean_files() {
    pattern="$1"
    name="$2"

    count=0
    total_size=0
    echo "  → Cleaning $name files..." >>/tmp/maintenance.log

    for file in $pattern; do
        [ -f "$file" ] && {
            if command -v stat >/dev/null 2>&1; then
                if [ "$(uname)" = "Darwin" ]; then
                    file_size=$(stat -f%z "$file" 2>/dev/null || echo "0")
                else
                    file_size=$(stat -c%s "$file" 2>/dev/null || echo "0")
                fi
                total_size=$((total_size + file_size))
            fi
            echo "    - $(basename "$file")" >>/tmp/maintenance.log
            rm -f "$file" 2>/dev/null && count=$((count + 1))
        }
    done

    if [ "$count" -gt 0 ]; then
        saved_formatted=$(format_bytes "$total_size")
        log success "Cleaned $count $name files (saved $saved_formatted)"
        echo "  ✓ Cleaned $count $name files, saved $saved_formatted" >>/tmp/maintenance.log
    else
        echo "  → No $name files to clean" >>/tmp/maintenance.log
    fi
}

# macOS specific cleanup
cleanup_macos() {
    log info "Running macOS-specific cleanup..."
    echo "=== macOS Cleanup ===" >>/tmp/maintenance.log

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
    clean_directory "$HOME/Developer/**/.build" "Swift builds"
    clean_directory "$HOME/.npm/_cacache" "npm cache"
    clean_files "$HOME/**/node_modules/.cache" "Node.js module cache"

    # System temporary files
    clean_files "/tmp/*" "temporary"
    clean_files "$HOME/.Trash/*" "trash"
    clean_files "$HOME/**/.DS_Store" "DS_Store"

    # Download folder cleanup (files older than 30 days)
    if [ -d "$HOME/Downloads" ]; then
        echo "  → Cleaning old Downloads (30+ days)..." >>/tmp/maintenance.log
        old_files=$(find "$HOME/Downloads" -type f -mtime +30 2>/dev/null)
        old_count=0
        old_size=0

        for file in $old_files; do
            [ -f "$file" ] && {
                if command -v stat >/dev/null 2>&1; then
                    file_size=$(stat -f%z "$file" 2>/dev/null || echo "0")
                    old_size=$((old_size + file_size))
                fi
                echo "    - $(basename "$file")" >>/tmp/maintenance.log
                old_count=$((old_count + 1))
            }
        done

        find "$HOME/Downloads" -type f -mtime +30 -delete 2>/dev/null || true

        if [ "$old_count" -gt 0 ]; then
            saved_formatted=$(format_bytes "$old_size")
            log success "Cleaned old Downloads ($old_count files, saved $saved_formatted)"
            echo "  ✓ Cleaned old Downloads: $old_count files, saved $saved_formatted" >>/tmp/maintenance.log
        else
            echo "  → No old Downloads to clean" >>/tmp/maintenance.log
        fi
    fi

    # Clear system caches (requires sudo)
    if [ "$(id -u)" -eq 0 ] || sudo -n true 2>/dev/null; then
        log info "Cleaning system caches (requires admin privileges)"
        echo "  → Cleaning system caches..." >>/tmp/maintenance.log

        system_before=0
        for cache_dir in /System/Library/Caches /Library/Caches /private/var/folders/*/C; do
            [ -d "$cache_dir" ] && {
                dir_size=$(calculate_size_bytes "$cache_dir")
                system_before=$((system_before + dir_size))
            }
        done

        sudo rm -rf /System/Library/Caches/* 2>/dev/null || true
        sudo rm -rf /Library/Caches/* 2>/dev/null || true
        sudo rm -rf /private/var/folders/*/C/* 2>/dev/null || true

        saved_formatted=$(format_bytes "$system_before")
        log success "Cleaned system caches (saved ~$saved_formatted)"
        echo "  ✓ Cleaned system caches, saved ~$saved_formatted" >>/tmp/maintenance.log
    else
        log warning "Skipping system cache cleanup (requires sudo)"
        echo "  ! Skipping system cache cleanup (requires sudo)" >>/tmp/maintenance.log
    fi
}

# Linux specific cleanup
cleanup_linux() {
    log info "Running Linux-specific cleanup..."
    echo "=== Linux Cleanup ===" >>/tmp/maintenance.log

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
        echo "  → Cleaning system logs..." >>/tmp/maintenance.log

        sudo find /var/log -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true
        sudo journalctl --vacuum-time=7d 2>/dev/null || true

        log success "Cleaned system logs"
        echo "  ✓ Cleaned system logs" >>/tmp/maintenance.log
    else
        log warning "Skipping system log cleanup (requires sudo)"
        echo "  ! Skipping system log cleanup (requires sudo)" >>/tmp/maintenance.log
    fi

    # Package manager caches
    if command -v apt >/dev/null 2>&1; then
        if sudo -n true 2>/dev/null; then
            echo "  → Cleaning apt cache..." >>/tmp/maintenance.log
            sudo apt clean 2>/dev/null && {
                log success "Cleaned apt cache"
                echo "  ✓ Cleaned apt cache" >>/tmp/maintenance.log
            }
        fi
    fi
}

# Universal cleanup for both platforms
cleanup_universal() {
    log info "Running universal cleanup..."
    echo "=== Universal Cleanup ===" >>/tmp/maintenance.log

    # Git cleanup in development directories
    if [ -d "$HOME/Developer" ]; then
        log info "Cleaning Git repositories..."
        echo "  → Cleaning Git repositories..." >>/tmp/maintenance.log

        repo_count=0
        find "$HOME/Developer" -name ".git" -type d -execdir sh -c '
            echo "    - $(pwd)" >>/tmp/maintenance.log
            git gc --aggressive --prune=now 2>/dev/null || true
            git remote prune origin 2>/dev/null || true
        ' \; 2>/dev/null || true

        repo_count=$(find "$HOME/Developer" -name ".git" -type d 2>/dev/null | wc -l)
        log success "Cleaned Git repositories ($repo_count repos)"
        echo "  ✓ Cleaned $repo_count Git repositories" >>/tmp/maintenance.log
    fi

    # Clean shell history duplicates
    if [ -f "$HOME/.zsh_history" ]; then
        echo "  → Cleaning zsh history duplicates..." >>/tmp/maintenance.log
        before_lines=$(wc -l <"$HOME/.zsh_history")

        awk '!seen[$0]++' "$HOME/.zsh_history" >/tmp/zsh_history_clean
        mv /tmp/zsh_history_clean "$HOME/.zsh_history"

        after_lines=$(wc -l <"$HOME/.zsh_history")
        removed_lines=$((before_lines - after_lines))

        log success "Cleaned zsh history duplicates ($removed_lines duplicates removed)"
        echo "  ✓ Cleaned zsh history: $removed_lines duplicates removed" >>/tmp/maintenance.log
    fi
}

# Show disk usage summary
show_disk_usage() {
    log info "Disk usage summary:"
    echo "=== Disk Usage Summary ===" >>/tmp/maintenance.log

    if command -v df >/dev/null 2>&1; then
        df -h / 2>/dev/null | tail -1 | while read -r used avail capacity; do
            log info "Root filesystem: $used used, $avail available ($capacity full)"
            echo "  Root filesystem: $used used, $avail available ($capacity full)" >>/tmp/maintenance.log
        done
    fi

    if [ "$IS_MAC" = true ] && command -v df >/dev/null 2>&1; then
        df -h /System/Volumes/Data 2>/dev/null | tail -1 | while read -r used avail capacity; do
            log info "Data volume: $used used, $avail available ($capacity full)"
            echo "  Data volume: $used used, $avail available ($capacity full)" >>/tmp/maintenance.log
        done
    fi
}

# Run mise maintenance
cleanup_mise() {
    log info "Running mise cleanup..."
    echo "=== Mise Cleanup ===" >>/tmp/maintenance.log
    [ "$IS_MAC" = "true" ] && HOME_PATH="/Users/mac/" || HOME_PATH="/home/mac"
    "$HOME_PATH/".local/bin/mise self-update -y
    "$HOME_PATH/".local/bin/mise upgrade
    "$HOME_PATH/".local/bin/mise prune
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

    # Run universal maintenance
    cleanup_universal
    cleanup_mise

    log success "System maintenance completed!"
    show_disk_usage

    # Restart services that benefit from cache clearing
    log info "Restarting services..."
    echo "=== Service Restart ===" >>/tmp/maintenance.log

    if [ "$IS_MAC" = true ]; then
        # Restart Finder and Dock
        killall Finder 2>/dev/null || true
        killall Dock 2>/dev/null || true
        sudo mdutil -E /
        echo "  ✓ Restarted Finder, Restarted Dock and Rebuilt Spotlight Index" >>/tmp/maintenance.log
    fi

    echo "=== Maintenance run completed at $(date) ===" >>/tmp/maintenance.log
}

main "$@" 2>>/tmp/maintenance.error.log
