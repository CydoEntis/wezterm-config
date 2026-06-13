local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find("windows") ~= nil
local home = os.getenv(is_windows and "USERPROFILE" or "HOME")

-- Plugins (each wrapped so a failure doesn't break the whole config)
local function load_plugin(url)
  local ok, plugin = pcall(wezterm.plugin.require, url)
  if not ok then
    wezterm.log_error("Failed to load plugin: " .. url)
    return nil
  end
  return plugin
end

local bar                = load_plugin("https://github.com/adriankarlen/bar.wezterm")
local theme_rotator      = load_plugin("https://github.com/koh-sh/wezterm-theme-rotator")
local wezterm_sync       = load_plugin("https://github.com/dfsramos/wezterm-sync")
local quota_limit        = load_plugin("https://github.com/EdenGibson/wezterm-quota-limit")
local agent_deck         = load_plugin("https://github.com/Eric162/wezterm-agent-deck")
local cmdpicker          = load_plugin("https://github.com/abidibo/wezterm-cmdpicker")
local workspace_picker   = load_plugin("https://github.com/isseii10/workspace-picker.wezterm")
local tabsets            = load_plugin("https://github.com/srackham/tabsets.wezterm")
local clip2path          = load_plugin("https://github.com/CydoEntis/clip2path.wezterm")

-- Inline fallback if plugin fails to load
local function clip2path_fallback(window, pane)
  local dir = home .. (is_windows and "\\Pictures\\screenshots" or "/Pictures/screenshots")
  local cmd
  if is_windows then
    cmd = {
      "powershell", "-NoProfile", "-NonInteractive", "-Command",
      string.format([[
        Add-Type -AssemblyName System.Windows.Forms, System.Drawing
        $dir = "%s"
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
        $img = [System.Windows.Forms.Clipboard]::GetImage()
        if ($img -ne $null) {
            $file = "$dir\clip_$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds()).png"
            $img.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
            [Console]::Write($file)
        } else {
            [Console]::Write([System.Windows.Forms.Clipboard]::GetText())
        }
      ]], dir)
    }
  else
    cmd = { "bash", "-c", string.format([[
      dir="%s"; mkdir -p "$dir"
      if pngpaste "$file" 2>/dev/null; then printf '%%s' "$file"
      else pbpaste; fi
    ]], dir) }
  end
  local ok, stdout = wezterm.run_child_process(cmd)
  if ok and stdout and #stdout > 0 then
    pane:send_text(stdout:gsub("[\r\n]+$", ""))
  end
end

-- Font
config.font = wezterm.font("Anka/Coder", { weight = "Regular", stretch = "Normal", style = "Normal" })
config.font_size = 13.0

-- Color scheme (set before bar applies)
config.color_scheme = "PaperColor Dark (base16)"

-- Tab bar colors
config.colors = {
  tab_bar = {
    background = "#1c1c1c",
    active_tab         = { bg_color = "#0087af", fg_color = "#eeeeee" },
    inactive_tab       = { bg_color = "#262626", fg_color = "#585858" },
    inactive_tab_hover = { bg_color = "#303030", fg_color = "#d0d0d0" },
    new_tab            = { bg_color = "#1c1c1c", fg_color = "#585858" },
    new_tab_hover      = { bg_color = "#262626", fg_color = "#d0d0d0" },
  },
}

-- Window appearance
config.window_background_opacity = 1.0
config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }
config.initial_cols = 220
config.initial_rows = 50

-- Tab bar
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- Scrollback / bell / cursor
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.default_cursor_style = "BlinkingBar"
config.foreground_text_hsb = { hue = 1.0, saturation = 1.2, brightness = 1.5 }

-- Leader key (used by cmdpicker: Ctrl+Space then Space = command palette)
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

-- Mouse: right-click copies selection or pastes; triple-click selects semantic zone
config.mouse_bindings = {
  {
    event = { Down = { streak = 3, button = "Left" } },
    action = act.SelectTextAtMouseCursor "SemanticZone",
    mods = "NONE",
  },
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(act.CopyTo "ClipboardAndPrimarySelection", pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.PasteFrom "Clipboard", pane)
      end
    end),
  },
}

-- Apply plugins first so their keys don't overwrite ours (cmdpicker must be last)
if bar           then bar.apply_to_config(config) end
if theme_rotator then theme_rotator.apply_to_config(config) end
if wezterm_sync  then wezterm_sync.apply_to_config(config) end
if quota_limit   then quota_limit.apply_to_config(config) end
if agent_deck    then agent_deck.apply_to_config(config) end
-- workspace-picker: LEADER+s = fuzzy picker, LEADER+S = new workspace, LEADER+r = rename
if workspace_picker then workspace_picker.apply_to_config(config) end
-- tabsets: event-driven; keys added below
if tabsets then
  tabsets.setup({ fuzzy_selector = true })
  wezterm.on("save_tabset",   function(window) tabsets.save_tabset(window) end)
  wezterm.on("load_tabset",   function(window) tabsets.load_tabset(window) end)
  wezterm.on("delete_tabset", function(window) tabsets.delete_tabset(window) end)
  wezterm.on("rename_tabset", function(window) tabsets.rename_tabset(window) end)
end
-- cmdpicker last (must be last per existing comment)
if clip2path then
  clip2path.apply_to_config(config)
else
  -- plugin didn't load; use inline implementation
  table.insert(config.keys, {
    key = "v", mods = "CTRL|ALT",
    action = wezterm.action_callback(clip2path_fallback),
  })
end
if cmdpicker  then cmdpicker.apply_to_config(config, { title = "Command Palette" }) end

-- Append our custom keys after plugins so nothing overwrites them
if not config.keys then config.keys = {} end
local custom_keys = {
  -- Split panes (Warp-style)
  { key = "d", mods = "CTRL",       action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "d", mods = "CTRL|SHIFT", action = act.SplitVertical   { domain = "CurrentPaneDomain" } },

  -- Navigate panes
  { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Left"  },
  { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Right" },
  { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Up"    },
  { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Down"  },

  -- Resize panes
  { key = "h", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize { "Left",  5 } },
  { key = "l", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize { "Right", 5 } },
  { key = "k", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize { "Up",    5 } },
  { key = "j", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize { "Down",  5 } },

  -- Close / zoom pane
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane { confirm = true } },
  { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },


}
-- tabsets: LEADER+t=save, LEADER+o=load, LEADER+x=delete, LEADER+e=rename
-- (avoids conflict with workspace-picker's LEADER+S)
if tabsets then
  table.insert(custom_keys, { key = "t", mods = "LEADER", action = act.EmitEvent "save_tabset" })
  table.insert(custom_keys, { key = "o", mods = "LEADER", action = act.EmitEvent "load_tabset" })
  table.insert(custom_keys, { key = "x", mods = "LEADER", action = act.EmitEvent "delete_tabset" })
  table.insert(custom_keys, { key = "e", mods = "LEADER", action = act.EmitEvent "rename_tabset" })
end

for _, k in ipairs(custom_keys) do
  table.insert(config.keys, k)
end

return config
