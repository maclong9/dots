# • Performance
[[ -n "$ZSH_PERF_MONITOR" ]] && {
    echo "⚡ ZSH performance monitoring enabled..."
    zmodload zsh/zprof
}

# Performance monitoring output at end
[[ -n "$ZSH_PERF_MONITOR" ]] && zprof