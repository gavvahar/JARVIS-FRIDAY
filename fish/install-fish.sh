#!/bin/bash

set -e

if command -v fish &>/dev/null; then
    echo "✅ Fish already installed"
else
    echo "Installing fish..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install fish
    else
        sudo apt update && sudo apt install -y fish
    fi
    echo "✅ Fish installed"
fi

FISH_PATH=$(which fish)

if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi

if [[ "$SHELL" != "$FISH_PATH" ]]; then
    chsh -s "$FISH_PATH"
    echo "✅ Fish set as default shell"
else
    echo "✅ Fish is already the default shell"
fi
