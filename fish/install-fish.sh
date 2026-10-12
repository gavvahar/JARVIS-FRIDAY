#!/bin/bash

set -e

# Only installs fish if missing; falls back to conda-forge if there's no sudo.
bash <(curl -fsSL "https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/shared/install-prereqs.sh") fish
export PATH="$HOME/.local/bin:$PATH"

FISH_PATH=$(command -v fish)

if [[ "$SHELL" == "$FISH_PATH" ]]; then
    echo "✅ Fish is already the default shell"
elif ! grep -qx "$FISH_PATH" /etc/shells && ! echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null; then
    echo "⚠️  Couldn't add $FISH_PATH to /etc/shells (no sudo) — run 'exec fish' to switch manually"
elif chsh -s "$FISH_PATH"; then
    echo "✅ Fish set as default shell"
else
    echo "⚠️  chsh failed — run 'exec fish' to switch manually"
fi
