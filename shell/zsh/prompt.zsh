# • Prompt
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true

# Cache git status to avoid repeated calls
_git_status_cache=""
_git_status_cache_time=0

precmd() {
    local current_time=$(date +%s)
    
    # Only check git status every GIT_CACHE_TIMEOUT seconds
    if (( current_time - _git_status_cache_time > GIT_CACHE_TIMEOUT )); then
        vcs_info
        
        # Set git status color based on repository state
        if [[ -n ${vcs_info_msg_0_} ]] && git rev-parse --is-inside-work-tree &>/dev/null; then
            local color=$(git diff-index --quiet HEAD -- 2>/dev/null && echo "$GIT_COLOR_CLEAN" || echo "$GIT_COLOR_DIRTY")
            zstyle ':vcs_info:git:*' formats " %F{8}—%f %B%F{$color}%b%f"
            zstyle ':vcs_info:git:*' actionformats " %F{8}—%f %B%F{$color}%b|%a%f"
            vcs_info
            _git_status_cache="${vcs_info_msg_0_}"
        else
            _git_status_cache=""
        fi
        _git_status_cache_time=$current_time
    fi
    
    local user_host="%F{7}%n %F{8}on %F{7}%m"
    local separator=" %F{8}—%f "
    local directory="%B%F{15}%~%b"
    local git_info="${_git_status_cache}"
}
  
PROMPT="%F{8}╭%f ${user_host}${separator}${directory}${git_info}
%F{8}╰%f %F{%(?.10.9)}λ%f "
