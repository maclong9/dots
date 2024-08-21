export PATH="$PATH:/Users/maclong/.local/share/mise/installs/zoxide/latest/bin"
export PROMPT="%F{white}%n@%m %B%F{brightwhite}%~ 
%F{%(?.blue.red)}%Bλ%b%f "
export EDITOR="vim"
export ASDF_FFMPEG_ENABLE="libaom fontconfig freetype frei0r lame libass libvorbis libvpx opus rtmpdump sdl2 snappy theora x264 x265 xz"

# TODO: Convert export and alias to loops

setopt correct

alias g="git"
alias lg="lazygit"
alias hg="history | grep"
alias ytad="yt-dlp -x --audio-format alac -o '%(title)s.%(ext)s' -P . --exec 'mv {} /Users/maclong/Music/Music/Media.localized/Automatically\ Add\ to\ Music.localized/'"

if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
    source ~/.zplug/init.zsh && zplug update
else
    source ~/.zplug/init.zsh
fi

zplug "zplug/zplug", hook-build:"zplug --self-manage"
zplug "djui/alias-tips"
zplug "modules/completion", from:prezto
zplug "modules/history", from:prezto
zplug "modules/syntax-highlighting", from:prezto
zplug "modules/utility", from:prezto

zplug check || zplug install
zplug load

eval "$(zoxide init zsh)"
eval "$(~/.local/bin/mise activate zsh)"
