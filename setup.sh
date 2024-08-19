git clone https://github.com/maclong9/dotfiles .config

for file in .config/*(D); do
  if [[ $file:t != ".git*" ]]; then
    ln -s "$file" "$HOME/.${file:t}"
  fi
done

curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl https://mise.run | sh
mise install
npm i -g pnpm vercel

source $HOME/.zshrc
