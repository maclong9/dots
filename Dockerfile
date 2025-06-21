FROM debian:latest

# Ensure color terminal in container
ENV TERM=xterm-256color

# Install system dependencies
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    git \
    curl \
    zsh \
	shellcheck \
	shfmt \
    vim \
    openssh-client

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

# Create non-root user (Debian syntax)
RUN groupadd --gid 1001 nodejs && \
    useradd --uid 1001 --gid nodejs --shell /bin/bash --create-home mac

# Switch to non-root user
USER mac

# Configure dotfiles
RUN curl -fsSL https://raw.githubusercontent.com/maclong9/dots/main/setup.sh | sh

# Expose common web development ports
EXPOSE 3000 5173 8080 4200 8000

# Keep container running
CMD ["tail", "-f", "/dev/null"]
