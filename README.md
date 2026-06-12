# wezterm-config

Cross-platform WezTerm configuration for Windows and Linux.

## Features

- **Font**: Anka/Coder
- **Theme**: PaperColor Dark
- **Split panes**: `Ctrl+Shift+\` (horizontal) / `Ctrl+Shift+-` (vertical)
- **Pane navigation**: `Ctrl+Shift+H/J/K/L`
- **Pane resize**: `Ctrl+Shift+Alt+H/J/K/L`
- **Image paste** (`Ctrl+Alt+V`): saves clipboard image to `~/Pictures/screenshots/` and types the path — works with Claude Code

## Setup

### Windows

**1. Install the font**

Download [AnkaCoder](https://www.fontspace.com/anka-coder-font-f17350) and install it (right-click the `.ttf` → Install for all users, or Install).

**2. Clone the repo**

```powershell
git clone https://github.com/YOUR_USERNAME/wezterm-config.git "$HOME\wezterm-config"
```

**3. Run the install script**

Open PowerShell as Administrator, then:

```powershell
~\wezterm-config\install.ps1
```

This symlinks `wezterm.lua` → `~\.wezterm.lua` and `clip2path.ps1` → `~\clip2path.ps1`.

If you can't run as Administrator, pass `-Copy` to copy the files instead of symlinking:

```powershell
~\wezterm-config\install.ps1 -Copy
```

**4. Restart WezTerm.**

---

### Linux

**1. Install the font**

Download AnkaCoder and install it:

```bash
mkdir -p ~/.local/share/fonts
cp /path/to/AnkaCoder*.ttf ~/.local/share/fonts/
fc-cache -fv
```

**2. Install clipboard tools**

```bash
# Ubuntu / Debian
sudo apt install wl-clipboard xclip

# Arch
sudo pacman -S wl-clipboard xclip

# Fedora
sudo dnf install wl-clipboard xclip
```

`wl-clipboard` is used on Wayland sessions; `xclip` is used on X11. Install both to cover either session type.

**3. Clone the repo**

```bash
git clone https://github.com/YOUR_USERNAME/wezterm-config.git ~/wezterm-config
```

**4. Run the install script**

```bash
chmod +x ~/wezterm-config/install.sh
~/wezterm-config/install.sh
```

This symlinks `wezterm.lua` → `~/.wezterm.lua` and `scripts/clip2path` → `~/.local/bin/clip2path`.

**5. Restart WezTerm.**

---

## Image Paste

Press `Ctrl+Alt+V` to paste a clipboard image into any terminal program.

The image is saved to `~/Pictures/screenshots/` and the file path is typed into the active pane. In Claude Code, press Enter after the path appears to submit it.

Works with the Windows Snipping Tool, Linux screenshot tools, and anything else that puts an image on the clipboard.

## Keybindings Reference

| Key | Action |
|-----|--------|
| `Ctrl+Shift+\` | Split pane horizontally |
| `Ctrl+Shift+-` | Split pane vertically |
| `Ctrl+Shift+H/J/K/L` | Navigate panes |
| `Ctrl+Shift+Alt+H/J/K/L` | Resize panes |
| `Ctrl+Shift+W` | Close pane |
| `Ctrl+Shift+Z` | Zoom/unzoom pane |
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous tab |
| `Ctrl+Shift+C` | Copy |
| `Ctrl+Shift+V` | Paste text |
| `Ctrl+Alt+V` | Paste image (saves to `~/Pictures/screenshots/`) |
| `Shift+PageUp/Down` | Scroll |
| `Ctrl+Shift+F` | Search |
