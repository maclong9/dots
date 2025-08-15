#!/bin/sh

# System maintenance script for cleaning caches and temporary files

# shellcheck disable=SC1091
. "$HOME/.config/scripts/core/utils.sh"

# Configuration variables
CLEANUP_DAYS_OLD="${CLEANUP_DAYS_OLD:-30}" # Default 30 days for old file cleanup

# Ensure HOME is set for launchd environment
[ "$IS_MAC" = "true" ] && HOME_PATH="/Users/mac" || HOME_PATH="/home/mac"

# Add timestamp to start of maintenance log
echo "=== Maintenance run started at $(date) ===" >>"$LOG_FILE"

# Calculate sizes before and after cleanup
calculate_size() {
    path="$1"
    [ -d "$path" ] || return 1

    if command_exists du; then
        du -sh "$path" 2>/dev/null | cut -f1
    else
        echo "0B"
    fi
}

# Get size in bytes for calculations
calculate_size_bytes() {
    path="$1"
    [ -d "$path" ] || return 1

    if command_exists du; then
        du -sb "$path" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

# Format bytes to human readable
format_bytes() {
    bytes="$1"
    if command_exists numfmt; then
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
        echo "  → Cleaning $name: $size_before" >>"$LOG_FILE"

        # Cache directory listing to avoid multiple find operations
        cache_file="/tmp/cleanup_cache_$$"
        find "$dir" -mindepth 1 -maxdepth 1 2>/dev/null >"$cache_file"

        # List items being cleaned from cache
        while IFS= read -r item; do
            [ -e "$item" ] && {
                echo "    - $(basename "$item")" >>"$LOG_FILE"
            }
        done <"$cache_file"

        # Get count from cache
        item_count=$(wc -l <"$cache_file" | tr -d ' ')
        rm -f "$cache_file"

        rm -rf "${dir:?}"/* "$dir"/.* 2>/dev/null || true

        size_after_bytes=$(calculate_size_bytes "$dir")
        saved_bytes=$((size_before_bytes - size_after_bytes))
        saved_formatted=$(format_bytes "$saved_bytes")

        log success "Cleaned $name (${item_count} items, saved $saved_formatted)"
        echo "  ✓ Cleaned $name: $item_count items, saved $saved_formatted" >>"$LOG_FILE"
    else
        log debug "$name already clean"
        echo "  → $name already clean" >>"$LOG_FILE"
    fi
}

# Clean individual files matching patterns
clean_files() {
    pattern="$1"
    name="$2"

    count=0
    total_size=0
    echo "  → Cleaning $name files..." >>"$LOG_FILE"

    # Use find instead of unquoted glob expansion for safety
    if echo "$pattern" | grep -q '\*'; then
        # Handle glob patterns with find
        base_dir="$(dirname "$pattern")"
        file_pattern="$(basename "$pattern")"

        # Convert shell glob to find pattern
        find_pattern="$(echo "$file_pattern" | sed 's/\*/\*/g')"

        # Process files without pipeline to preserve variable scope
        while IFS= read -r file; do
            [ -f "$file" ] && {
                if command_exists stat; then
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
        done <<EOF
$(find "$base_dir" -maxdepth 1 -name "$find_pattern" -type f 2>/dev/null)
EOF
    else
        # Handle single file patterns
        [ -f "$pattern" ] && {
            if command_exists stat; then
                if [ "$(uname)" = "Darwin" ]; then
                    file_size=$(stat -f%z "$pattern" 2>/dev/null || echo "0")
                else
                    file_size=$(stat -c%s "$pattern" 2>/dev/null || echo "0")
                fi
                total_size=$((total_size + file_size))
            fi
            echo "    - $(basename "$pattern")" >>/tmp/maintenance.log
            rm -f "$pattern" 2>/dev/null && count=$((count + 1))
        }
    fi

    if [ "$count" -gt 0 ]; then
        saved_formatted=$(format_bytes "$total_size")
        log success "Cleaned ${count} $name files (saved $saved_formatted)"
        echo "  ✓ Cleaned $count $name files, saved $saved_formatted" >>/tmp/maintenance.log
    else
        echo "  → No $name files to clean" >>/tmp/maintenance.log
    fi
}

# macOS specific cleanup with parallelization
cleanup_macos() {
    # Run independent directory cleanups in parallel
    clean_directory "$HOME_PATH/Library/Logs" "user logs" &
    clean_directory "$HOME_PATH/Library/WebKit" "WebKit cache" &
    clean_directory "$HOME_PATH/Library/Developer/CoreSimulator/Caches" "iOS Simulator caches" &
    clean_directory "$HOME_PATH/Library/Caches/com.apple.dt.Xcode" "Xcode caches" &
    clean_directory "$HOME_PATH/Developer/**/.build" "Swift builds" &
    clean_files "$HOME_PATH/.Trash/*" "trash" &

    # Wait for parallel operations to complete
    wait
    # Download folder cleanup (files older than configurable days)
    if [ -d "$HOME_PATH/Downloads" ]; then
        echo "  → Cleaning old Downloads (${CLEANUP_DAYS_OLD}+ days)..." >>/tmp/maintenance.log
        old_files=$(find "$HOME_PATH/Downloads" -type f -mtime "+${CLEANUP_DAYS_OLD}" 2>/dev/null)
        old_count=0
        old_size=0

        for file in $old_files; do
            [ -f "$file" ] && {
                if command_exists stat; then
                    file_size=$(stat -f%z "$file" 2>/dev/null || echo "0")
                    old_size=$((old_size + file_size))
                fi
                old_count=$((old_count + 1))
            }
        done

        find "$HOME_PATH/Downloads" -type f -mtime "+${CLEANUP_DAYS_OLD}" -delete 2>/dev/null || true

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

# Linux specific cleanup with parallelization
cleanup_linux() {
    # Run independent user cache cleanups in parallel
    clean_directory "$HOME_PATH/.cache/google-chrome" "Chrome cache" &
    clean_directory "$HOME_PATH/.cache/pip" "pip cache" &
    clean_directory "$HOME_PATH/.cargo/registry/cache" "Cargo cache" &
    clean_directory "$HOME_PATH/.gradle/caches" "Gradle caches" &
    clean_directory "$HOME_PATH/.m2/repository" "Maven repository" &
    clean_files "$HOME_PATH/**/node_modules/.cache" "Node.js module cache" &

    # Wait for parallel cache cleanups to complete
    wait

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
    if command_exists apt; then
        if sudo -n true 2>/dev/null; then
            echo "  → Cleaning apt cache..." >>/tmp/maintenance.log
            sudo apt clean 2>/dev/null && {
                log success "Cleaned apt cache"
                echo "  ✓ Cleaned apt cache" >>/tmp/maintenance.log
            }
        fi
    fi
}

# Universal cleanup for all platforms
cleanup_universal() {
    echo "=== Universal Cleanup ===" >>/tmp/maintenance.log

    # Clean git repositories with caching
    if [ -d "$HOME_PATH/Developer" ]; then
        echo "  → Cleaning Git repositories..." >>/tmp/maintenance.log

        # Cache git repository list to avoid multiple find operations
        cache_file="/tmp/git_repos_cache_$$"
        find "$HOME_PATH/Developer" -name ".git" -type d >"$cache_file" 2>/dev/null

        # Process repositories from cache
        while IFS= read -r git_dir; do
            [ -n "$git_dir" ] && {
                repo_dir=$(dirname "$git_dir")
                cd "$repo_dir" || continue
                repo_name=$(basename "$PWD")

                if git rev-parse --git-dir >/dev/null 2>&1; then
                    git gc --quiet 2>/dev/null || true
                    git prune 2>/dev/null || true
                    echo "      ✓ $repo_name repository cleaned successfully" >>/tmp/maintenance.log
                else
                    printf "      ✓ %s repository cleaned successfully\n" "$repo_name"
                    echo "      ✓ $repo_name repository cleaned successfully" >>/tmp/maintenance.log
                    git remote prune origin 2>/dev/null || true
                fi
            }
        done <"$cache_file"

        repo_count=$(wc -l <"$cache_file" | tr -d ' ')
        rm -f "$cache_file"
        echo "  ✓ Cleaned $repo_count Git repositories" >>/tmp/maintenance.log

        echo "  → Cleaning zsh history duplicates..." >>/tmp/maintenance.log
        before_lines=$(wc -l <"$HOME_PATH/.zsh_history")
        awk '!seen[$0]++' "$HOME_PATH/.zsh_history" >/tmp/zsh_history_clean
        mv /tmp/zsh_history_clean "$HOME_PATH/.zsh_history"

        after_lines=$(wc -l <"$HOME_PATH/.zsh_history")
        removed_lines=$((before_lines - after_lines))

        log success "Cleaned zsh history duplicates ($removed_lines duplicates removed)"
        echo "  ✓ Cleaned zsh history: $removed_lines duplicates removed" >>/tmp/maintenance.log
    fi
}

# Show disk usage summary
show_disk_usage() {
    log info "Disk usage summary:"
    echo "=== Disk Usage Summary ===" >>/tmp/maintenance.log

    if command_exists df; then
        df -h / 2>/dev/null | tail -1 | while read -r filesystem size used avail capacity _; do
            echo "Root filesystem ($filesystem):"
            echo "  Size: $size"
            echo "  Used: $used"
            echo "  Available: $avail"
            echo "  Capacity: $capacity"
            {
                echo "  Root filesystem ($filesystem):"
                echo "    Size: $size"
                echo "    Used: $used"
                echo "    Available: $avail"
                echo "    Capacity: $capacity"
            } >>/tmp/maintenance.log
        done
    fi

    if [ "$IS_MAC" = true ] && command_exists df; then
        df -h /System/Volumes/Data 2>/dev/null | tail -1 | while read -r filesystem size used avail capacity _; do
            echo "Data volume ($filesystem):"
            echo "  Size: $size"
            echo "  Used: $used"
            echo "  Available: $avail"
            echo "  Capacity: $capacity"
            {
                echo "  Data volume ($filesystem):"
                echo "    Size: $size"
                echo "    Used: $used"
                echo "    Available: $avail"
                echo "    Capacity: $capacity"
            } >>/tmp/maintenance.log
        done
    fi
}
cleanup_mise() {
    echo "=== Mise Cleanup ===" >>/tmp/maintenance.log
    [ "$IS_MAC" = "true" ] && HOME_PATH="/Users/mac" || HOME_PATH="/home/mac"

    mise_output=$("$HOME_PATH/.local/bin/mise" self-update -y 2>&1)
    echo "$mise_output"
    echo "$mise_output" >>/tmp/maintenance.log

    mise_output=$("$HOME_PATH/.local/bin/mise" prune 2>&1)
    echo "$mise_output"
    echo "$mise_output" >>/tmp/maintenance.log
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
    log info "Restarting system services to apply cache cleanup..."
    if [ "$IS_MAC" = true ]; then
        log info "Dumping current macOS defaults..."
        echo "=== macOS Defaults Backup ===" >>/tmp/maintenance.log
        "$HOME_PATH/.config/scripts/defaults/dump-defaults.sh" >>/tmp/maintenance.log 2>&1
        log success "macOS defaults dumped successfully"

        log info "Restarting macOS system services..."
        echo "  → Restarting macOS system services..." >>/tmp/maintenance.log

        # Restart Finder to refresh file system cache
        log info "Restarting Finder (file system cache refresh)..."
        killall Finder 2>/dev/null || true
        log success "Finder restarted successfully"
        echo "    ✓ Finder restarted (file system cache refreshed)" >>/tmp/maintenance.log

        # Restart Dock to refresh application cache
        log info "Restarting Dock (application cache refresh)..."
        killall Dock 2>/dev/null || true
        log success "Dock restarted successfully"
        echo "    ✓ Dock restarted (application cache refreshed)" >>/tmp/maintenance.log

        # Rebuild Spotlight index for better search performance
        log info "Rebuilding Spotlight index (search optimization)..."
        spotlight_output=$(sudo mdutil -E / 2>&1)
        echo "$spotlight_output"
        echo "$spotlight_output" >>/tmp/maintenance.log
        log success "Spotlight index rebuild initiated"
        echo "    ✓ Spotlight index rebuild initiated (search optimization)" >>/tmp/maintenance.log
    fi

    echo "=== Maintenance run completed at $(date) ===" >>/tmp/maintenance.log
}

main "$@" 2>>/tmp/maintenance.error.log
