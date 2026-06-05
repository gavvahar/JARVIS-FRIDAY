#!/bin/bash

set -e

if [[ -d "$HOME/.config/fish" ]]; then
    echo "Backing up existing fish config..."
    mv "$HOME/.config/fish" "$HOME/.config/fish.bak.$(date +%s)"
fi

git clone https://github.com/gavvahar/JARVIS-FRIDAY.git /tmp/JARVIS-FRIDAY-install
cp -r /tmp/JARVIS-FRIDAY-install/fish/. "$HOME/.config/fish"
cp /tmp/JARVIS-FRIDAY-install/shared/get_weather.py "$HOME/.config/fish/get_weather.py"
rm -rf /tmp/JARVIS-FRIDAY-install
echo "✅ Fish config cloned"
