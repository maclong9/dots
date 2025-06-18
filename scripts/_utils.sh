#!/bin/sh

# Shell Completions for Utility Functions
# Add this to your .zshrc or source it from your shell configuration

# Completion for safe_symlink function
_safe_symlink_completion() {
    _arguments \
        '1:source file:_files' \
        '2:target file:_files'
}

# Completion for download_file function
_download_file_completion() {
    _arguments \
        '1:URL:' \
        '2:destination:_files'
}

# Completion for verify_checksum function
_verify_checksum_completion() {
    _arguments \
        '1:file:_files' \
        '2:checksum:'
}

# Completion for backup_file function
_backup_file_completion() {
    _arguments \
        '1:file to backup:_files'
}

# Completion for spinner function
_spinner_completion() {
    _arguments \
        '1:message:' \
        '*:command:_command_names'
}

# Completion for prompt_user function
_prompt_user_completion() {
    _arguments \
        '1:prompt message:' \
        '2:default response:(y n yes no)'
}

# Completion for log functions
_log_completion() {
    _arguments \
        '1:message:'
}

# Completion for count_files function
_count_files_completion() {
    _arguments \
        '1:pattern:_files'
}

# Completion for ensure_directory function
_ensure_directory_completion() {
    _arguments \
        '1:directory path:_directories'
}

# Register completions with zsh
if [ -n "$ZSH_VERSION" ]; then
    # Main utility functions
    compdef _kp_completion kp
    compdef _dev_completion dev
    compdef _cdi_completion cdi

    # Utility script functions (if sourced)
    compdef _safe_symlink_completion safe_symlink
    compdef _download_file_completion download_file
    compdef _verify_checksum_completion verify_checksum
    compdef _backup_file_completion backup_file
    compdef _spinner_completion spinner
    compdef _prompt_user_completion prompt_user
    compdef _count_files_completion count_files
    compdef _ensure_directory_completion ensure_directory

    # Log functions
    compdef _log_completion log_info
    compdef _log_completion log_success
    compdef _log_completion log_warning
    compdef _log_completion log_error
    compdef _log_completion log_debug
fi
