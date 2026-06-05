# JARVIS / FRIDAY

Terminal configurations themed after the AI assistants from Iron Man. Switches to **FRIDAY** mode (purple) on Fridays.

Supports **bash**, **fish**, and **zsh**.

## Repo structure

```
JARVIS-FRIDAY/
├── bash/        — Bash config (.bashrc, inputrc, install scripts, Starship prompt)
├── fish/        — Fish config (config.fish, functions/, conf.d/, install scripts, Starship prompt)
├── zsh/         — Zsh config (.zshrc, install script, Starship prompt)
└── shared/      — Files shared across shells (get_weather.py)
```

## Quick install

### Bash

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/bash/setup.sh)
```

### Fish

```bash
curl -fsSL https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/fish/setup.sh | bash
```

### Zsh

```bash
curl -fsSL https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/zsh/install.sh | bash
```

## Tools installed

| Tool | Purpose |
| --- | --- |
| [Starship](https://starship.rs) | Cross-shell prompt with JARVIS/FRIDAY separator |
| [Zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` via `z` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy history search (`Ctrl+R`) and file picker (`Ctrl+T`) |
| [Miniconda](https://docs.anaconda.com/miniconda/) | Python package manager (optional) |
| [ble.sh](https://github.com/akinomyoga/ble.sh) | Inline autosuggestions — bash only, Linux/macOS/WSL2 |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Ghost-text suggestions — zsh only |

## Commands

| Command | Description |
| --- | --- |
| `jarvis` | System diagnostics panel (memory, CPU, disk, network) |
| `brief` | Morning briefing with weather |
| `jarvis-locate add "City, State"` | Add a weather location |
| `jarvis-locate remove "City, State"` | Remove a location |
| `jarvis-locate` | List saved locations |
| `jarvis-locate clear` | Clear all locations, fall back to IP detection |

## Platform support

| Platform | Bash | Fish | Zsh |
| --- | --- | --- | --- |
| Linux | ✅ | ✅ | ✅ |
| macOS | ✅ (requires bash 5 via Homebrew) | ✅ | ✅ |
| Windows WSL2 | ✅ | ✅ | ✅ |
| Windows Git Bash | ✅ (no ble.sh) | — | — |
