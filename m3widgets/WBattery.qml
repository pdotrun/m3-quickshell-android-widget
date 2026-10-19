// WBattery.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Services.UPower

WidgetBase {
  id: root

  readonly property bool wide: cw >= 4 && ch < 2
  readonly property bool showTime: opt("showTime", true)

  readonly property var dev: {
    const v = UPower.devices.values
    for (let i = 0; i < v.length; i++)
      if (v[i].isLaptopBattery) return v[i]
    return null
  }
  readonly property bool has: preview || dev !== null

  readonly property real pct: {
    if (preview) return 0.78
    if (dev === null) return 0
    let p = dev.percentage
    if (p > 1.0001) p = p / 100
    return Math.max(0, Math.min(1, p))
  }
  readonly property bool charging: preview || (dev !== null && dev.state === UPowerDeviceState.Charging)
  readonly property bool full: !preview && dev !== null && dev.state === UPowerDeviceState.FullyCharged
  readonly property bool low: has && !charging && !full && pct <= 0.15

  readonly property color arcColor: low ? Theme.m3Error : Theme.m3Primary

  property real shown: pct
  Behavior on shown { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

  function fmt(sec) {
    if (!sec || sec <= 0) return ""
    const h = Math.floor(sec / 3600)
    const m = Math.round((sec % 3600) / 60)
    return h > 0 ? h + " h " + m + " min" : m + " min"
  }

  readonly property string status: {
    if (preview) return "Charging"
    if (!has) return "No battery"
    if (full) return "Fully charged"
    if (charging) {
      const t = showTime ? fmt(dev.timeToFull) : ""
      return t !== "" ? "Charging · " + t : "Charging"
    }
    const t2 = showTime ? fmt(dev.timeToEmpty) : ""
    return t2 !== "" ? t2 + " left" : "On battery"
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.widgetRadius
    color: Theme.m3SurfaceContainer
  }

  Item {
    id: ring
    readonly property real side: root.wide ? root.height - 24 : Math.min(root.width, root.height) - 28
    width: side
    height: side
    x: root.wide ? 16 : (root.width - side) / 2
    y: root.wide ? 12 : 14

    Shape {
      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer
      readonly property real sw: ring.side * 0.11

      ShapePath {
        strokeColor: Theme.m3SurfaceContainerHighest
        strokeWidth: ring.side * 0.11
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        PathAngleArc {
          centerX: ring.side / 2
          centerY: ring.side / 2
          radiusX: ring.side / 2 - ring.side * 0.055
          radiusY: radiusX
          startAngle: -90
          sweepAngle: 359.9
        }
      }
      ShapePath {
        strokeColor: root.has ? root.arcColor : "transparent"
        strokeWidth: ring.side * 0.11
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        PathAngleArc {
          centerX: ring.side / 2
          centerY: ring.side / 2
          radiusX: ring.side / 2 - ring.side * 0.055
          radiusY: radiusX
          startAngle: -90
          sweepAngle: Math.max(0.1, 359.9 * root.shown)
        }
      }
    }

    Column {
      anchors.centerIn: parent
      spacing: 0
      Icon {
        anchors.horizontalCenter: parent.horizontalCenter
        name: root.has ? "bolt" : "power"
        visible: root.charging || !root.has
        size: ring.side * 0.2
        color: root.has ? root.arcColor : Theme.m3OnSurfaceVariant
      }
      M3Text {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.has
        text: Math.round(root.pct * 100) + "%"
        font.pixelSize: ring.side * 0.24
        font.weight: Font.Bold
      }
    }
  }

  M3Text {
    visible: !root.wide
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 8
    width: parent.width - 24
    horizontalAlignment: Text.AlignHCenter
    elide: Text.ElideRight
    text: root.status
    font.pixelSize: 11
    color: Theme.m3OnSurfaceVariant
  }

  Column {
    visible: root.wide
    anchors.left: ring.right
    anchors.leftMargin: 18
    anchors.right: parent.right
    anchors.rightMargin: 16
    anchors.verticalCenter: parent.verticalCenter
    spacing: 2
    M3Text { text: root.has ? Math.round(root.pct * 100) + "%" : "Battery"; font.pixelSize: 28; font.weight: Font.Bold }
    M3Text { width: parent.width; elide: Text.ElideRight; text: root.status; font.pixelSize: 14; color: Theme.m3OnSurfaceVariant }
  }
}
