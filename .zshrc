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
alias clc='fc -ln -1 | sed "s/^/λ /" | tee /tmp/last_cmd.log && script -q /tmp/last_out.log "$(fc -ln -1)" && { cat /tmp/last_cmd.log; cat /tmp/last_out.log; } | pbcopy'
alias sf="swift format --recursive --in-place"
alias sl="swift format lint --recursive"
alias dev="container exec -t -i development zsh"

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
