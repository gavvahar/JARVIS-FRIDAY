#!/bin/bash

set -e

case "$(uname -s)" in
    Linux*)
        echo "Installing prerequisites (Linux)..."
        # Only installs what's missing; falls back to conda-forge if there's no sudo.
        bash <(curl -fsSL "https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/shared/install-prereqs.sh") \
            unzip curl git python3 gawk make -- fontconfig libatomic1 bash-completion
        ;;
    Darwin*)
        echo "Installing prerequisites (macOS)..."
        if ! command -v brew &>/dev/null; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        # Ensure a modern bash (macOS ships bash 3.2)
        if ! brew list bash &>/dev/null; then
            echo "Installing bash 5 via Homebrew..."
            brew install bash
            echo "  Add $(brew --prefix)/bin/bash to /etc/shells and run:"
            echo "  chsh -s \$(brew --prefix)/bin/bash"
        fi
        brew install git python3 bash-completion@2 gawk make
        echo "✅ Prerequisites installed"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        echo "Windows detected."
        echo "  Git for Windows: https://git-scm.com/download/win"
        echo "  Python 3:        https://www.python.org/downloads/"
        echo "  (Or use WSL2 for a fully native Linux environment.)"
        ;;
    *)
        echo "Unknown OS. Install manually: curl git python3"
        exit 1
        ;;
esac
