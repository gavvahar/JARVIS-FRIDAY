# ─── J.A.R.V.I.S. / F.R.I.D.A.Y. — PowerShell Profile ──────────────────────

# ── OS & version detection ────────────────────────────────────────────────────
$_PSMajor   = $PSVersionTable.PSVersion.Major
$_IsWindows = if ($_PSMajor -ge 6) { $IsWindows } else { $env:OS -eq 'Windows_NT' }
$_IsLinux   = if ($_PSMajor -ge 6) { $IsLinux }   else { $false }
$_IsMacOS   = if ($_PSMajor -ge 6) { $IsMacOS }   else { $false }

$_ConfigDir = $PSScriptRoot

# ── FRIDAY mode ───────────────────────────────────────────────────────────────
$_IsFriday = (Get-Date).DayOfWeek -eq 'Friday'
$_ESC      = [char]27

if ($_IsFriday) {
    $env:STARSHIP_CONFIG = "$_ConfigDir/../shared/starship-friday.toml"
    $_Bold   = "$_ESC[1;38;2;192;132;252m"
    $_Color  = "$_ESC[38;2;192;132;252m"
    $_AIName = 'F.R.I.D.A.Y.'
    $_AIFull = 'Female Replacement Intelligent Digital Asst.'
    $_StatusMessages = @(
        'All systems green.',
        'Ready when you are.',
        'Standing by.',
        'Online and operational.',
        'Good to go.',
        'At your service.',
        'Systems clear.'
    )
} else {
    $env:STARSHIP_CONFIG = "$_ConfigDir/../shared/starship.toml"
    $_Bold   = "$_ESC[1;36m"
    $_Color  = "$_ESC[36m"
    $_AIName = 'J.A.R.V.I.S.'
    $_AIFull = 'Just A Rather Very Intelligent System'
    $_StatusMessages = @(
        'All systems operational.',
        'Running at peak efficiency.',
        'No anomalies detected.',
        'Diagnostics complete. All clear.',
        'Systems nominal. Standing by.'
    )
}
$_Reset = "$_ESC[0m"

# Define box-drawing characters via code points so the source file contains no
# multi-byte UTF-8 sequences that PS 5.1 misreads as string delimiters under
# Windows-1252 (e.g. 0x94 = curly double-quote, which closes double-quoted strings).
$_C_HR = [char]0x2550  # =
$_C_VR = [char]0x2551  # |
$_C_TL = [char]0x2554  # top-left corner
$_C_TR = [char]0x2557  # top-right corner
$_C_BL = [char]0x255A  # bottom-left corner
$_C_BR = [char]0x255D  # bottom-right corner
$_C_LM = [char]0x2560  # left mid-separator
$_C_RM = [char]0x2563  # right mid-separator
$_C_DI = [char]0x25C8  # diamond bullet
$_C_EM = [char]0x2014  # em dash

# ── Box helpers ───────────────────────────────────────────────────────────────
function _jv_row([string]$text, [int]$width) {
    $content = "  $text"
    if ($content.Length -gt $width) { $content = $content.Substring(0, $width) }
    "$_Color  ${_C_VR}$($content.PadRight($width))${_C_VR}$_Reset"
}

function _jv_sep([int]$width) {
    "$_Bold  ${_C_LM}$("$_C_HR" * $width)${_C_RM}$_Reset"
}

