ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"

# • Syntax highlighting
if [[ -r "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# • Completions
if [[ -d "$ZSH_PLUGIN_DIR/zsh-completions/src" ]]; then
  fpath=("$ZSH_PLUGIN_DIR/zsh-completions/src" $fpath)
fi

# • Autosuggestions
if [[ -r "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# • Autocomplete
if [[ -r "$ZSH_PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]]; then
  source "$ZSH_PLUGIN_DIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
fi

