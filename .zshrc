# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/maclong/.zsh/completions:"* ]]; then export FPATH="/Users/maclong/.zsh/completions:$FPATH"; fi

# General Settings
PROMPT="%F{white}%n %B%F{brightwhite}%~
%F{%(?.blue.red)}%Bλ%b%f "
autoload -Uz compinit
compinit
setopt AUTO_CD CORRECT INTERACTIVE_COMMENTS SHARE_HISTORY

# Aliases
alias g="git"
alias hg="history 1 | grep"
alias ls="sls -cli"
alias mkdir="mkdir -p"
alias dig="deno install -gArf"
alias remove="/bin/rm"
alias sf="swift format --recursive --in-place"
alias v="vim"

# Kill Port
kp() { kill -9 $(lsof -ti tcp:$1) }

# Make Directory and Navigate Into
mkcd() { mkdir $1 && cd $1; }

# Run `npx` with Deno
nx() { deno run -A npm:$1 ${@:2} }

# Safely move to trash
rm() { mv $1 ~/.Trash }

# Universal Swift Build
# Function to build a Swift CLI tool as a universal binary (arm64 and x86_64)
# Usage: build_swift_universal <executable_name>
build_swift_universal() {
    if [[ -z "$1" ]]; then
        echo "Error: Please provide the executable name as an argument."
        return 1
    fi

    local executable_name="$1"

    # Build for arm64
    echo "Building for arm64..."
    swift build --arch arm64 -c release
    if [[ $? -ne 0 ]]; then
        echo "Error: arm64 build failed."
        return 1
    fi

    # Build for x86_64
    echo "Building for x86_64..."
    swift build --arch x86_64 -c release
    if [[ $? -ne 0 ]]; then
        echo "Error: x86_64 build failed."
        return 1
    fi

    # Combine binaries with lipo
    echo "Creating universal binary..."
    lipo -create -output "$executable_name" \
        .build/arm64-apple-macosx/release/"$executable_name" \
        .build/x86_64-apple-macosx/release/"$executable_name"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create universal binary."
        return 1
    fi

    # Verify the universal binary
    echo "Verifying universal binary..."
    lipo -info "$executable_name"

    # Make the binary executable
    chmod +x "$executable_name"
    echo "Universal binary created: $executable_name"
}

. "/Users/maclong/.deno/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
