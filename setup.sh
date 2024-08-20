git clone https://github.com/maclong9/dots .config

for file in .config/*(D); do
  if [[ $file:t =~ ^\..* && $file:t != ".git" && $file:t != ".gitignore" ]]; then
    ln -s "$file" "$HOME/${file:t}"
  fi
done

curl https://mise.run | sh
eval "$(~/.local/bin/mise activate zsh)"
mise install

curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

npm i -g pnpm vercel

source $HOME/.zshrc
