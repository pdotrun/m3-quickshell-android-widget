// OverlayLayer.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
  id: win

  required property var modelData
  readonly property string screenName: modelData.name
  readonly property string kind: Store.overlayKind
  readonly property bool active: kind !== "" && Store.overlayScreen === screenName
  readonly property bool isMenu: kind === "desktopMenu" || kind === "widgetMenu"

  screen: modelData
  visible: active
  anchors { top: true; bottom: true; left: true; right: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "m3widgets-overlay"
  WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  function desktopItems() {
    const scr = win.screenName
    return [
      { label: "Add widget", icon: "widgets", act: function () { Store.openAdd(scr) } },
      { label: Store.editMode ? "Done editing" : "Edit widgets",
        icon: Store.editMode ? "check" : "edit",
        act: function () { Store.editMode = !Store.editMode } },
      { label: "Select Wallpapers", icon: "wallpaper",
        act: function () { Store.openWallpapers(scr) } },
      { sep: true },
      { label: "Snap to grid", icon: "grid", check: Store.snap, keepOpen: true,
        act: function () { Store.snap = !Store.snap } },
      { label: "Lock widgets", icon: "lock", check: Store.locked, keepOpen: true,
        act: function () { Store.locked = !Store.locked } },
      { sep: true },
      { label: "Reset layout", icon: "refresh", danger: true,
        act: function () { Store.resetLayout() } }
    ]
  }

  function widgetItems(id) {
    const scr = win.screenName
    const w = Store.get(id)
    if (!w) return []
    const def = Catalog.kinds[w.kind]
    const out = [
      { header: def.name },
      { label: "Configure…", icon: "settings", act: function () { Store.openConfig(scr, id) } },
      { label: "Move", icon: "move", act: function () { Store.startCarry(id, scr) } },
      { label: Store.editMode ? "Done editing" : "Edit layout",
        icon: Store.editMode ? "check" : "edit",
        act: function () { Store.editMode = !Store.editMode } }
    ]
    if (def.sizes.length > 1) {
      out.push({ sep: true })
      out.push({ header: "Size" })
      for (let i = 0; i < def.sizes.length; i++) {
        const s = def.sizes[i]
        out.push({ label: s.label, icon: "resize", check: s.id === w.sizeId, keepOpen: true,
                   act: function () { Store.setSize(id, s.id) } })
      }
    }
    out.push({ sep: true })
    out.push({ label: "Duplicate", icon: "copy", act: function () { Store.duplicate(id) } })
    out.push({ label: "Remove", icon: "delete", danger: true, act: function () { Store.remove(id) } })
    return out
  }

  FocusScope {
    id: scope
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: Store.closeOverlay()

    Rectangle {
      anchors.fill: parent
      color: Qt.alpha(Theme.m3Scrim, 0.42)
      visible: win.kind === "add" || win.kind === "config"
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
      onPressed: Store.closeOverlay()
    }

    Loader {
      active: win.active && win.isMenu
      sourceComponent: Component {
        ContextMenu {
          boundsW: scope.width
          boundsH: scope.height
          anchorX: Store.overlayX
          anchorY: Store.overlayY
          items: win.kind === "desktopMenu" ? win.desktopItems() : win.widgetItems(Store.overlayTarget)
        }
      }
    }

    Loader {
      active: win.active && win.kind === "add"
      sourceComponent: Component {
        AddDialog {
          screenName: win.screenName
          boundsW: scope.width
          boundsH: scope.height
        }
      }
    }

    Loader {
      active: win.active && win.kind === "config"
      sourceComponent: Component {
        ConfigDialog {
          wid: Store.overlayTarget
          boundsW: scope.width
          boundsH: scope.height
        }
      }
    }
  }
}
