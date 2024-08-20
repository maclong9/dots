export PATH="$PATH:/Users/maclong/.local/share/mise/installs/zoxide/latest/bin"
export PROMPT="%F{white}%n@%m %B%F{brightwhite}%~ 
%F{%(?.blue.red)}%Bλ%b%f "

alias g="git"
alias hg="history | grep"
alias ytad="yt-dlp -x --audio-format alac"

if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
    source ~/.zplug/init.zsh && zplug update
else
    source ~/.zplug/init.zsh
fi

zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"
zplug "zplug/zplug", hook-build:"zplug --self-manage"
zplug check || zplug install
zplug clean --force
zplug load

eval "$(~/.local/bin/mise activate zsh)"
eval "$(zoxide init zsh)"
