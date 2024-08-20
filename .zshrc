export PATH="$PATH:/Users/maclong/.local/share/mise/installs/zoxide/latest/bin"
export PROMPT="%F{white}%n@%m %B%F{brightwhite}%~ 
%F{%(?.blue.red)}%Bλ%b%f "

setopt autocd

alias g="git"
alias hg="history | grep"
alias ytad="yt-dlp -x --audio-format alac"

source ~/.zplug/init.zsh
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"
zplug "zplug/zplug", hook-build:"zplug --self-manage"
if ! zplug check --verbose; then
    zplug install
fi
zplug load

eval "$(~/.local/bin/mise activate zsh)"
eval "$(zoxide init zsh)"
