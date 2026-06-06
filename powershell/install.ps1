#Requires -Version 5.1
# ─── J.A.R.V.I.S. / F.R.I.D.A.Y. — PowerShell Install ──────────────────────

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$CYAN   = [char]27 + '[1;36m'
$RESET  = [char]27 + '[0m'
$YELLOW = [char]27 + '[1;33m'

function log  { Write-Host "${CYAN}[J.A.R.V.I.S.]${RESET} $args" }
function warn { Write-Host "${YELLOW}[J.A.R.V.I.S.]${RESET} $args" }
function prompt-yn([string]$msg) {
    $reply = Read-Host "${CYAN}[J.A.R.V.I.S.]${RESET} $msg [y/N]"
    return $reply -match '^[Yy]$'
}

$_PSMajor   = $PSVersionTable.PSVersion.Major
$_IsWindows = if ($_PSMajor -ge 6) { $IsWindows } else { $env:OS -eq 'Windows_NT' }
$_IsLinux   = if ($_PSMajor -ge 6) { $IsLinux }   else { $false }
$_IsMacOS   = if ($_PSMajor -ge 6) { $IsMacOS }   else { $false }

$REPO_URL   = 'https://github.com/gavvahar/JARVIS-FRIDAY.git'
$REPO_DIR   = "$HOME/.config/JARVIS-FRIDAY"
$INSTALL_DIR = "$REPO_DIR/powershell"

Write-Host ""
Write-Host "  ${CYAN}╔══[ J.A.R.V.I.S. POWERSHELL SETUP ]══╗${RESET}"
Write-Host "  ${CYAN}║  Cross-platform PowerShell config     ║${RESET}"
Write-Host "  ${CYAN}╚══════════════════════════════════════╝${RESET}"
Write-Host ""

# ── Suggest PowerShell 7 if on 5.1 ───────────────────────────────────────────
if ($_PSMajor -lt 7) {
    warn "Running on PowerShell $($_PSMajor). PowerShell 7+ is recommended for full feature support."
    warn "Install: winget install Microsoft.PowerShell"
    Write-Host ""
}

# ── Clone / update repo ───────────────────────────────────────────────────────
if (Test-Path $REPO_DIR) {
    log "Repo already at $REPO_DIR — pulling latest..."
    & git -C $REPO_DIR pull
} else {
    log "Cloning repo to $REPO_DIR..."
    & git clone $REPO_URL $REPO_DIR
}
log "Config ready at $INSTALL_DIR"

# ── Install tools ─────────────────────────────────────────────────────────────
log "Installing tools..."

if ($_IsWindows) {
    $useWinget = Get-Command winget -ErrorAction SilentlyContinue
    $useChoco  = Get-Command choco  -ErrorAction SilentlyContinue

    foreach ($tool in @(
        @{ Name = 'starship'; Winget = 'Starship.Starship';    Choco = 'starship'      },
        @{ Name = 'zoxide';   Winget = 'ajeetdsouza.zoxide';   Choco = 'zoxide'        },
        @{ Name = 'fzf';      Winget = 'junegunn.fzf';         Choco = 'fzf'           }
    )) {
        if (Get-Command $tool.Name -ErrorAction SilentlyContinue) {
            log "$($tool.Name) already installed — skipping"
        } elseif ($useWinget) {
            log "Installing $($tool.Name) via winget..."
            & winget install --id $tool.Winget -e --accept-source-agreements --accept-package-agreements
        } elseif ($useChoco) {
            log "Installing $($tool.Name) via choco..."
            & choco install $tool.Choco -y
        } else {
            warn "$($tool.Name) not found. Install winget or Chocolatey, then re-run."
        }
    }
} elseif ($_IsMacOS) {
    if (-not (Get-Command brew -ErrorAction SilentlyContinue)) {
        warn "Homebrew not found. Install from https://brew.sh then re-run."
        exit 1
    }
    foreach ($pkg in @('starship', 'zoxide', 'fzf')) {
        if (Get-Command $pkg -ErrorAction SilentlyContinue) {
            log "$pkg already installed — skipping"
        } else {
            log "Installing $pkg..."
            & brew install $pkg
        }
    }
} elseif ($_IsLinux) {
    $needInstall = @('starship', 'zoxide', 'fzf') | Where-Object { -not (Get-Command $_ -ErrorAction SilentlyContinue) }
    if ($needInstall) {
        if (Get-Command apt-get -ErrorAction SilentlyContinue) {
            log "Installing fzf and zoxide via apt..."
            & sudo apt-get update -qq
            & sudo apt-get install -y fzf zoxide
        }
        if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
            log "Installing starship..."
            & bash -c 'curl -sS https://starship.rs/install.sh | sh -s -- --yes'
        }
    } else {
        log "All tools already installed"
    }
}

