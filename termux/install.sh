#!/usr/bin/env bash
set -euo pipefail

source <(curl -fsSL "https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/shared/shell-colors.sh")

if [[ ! -d "/data/data/com.termux" ]]; then
    err "This script must run inside Termux on Android."
fi

REPO_URL="https://github.com/gavvahar/JARVIS-FRIDAY.git"
REPO_DIR="$HOME/.config/JARVIS-FRIDAY"

printf "\n${CYAN}  ╔══[ J.A.R.V.I.S. TERMUX SETUP ]════════╗${RESET}\n"
printf "${CYAN}  ║  Android / Termux configuration       ║${RESET}\n"
printf "${CYAN}  ╚═══════════════════════════════════════╝${RESET}\n\n"

# ── Packages ──────────────────────────────────────────────────────────────────
log "Updating package list..."
pkg update -y

log "Installing core packages..."
pkg install -y git curl python starship zoxide fzf procps iproute2

# ── Shell choice ──────────────────────────────────────────────────────────────
printf "${CYAN}[J.A.R.V.I.S.]${RESET} Which shell? [1] bash (default)  [2] zsh  [3] fish  "
read -r shell_choice </dev/tty || shell_choice="1"
case "$shell_choice" in
    2) SHELL_NAME="zsh" ;;
    3) SHELL_NAME="fish" ;;
    *) SHELL_NAME="bash" ;;
esac

if [[ "$SHELL_NAME" == "zsh" ]]; then
    pkg install -y zsh
elif [[ "$SHELL_NAME" == "fish" ]]; then
    pkg install -y fish
fi

# ── Clone / update repo ───────────────────────────────────────────────────────
if [[ -d "$REPO_DIR" ]]; then
    log "Repo already at $REPO_DIR — pulling latest..."
    git -C "$REPO_DIR" pull
else
    log "Cloning repo to $REPO_DIR..."
    git clone "$REPO_URL" "$REPO_DIR"
fi
log "Config ready at $REPO_DIR"

# bash/.bashrc reads shared/starship*.toml straight out of this clone at
# every shell startup, and the zsh/fish setups below copy them from here too,
# so render both themes into it now (see shared/starship.toml.tmpl).
bash "$REPO_DIR/shared/render-starship-theme.sh" "$REPO_DIR/shared/starship.toml.tmpl" "$REPO_DIR/shared/starship.toml" \
    "J.A.R.V.I.S." "bold cyan" "bold yellow" "bold blue" "bold cyan" "bold blue"
bash "$REPO_DIR/shared/render-starship-theme.sh" "$REPO_DIR/shared/starship.toml.tmpl" "$REPO_DIR/shared/starship-friday.toml" \
    "F.R.I.D.A.Y." "bold #c084fc" "bold #fbbf24" "bold #fbbf24" "bold #fbbf24" "bold #fbbf24"

# ── Shell setup ───────────────────────────────────────────────────────────────
if [[ "$SHELL_NAME" == "bash" ]]; then
    log "Setting up bash..."
    [[ -f "$HOME/.bashrc" && ! -L "$HOME/.bashrc" ]] && \
        mv "$HOME/.bashrc" "$HOME/.bashrc.bak.$(date +%s)"
    ln -sf "$REPO_DIR/bash/.bashrc" "$HOME/.bashrc"
    ln -sf "$REPO_DIR/bash/inputrc"  "$HOME/.inputrc"
    log "~/.bashrc symlinked"

elif [[ "$SHELL_NAME" == "zsh" ]]; then
    log "Setting up zsh..."
    mkdir -p ~/zsh
    cp "$REPO_DIR/shared/starship.toml"        ~/zsh/starship.toml
    cp "$REPO_DIR/shared/starship-friday.toml" ~/zsh/starship-friday.toml

    PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
    mkdir -p "$PLUGIN_DIR"

    if [[ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]]; then
        log "Installing zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
            "$PLUGIN_DIR/zsh-autosuggestions"
    fi
    if [[ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]]; then
        log "Installing zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
            "$PLUGIN_DIR/zsh-syntax-highlighting"
    fi

    ZSHRC_LINE="source $REPO_DIR/zsh/.zshrc"
    grep -qF "$ZSHRC_LINE" ~/.zshrc 2>/dev/null || echo "$ZSHRC_LINE" > ~/.zshrc
    log "~/.zshrc configured"
    chsh -s zsh && log "Default shell set to zsh"

elif [[ "$SHELL_NAME" == "fish" ]]; then
    log "Setting up fish..."
    [[ -d "$HOME/.config/fish" ]] && \
        mv "$HOME/.config/fish" "$HOME/.config/fish.bak.$(date +%s)"
    cp -r "$REPO_DIR/fish/." "$HOME/.config/fish"
    cp "$REPO_DIR/shared/get_weather.py"       "$HOME/.config/fish/get_weather.py"
    cp "$REPO_DIR/shared/starship.toml"        "$HOME/.config/fish/starship.toml"
    cp "$REPO_DIR/shared/starship-friday.toml" "$HOME/.config/fish/starship-friday.toml"
    log "Fish config installed"
    chsh -s fish && log "Default shell set to fish"
fi

# ── Weather script ────────────────────────────────────────────────────────────
log "Setting up weather script..."
cp "$REPO_DIR/shared/get_weather.py" "$REPO_DIR/bash/get_weather.py"

printf "\n${CYAN}  ╔══[ INSTALLATION COMPLETE ]══════════╗${RESET}\n"
printf "${CYAN}  ║  Restart Termux to activate JARVIS  ║${RESET}\n"
printf "${CYAN}  ╚═════════════════════════════════════╝${RESET}\n\n"
