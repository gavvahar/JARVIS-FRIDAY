#!/bin/bash

set -e

case "$(uname -s)" in
    Linux*)
        echo "Installing prerequisites (Linux)..."
        if command -v apt &>/dev/null; then
            sudo apt update

            sudo apt install -y unzip curl git python3 fontconfig libatomic1 bash-completion gawk make
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y unzip curl git python3 fontconfig bash-completion gawk make
        elif command -v pacman &>/dev/null; then
            sudo pacman -Sy --noconfirm unzip curl git python fontconfig bash-completion gawk make
        else
            echo "Unsupported package manager. Install manually: curl git python3"
            exit 1
        fi
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

echo "✅ Prerequisites installed"
