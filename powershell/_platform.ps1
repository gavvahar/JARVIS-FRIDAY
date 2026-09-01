# ─── OS & PowerShell version detection ──────────────────────────────────────
# Shared by install.ps1 (fetched remotely, before the repo is cloned) and
# profile.ps1 (dot-sourced locally from the cloned repo).

$_PSMajor   = $PSVersionTable.PSVersion.Major
$_IsWindows = if ($_PSMajor -ge 6) { $IsWindows } else { $env:OS -eq 'Windows_NT' }
$_IsLinux   = if ($_PSMajor -ge 6) { $IsLinux }   else { $false }
$_IsMacOS   = if ($_PSMajor -ge 6) { $IsMacOS }   else { $false }
