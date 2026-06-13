# WezTerm config installer for Windows
# Run from an elevated (Administrator) PowerShell prompt for symlink support.
# If you can't run as admin, use the -Copy flag to copy files instead.
param([switch]$Copy)

$repo = $PSScriptRoot
$userHome = $env:USERPROFILE

# Link wezterm.lua
$src  = "$repo\wezterm.lua"
$dest = "$userHome\.wezterm.lua"
if (Test-Path $dest) { Remove-Item $dest -Force }
if ($Copy) {
    Copy-Item $src $dest
    Write-Host "Copied:  $dest"
} else {
    New-Item -ItemType SymbolicLink -Path $dest -Target $src | Out-Null
    Write-Host "Linked:  $dest"
}

# Screenshots directory (used by clip2path plugin)
$screenshotsDir = "$userHome\Pictures\screenshots"
if (-not (Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir | Out-Null
    Write-Host "Created: $screenshotsDir"
}

# Check git is in SYSTEM PATH — WezTerm's GUI process needs it to auto-download plugins
$systemPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
$gitInSystem = ($systemPath -split ";") -match "Git"
if (-not $gitInSystem) {
    Write-Host ""
    Write-Host "WARNING: Git is not in the Windows system PATH." -ForegroundColor Yellow
    Write-Host "  WezTerm plugins won't auto-download on first launch."
    Write-Host "  Fix: reinstall Git and choose 'Git from the command line and also from 3rd-party software'."
}

Write-Host ""
Write-Host "Done! Restart WezTerm — plugins will download automatically on first launch."
