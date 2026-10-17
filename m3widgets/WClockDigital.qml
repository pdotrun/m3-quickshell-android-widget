import QtQuick
import Quickshell

WidgetBase {
  id: root

  readonly property bool use24: opt("use24h", false)
  readonly property bool showDate: opt("showDate", true)
  readonly property bool wide: cw >= 4

  SystemClock { id: clk; precision: SystemClock.Minutes }

  function pad(n) { return n < 10 ? "0" + n : "" + n }

  readonly property int hrs: clk.date.getHours()
  readonly property string hh: pad(use24 ? hrs : (hrs % 12 === 0 ? 12 : hrs % 12))
  readonly property string mm: pad(clk.date.getMinutes())
  readonly property string ampm: hrs < 12 ? "AM" : "PM"

  Rectangle {
    anchors.fill: parent
    radius: Theme.widgetRadius
    color: Theme.m3SurfaceContainer

    // Stacked 2x2 layout (Pixel's large digital clock)
    Column {
      visible: !root.wide
      anchors.left: parent.left
      anchors.leftMargin: 24
      anchors.verticalCenter: parent.verticalCenter
      spacing: -root.height * 0.07

      M3Text {
        text: root.hh
        color: Theme.m3Primary
        font.pixelSize: root.height * 0.42
        font.weight: Font.Bold
      }
      M3Text {
        text: root.mm
        color: Theme.m3Tertiary
        font.pixelSize: root.height * 0.42
        font.weight: Font.Bold
      }
    }

    M3Text {
      visible: !root.wide && !root.use24
      anchors.right: parent.right
      anchors.rightMargin: 20
      anchors.top: parent.top
      anchors.topMargin: 18
      text: root.ampm
      color: Theme.m3OnSurfaceVariant
      font.pixelSize: 14
      font.weight: Font.Medium
    }

    // Wide 4x2 layout
    Column {
      visible: root.wide
      anchors.centerIn: parent
      spacing: 2

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4
        M3Text { text: root.hh; color: Theme.m3Primary; font.pixelSize: root.height * 0.5; font.weight: Font.Bold }
        M3Text { text: ":"; color: Theme.m3OnSurfaceVariant; font.pixelSize: root.height * 0.5; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter; anchors.verticalCenterOffset: -root.height * 0.03 }
        M3Text { text: root.mm; color: Theme.m3Tertiary; font.pixelSize: root.height * 0.5; font.weight: Font.Bold }
        M3Text {
          visible: !root.use24
          text: root.ampm
          color: Theme.m3OnSurfaceVariant
          font.pixelSize: 16
          font.weight: Font.Medium
          anchors.verticalCenter: parent.verticalCenter
          anchors.verticalCenterOffset: root.height * 0.07
        }
      }
      M3Text {
        visible: root.showDate
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDate(clk.date, "dddd, MMMM d")
        color: Theme.m3OnSurfaceVariant
        font.pixelSize: 16
      }
    }
  }
}
