#!/bin/bash

set -e

if [[ -d "$HOME/.config/fish" ]]; then
    echo "Backing up existing fish config..."
    mv "$HOME/.config/fish" "$HOME/.config/fish.bak.$(date +%s)"
fi

git clone https://github.com/gavvahar/JARVIS-FRIDAY.git /tmp/JARVIS-FRIDAY-install
cp -r /tmp/JARVIS-FRIDAY-install/fish/. "$HOME/.config/fish"
cp /tmp/JARVIS-FRIDAY-install/shared/get_weather.py "$HOME/.config/fish/get_weather.py"
bash /tmp/JARVIS-FRIDAY-install/shared/render-starship-theme.sh \
    /tmp/JARVIS-FRIDAY-install/shared/starship.toml.tmpl "$HOME/.config/fish/starship.toml" \
    "J.A.R.V.I.S." "bold cyan" "bold yellow" "bold blue" "bold cyan" "bold blue"
bash /tmp/JARVIS-FRIDAY-install/shared/render-starship-theme.sh \
    /tmp/JARVIS-FRIDAY-install/shared/starship.toml.tmpl "$HOME/.config/fish/starship-friday.toml" \
    "F.R.I.D.A.Y." "bold #c084fc" "bold #fbbf24" "bold #fbbf24" "bold #fbbf24" "bold #fbbf24"
rm -rf /tmp/JARVIS-FRIDAY-install
echo "✅ Fish config cloned"
