#!/bin/bash

set -e

# ── Starship ──────────────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    echo "✅ Starship already installed"
else
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    echo "✅ Starship installed"
fi

# ── Zoxide ────────────────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    echo "✅ Zoxide already installed"
else
    echo "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    echo "✅ Zoxide installed"
fi

# ── Fzf ───────────────────────────────────────────────────────────────────────
if [[ -x "$HOME/.fzf/bin/fzf" ]] || command -v fzf &>/dev/null; then
    echo "✅ Fzf already installed"
else
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --bin
    echo "✅ Fzf installed"
fi
