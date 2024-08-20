git clone https://github.com/maclong9/dots .config

for file in .config/*(D); do
  if [[ $file:t =~ ^\..* && $file:t != ".git" && $file:t != ".gitignore" ]]; then
    ln -s "$file" "$HOME/${file:t}"
  fi
done

curl https://mise.run | sh
eval "$(~/.local/bin/mise activate zsh)"
mise install
source $HOME/.zshrc
sleep 50
npm i -g pnpm vercel
