# JARVIS / FRIDAY

Terminal configurations themed after the AI assistants from Iron Man. Switches to **FRIDAY** mode (purple) on Fridays.

Supports **bash**, **fish**, **zsh**, **PowerShell**, and **Termux** (Android).

## Repo structure

```
JARVIS-FRIDAY/
├── bash/        — Bash config (.bashrc, inputrc, install scripts, Starship prompt)
├── fish/        — Fish config (config.fish, functions/, conf.d/, install scripts, Starship prompt)
├── powershell/  — PowerShell config (profile.ps1, install.ps1, Starship prompt)
├── termux/      — Termux (Android) install script
├── zsh/         — Zsh config (.zshrc, install script, Starship prompt)
└── shared/      — Files shared across shells (get_weather.py, starship theme template + renderer)
```

## Quick install

### Bash

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/bash/setup.sh)
```

### Fish

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/fish/setup.sh)
```

### Zsh

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/zsh/install.sh)
```

### Termux (Android)

Install [Termux from F-Droid](https://f-droid.org/packages/com.termux/) (not the Play Store — that version is outdated), then run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/termux/install.sh)
```

### PowerShell (5.1 or 7+)

Linux / macOS / WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/powershell/install.ps1 -o /tmp/jarvis-install.ps1 && pwsh /tmp/jarvis-install.ps1; rm -f /tmp/jarvis-install.ps1
```

Windows (native PowerShell):

```powershell
Invoke-RestMethod https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/powershell/install.ps1 | Invoke-Expression
```

## Tools installed

| Tool                                                                    | Purpose                                                    |
| ----------------------------------------------------------------------- | ---------------------------------------------------------- |
| [Starship](https://starship.rs)                                         | Cross-shell prompt with JARVIS/FRIDAY separator            |
| [Zoxide](https://github.com/ajeetdsouza/zoxide)                         | Smarter `cd` via `z`                                       |
| [fzf](https://github.com/junegunn/fzf)                                  | Fuzzy history search (`Ctrl+R`) and file picker (`Ctrl+T`) |
| [Miniconda](https://docs.anaconda.com/miniconda/)                       | Python package manager (optional)                          |
| [ble.sh](https://github.com/akinomyoga/ble.sh)                          | Inline autosuggestions — bash only, Linux/macOS/WSL2       |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Ghost-text suggestions — zsh only                          |
| [PSReadLine](https://github.com/PowerShell/PSReadLine)                  | History-based autosuggestions — PowerShell only            |
| [PSFzf](https://github.com/kelleyma49/PSFzf)                            | fzf keybindings for PowerShell                             |

## Commands

| Command                              | Description                                           |
| ------------------------------------ | ----------------------------------------------------- |
| `jarvis`                             | System diagnostics panel (memory, CPU, disk, network) |
| `brief`                              | Morning briefing with weather                         |
| `jarvis-locate add "City, State"`    | Add a weather location                                |
| `jarvis-locate remove "City, State"` | Remove a location                                     |
| `jarvis-locate`                      | List saved locations                                  |
| `jarvis-locate clear`                | Clear all locations, fall back to IP detection        |
| `jarvis-unit F` / `jarvis-unit C`    | Set temperature unit (default: F)                     |

## Platform support

| Platform       | Bash                              | Fish | Zsh | PowerShell      |
| -------------- | --------------------------------- | ---- | --- | --------------- |
| Linux          | ✅                                | ✅   | ✅  | ✅ (pwsh 7+)    |
| macOS          | ✅ (requires bash 5 via Homebrew) | ✅   | ✅  | ✅ (pwsh 7+)    |
| Windows WSL2   | ✅                                | ✅   | ✅  | ✅ (pwsh 7+)    |
| Windows native | ✅ (Git Bash, no ble.sh)          | —    | —   | ✅ (5.1 and 7+) |
| Android Termux | ✅                                | ✅   | ✅  | —               |
