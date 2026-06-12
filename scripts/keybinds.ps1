$lines = @"

  WezTerm Keybinds
  ================

  PANES
    Ctrl+Alt+|            Split pane horizontal
    Ctrl+Alt+_            Split pane vertical
    Ctrl+Shift+W          Close pane
    Ctrl+Shift+Z          Zoom / unzoom pane
    Ctrl+Shift+H/J/K/L    Navigate panes (left/down/up/right)
    Ctrl+Shift+Alt+H/J/K/L  Resize panes

  TABS
    Ctrl+Shift+T          New tab
    Ctrl+Tab              Next tab
    Ctrl+Shift+Tab        Previous tab

  COPY / PASTE
    Ctrl+Shift+C          Copy
    Ctrl+Shift+V          Paste text
    Ctrl+Alt+V            Paste image (saves to ~/Pictures/screenshots)
    Right-click           Copy selection, or paste if nothing selected

  SCROLL
    Shift+PageUp          Scroll up
    Shift+PageDown        Scroll down

  SEARCH
    Ctrl+Shift+F          Search

  HELP
    Ctrl+Shift+/          Show this cheat sheet

"@

Write-Host $lines
Read-Host "  Press Enter to close"
