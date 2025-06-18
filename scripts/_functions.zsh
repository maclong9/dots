
# Completion for kp (kill process on port)
_kp_completion() {
    local context state line

    _arguments \
        '1:port number:_ports'
}

# Custom port completion function
_ports() {
    local ports
    # Get commonly used development ports and currently listening ports
    ports=(
        "3000:Node.js/React dev server"
        "3001:Alternative dev server"
        "4000:Ruby/Rails dev server"
        "5000:Flask/Python dev server"
        "8000:Django/Python dev server"
        "8080:Alternative HTTP server"
        "8888:Jupyter Notebook"
        "9000:Various services"
    )

    # Add currently listening ports if lsof is available
    if command -v lsof >/dev/null 2>&1; then
        local listening_ports
        listening_ports=$(lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null | awk 'NR>1 {split($9,a,":"); if(a[2] && a[2] ~ /^[0-9]+$/) print a[2]}' | sort -n | uniq)

        for port in $listening_ports; do
            if [ -n "$port" ]; then
                ports+=("$port:currently listening")
            fi
        done
    fi

    _describe 'ports' ports
}

# Completion for dev function (project navigation).
#
# Provides completion for top-level directories (personal, clients, study, work) and their subdirectories.
#
# - Parameters:
#   - None
# - Returns:
#   - None
# - Usage:
#   ```sh
#   dev <tab>
#   dev personal <tab>
#   ```
_dev_completion() {
    local context state line
    local base_dir="$HOME/Developer"
    local target_dir

    if [[ $CURRENT -eq 2 ]]; then
        _values 'directory' personal clients study work
    else
        case "${words[2]}" in
            p|personal) target_dir="$base_dir/personal" ;;
            c|clients) target_dir="$base_dir/clients" ;;
            s|study) target_dir="$base_dir/study" ;;
            w|work) target_dir="$base_dir/work" ;;
            *) target_dir="$base_dir/${words[2]}" ;;
        esac

        # Build path for deeper subdirectories
        for (( i=3; i<CURRENT; i++ )); do
            target_dir="$target_dir/${words[i]}"
        done

        if [ -d "$target_dir" ]; then
            _path_files -W "$target_dir" -/
        fi
    fi
}

# Completion for cdi function (iCloud navigation)
_cdi_completion() {
    local base="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
    if [ -d "$base" ]; then
        _path_files -W "$base" -/
    fi
}

