export PATH="$PATH:/Users/maclong/.local/share/mise/installs/zoxide/latest/bin"
export PROMPT="%F{white}%n@%m %B%F{brightwhite}%~ 
%F{%(?.blue.red)}%Bλ%b%f "
export EDITOR="hx"

alias _="sudo"
alias g="git"
alias hg="history | grep"
alias mkdir="mkdir -p"
alias ytad="yt-dlp -x --audio-format alac -o '%(title)s.%(ext)s' -P . --exec 'mv {} /Users/maclong/Music/Music/Media.localized/Automatically\ Add\ to\ Music.localized/'"

yy() {
    local tmp="${$(mktemp -t "yazi-cwd.XXXXXX"):A}"
    yazi "$@" --cwd-file="$tmp"
    if [[ -s "$tmp" ]]; then
        local cwd="$(<$tmp)"
        [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

setopt correct

if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
    source ~/.zplug/init.zsh && zplug update
else
    source ~/.zplug/init.zsh
fi

zplug "zplug/zplug", hook-build:"zplug --self-manage"
zplug "djui/alias-tips"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting"

zplug check || zplug install
zplug load

eval "$(zoxide init zsh)"
eval "$(~/.local/bin/mise activate zsh)"
