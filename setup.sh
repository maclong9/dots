#!/bin/sh

# Clone the dotfiles repository
git clone https://github.com/maclong9/dots .config

# Create symlinks for dotfiles
for file in .config/*(D); do
  if [[ $file:t =~ ^\..* && $file:t != ".git" && $file:t != ".gitignore" ]]; then
    ln -s "$file" "$HOME/${file:t}"
  fi
done

# Install mise
curl https://mise.run | sh
eval "$(~/.local/bin/mise activate zsh)"
mise install

# Source .zshrc and wait for zplug to complete
source $HOME/.zshrc

# Function to check if zplug is still running
zplug_running() {
  jobs | grep -q 'zplug'
}

# Wait for zplug to complete
echo "Waiting for zplug to complete..."
while zplug_running; do
  sleep 1
done
echo "zplug completed."

# Now run npm commands
npm i -g pnpm vercel
