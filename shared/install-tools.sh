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

# ── Upterm (self-hosted terminal-sharing relay client) ───────────────────────
if command -v upterm &>/dev/null; then
    echo "✅ Upterm already installed"
elif [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* || "$(uname -s)" == CYGWIN* ]]; then
    echo "⚠️  Skipping upterm on Windows — not yet wired up (PowerShell has no winget package for it either)"
else
    UPTERM_VERSION="v0.25.1"
    case "$(uname -s)-$(uname -m)" in
        Linux-x86_64)              _UPTERM_ASSET="upterm_linux_amd64.tar.gz"  ;;
        Linux-aarch64|Linux-arm64) _UPTERM_ASSET="upterm_linux_arm64.tar.gz"  ;;
        Darwin-x86_64)             _UPTERM_ASSET="upterm_darwin_amd64.tar.gz" ;;
        Darwin-arm64)              _UPTERM_ASSET="upterm_darwin_arm64.tar.gz" ;;
        *)                         _UPTERM_ASSET="" ;;
    esac
    if [[ -n "$_UPTERM_ASSET" ]]; then
        echo "Installing upterm..."
        mkdir -p "$HOME/.local/bin"
        curl -sL "https://github.com/owenthereal/upterm/releases/download/${UPTERM_VERSION}/${_UPTERM_ASSET}" \
            | tar -xz -C "$HOME/.local/bin" upterm
        chmod +x "$HOME/.local/bin/upterm"
        echo "✅ Upterm installed"
    else
        echo "⚠️  Upterm auto-install not supported on $(uname -s)/$(uname -m) — install manually: https://github.com/owenthereal/upterm#installation"
    fi
fi