# ── System info ───────────────────────────────────────────────────────────────
function _jv_sysinfo {
    $info = [ordered]@{ Uptime = ''; Memory = ''; CpuLoad = ''; Disk = ''; DriveName = ''; Network = '' }

    if ($_IsWindows) {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        if ($os) {
            $up = (Get-Date) - $os.LastBootUpTime
            $info.Uptime = if ($up.Days -gt 0) {
                "$($up.Days)d $($up.Hours)h $($up.Minutes)m"
            } else {
                "$($up.Hours)h $($up.Minutes)m"
            }
            $usedMB  = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1024, 1)
            $totalMB = [math]::Round($os.TotalVisibleMemorySize / 1024, 1)
            $info.Memory = "${usedMB}M/${totalMB}M"
        }
        $cpu = (Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue |
                Measure-Object LoadPercentage -Average).Average
        if ($null -ne $cpu) { $info.CpuLoad = "${cpu}%" }
        $net = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
               Where-Object { $_.InterfaceAlias -notmatch 'Loopback|Bluetooth|vEthernet' } |
               Select-Object -First 1
        if ($net) { $info.Network = $net.IPAddress }
        $info.DriveName = 'C:\'
        $disk = Get-PSDrive C -ErrorAction SilentlyContinue
    } elseif ($_IsLinux) {
        $up = & uptime -p 2>$null
        if ($up) { $info.Uptime = $up -replace '^up ', '' }
        $mem = Get-Content /proc/meminfo -ErrorAction SilentlyContinue
        if ($mem) {
            $total = [long](($mem | Select-String '^MemTotal').Line -replace '\D')
            $avail = [long](($mem | Select-String '^MemAvailable').Line -replace '\D')
            $usedGB  = [math]::Round(($total - $avail) / 1MB, 1)
            $totalGB = [math]::Round($total / 1MB, 1)
            $info.Memory = "${usedGB}G/${totalGB}G"
        }
        $load = Get-Content /proc/loadavg -ErrorAction SilentlyContinue
        if ($load) { $info.CpuLoad = ($load -split ' ')[0] }
        $netLine = (& ip route get 1 2>$null) -join ' '
        if ($netLine -match 'src\s+(\S+)') { $info.Network = $Matches[1] }
        $info.DriveName = '/'
        $disk = Get-PSDrive -Name '/' -ErrorAction SilentlyContinue
    } elseif ($_IsMacOS) {
        $boot = (& sysctl -n kern.boottime 2>$null) -join ''
        if ($boot -match 'sec\s*=\s*(\d+)') {
            $up = (Get-Date) - [DateTimeOffset]::FromUnixTimeSeconds([long]$Matches[1]).LocalDateTime
            $info.Uptime = if ($up.Days -gt 0) {
                "$($up.Days)d $($up.Hours)h $($up.Minutes)m"
            } else {
                "$($up.Hours)h $($up.Minutes)m"
            }
        }
        $totalBytes = (& sysctl -n hw.memsize 2>$null) -join ''
        $vmStat = & vm_stat 2>$null
        if ($totalBytes -and $vmStat) {
            $active = [long](($vmStat | Select-String 'Pages active').Line -replace '\D')
            $wired  = [long](($vmStat | Select-String 'Pages wired').Line -replace '\D')
            $usedGB  = [math]::Round(($active + $wired) * 4096 / 1GB, 1)
            $totalGB = [math]::Round([long]$totalBytes / 1GB, 1)
            $info.Memory = "${usedGB}G/${totalGB}G"
        }
        $loadLine = (& sysctl -n vm.loadavg 2>$null) -join ''
        if ($loadLine) { $info.CpuLoad = ($loadLine -split '\s+')[1] }
        $iface = (& route get default 2>$null | Select-String 'interface:')
        if ($iface) {
            $ifName = ($iface.Line -split ':')[1].Trim()
            $ip = & ipconfig getifaddr $ifName 2>$null
            if ($ip) { $info.Network = ($ip -join '').Trim() }
        }
        $info.DriveName = '/'
        $disk = Get-PSDrive -Name '/' -ErrorAction SilentlyContinue
    }

    if ($disk -and ($disk.Used + $disk.Free) -gt 0) {
        $usedGB  = [math]::Round($disk.Used / 1GB, 1)
        $totalGB = [math]::Round(($disk.Used + $disk.Free) / 1GB, 1)
        $pct     = [math]::Round($disk.Used / ($disk.Used + $disk.Free) * 100)
        $info.Disk = "${usedGB}G/${totalGB}G (${pct}%)"
    }

    return $info
}

# ── Greeting ──────────────────────────────────────────────────────────────────
function _jv_greeting {
    $hour    = (Get-Date).Hour
    $period  = if ($hour -lt 12) { 'morning' } elseif ($hour -lt 17) { 'afternoon' } else { 'evening' }
    $dt      = (Get-Date).ToString('dddd, MMMM dd yyyy ') + $_C_EM + (Get-Date).ToString(' hh:mm tt')
    $user    = if ($env:USER) { $env:USER } else { $env:USERNAME }
    $status  = $_StatusMessages | Get-Random
    $sys     = _jv_sysinfo
    $width   = 60
    $sep     = "$_C_HR" * $width
    $hdr     = "${_C_HR}${_C_HR}[ $_AIName ]"
    $hdrFill = "$_C_HR" * ($width - $hdr.Length)

    Write-Host ""
    Write-Host "  ${_Bold}${_C_TL}${hdr}${hdrFill}${_C_TR}${_Reset}"
    Write-Host (_jv_row $_AIFull $width)
    Write-Host "  ${_Bold}${_C_LM}${sep}${_C_RM}${_Reset}"
    Write-Host (_jv_row "Good $period, $user." $width)
    Write-Host (_jv_row $dt $width)
    if ($sys.Uptime)  { Write-Host (_jv_row "Uptime: $($sys.Uptime)" $width) }
    if ($sys.Memory -and $sys.CpuLoad) {
        Write-Host (_jv_row "Memory: $($sys.Memory)   CPU: $($sys.CpuLoad)" $width)
    }
    Write-Host "  ${_Bold}${_C_LM}${sep}${_C_RM}${_Reset}"
    Write-Host (_jv_row "${_C_DI} $status" $width)
    Write-Host "  ${_Bold}${_C_BL}${sep}${_C_BR}${_Reset}"
    Write-Host ""
}

