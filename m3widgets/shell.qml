import Quickshell

// Android-style Material 3 desktop widgets for Hyprland.
// Run with:  qs -c m3widgets
ShellRoot {
  // Widget surface (below windows, above the wallpaper)
  Variants {
    model: Quickshell.screens
    DesktopLayer {}
  }

  // Menus + dialogs (above everything, only mapped while open)
  Variants {
    model: Quickshell.screens
    OverlayLayer {}
  }
}
