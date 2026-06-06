# JARVIS / FRIDAY

Terminal configurations themed after the AI assistants from Iron Man. Switches to **FRIDAY** mode (purple) on Fridays.

Supports **bash**, **fish**, **zsh**, and **PowerShell**.

## Repo structure

```
JARVIS-FRIDAY/
├── bash/        — Bash config (.bashrc, inputrc, install scripts, Starship prompt)
├── fish/        — Fish config (config.fish, functions/, conf.d/, install scripts, Starship prompt)
├── powershell/  — PowerShell config (profile.ps1, install.ps1, Starship prompt)
├── zsh/         — Zsh config (.zshrc, install script, Starship prompt)
└── shared/      — Files shared across shells (get_weather.py)
```

## Quick install

### Bash

```bash
bash <(curl -fsSL https://gitlab.com/self-host-server/JARVIS-FRIDAY/-/raw/main/bash/setup.sh)
```

### Fish

```bash
curl -fsSL https://gitlab.com/self-host-server/JARVIS-FRIDAY/-/raw/main/fish/setup.sh | bash
```

### Zsh

```bash
curl -fsSL https://gitlab.com/self-host-server/JARVIS-FRIDAY/-/raw/main/zsh/install.sh | bash
```

### PowerShell (5.1 or 7+)

Linux / macOS / WSL:

```bash
curl -fsSL https://gitlab.com/self-host-server/JARVIS-FRIDAY/-/raw/main/powershell/install.ps1 | pwsh
```

Windows (native PowerShell):

```powershell
Invoke-RestMethod https://gitlab.com/self-host-server/JARVIS-FRIDAY/-/raw/main/powershell/install.ps1 | Invoke-Expression
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
| `jarvis-unit F` / `jarvis-unit C`   | Set temperature unit (default: F)                     |

## Platform support

| Platform       | Bash                              | Fish | Zsh | PowerShell      |
| -------------- | --------------------------------- | ---- | --- | --------------- |
| Linux          | ✅                                | ✅   | ✅  | ✅ (pwsh 7+)    |
| macOS          | ✅ (requires bash 5 via Homebrew) | ✅   | ✅  | ✅ (pwsh 7+)    |
| Windows WSL2   | ✅                                | ✅   | ✅  | ✅ (pwsh 7+)    |
| Windows native | ✅ (Git Bash, no ble.sh)          | —    | —   | ✅ (5.1 and 7+) |
