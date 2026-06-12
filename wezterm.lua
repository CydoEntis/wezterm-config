local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find("windows") ~= nil
local home = os.getenv(is_windows and "USERPROFILE" or "HOME")

-- Font
config.font = wezterm.font("Anka/Coder", { weight = "Regular", stretch = "Normal", style = "Normal" })
config.font_size = 13.0

-- Color scheme
config.color_scheme = "PaperColor Dark (base16)"

-- Tab bar colors matched to PaperColor Dark
config.colors = {
  tab_bar = {
    background = "#1c1c1c",
    active_tab = {
      bg_color = "#0087af",
      fg_color = "#eeeeee",
    },
    inactive_tab = {
      bg_color = "#262626",
      fg_color = "#585858",
    },
    inactive_tab_hover = {
      bg_color = "#303030",
      fg_color = "#d0d0d0",
    },
    new_tab = {
      bg_color = "#1c1c1c",
      fg_color = "#585858",
    },
    new_tab_hover = {
      bg_color = "#262626",
      fg_color = "#d0d0d0",
    },
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

  -- Close pane
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },

  -- Zoom pane (toggle fullscreen for current pane)
  { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },

  -- New tab / close tab
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },

  -- Navigate tabs
  { key = "Tab",       mods = "CTRL",       action = act.ActivateTabRelative(1) },
  { key = "Tab",       mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

  -- Copy / Paste
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "v", mods = "CTRL",       action = act.SendKey({ key = "v", mods = "CTRL" }) },

  -- Image paste: saves clipboard image to ~/Pictures/screenshots and sends the path
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

  -- Keybind cheat sheet
  {
    key = "/",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window, pane)
      local cmd
      if is_windows then
        cmd = { "powershell", "-NoProfile", "-File", home .. "\\wezterm-config\\scripts\\keybinds.ps1" }
      else
        cmd = { home .. "/.local/bin/wezterm-keybinds" }
      end
      window:perform_action(
        act.SplitPane({
          direction = "Right",
          size = { Percent = 35 },
          command = { args = cmd },
        }),
        pane
      )
    end),
  },
}

-- Mouse bindings: right-click copies selection or pastes; triple-click selects semantic zone
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

return config
