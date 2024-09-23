export PATH="$PATH:$(find $HOME/.local/share/mise/installs -type d -name bin | \
  tr '\n' ':' | sed 's/:$//')"
export PROMPT="%F{white}%n@%m %B%F{brightwhite}%~ 
%F{%(?.blue.red)}%Bλ%b%f "
export EDITOR="vim"

alias _="sudo"
alias cat="bat"
alias ls="sls -cli"
alias g="git"
alias hg="history | grep"
alias mkdir="mkdir -p"
alias ytad="yt-dlp -x --audio-format alac -o '%(title)s.%(ext)s' -P . \
  --exec 'mv {} /Users/maclong/Music/Music/Media.localized/Automatically\ Add\ to\ Music.localized/'"

kp() { kill -9 $(lsof -ti tcp:$1); }

eval "$(zoxide init zsh)"
eval "$(~/.local/bin/mise activate zsh)"
