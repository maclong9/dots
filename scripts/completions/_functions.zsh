#!/bin/zsh

# Completion for kp (kill process on port)
_kp_completion() {
    # shellcheck disable=SC2034  # These variables are used by ZSH completion system
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
