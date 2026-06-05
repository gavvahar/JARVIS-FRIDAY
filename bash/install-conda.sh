#!/bin/bash

set -e

# conda binary lives in different places on Windows vs Unix
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) CONDA="$HOME/miniconda3/Scripts/conda" ;;
    *)                     CONDA="$HOME/miniconda3/bin/conda"     ;;
esac

if command -v conda &>/dev/null || [[ -x "$CONDA" ]]; then
    echo "✅ Conda already installed"
else
    echo "Installing Miniconda..."
    case "$(uname -s)-$(uname -m)" in
        Darwin-arm64)
            curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
            bash Miniconda3-latest-MacOSX-arm64.sh -b -p "$HOME/miniconda3"
            rm Miniconda3-latest-MacOSX-arm64.sh ;;
        Darwin-*)
            curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
            bash Miniconda3-latest-MacOSX-x86_64.sh -b -p "$HOME/miniconda3"
            rm Miniconda3-latest-MacOSX-x86_64.sh ;;
        MINGW*|MSYS*|CYGWIN*)
            curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe \
                --output "$HOME/Miniconda3-latest-Windows-x86_64.exe"
            "$HOME/Miniconda3-latest-Windows-x86_64.exe" \
                /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /S \
                /D="$(cygpath -w "$HOME/miniconda3")" || true
            # NSIS silent installer spawns asynchronously — wait before removing exe
            local retries=30
            printf "Waiting for installer to complete"
            while [[ ! -x "$CONDA" ]] && (( retries-- > 0 )); do
                sleep 2; printf "."
            done
            printf "\n"
            rm -f "$HOME/Miniconda3-latest-Windows-x86_64.exe"
            ;;
        *)
            curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
            bash Miniconda3-latest-Linux-x86_64.sh -b -p "$HOME/miniconda3"
            rm Miniconda3-latest-Linux-x86_64.sh ;;
    esac
    echo "✅ Miniconda installed"
fi

if ! grep -q "conda initialize" "$HOME/.bashrc" 2>/dev/null; then
    echo "Initializing conda for bash..."
    "$CONDA" init bash
    echo "✅ Conda initialized"
else
    echo "✅ Conda already initialized for bash"
fi

if "$CONDA" config --show auto_activate_base 2>/dev/null | grep -q "True"; then
    "$CONDA" config --set auto_activate_base false
    "$CONDA" config --set changeps1 false
    echo "✅ Auto-activate base disabled"
else
    echo "✅ Auto-activate base already off"
fi

echo ""
echo "Restart your shell or run: source ~/.bashrc"
