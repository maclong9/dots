FROM debian:latest

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

# Ensure color terminal in container persists across shell sessions
RUN echo 'export TERM=xterm-256color' >> /etc/environment && \
    echo 'export TERM=xterm-256color' >> /etc/zsh/zshenv

# Set working directory
WORKDIR ~/Developer

# Install global npm packages
RUN npm install -g \
	@anthropic-ai/claude-code \
	vercel \	
	wrangler

# Configure dotfiles
RUN curl -fsSL https://raw.githubusercontent.com/maclong9/dots/main/setup.sh | sh

# Expose common web development ports
EXPOSE 3000 5173 8080 4200 8000

# Keep container running
CMD ["tail", "-f", "/dev/null"]
