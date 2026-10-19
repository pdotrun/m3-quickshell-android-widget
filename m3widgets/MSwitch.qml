// MSwitch.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick

Item {
  id: root
  property bool checked: false
  signal toggled(bool value)

  implicitWidth: 52
  implicitHeight: 32

  Rectangle {
    anchors.fill: parent
    radius: height / 2
    color: root.checked ? Theme.m3Primary : Theme.m3SurfaceContainerHighest
    border.width: root.checked ? 0 : 2
    border.color: Theme.m3Outline
  }

  Rectangle {
    id: thumb
    width: root.checked ? 24 : 16
    height: width
    radius: width / 2
    anchors.verticalCenter: parent.verticalCenter
    x: root.checked ? root.width - 16 - width / 2 : 16 - width / 2
    color: root.checked ? Theme.m3OnPrimary : Theme.m3Outline
    Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on width { NumberAnimation { duration: 140 } }

    Icon {
      anchors.centerIn: parent
      visible: root.checked
      name: "check"
      size: 16
      color: Theme.m3PrimaryContainer
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggled(!root.checked)
  }
}
