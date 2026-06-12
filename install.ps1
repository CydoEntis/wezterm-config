# WezTerm config installer for Windows
# Run from an elevated (Administrator) PowerShell prompt for symlink support.
# If you can't run as admin, use the -Copy flag to copy files instead.
param([switch]$Copy)

$repo = $PSScriptRoot
$userHome = $env:USERPROFILE

$links = @{
    "$userHome\.wezterm.lua" = "$repo\wezterm.lua"
    "$userHome\clip2path.ps1" = "$repo\scripts\clip2path.ps1"
}

foreach ($entry in $links.GetEnumerator()) {
    if (Test-Path $entry.Key) {
        Remove-Item $entry.Key -Force
    }
    if ($Copy) {
        Copy-Item $entry.Value $entry.Key
        Write-Host "Copied: $($entry.Key)"
    } else {
        New-Item -ItemType SymbolicLink -Path $entry.Key -Target $entry.Value | Out-Null
        Write-Host "Linked: $($entry.Key)"
    }
}

$screenshotsDir = "$userHome\Pictures\screenshots"
if (-not (Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir | Out-Null
    Write-Host "Created: $screenshotsDir"
}

Write-Host ""
Write-Host "Done! Restart WezTerm to apply the config."
