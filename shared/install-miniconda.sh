#!/bin/bash
# Installs Miniconda to ~/miniconda3 if not already present. Idempotent —
# callers (fish/install-conda.sh, zsh/install.sh) are safe to invoke this
# unconditionally and handle conda-init themselves afterward.

set -e

CONDA="$HOME/miniconda3/bin/conda"
if command -v conda &>/dev/null || [[ -x "$CONDA" ]]; then
    echo "✅ Conda already installed"
else
    echo "Installing Miniconda..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        curl -fsSL -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
    else
        curl -fsSL -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    fi
    bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
    rm /tmp/miniconda.sh
    echo "✅ Miniconda installed"
fi