# ── jarvis ────────────────────────────────────────────────────────────────────
function jarvis {
    $sys     = _jv_sysinfo
    $width   = 54
    $sep     = "$_C_HR" * $width
    $hdr     = "${_C_HR}${_C_HR}[ $_AIName DIAGNOSTICS ]"
    $hdrFill = "$_C_HR" * ($width - $hdr.Length)

    Write-Host ""
    Write-Host "  ${_Bold}${_C_TL}${hdr}${hdrFill}${_C_TR}${_Reset}"
    if ($sys.Uptime)    { Write-Host (_jv_row "Uptime:   $($sys.Uptime)"   $width) }
    if ($sys.Memory)    { Write-Host (_jv_row "Memory:   $($sys.Memory)"   $width) }
    if ($sys.CpuLoad)   { Write-Host (_jv_row "CPU Load: $($sys.CpuLoad)"  $width) }
    if ($sys.Disk)      { Write-Host (_jv_row "Disk $($sys.DriveName):  $($sys.Disk)" $width) }
    if ($sys.Network)   { Write-Host (_jv_row "Network:  $($sys.Network)"  $width) }
    if ($env:CONDA_DEFAULT_ENV -and $env:CONDA_DEFAULT_ENV -ne 'base') {
        Write-Host (_jv_row "Conda:    $env:CONDA_DEFAULT_ENV" $width)
    }
    Write-Host "  ${_Bold}${_C_BL}${sep}${_C_BR}${_Reset}"
    Write-Host ""
}

# ── brief ─────────────────────────────────────────────────────────────────────
$script:_WeatherScript = "$_ConfigDir/get_weather.py"
$script:_LocationsFile = "$_ConfigDir/jarvis-locations.json"

function _jv_load_locations {
    if (Test-Path $script:_LocationsFile) {
        $json = Get-Content $script:_LocationsFile -Raw -ErrorAction SilentlyContinue
        if ($json) { return @(($json | ConvertFrom-Json)) }
    }
    return @()
}

function brief {
    $hour   = (Get-Date).Hour
    $period = if ($hour -lt 12) { 'morning' } elseif ($hour -lt 17) { 'afternoon' } else { 'evening' }
    $dt     = (Get-Date).ToString('dddd, MMMM dd yyyy ') + $_C_EM + (Get-Date).ToString(' hh:mm tt')
    $sys    = _jv_sysinfo
    $locs   = _jv_load_locations
    $width  = 60
    $sep    = "$_C_HR" * $width
    $hdr     = "${_C_HR}${_C_HR}[ $_AIName BRIEF ]"
    $hdrFill = "$_C_HR" * ($width - $hdr.Length)

    $weatherLines = @()
    if ((Test-Path $script:_WeatherScript) -and (Get-Command python3 -ErrorAction SilentlyContinue)) {
        if ($locs.Count -gt 0) {
            foreach ($loc in $locs) {
                $w = & python3 $script:_WeatherScript $loc 2>$null
                if ($w) { $weatherLines += $w }
            }
        } else {
            $w = & python3 $script:_WeatherScript 2>$null
            if ($w) { $weatherLines += $w }
        }
    }

    Write-Host ""
    Write-Host "  ${_Bold}${_C_TL}${hdr}${hdrFill}${_C_TR}${_Reset}"
    Write-Host (_jv_row "Good $period. Here is your briefing." $width)
    Write-Host (_jv_row $dt $width)
    if ($weatherLines.Count -gt 0) {
        Write-Host (_jv_row '' $width)
        Write-Host (_jv_row 'Weather:' $width)
        foreach ($w in $weatherLines) {
            $parts = $w -split ':::'
            if ($parts.Count -ge 3) {
                $loc  = $parts[0].PadRight(17).Substring(0, 17)
                $time = $parts[1]
                $cond = $parts[2]
                Write-Host (_jv_row "  $loc  $time  $cond" $width)
            }
        }
    }
    Write-Host "  ${_Bold}${_C_LM}${sep}${_C_RM}${_Reset}"
    if ($sys.Uptime)  { Write-Host (_jv_row "Uptime:   $($sys.Uptime)"  $width) }
    if ($sys.Memory)  { Write-Host (_jv_row "Memory:   $($sys.Memory)"  $width) }
    if ($sys.CpuLoad) { Write-Host (_jv_row "CPU:      $($sys.CpuLoad)" $width) }
    if ($sys.Disk)    { Write-Host (_jv_row "Disk:     $($sys.Disk)"    $width) }
    if ($sys.Network) { Write-Host (_jv_row "Network:  $($sys.Network)" $width) }
    Write-Host "  ${_Bold}${_C_BL}${sep}${_C_BR}${_Reset}"
    Write-Host ""
}

