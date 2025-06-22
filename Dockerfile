FROM debian:latest

# Ensure color terminal in container
ENV TERM=xterm-256color

# Install system dependencies
RUN apt-get update && apt-get install -y \
	cron \
	shellcheck \
	shfmt \
    curl \
    git \
    nodejs \
    npm \
    openssh-client \
    vim \
    zsh

# Set working directory
WORKDIR ~/Developer

# Install global npm packages
RUN npm install -g \
    @anthropic-ai/claude-code \
    vercel \
    vite \
    typescript \
    eslint \
    prettier

# Configure dotfiles
RUN curl -fsSL https://raw.githubusercontent.com/maclong9/dots/main/setup.sh | sh

# Expose common web development ports
EXPOSE 3000 5173 8080 4200 8000

# Keep container running
CMD ["tail", "-f", "/dev/null"]
