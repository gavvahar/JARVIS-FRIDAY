#!/bin/bash

set -e

BASE="https://raw.githubusercontent.com/gavvahar/fish-terminal/main"

echo "── Step 1: Install Fish shell ───────────────────────────────────────────────"
curl -fsSL "$BASE/install-fish.sh" | bash

echo ""
echo "── Step 2: Clone Fish config ────────────────────────────────────────────────"
curl -fsSL "$BASE/install.sh" | bash

echo ""
printf "── Step 3: Install tools (Zoxide, Fzf)? [y/N] " >/dev/tty
read -r tools </dev/tty || true
if [[ "$tools" =~ ^[Yy]$ ]]; then
    curl -fsSL "$BASE/install-tools.sh" | bash
else
    echo "Skipping tools install"
    sed -i 's/ \$HOME\/.fzf\/bin//' "$HOME/.config/fish/config.fish"
    sed -i '/# 2\. Initialize zoxide/d' "$HOME/.config/fish/config.fish"
    sed -i '/zoxide init fish | source/d' "$HOME/.config/fish/config.fish"
    sed -i '/# 3\. Enable fzf/d' "$HOME/.config/fish/config.fish"
    sed -i '/fzf --fish | source/d' "$HOME/.config/fish/config.fish"
fi

echo ""
printf "── Step 4: Install Conda? [y/N] " >/dev/tty
read -r conda </dev/tty || true
if [[ "$conda" =~ ^[Yy]$ ]]; then
    curl -fsSL "$BASE/install-conda.sh" | bash
else
    echo "Skipping Conda install"
    sed -i '/# >>> conda initialize >>>/,/# <<< conda initialize <<</d' "$HOME/.config/fish/config.fish"
fi

echo ""
echo "✅ Setup complete — restart your shell or open a new terminal"
