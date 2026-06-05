#!/bin/bash

set -e

_OS="$(uname -s)"

# ── Starship ──────────────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    echo "✅ Starship already installed"
else
    echo "Installing starship..."
    case "$_OS" in
        MINGW*|MSYS*|CYGWIN*)
            # /usr/local/bin doesn't exist in Git Bash; install to ~/.local/bin
            mkdir -p "$HOME/.local/bin"
            curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$HOME/.local/bin" --yes
            ;;
        *)
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
            ;;
    esac
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
    ~/.fzf/install
    echo "✅ Fzf installed"
fi

# ── ble.sh (fish-style autosuggestions) ──────────────────────────────────────
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
        echo "⚠️  ble.sh not supported on Git Bash — skipping (Up/Down history search active via readline)" ;;
    *)
        if [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
            echo "✅ ble.sh already installed"
        else
            echo "Installing ble.sh..."
            rm -rf /tmp/blesh-src
            git clone --depth 1 https://github.com/akinomyoga/ble.sh.git /tmp/blesh-src
            make -C /tmp/blesh-src install PREFIX=~/.local
            rm -rf /tmp/blesh-src
            echo "✅ ble.sh installed"
        fi ;;
esac
