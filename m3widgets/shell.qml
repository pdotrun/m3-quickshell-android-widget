// shell.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import Quickshell

ShellRoot {
  Variants {
    model: Quickshell.screens
    DesktopLayer {}
  }

  Variants {
    model: Quickshell.screens
    OverlayLayer {}
  }

  LazyLoader {
    active: Store.wallOpen
    component: WallPicker {
      screenName: Store.wallScreen
      onFinished: Store.closeWallpapers()
    }
  }
}
