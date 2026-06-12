local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find("windows") ~= nil
local home = os.getenv(is_windows and "USERPROFILE" or "HOME")

-- Plugins
local bar          = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
local theme_rotator = wezterm.plugin.require("https://github.com/koh-sh/wezterm-theme-rotator")
local wezterm_sync = wezterm.plugin.require("https://github.com/dfsramos/wezterm-sync")
local quota_limit  = wezterm.plugin.require("https://github.com/EdenGibson/wezterm-quota-limit")
local agent_deck   = wezterm.plugin.require("https://github.com/Eric162/wezterm-agent-deck")
local cmdpicker    = wezterm.plugin.require("https://github.com/abidibo/wezterm-cmdpicker")

-- Font
config.font = wezterm.font("Anka/Coder", { weight = "Regular", stretch = "Normal", style = "Normal" })
config.font_size = 13.0

-- Color scheme (set before bar.apply_to_config)
config.color_scheme = "PaperColor Dark (base16)"

-- Window appearance
config.window_background_opacity = 1.0
config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }
config.initial_cols = 220
config.initial_rows = 50

-- Tab bar (bar.wezterm will style it)
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- Scrollback
config.scrollback_lines = 10000

-- Bell
config.audible_bell = "Disabled"

-- Cursor
config.default_cursor_style = "BlinkingBar"

-- Slightly brighten text for readability
config.foreground_text_hsb = {
  hue = 1.0,
  saturation = 1.2,
  brightness = 1.5,
}

-- Leader key — used by cmdpicker (Leader then Space = command palette)
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

-- Keybindings
config.keys = {
  -- Split panes
  { key = "\\", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "-",  mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Navigate panes
  { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },

  -- Resize panes
  { key = "H", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Left",  5 }) },
  { key = "L", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "K", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Up",    5 }) },
  { key = "J", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Down",  5 }) },

  -- Close / zoom pane
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },

  -- Tabs
  { key = "t",   mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "Tab", mods = "CTRL",       action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

  -- Copy / paste
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "v", mods = "CTRL",       action = act.SendKey({ key = "v", mods = "CTRL" }) },

  -- Image paste: saves clipboard image to ~/Pictures/screenshots and types the path
  {
    key = "v",
    mods = "CTRL|ALT",
    action = wezterm.action_callback(function(window, pane)
      local cmd
      if is_windows then
        cmd = { "powershell", "-NoProfile", "-NonInteractive", "-File", home .. "\\clip2path.ps1" }
      else
        cmd = { home .. "/.local/bin/clip2path" }
      end
      local success, stdout, stderr = wezterm.run_child_process(cmd)
      if success and stdout and #stdout > 0 then
        local text = stdout:gsub("[\r\n]+$", "")
        pane:send_text(text)
      end
    end),
  },

  -- Scroll
  { key = "PageUp",   mods = "SHIFT", action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },

  -- Search
  { key = "f", mods = "CTRL|SHIFT", action = act.Search({ CaseSensitiveString = "" }) },
}

-- Mouse: right-click copies selection or pastes; triple-click selects semantic zone
config.mouse_bindings = {
  {
    event = { Down = { streak = 3, button = "Left" } },
    action = act.SelectTextAtMouseCursor("SemanticZone"),
    mods = "NONE",
  },
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.PasteFrom("Clipboard"), pane)
      end
    end),
  },
}

-- Apply plugins (cmdpicker must be last)
bar.apply_to_config(config)
theme_rotator.apply_to_config(config)
wezterm_sync.apply_to_config(config)
quota_limit.apply_to_config(config)
agent_deck.apply_to_config(config)
cmdpicker.apply_to_config(config, { title = "Command Palette" })

return config
