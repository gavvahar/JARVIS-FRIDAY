#!/bin/bash

set -e

BASE="https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/shared"
bash <(curl -fsSL "$BASE/install-tools.sh")

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