# ── jarvis-locate ─────────────────────────────────────────────────────────────
function jarvis-locate {
    param(
        [string]$Sub = '',
        [Parameter(ValueFromRemainingArguments)][string[]]$Rest
    )
    $loc = ($Rest -join ' ').Trim()

    if ($Sub -eq '' -or $Sub -eq 'list') {
        $locs = _jv_load_locations
        if ($locs.Count -eq 0) {
            Write-Host "  ${_Color}${_C_DI}${_Reset} No locations set ${_C_EM} using IP detection."
        } else {
            Write-Host "  ${_Bold}Monitored locations:$_Reset"
            for ($i = 0; $i -lt $locs.Count; $i++) {
                Write-Host "  $_Color$($i + 1).$_Reset $($locs[$i])"
            }
        }
    } elseif ($Sub -eq 'add') {
        if (-not $loc) { Write-Host 'Usage: jarvis-locate add "City, State"'; return }
        $locs = [System.Collections.Generic.List[string]](_jv_load_locations)
        $locs.Add($loc)
        $locs | ConvertTo-Json | Set-Content $script:_LocationsFile
        Write-Host "  ${_Color}${_C_DI}${_Reset} Added: $loc"
    } elseif ($Sub -eq 'remove') {
        if (-not $loc) { Write-Host 'Usage: jarvis-locate remove "City, State"'; return }
        $locs = [System.Collections.Generic.List[string]](_jv_load_locations | Where-Object { $_ -ne $loc })
        $locs | ConvertTo-Json | Set-Content $script:_LocationsFile
        Write-Host "  ${_Color}${_C_DI}${_Reset} Removed: $loc"
    } elseif ($Sub -eq 'clear') {
        '[]' | Set-Content $script:_LocationsFile
        Write-Host "  ${_Color}${_C_DI}${_Reset} All locations cleared. Falling back to IP detection."
    } else {
        Write-Host 'Usage:'
        Write-Host "  jarvis-locate                       ${_C_EM} show monitored locations"
        Write-Host "  jarvis-locate add `"City, State`"    ${_C_EM} add a location"
        Write-Host "  jarvis-locate remove `"City, State`" ${_C_EM} remove a location"
        Write-Host "  jarvis-locate clear                 ${_C_EM} clear all locations"
    }
}

# ── PSReadLine ────────────────────────────────────────────────────────────────
if (Get-Module PSReadLine -ListAvailable -ErrorAction SilentlyContinue) {
    Import-Module PSReadLine
    $psrlVersion = (Get-Module PSReadLine).Version
    if ($psrlVersion -ge [version]'2.1.0') {
        Set-PSReadLineOption -PredictionSource History
    }
    Set-PSReadLineKeyHandler -Key Tab             -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow         -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow       -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow  -Function BackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    if ($psrlVersion -ge [version]'2.2.0') {
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
    if ($_IsFriday) {
        Set-PSReadLineOption -Colors @{
            Command   = "$_ESC[38;2;192;132;252m"
            Comment   = "$_ESC[38;2;85;51;102m"
            Keyword   = "$_ESC[38;2;251;191;36m"
            Parameter = "$_ESC[37m"
        }
    } else {
        Set-PSReadLineOption -Colors @{
            Command   = "$_ESC[36m"
            Comment   = "$_ESC[90m"
            Keyword   = "$_ESC[34m"
            Parameter = "$_ESC[37m"
        }
    }
}

# ── PSFzf ─────────────────────────────────────────────────────────────────────
if (Get-Module PSFzf -ListAvailable -ErrorAction SilentlyContinue) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# ── Zoxide ────────────────────────────────────────────────────────────────────
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ── Starship ──────────────────────────────────────────────────────────────────
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# ── Git shortcuts ─────────────────────────────────────────────────────────────
function gs  { git status @args }
function ga  { git add @args }
function gc  { git commit @args }
function gp  { git push @args }
function gl  { git pull @args }

# ── Conda ─────────────────────────────────────────────────────────────────────
$_condaPaths = @(
    (Join-Path $HOME 'miniconda3\Scripts\conda.exe'),
    "$HOME/miniconda3/bin/conda",
    "$HOME/opt/miniconda3/bin/conda",
    'C:\ProgramData\miniconda3\Scripts\conda.exe'
)
$_condaExe = Get-Command conda -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue
if (-not $_condaExe) {
    $_condaExe = $_condaPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if ($_condaExe) {
    (& $_condaExe 'shell.powershell' 'hook') | Out-String | Invoke-Expression
}

# ── Greeting ──────────────────────────────────────────────────────────────────
_jv_greeting
