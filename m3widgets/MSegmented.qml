// MSegmented.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick

Item {
  id: root
  property var options: []
  property var value: ""
  signal picked(var v)

  implicitHeight: 40

  Row {
    anchors.fill: parent
    Repeater {
      model: root.options
      delegate: Rectangle {
        id: seg
        required property var modelData
        readonly property bool sel: root.value === modelData.v
        width: root.width / Math.max(1, root.options.length)
        height: root.height
        radius: height / 2
        color: sel ? Theme.m3SecondaryContainer : "transparent"
        Behavior on color { ColorAnimation { duration: 140 } }

        Row {
          anchors.centerIn: parent
          spacing: 6
          Icon { visible: seg.sel; name: "check"; size: 16; color: Theme.m3OnSecondaryContainer; anchors.verticalCenter: parent.verticalCenter }
          M3Text {
            text: seg.modelData.l
            color: seg.sel ? Theme.m3OnSecondaryContainer : Theme.m3OnSurface
            font.pixelSize: 14
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.picked(seg.modelData.v)
        }
      }
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: height / 2
    color: "transparent"
    border.width: 1
    border.color: Theme.m3Outline
  }
}
