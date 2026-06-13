#!/usr/bin/env bash
set -e

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- wezterm.lua symlink ---
ln -sf "$REPO/wezterm.lua" "$HOME/.wezterm.lua"
echo "Linked ~/.wezterm.lua"

# --- screenshots dir ---
mkdir -p "$HOME/Pictures/screenshots"
echo "Created ~/Pictures/screenshots"

# --- WezTerm plugins ---
# Pre-seed the plugin cache so WezTerm finds them without needing git in its
# process environment. On Linux/Mac the GUI process usually inherits PATH, but
# pre-seeding is still faster than waiting for WezTerm to clone on first launch.
case "$(uname)" in
  Darwin) PLUGIN_ROOT="$HOME/Library/Application Support/wezterm/plugins" ;;
  *)      PLUGIN_ROOT="$HOME/.local/share/wezterm/plugins" ;;
esac
mkdir -p "$PLUGIN_ROOT"

declare -A PLUGINS=(
  ["httpssCssZssZsgithubsDscomsZsCydoEntissZsclip2pathsDswezterm"]="https://github.com/CydoEntis/clip2path.wezterm"
  ["httpssCssZssZsgithubsDscomsZsisseii10sZsworkspacesDspickersDswezterm"]="https://github.com/isseii10/workspace-picker.wezterm"
  ["httpssCssZssZsgithubsDscomsZssrackhamsZstabsetsDswezterm"]="https://github.com/srackham/tabsets.wezterm"
)

if ! command -v git &>/dev/null; then
  echo "WARNING: git not found — skipping plugin pre-seed."
  echo "  Install git and re-run this script to pre-seed WezTerm plugins."
else
  for encoded in "${!PLUGINS[@]}"; do
    url="${PLUGINS[$encoded]}"
    dir="$PLUGIN_ROOT/$encoded"
    if [ -f "$dir/plugin/init.lua" ]; then
      echo "Updating plugin: $url"
      git -C "$dir" pull --quiet
    else
      echo "Installing plugin: $url"
      rm -rf "$dir"
      git clone --quiet "$url" "$dir"
    fi
  done
fi

echo ""
echo "Done! Restart WezTerm to apply the config."
