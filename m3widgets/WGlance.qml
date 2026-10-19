// WGlance.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick
import QtQuick.Effects
import Quickshell

WidgetBase {
  id: root

  readonly property bool card: opt("style", "none") === "card"

  SystemClock { id: clk; precision: SystemClock.Minutes }
  WeatherSource {
    id: wx
    city: root.opt("city", "")
    unit: root.opt("unit", "c")
    demo: root.preview
  }

  readonly property string line2: {
    if (wx.valid) return Math.round(wx.temp) + "°  ·  " + wx.summary
    if (wx.loading) return "Loading weather…"
    return wx.error !== "" ? wx.error : "Weather unavailable"
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.widgetRadius
    color: Theme.m3SurfaceContainer
    visible: root.card
  }

  Item {
    id: content
    anchors.fill: parent
    anchors.leftMargin: root.card ? 24 : 8
    anchors.rightMargin: 8

    layer.enabled: !root.card
    layer.effect: MultiEffect {
      shadowEnabled: true
      shadowColor: Qt.alpha(Theme.m3Shadow, 0.7)
      shadowBlur: 0.45
      shadowVerticalOffset: 1
    }

    Column {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2

      M3Text {
        text: Qt.formatDate(clk.date, "ddd, MMM d")
        font.pixelSize: root.height * 0.40
        font.weight: Font.Medium
        color: Theme.m3OnSurface
      }

      Row {
        spacing: 8
        WeatherIcon {
          width: 24
          height: 24
          visible: wx.valid
          kind: wx.kind
          night: !wx.isDay
          sunColor: Theme.m3Tertiary
          cloudColor: Theme.m3OnSurface
          accentColor: Theme.m3Primary
          anchors.verticalCenter: parent.verticalCenter
        }
        M3Text {
          text: root.line2
          font.pixelSize: 16
          color: Theme.m3OnSurface
          anchors.verticalCenter: parent.verticalCenter
        }
      }
    }
  }
}
