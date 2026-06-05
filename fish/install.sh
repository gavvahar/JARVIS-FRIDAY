#!/bin/bash

set -e

if [[ -d "$HOME/.config/fish" ]]; then
    echo "Backing up existing fish config..."
    mv "$HOME/.config/fish" "$HOME/.config/fish.bak.$(date +%s)"
fi

git clone https://github.com/gavvahar/fish-terminal.git "$HOME/.config/fish"
echo "✅ Fish config cloned"
