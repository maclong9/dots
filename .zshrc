export PATH="$PATH:/Users/maclong/.local/share/mise/installs/zoxide/latest/bin"
export PROMPT="%F{white}%n@%m %B%F{brightwhite}%~ 
%F{%(?.blue.red)}%Bλ%b%f "

autoload -U compinit; compinit
setopt correct

alias _="sudo"
alias g="git"
alias hg="history | grep"
alias mkdir="mkdir -p"
alias ytad="yt-dlp -x --audio-format alac -o '%(title)s.%(ext)s' -P . --exec 'mv {} /Users/maclong/Music/Music/Media.localized/Automatically\ Add\ to\ Music.localized/'"

if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

zplug "zplug/zplug", hook-build:"zplug --self-manage"
zplug "djui/alias-tips"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting"

zplug check || zplug install
zplug load

eval "$(zoxide init zsh)"
eval "$(~/.local/bin/mise activate zsh)"
