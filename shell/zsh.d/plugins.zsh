# Install zinit if not present
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME/.git" ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Load plugins (auto-installs on first run)
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light marlonrichert/zsh-autocomplete

# Configure autocomplete keybindings
bindkey -M emacs \
  "^[p"   .history-search-backward \
  "^[n"   .history-search-forward \
  "^P"    .up-line-or-history \
  "^[OA"  .up-line-or-history \
  "^[[A"  .up-line-or-history \
  "^N"    .down-line-or-history \
  "^[OB"  .down-line-or-history \
  "^[[B"  .down-line-or-history \
  "^R"    .history-incremental-search-backward \
  "^S"    .history-incremental-search-forward

bindkey -a \
  "^P"    .up-history \
  "^N"    .down-history \
  "k"     .up-line-or-history \
  "^[OA"  .up-line-or-history \
  "^[[A"  .up-line-or-history \
  "j"     .down-line-or-history \
  "^[OB"  .down-line-or-history \
  "^[[B"  .down-line-or-history \
  "/"     .vi-history-search-backward \
  "?"     .vi-history-search-forward

# Enable Tab/Shift-Tab cycling through completions
bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete

