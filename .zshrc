export PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "

autoload -Uz compinit
compinit

# Aliases
alias c="clear"
alias g="git"
alias hg="history | grep"
alias sf="swift format --recursive --in-place"
alias mkdir="mkdir -p"

# Kill Port
kp() { 
    kill -9 $(lsof -ti tcp:$1); 
}

# Run `npx` with Deno
nx() { 
    deno run -A npm:$1 ${@:2}; 
}

# Make Directory and Navigate Into
mkcd() { mkdir $1 && cd $1; }

# Open or Create Vim Session
vs() {
    [[ -f ./Session.vim ]] &&
        vim -S Session.vim ||
        vim +Obsession
}

# Create New SvelteKit Project
cs() {
  # Create new project and initialise
  pnpx sv create $1
  cd $1
  git init

  # Setup commitlint and move tw plugins to devDeps
  pnpm add --save-dev @commitlint/{cli,config-conventional} @tailwindcss/forms @tailwindcss/container-queries @tailwindcss/typography
  echo "export default { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js

  # Setup Husky
  pnpm add --save-dev husky
  pnpm husky init
  echo "pnpm dlx commitlint --edit \$1" > .husky/commit-msg
  echo "pnpm test && pnpm lint && pnpm check" > .husky/pre-commit
  
  # Generate VSCode extension recommendations
  mkdir .vscode
  curl https://gist.githubusercontent.com/maclong9/de559a23c06949a8c95e548112a6567f/raw/2bdc2738c56bfe436be2326d03469988fcc6795f/extensions.json > .vscode/extensions.json

  # Remove default Storybook files
  rm -rf ./src/stories/**/*

  # Initial build and format
  pnpm build && pnpm format

  # Create repository
  gh repo create

  # Create initial commit and push
  git add .
  git commit -m "chore: 🎉 initialize project

  Setup development environment:
  - Configure SvelteKit as frontend framework
  - Integrate ESLint and Prettier for code quality
  - Configure Vitest for unit testing infrastructure
  - Add Playwright for end-to-end testing automation
  - Install and configure TailwindCSS for styling
  - Setup commitlint to enforce conventional commit messages
  - Implement husky pre-commit hooks for automated checks
  - Setup Storybook for developing component in isolation
  - Generate VSCode `extensions.json` recommendations"
  git push
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
