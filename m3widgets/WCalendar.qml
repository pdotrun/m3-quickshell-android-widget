import QtQuick
import Quickshell

WidgetBase {
  id: root

  readonly property bool month: cw >= 4 && ch >= 3
  readonly property int startDow: opt("weekStart", "sun") === "mon" ? 1 : 0

  SystemClock { id: clk; precision: SystemClock.Minutes }

  property int monthOffset: 0

  readonly property var today: clk.date
  readonly property var viewDate: new Date(today.getFullYear(), today.getMonth() + monthOffset, 1)
  readonly property int firstOffset: (viewDate.getDay() - startDow + 7) % 7

  readonly property var cells: {
    const out = []
    const vy = viewDate.getFullYear()
    const vm = viewDate.getMonth()
    const ty = today.getFullYear()
    const tm = today.getMonth()
    const td = today.getDate()
    for (let i = 0; i < 42; i++) {
      const dt = new Date(vy, vm, 1 - firstOffset + i)
      out.push({
        d: dt.getDate(),
        inMonth: dt.getMonth() === vm,
        isToday: dt.getFullYear() === ty && dt.getMonth() === tm && dt.getDate() === td
      })
    }
    return out
  }

  readonly property var dayNames: {
    const all = ["S", "M", "T", "W", "T", "F", "S"]
    const out = []
    for (let i = 0; i < 7; i++) out.push(all[(i + startDow) % 7])
    return out
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.widgetRadius
    color: root.month ? Theme.m3SurfaceContainer : Theme.m3PrimaryContainer
  }

  // ---- 2x2 date tile ---------------------------------------------------------
  Item {
    anchors.fill: parent
    visible: !root.month

    M3Text {
      x: 20
      y: 16
      text: Qt.formatDate(clk.date, "dddd")
      color: Theme.m3OnPrimaryContainer
      font.pixelSize: 15
      font.weight: Font.Medium
    }
    M3Text {
      x: 20
      y: 36
      text: Qt.formatDate(clk.date, "MMMM")
      color: Theme.m3OnPrimaryContainer
      opacity: 0.75
      font.pixelSize: 14
    }

    CookieShape {
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.margins: 12
      width: Math.min(parent.width, parent.height) * 0.62
      height: width
      sides: 12
      amp: 0.06
      color: Theme.m3Primary
      M3Text {
        anchors.centerIn: parent
        text: clk.date.getDate()
        color: Theme.m3OnPrimary
        font.pixelSize: parent.height * 0.5
        font.weight: Font.Bold
      }
    }
  }

  // ---- 4x4 month view ----------------------------------------------------------
  Item {
    id: grid
    anchors.fill: parent
    anchors.margins: 16
    visible: root.month

    readonly property real colW: width / 7
    readonly property real rowH: (height - 56) / 7

    Item {
      id: head
      width: parent.width
      height: 40

      M3Text {
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDate(root.viewDate, "MMMM yyyy")
        font.pixelSize: 20
        font.weight: Font.Medium
        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton
          onClicked: root.monthOffset = 0
        }
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        Repeater {
          model: [ { n: "chevron_left", s: -1 }, { n: "chevron_right", s: 1 } ]
          delegate: Rectangle {
            required property var modelData
            width: 36
            height: 36
            radius: 18
            color: nav.containsMouse ? Qt.alpha(Theme.m3OnSurface, 0.1) : "transparent"
            Icon { anchors.centerIn: parent; name: modelData.n; size: 22; color: Theme.m3OnSurfaceVariant }
            MouseArea {
              id: nav
              anchors.fill: parent
              hoverEnabled: true
              acceptedButtons: Qt.LeftButton
              cursorShape: Qt.PointingHandCursor
              onClicked: root.monthOffset += modelData.s
            }
          }
        }
      }
    }

    Row {
      id: names
      y: head.height + 4
      Repeater {
        model: root.dayNames
        delegate: M3Text {
          required property string modelData
          width: grid.colW
          height: grid.rowH
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          text: modelData
          font.pixelSize: 12
          font.weight: Font.Medium
          color: Theme.m3OnSurfaceVariant
        }
      }
    }

    Grid {
      y: names.y + grid.rowH
      columns: 7
      Repeater {
        model: root.cells
        delegate: Item {
          required property var modelData
          width: grid.colW
          height: grid.rowH

          Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) - 2
            height: width
            radius: width / 2
            color: Theme.m3Primary
            visible: modelData.isToday
          }
          M3Text {
            anchors.centerIn: parent
            text: modelData.d
            font.pixelSize: 14
            font.weight: modelData.isToday ? Font.Bold : Font.Normal
            color: modelData.isToday ? Theme.m3OnPrimary
                 : (modelData.inMonth ? Theme.m3OnSurface : Theme.m3OnSurfaceVariant)
            opacity: modelData.inMonth || modelData.isToday ? 1 : 0.4
          }
        }
      }
    }
  }
}
