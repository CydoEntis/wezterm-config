#!/usr/bin/env bash
set -e

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- wezterm.lua symlink ---
cp "$REPO/wezterm.lua" "$HOME/.wezterm.lua"
echo "Copied ~/.wezterm.lua"

# --- screenshots dir (used by clip2path plugin) ---
mkdir -p "$HOME/Pictures/screenshots"
echo "Created ~/Pictures/screenshots"

# --- WezTerm plugin cache ---
# WezTerm's auto-clone is unreliable; we pre-seed the cache so plugins load
# on first launch without any manual steps.
case "$(uname)" in
  Darwin) PLUGIN_ROOT="$HOME/Library/Application Support/wezterm/plugins" ;;
  *)      PLUGIN_ROOT="$HOME/.local/share/wezterm/plugins" ;;
esac
mkdir -p "$PLUGIN_ROOT"

declare -A PLUGINS=(
  ["httpssCssZssZsgithubsDscomsZsCydoEntissZsclip2pathsDswezterm"]="https://github.com/CydoEntis/clip2path.wezterm"
  ["httpssCssZssZsgithubsDscomsZsisseii10sZsworkspacesDpickersDswezterm"]="https://github.com/isseii10/workspace-picker.wezterm"
  ["httpssCssZssZsgithubsDscomsZssrackhamsZstabsetsDswezterm"]="https://github.com/srackham/tabsets.wezterm"
)

if ! command -v git &>/dev/null; then
  echo "WARNING: git not found — skipping plugin pre-seed. Install Git and re-run."
else
  for encoded in "${!PLUGINS[@]}"; do
    url="${PLUGINS[$encoded]}"
    dir="$PLUGIN_ROOT/$encoded"
    if [ -f "$dir/plugin/init.lua" ]; then
      echo "Updating: $url"
      git -C "$dir" pull --quiet 2>/dev/null
    else
      echo "Installing: $url"
      rm -rf "$dir"
      git clone --quiet "$url" "$dir" 2>/dev/null
    fi
  done
fi

echo ""
echo "Done! Restart WezTerm to apply the config."
