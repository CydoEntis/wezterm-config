# WezTerm config installer for Windows
# Run from an elevated (Administrator) PowerShell prompt for symlink support.
# If you can't run as admin, use the -Copy flag to copy files instead.
param([switch]$Copy)

$repo = $PSScriptRoot
$home = $env:USERPROFILE

$links = @{
    "$home\.wezterm.lua" = "$repo\wezterm.lua"
    "$home\clip2path.ps1" = "$repo\scripts\clip2path.ps1"
}

foreach ($entry in $links.GetEnumerator()) {
    if (Test-Path $entry.Key) {
        Write-Host "Already exists, skipping: $($entry.Key)"
        continue
    }
    if ($Copy) {
        Copy-Item $entry.Value $entry.Key
        Write-Host "Copied: $($entry.Key)"
    } else {
        New-Item -ItemType SymbolicLink -Path $entry.Key -Target $entry.Value | Out-Null
        Write-Host "Linked: $($entry.Key)"
    }
}

$screenshotsDir = "$home\Pictures\screenshots"
if (-not (Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir | Out-Null
    Write-Host "Created: $screenshotsDir"
}

Write-Host ""
Write-Host "Done! Restart WezTerm to apply the config."
