#!/bin/bash
# Installs only the prerequisites that are actually missing. Uses the system
# package manager when sudo works; otherwise (e.g. a locked-down work laptop)
# falls back to conda-forge, installing into a dedicated ~/miniconda3 env and
# symlinking the binaries into ~/.local/bin — no root needed. Shared by
# bash/install-prereqs.sh, fish/install-prereqs.sh, fish/install-fish.sh and
# zsh/install.sh.
#
# Usage: install-prereqs.sh <command>... [-- <optional-package>...]
#   <command>           must end up on PATH (checked with `command -v`)
#   <optional-package>  system package installed only when sudo works

set -e

SHARED="https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/shared"
CONDA="$HOME/miniconda3/bin/conda"
CONDA_ENV="jarvis-tools"
BIN_DIR="$HOME/.local/bin"

REQUIRED=()
while [[ $# -gt 0 && "$1" != "--" ]]; do REQUIRED+=("$1"); shift; done
if [[ "$1" == "--" ]]; then shift; fi
OPTIONAL=("$@")

# Make previously symlinked fallback binaries count as installed.
export PATH="$BIN_DIR:$PATH"

pkg_manager() {
    if   [[ "$OSTYPE" == darwin* ]];     then echo brew
    elif command -v apt-get &>/dev/null; then echo apt
    elif command -v dnf     &>/dev/null; then echo dnf
    elif command -v pacman  &>/dev/null; then echo pacman
    else                                      echo none
    fi
}

# Translate a package name for the given manager; empty means "not needed there".
pkg_name() {
    case "$1:$2" in
        pacman:python3)    echo python ;;
        conda:python3)     echo python ;;
        dnf:libatomic1)    echo libatomic ;;
        pacman:libatomic1) ;;
        *)                 echo "$2" ;;
    esac
}

pkg_installed() {
    case "$1" in
        apt)    dpkg -s "$2" &>/dev/null ;;
        dnf)    rpm -q "$2" &>/dev/null ;;
        pacman) pacman -Qi "$2" &>/dev/null ;;
        *)      return 1 ;;
    esac
}

# Root, cached/passwordless sudo, or a successful password prompt. Set
# JARVIS_NO_SUDO=1 to go straight to the conda fallback.
SUDO=""
can_sudo() {
    [[ -n "$JARVIS_NO_SUDO" ]] && return 1
    [[ $EUID -eq 0 ]] && return 0
    command -v sudo &>/dev/null || return 1
    sudo -n true 2>/dev/null && { SUDO="sudo"; return 0; }
    echo "sudo is needed to install: $*"
    echo "(no sudo rights? press Enter 3 times to install without root instead)"
    sudo -v -p "[sudo] password for $USER: " 2>/dev/null && { SUDO="sudo"; return 0; }
    return 1
}

system_install() {
    case "$1" in
        apt)    shift; $SUDO apt-get update -qq && $SUDO apt-get install -y "$@" ;;
        dnf)    shift; $SUDO dnf install -y "$@" ;;
        pacman) shift; $SUDO pacman -Sy --noconfirm "$@" ;;
    esac
}

conda_install() {
    bash <(curl -fsSL "$SHARED/install-miniconda.sh")
    local pkgs=() cmd
    for cmd in "$@"; do pkgs+=("$(pkg_name conda "$cmd")"); done
    # --override-channels keeps this off the Anaconda `defaults` channel, which
    # needs a ToS acceptance and is often blocked on corporate networks.
    if [[ -d "$HOME/miniconda3/envs/$CONDA_ENV" ]]; then
        "$CONDA" install -y -n "$CONDA_ENV" --override-channels -c conda-forge "${pkgs[@]}"
    else
        "$CONDA" create -y -n "$CONDA_ENV" --override-channels -c conda-forge "${pkgs[@]}"
    fi
    mkdir -p "$BIN_DIR"
    for cmd in "$@"; do
        if [[ -x "$HOME/miniconda3/envs/$CONDA_ENV/bin/$cmd" ]]; then
            ln -sf "$HOME/miniconda3/envs/$CONDA_ENV/bin/$cmd" "$BIN_DIR/$cmd"
        fi
    done
}

PM=$(pkg_manager)

MISSING=()
for cmd in "${REQUIRED[@]}"; do
    command -v "$cmd" &>/dev/null || MISSING+=("$cmd")
done

MISSING_OPTIONAL=()
for pkg in "${OPTIONAL[@]}"; do
    pkg=$(pkg_name "$PM" "$pkg")
    if [[ -n "$pkg" ]] && ! pkg_installed "$PM" "$pkg"; then
        MISSING_OPTIONAL+=("$pkg")
    fi
done

if [[ ${#MISSING[@]} -eq 0 && ${#MISSING_OPTIONAL[@]} -eq 0 ]]; then
    echo "✅ Prerequisites already installed"
    exit 0
fi

if [[ "$PM" == brew ]] && command -v brew &>/dev/null; then
    if [[ ${#MISSING[@]} -gt 0 ]]; then
        brew install "${MISSING[@]}"
    fi
elif [[ "$PM" != brew && "$PM" != none ]] && can_sudo "${MISSING[@]}" "${MISSING_OPTIONAL[@]}"; then
    SYSTEM_PKGS=()
    for cmd in "${MISSING[@]}"; do SYSTEM_PKGS+=("$(pkg_name "$PM" "$cmd")"); done
    system_install "$PM" "${SYSTEM_PKGS[@]}" "${MISSING_OPTIONAL[@]}"
else
    if [[ ${#MISSING[@]} -gt 0 ]]; then
        echo "No sudo — installing ${MISSING[*]} from conda-forge into ~/miniconda3 (no root needed)..."
        conda_install "${MISSING[@]}"
    fi
    if [[ ${#MISSING_OPTIONAL[@]} -gt 0 ]]; then
        echo "⚠️  Skipping optional packages that need sudo: ${MISSING_OPTIONAL[*]}"
    fi
fi

STILL_MISSING=()
for cmd in "${MISSING[@]}"; do
    command -v "$cmd" &>/dev/null || STILL_MISSING+=("$cmd")
done
if [[ ${#STILL_MISSING[@]} -gt 0 ]]; then
    echo "❌ Could not install: ${STILL_MISSING[*]} — install manually and re-run"
    exit 1
fi

echo "✅ Prerequisites installed"
