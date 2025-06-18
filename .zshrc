# Load Completions
autoload -Uz compinit && compinit

# ZSH options
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY

# History configuration
export HISTSIZE=10000
export SAVEHIST=10000

# Custom prompt
PROMPT='%F{7}%n %B%F{15}%~
%F{%(?.10.9)}%Bλ%b%f '

# Aliases
alias g='git'
alias clc='fc -ln -1 > /tmp/last_cmd.log && CMD=$(< /tmp/last_cmd.log) && eval "$CMD" \
> /tmp/last_out.log 2>&1 && { echo "λ $CMD"; echo "⇣"; cat /tmp/last_out.log; } | pbcopy'
alias sf="swift format --recursive --in-place"
alias sl="swift format lint --recursive"

# Navigate to iCloud
cdi() {
  base="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
  target="$base"
  [ "$#" -gt 0 ] && target="$base/$*"
  [ -d "$target" ] && cd "$target" || {
    printf 'Directory does not exist: %s\n' "$target" >&2
    return 1
  }
}

# Completions for iCloud Navigation
_cdi_completion() {
  local base="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
  _path_files -W "$base" -/
}
compdef _cdi_completion cdi

# Kill Process on Given Port
kp() {
	[[ -z "$1" ]] && {
		echo "Usage: kp <port>"
		return 1
	}
	local pid=$(lsof -ti tcp:$1)
	if [[ -n "$pid" ]]; then
		kill -9 $pid && echo "Killed process on port $1"
	else
		echo "No process found on port $1"
	fi
}