# ── PowerShell modules ────────────────────────────────────────────────────────
log "Installing PowerShell modules..."
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -eq 'Restricted' -or $policy -eq 'Undefined') {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
}

foreach ($mod in @('PSReadLine', 'PSFzf')) {
    if (Get-Module $mod -ListAvailable -ErrorAction SilentlyContinue) {
        log "$mod already installed — skipping"
    } else {
        log "Installing $mod..."
        Install-Module $mod -Scope CurrentUser -Force -AllowClobber
    }
}

# ── get_weather.py ────────────────────────────────────────────────────────────
$weatherDest = "$INSTALL_DIR/get_weather.py"
if (-not (Test-Path $weatherDest)) {
    log "Copying get_weather.py..."
    Copy-Item "$REPO_DIR/shared/get_weather.py" $weatherDest
} else {
    log "get_weather.py already in place"
}

# ── Wire up $PROFILE ──────────────────────────────────────────────────────────
$sourceLine = ". `"$INSTALL_DIR/profile.ps1`""
$profileDir = Split-Path $PROFILE

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (Test-Path $PROFILE) {
    if (Select-String -Path $PROFILE -Pattern 'JARVIS-FRIDAY' -Quiet) {
        log "`$PROFILE already configured — skipping"
    } else {
        Add-Content $PROFILE "`n$sourceLine"
        log "Added sourcing line to `$PROFILE"
    }
} else {
    Set-Content $PROFILE $sourceLine
    log "Created `$PROFILE"
}

# ── Conda (optional) ──────────────────────────────────────────────────────────
if (prompt-yn "Install Miniconda?") {
    $condaPath = "$HOME/miniconda3"
    $condaExe  = if ($_IsWindows) { "$condaPath/Scripts/conda.exe" } else { "$condaPath/bin/conda" }
    if (-not ((Get-Command conda -ErrorAction SilentlyContinue) -or (Test-Path $condaExe))) {
        log "Installing Miniconda..."
        if ($_IsWindows) {
            $installer = "$env:TEMP/miniconda.exe"
            Invoke-WebRequest 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe' -OutFile $installer
            & $installer /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /S "/D=$condaPath"
            Remove-Item $installer -ErrorAction SilentlyContinue
        } elseif ($_IsMacOS) {
            $installer = '/tmp/miniconda.sh'
            & bash -c "curl -fsSL -o $installer https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh && bash $installer -b -p $condaPath && rm $installer"
        } else {
            $installer = '/tmp/miniconda.sh'
            & bash -c "curl -fsSL -o $installer https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && bash $installer -b -p $condaPath && rm $installer"
        }
    } else {
        log "Conda already installed — skipping install"
    }
    log "Running conda init powershell..."
    & $condaExe init powershell
    log "Conda ready. Restart PowerShell to activate."
} else {
    log "Skipping Conda"
}

Write-Host ""
Write-Host "  ${CYAN}╔══[ INSTALLATION COMPLETE ]══════════════╗${RESET}"
Write-Host "  ${CYAN}║  Restart PowerShell to activate JARVIS  ║${RESET}"
Write-Host "  ${CYAN}╚══════════════════════════════════════════╝${RESET}"
Write-Host ""
