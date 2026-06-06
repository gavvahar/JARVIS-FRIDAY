#!/bin/bash

set -e

if [[ -d "$HOME/.config/fish" ]]; then
    echo "Backing up existing fish config..."
    mv "$HOME/.config/fish" "$HOME/.config/fish.bak.$(date +%s)"
fi

git clone https://gitlab.com/self-host-server/JARVIS-FRIDAY.git /tmp/JARVIS-FRIDAY-install
cp -r /tmp/JARVIS-FRIDAY-install/fish/. "$HOME/.config/fish"
cp /tmp/JARVIS-FRIDAY-install/shared/get_weather.py "$HOME/.config/fish/get_weather.py"
cp /tmp/JARVIS-FRIDAY-install/shared/starship.toml "$HOME/.config/fish/starship.toml"
cp /tmp/JARVIS-FRIDAY-install/shared/starship-friday.toml "$HOME/.config/fish/starship-friday.toml"
rm -rf /tmp/JARVIS-FRIDAY-install
echo "✅ Fish config cloned"
