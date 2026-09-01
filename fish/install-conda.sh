#!/bin/bash

set -e

CONDA="$HOME/miniconda3/bin/conda"

BASE="https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/shared"
bash <(curl -fsSL "$BASE/install-miniconda.sh")

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
