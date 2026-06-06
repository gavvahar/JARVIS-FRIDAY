#!/usr/bin/env bash
set -euo pipefail

CYAN=$'\e[1;36m'; YELLOW=$'\e[1;33m'; RED=$'\e[1;31m'; RESET=$'\e[0m'
log()  { printf "${CYAN}[J.A.R.V.I.S.]${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}[J.A.R.V.I.S.]${RESET} %s\n" "$*"; }
err()  { printf "${RED}[J.A.R.V.I.S.]${RESET} %s\n" "$*" >&2; exit 1; }

RAW="https://gitlab.com/self-host-server/JARVIS-FRIDAY/-/raw/main/zsh"

# ── OS detection ──────────────────────────────────────────────────────────────
os() {
    if   [[ "$OSTYPE" == darwin* ]];          then echo macos
    elif command -v apt-get &>/dev/null;      then echo debian
    elif command -v dnf     &>/dev/null;      then echo fedora
    elif command -v pacman  &>/dev/null;      then echo arch
    else                                           echo unknown
    fi
}

pkg_install() {
    case $(os) in
        macos)   brew install "$@" ;;
        debian)  sudo apt-get install -y "$@" ;;
        fedora)  sudo dnf install -y "$@" ;;
        arch)    sudo pacman -S --noconfirm "$@" ;;
        unknown) err "Cannot auto-install $*. Please install manually and re-run." ;;
    esac
}

# ── prerequisites ─────────────────────────────────────────────────────────────
log "Installing prerequisites..."
case $(os) in
    debian) sudo apt-get update -qq && sudo apt-get install -y unzip curl git fontconfig libatomic1 ;;
    fedora) sudo dnf install -y unzip curl git fontconfig ;;
    arch)   sudo pacman -S --noconfirm unzip curl git fontconfig ;;
    macos)  command -v brew &>/dev/null || err "Homebrew is required on macOS. Install from https://brew.sh" ;;
esac

# ── zsh ───────────────────────────────────────────────────────────────────────
if command -v zsh &>/dev/null; then
    log "zsh $(zsh --version | awk '{print $2}') already installed — skipping"
else
    log "Installing zsh..."
    pkg_install zsh
fi

# ── starship ──────────────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    log "starship already installed — skipping"
else
    log "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# ── fzf ───────────────────────────────────────────────────────────────────────
if command -v fzf &>/dev/null || [[ -x "$HOME/.fzf/bin/fzf" ]]; then
    log "fzf already installed — skipping"
else
    log "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --bin
fi

# ── zoxide ────────────────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null || [[ -x "$HOME/.local/bin/zoxide" ]]; then
    log "zoxide already installed — skipping"
else
    log "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# ── zsh plugins ───────────────────────────────────────────────────────────────
PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
mkdir -p "$PLUGIN_DIR"

if [[ -d "$PLUGIN_DIR/zsh-autosuggestions" ]]; then
    log "zsh-autosuggestions already installed — skipping"
else
    log "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"
fi

if [[ -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]]; then
    log "zsh-syntax-highlighting already installed — skipping"
else
    log "Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGIN_DIR/zsh-syntax-highlighting"
fi

# ── JARVIS config ─────────────────────────────────────────────────────────────
log "Downloading JARVIS config..."
mkdir -p ~/zsh
curl -fsSL "$RAW/.zshrc"               -o ~/zsh/.zshrc
curl -fsSL "https://gitlab.com/self-host-server/JARVIS-FRIDAY/-/raw/main/shared/starship.toml"        -o ~/zsh/starship.toml
curl -fsSL "https://gitlab.com/self-host-server/JARVIS-FRIDAY/-/raw/main/shared/starship-friday.toml" -o ~/zsh/starship-friday.toml

# ── ~/.zshrc ──────────────────────────────────────────────────────────────────
ZSHRC_LINE='source ~/zsh/.zshrc'
ZSHRC_COUNT=$(grep -c "$ZSHRC_LINE" ~/.zshrc 2>/dev/null || echo 0)
if [[ "$ZSHRC_COUNT" -eq 1 ]] && [[ $(grep -v '^\s*$' ~/.zshrc | wc -l) -eq 1 ]]; then
    log "~/.zshrc already configured — skipping"
else
    echo "$ZSHRC_LINE" > ~/.zshrc
    log "Wrote ~/.zshrc"
fi

# ── default shell ─────────────────────────────────────────────────────────────
ZSH_BIN=$(command -v zsh)
if [[ "$SHELL" == "$ZSH_BIN" ]]; then
    log "Default shell is already zsh — skipping"
else
    printf "${CYAN}[J.A.R.V.I.S.]${RESET} Change default shell to zsh? [y/N] "
    read -r reply
    if [[ "$reply" =~ ^[Yy]$ ]]; then
        if ! grep -qx "$ZSH_BIN" /etc/shells; then
            echo "$ZSH_BIN" | sudo tee -a /etc/shells
        fi
        chsh -s "$ZSH_BIN"
        log "Default shell changed. Log out and back in to apply."
    fi
fi

# ── miniconda ─────────────────────────────────────────────────────────────────
CONDA="$HOME/miniconda3/bin/conda"
if command -v conda &>/dev/null || [[ -x "$CONDA" ]]; then
    log "conda already installed — skipping"
else
    log "Installing Miniconda..."
    if [[ "$OSTYPE" == darwin* ]]; then
        curl -fsSL -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
    else
        curl -fsSL -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    fi
    bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
    rm /tmp/miniconda.sh
    log "Miniconda installed"
fi
"$CONDA" init zsh
if "$CONDA" config --show auto_activate_base 2>/dev/null | grep -q "True"; then
    "$CONDA" config --set auto_activate_base false
    "$CONDA" config --set changeps1 false
    log "Disabled conda auto-activate base"
else
    log "conda auto-activate base already off"
fi

printf "\n${CYAN}  ╔══[ J.A.R.V.I.S. INSTALLATION COMPLETE ]══╗${RESET}\n"
printf "${CYAN}  ║  Run: exec zsh                            ║${RESET}\n"
printf "${CYAN}  ╚════════════════════════════════════════════╝${RESET}\n\n"
