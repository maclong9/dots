FROM alpine:latest

# Install system dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    deno \
    curl \
    zsh \
    vim \
    openssh-client
    
# Set working directory
WORKDIR /workspace

# Install global npm packages
RUN npm install -g \
    @anthropic-ai/claude-code \
    vercel \
    vite \
    typescript \
    eslint \
    prettier

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S main -u 1001

# Switch to non-root user
USER main

# Configure dotfiles
RUN curl -fsSL https://raw.githubusercontent.com/maclong9/dots/main/setup.sh | sh

# Expose common web development ports
EXPOSE 3000 5173 8080 4200 8000

# Keep container running
CMD ["tail", "-f", "/dev/null"]
