# WezTerm config installer for Windows
# Run from an elevated (Administrator) PowerShell prompt for symlink support.
# If you can't run as admin, use the -Copy flag to copy files instead.
param([switch]$Copy)

$repo = $PSScriptRoot
$userHome = $env:USERPROFILE

# --- wezterm.lua symlink / copy ---
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

# --- screenshots dir ---
$screenshotsDir = "$userHome\Pictures\screenshots"
if (-not (Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir | Out-Null
    Write-Host "Created: $screenshotsDir"
}

# --- WezTerm plugins ---
# WezTerm's GUI process only sees the SYSTEM PATH, not the user PATH, so it
# can't always find git to auto-clone plugins. We pre-seed the cache here using
# whatever git the current shell can find (user or system PATH).
$pluginRoot = "$env:APPDATA\wezterm\plugins"
if (-not (Test-Path $pluginRoot)) {
    New-Item -ItemType Directory -Path $pluginRoot | Out-Null
}

$plugins = @(
    @{ url = "https://github.com/CydoEntis/clip2path.wezterm";        dir = "httpssCssZssZsgithubsDscomsZsCydoEntissZsclip2pathsDswezterm" }
    @{ url = "https://github.com/isseii10/workspace-picker.wezterm";  dir = "httpssCssZssZsgithubsDscomsZsisseii10sZsworkspacesDspickersDswezterm" }
    @{ url = "https://github.com/srackham/tabsets.wezterm";           dir = "httpssCssZssZsgithubsDscomsZssrackhamsZstabsetsDswezterm" }
)

$gitOk = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
if (-not $gitOk) {
    Write-Host ""
    Write-Host "WARNING: git not found in PATH." -ForegroundColor Yellow
    Write-Host "  WezTerm plugins will not be pre-seeded."
    Write-Host "  To fix: reinstall Git and choose 'Add Git to system PATH'."
    Write-Host "  Plugins already in the cache will still load fine."
} else {
    foreach ($p in $plugins) {
        $dir = "$pluginRoot\$($p.dir)"
        if (Test-Path "$dir\plugin\init.lua") {
            Write-Host "Plugin up to date (pull): $($p.url)"
            git -C $dir pull --quiet
        } else {
            Write-Host "Installing plugin: $($p.url)"
            if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
            git clone --quiet $p.url $dir
        }
    }
}

# --- system PATH advisory ---
$systemPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
$gitInSystemPath = $systemPath -split ";" | Where-Object { $_ -like "*Git*" }
if (-not $gitInSystemPath) {
    Write-Host ""
    Write-Host "TIP: Git is not in the Windows SYSTEM PATH." -ForegroundColor Cyan
    Write-Host "  WezTerm launched from the taskbar won't auto-download new plugins."
    Write-Host "  Fix: reinstall Git → choose 'Git from the command line and also from 3rd-party software'."
}

Write-Host ""
Write-Host "Done! Restart WezTerm to apply the config."
