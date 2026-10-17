import QtQuick
import Quickshell

WidgetBase {
  id: root

  readonly property bool wide: cw >= 4

  WeatherSource {
    id: wx
    city: root.opt("city", "")
    unit: root.opt("unit", "c")
    demo: root.preview
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.widgetRadius
    color: Theme.m3SurfaceContainer
  }

  // ---- current conditions (left 176 px; the whole widget at 2x2) ---------
  Item {
    id: now
    width: Math.min(176, root.width)
    height: root.height

    CookieShape {
      x: 16
      y: 16
      width: 58
      height: 58
      sides: 8
      amp: 0.09
      color: Theme.m3SecondaryContainer
      WeatherIcon {
        anchors.centerIn: parent
        width: 38
        height: 38
        visible: wx.valid
        kind: wx.kind
        night: !wx.isDay
      }
    }

    Column {
      visible: wx.valid
      anchors.right: parent.right
      anchors.rightMargin: 16
      y: 18
      spacing: 2
      M3Text {
        anchors.right: parent.right
        width: 84
        horizontalAlignment: Text.AlignRight
        text: wx.place
        elide: Text.ElideRight
        font.pixelSize: 13
        color: Theme.m3OnSurface
      }
      M3Text {
        anchors.right: parent.right
        text: "H " + Math.round(wx.hi) + "°  L " + Math.round(wx.lo) + "°"
        font.pixelSize: 12
        color: Theme.m3OnSurfaceVariant
      }
    }

    Column {
      anchors.left: parent.left
      anchors.leftMargin: 18
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 14
      spacing: -2

      M3Text {
        text: wx.valid ? Math.round(wx.temp) + "°" : "–"
        font.pixelSize: 52
        font.weight: Font.Medium
        color: Theme.m3OnSurface
      }
      M3Text {
        width: now.width - 32
        elide: Text.ElideRight
        text: wx.valid ? wx.summary
              : (wx.loading ? "Loading…" : (wx.error !== "" ? wx.error + " · tap to retry" : "Unavailable"))
        font.pixelSize: 14
        color: Theme.m3OnSurfaceVariant
      }
    }
  }

  // ---- next hours (4x2 only) -----------------------------------------------
  Row {
    visible: root.wide && wx.valid
    anchors.left: now.right
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.verticalCenter: parent.verticalCenter
    height: parent.height - 32

    Repeater {
      model: wx.hourly
      delegate: Item {
        required property var modelData
        width: parent.width / Math.max(1, wx.hourly.length)
        height: parent.height

        Rectangle {
          anchors.fill: parent
          anchors.margins: 3
          radius: 20
          color: Theme.m3SurfaceContainerHigh

          Column {
            anchors.centerIn: parent
            spacing: 6
            M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.h; font.pixelSize: 11; color: Theme.m3OnSurfaceVariant }
            WeatherIcon { anchors.horizontalCenter: parent.horizontalCenter; width: 28; height: 28; kind: modelData.k; night: modelData.night }
            M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.t + "°"; font.pixelSize: 15; font.weight: Font.Medium }
          }
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    enabled: !root.preview
    onClicked: wx.refresh()
  }
}
