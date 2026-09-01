#!/bin/bash

set -e

REPO_DIR="$HOME/.config/JARVIS-FRIDAY"
INSTALL_DIR="$REPO_DIR/bash"

if [[ -d "$REPO_DIR" ]]; then
    echo "Backing up existing config..."
    mv "$REPO_DIR" "$REPO_DIR.bak.$(date +%s)"
fi

git clone https://github.com/gavvahar/JARVIS-FRIDAY.git "$REPO_DIR"
echo "✅ Config cloned"

if [[ -f "$HOME/.bashrc" && ! -L "$HOME/.bashrc" ]]; then
    echo "Backing up existing ~/.bashrc..."
    mv "$HOME/.bashrc" "$HOME/.bashrc.bak.$(date +%s)"
fi

# Try symlink, fall back to copy (Windows may lack symlink permissions)
if ln -sf "$INSTALL_DIR/.bashrc" "$HOME/.bashrc" 2>/dev/null; then
    echo "✅ ~/.bashrc symlinked"
else
    cp "$INSTALL_DIR/.bashrc" "$HOME/.bashrc"
    echo "✅ ~/.bashrc copied (run 'cp ~/.config/JARVIS-FRIDAY/bash/.bashrc ~/.bashrc' to update)"
fi

if ln -sf "$INSTALL_DIR/inputrc" "$HOME/.inputrc" 2>/dev/null; then
    echo "✅ ~/.inputrc symlinked"
else
    cp "$INSTALL_DIR/inputrc" "$HOME/.inputrc"
    echo "✅ ~/.inputrc copied (run 'cp ~/.config/JARVIS-FRIDAY/bash/inputrc ~/.inputrc' to update)"
fi

# macOS: ~/.bashrc is not sourced by default for login shells
if [[ "$(uname -s)" == "Darwin" ]]; then
    PROFILE="$HOME/.bash_profile"
    if ! grep -q '\.bashrc' "$PROFILE" 2>/dev/null; then
        echo '[ -f ~/.bashrc ] && source ~/.bashrc' >> "$PROFILE"
        echo "✅ Added ~/.bashrc sourcing to ~/.bash_profile"
    fi
fi

echo ""
echo "Done! Reload your shell:"
echo "  source ~/.bashrc"
