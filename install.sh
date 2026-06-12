#!/usr/bin/env bash
set -e

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ln -sf "$REPO/wezterm.lua" "$HOME/.wezterm.lua"
echo "Linked ~/.wezterm.lua"

mkdir -p "$HOME/.local/bin"
ln -sf "$REPO/scripts/clip2path" "$HOME/.local/bin/clip2path"
chmod +x "$REPO/scripts/clip2path"
echo "Linked ~/.local/bin/clip2path"

mkdir -p "$HOME/Pictures/screenshots"
echo "Created ~/Pictures/screenshots"

echo ""
echo "Done! Restart WezTerm to apply the config."
