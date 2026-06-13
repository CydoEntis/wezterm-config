#!/usr/bin/env bash
set -e

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Link wezterm.lua
ln -sf "$REPO/wezterm.lua" "$HOME/.wezterm.lua"
echo "Linked ~/.wezterm.lua"

# Screenshots directory (used by clip2path plugin)
mkdir -p "$HOME/Pictures/screenshots"
echo "Created ~/Pictures/screenshots"

echo ""
echo "Done! Restart WezTerm — plugins will download automatically on first launch."
