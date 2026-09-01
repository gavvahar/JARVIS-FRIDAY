#!/bin/bash
# Installs starship, zoxide, and fzf. Shared by bash/install-tools.sh and
# fish/install-tools.sh. Any args are passed through to fzf's own installer
# (e.g. --bin, which skips fzf's shell-integration files — fish wires its
# own via `fzf --fish | source` instead).

set -e

# ── Starship ──────────────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    echo "✅ Starship already installed"
else
    echo "Installing starship..."
    mkdir -p "$HOME/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$HOME/.local/bin" --yes
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
    ~/.fzf/install "$@"
    echo "✅ Fzf installed"
fi
