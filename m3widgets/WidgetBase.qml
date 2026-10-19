// WidgetBase.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick

Item {
  property var cfg: ({})
  property int cw: 2
  property int ch: 2
  property bool preview: false

  function opt(key, def) {
    return (cfg && cfg[key] !== undefined) ? cfg[key] : def
  }
}
