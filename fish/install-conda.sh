#!/bin/bash

set -e

CONDA="$HOME/miniconda3/bin/conda"

if command -v conda &>/dev/null || [[ -x "$CONDA" ]]; then
    echo "✅ Conda already installed"
else
    echo "Installing Miniconda..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        curl -fsSL -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
    else
        curl -fsSL -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    fi
    bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
    rm /tmp/miniconda.sh
    echo "✅ Miniconda installed"
fi

if ! grep -q "conda initialize" "$HOME/.config/fish/config.fish" 2>/dev/null; then
    echo "Initializing conda for fish..."
    "$CONDA" init fish
    echo "✅ Conda initialized"
else
    echo "✅ Conda already initialized for fish"
fi

if "$CONDA" config --show auto_activate_base 2>/dev/null | grep -q "True"; then
    "$CONDA" config --set auto_activate_base false
    "$CONDA" config --set changeps1 false
    echo "✅ Auto-activate base disabled"
else
    echo "✅ Auto-activate base already off"
fi

echo ""
echo "Restart your shell or run: source ~/.config/fish/config.fish"
