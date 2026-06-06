#!/bin/bash

set -e

BASE="https://gitlab.com/self-host-server/JARVIS-FRIDAY/-/raw/main/bash"

echo "════════════════════════════════════════"
echo "  Bash Terminal Setup"
echo "════════════════════════════════════════"
echo ""

echo "[ 1 / 4 ] Prerequisites..."
bash <(curl -fsSL "$BASE/install-prereqs.sh")
echo ""

echo "[ 2 / 4 ] Tools (starship, zoxide, fzf)..."
bash <(curl -fsSL "$BASE/install-tools.sh")
echo ""

echo "[ 3 / 4 ] Miniconda (optional — skip with Ctrl+C)..."
bash <(curl -fsSL "$BASE/install-conda.sh") || true
echo ""

echo "[ 4 / 4 ] Config..."
bash <(curl -fsSL "$BASE/install.sh")
echo ""

echo "════════════════════════════════════════"
echo "  All done! Reload your shell:"
echo "  source ~/.bashrc"
echo "════════════════════════════════════════"
