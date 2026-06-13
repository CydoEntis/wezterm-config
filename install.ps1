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

# --- screenshots dir (used by clip2path plugin) ---
$screenshotsDir = "$userHome\Pictures\screenshots"
if (-not (Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir | Out-Null
    Write-Host "Created: $screenshotsDir"
}

# --- WezTerm plugin cache ---
# WezTerm's auto-clone is unreliable; we pre-seed the cache so plugins load
# on first launch without any manual steps.
$pluginRoot = "$env:APPDATA\wezterm\plugins"
if (-not (Test-Path $pluginRoot)) { New-Item -ItemType Directory -Path $pluginRoot | Out-Null }

$plugins = @(
    @{ url = "https://github.com/CydoEntis/clip2path.wezterm";       dir = "httpssCssZssZsgithubsDscomsZsCydoEntissZsclip2pathsDswezterm" }
    @{ url = "https://github.com/isseii10/workspace-picker.wezterm"; dir = "httpssCssZssZsgithubsDscomsZsisseii10sZsworkspacesDpickersDswezterm" }
    @{ url = "https://github.com/srackham/tabsets.wezterm";          dir = "httpssCssZssZsgithubsDscomsZssrackhamsZstabsetsDswezterm" }
)

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "WARNING: git not found — skipping plugin pre-seed. Install Git and re-run." -ForegroundColor Yellow
} else {
    foreach ($p in $plugins) {
        $dir = "$pluginRoot\$($p.dir)"
        if (Test-Path "$dir\plugin\init.lua") {
            Write-Host "Updating: $($p.url)"
            git -C $dir pull --quiet 2>&1 | Out-Null
        } else {
            Write-Host "Installing: $($p.url)"
            if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
            git clone --quiet $p.url $dir 2>&1 | Out-Null
        }
    }
}

Write-Host ""
Write-Host "Done! Restart WezTerm to apply the config."
