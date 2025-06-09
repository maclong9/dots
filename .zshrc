# ZSH Configuration
# Modern shell setup with optimized loading

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

# ZSH options
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY PROMPT_SUBST

# History configuration
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# Initialize completions early
autoload -Uz compinit
compinit -C

# cache completions
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

# Load plugins with error handling and existence checks
ZSH_PLUGINS_DIR="$HOME/.local/share/zsh"
plugins=(
	"zsh-completions/src:fpath"
	"zsh-autosuggestions/zsh-autosuggestions.zsh:source"
	"zsh-you-should-use/you-should-use.plugin.zsh:source"
	"zsh-autocomplete/zsh-autocomplete.plugin.zsh:source"
	"zsh-syntax-highlighting/zsh-syntax-highlighting.zsh:source"
)

for plugin in $plugins; do
	plugin_path="${plugin%:*}"
	action="${plugin#*:}"
	full_path="$ZSH_PLUGINS_DIR/$plugin_path"

	if [[ "$action" == "fpath" && -d "$full_path" ]]; then
		fpath=("$full_path" $fpath)
	elif [[ "$action" == "source" && -f "$full_path" ]]; then
		source "$full_path"
	fi
done

# zsh-autocomplete keybindings
bindkey '^I' menu-complete
bindkey "$terminfo[kcbt]" reverse-menu-complete
bindkey -M emacs \
	"^[p" .history-search-backward \
	"^[n" .history-search-forward \
	"^P" .up-line-or-history \
	"^[OA" .up-line-or-history \
	"^[[A" .up-line-or-history \
	"^N" .down-line-or-history \
	"^[OB" .down-line-or-history \
	"^[[B" .down-line-or-history \
	"^R" .history-incremental-search-backward \
	"^S" .history-incremental-search-forward
bindkey -a \
	"^P" .up-history \
	"^N" .down-history \
	"k" .up-line-or-history \
	"^[OA" .up-line-or-history \
	"^[[A" .up-line-or-history \
	"j" .down-line-or-history \
	"^[OB" .down-line-or-history \
	"^[[B" .down-line-or-history \
	"/" .vi-history-search-backward \
	"?" .vi-history-search-forward

# External tool integrations
tools_init() {
	command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
	command -v jj >/dev/null 2>&1 && source <(COMPLETE=zsh jj)
	[[ -f "$HOME/.local/share/zsh/completions/_mise" ]] && source "$HOME/.local/share/zsh/completions/_mise"
}
tools_init

# Custom prompt
PROMPT='%F{7}%n %B%F{15}%~
%F{%(?.10.9)}%Bλ%b%f '

# Aliases
## File operations
alias cat="bat"
alias ls="sls -cli"
alias la="sls -clia"

## Directory navigation
alias cd="z"
alias cdi="zi"

## Development tools
alias sf="swift format --recursive --in-place"
alias sl="swift format lint --recursive"

## Version control (JJ)
alias jgp="jj git push"
alias jd="jj describe -m"
alias jn="jj new"

# Utility functions

## Kill Process on Given Port
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

# Set Given Bookmark to Given Revision
jbs() { jj bookmark set "$1" -r "$2"; }
