// WSearch.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick
import Quickshell

WidgetBase {
  id: root

  Rectangle {
    anchors.fill: parent
    radius: height / 2
    color: ma.containsMouse ? Theme.m3SurfaceContainerHighest : Theme.m3SurfaceContainerHigh
    Behavior on color { ColorAnimation { duration: 120 } }

    Row {
      anchors.left: parent.left
      anchors.leftMargin: 22
      anchors.right: parent.right
      anchors.rightMargin: 16
      anchors.verticalCenter: parent.verticalCenter
      spacing: 14

      Icon { name: "search"; size: 24; color: Theme.m3OnSurfaceVariant; anchors.verticalCenter: parent.verticalCenter }
      M3Text {
        width: parent.width - 40
        elide: Text.ElideRight
        text: root.opt("label", "Search")
        font.pixelSize: 16
        color: Theme.m3OnSurfaceVariant
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    MouseArea {
      id: ma
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton
      cursorShape: Qt.PointingHandCursor
      enabled: !root.preview
      onClicked: {
        const c = String(root.opt("command", "")).trim()
        if (c !== "") Quickshell.execDetached(["sh", "-c", c])
      }
    }
  }
}
