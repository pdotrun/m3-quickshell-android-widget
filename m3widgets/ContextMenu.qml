import QtQuick
import QtQuick.Effects

// items: [{ label, icon, check, danger, keepOpen, act }, { sep: true }, { header: "Text" }]
Item {
  id: root

  property var items: []
  property real boundsW: 1920
  property real boundsH: 1080
  property real anchorX: 0
  property real anchorY: 0

  width: 252
  height: col.implicitHeight + 16
  x: Math.max(8, Math.min(anchorX, boundsW - width - 8))
  y: Math.max(8, Math.min(anchorY, boundsH - height - 8))

  transformOrigin: Item.TopLeft
  scale: 0.9
  opacity: 0
  Behavior on scale { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
  Behavior on opacity { NumberAnimation { duration: 120 } }
  Component.onCompleted: Qt.callLater(function () { root.scale = 1; root.opacity = 1 })

  MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }

  Rectangle {
    anchors.fill: parent
    radius: 20
    color: Theme.m3SurfaceContainer
    border.width: 1
    border.color: Qt.alpha(Theme.m3OutlineVariant, 0.6)
    layer.enabled: true
    layer.effect: MultiEffect {
      shadowEnabled: true
      shadowColor: Qt.alpha(Theme.m3Shadow, 0.6)
      shadowBlur: 0.8
      shadowVerticalOffset: 6
    }
  }

  Column {
    id: col
    x: 8
    y: 8
    width: parent.width - 16

    Repeater {
      model: root.items
      delegate: Item {
        id: row
        required property var modelData
        readonly property bool isSep: modelData.sep === true
        readonly property bool isHdr: modelData.header !== undefined
        width: col.width
        height: isSep ? 17 : (isHdr ? 32 : 44)

        Rectangle {
          visible: row.isSep
          anchors.centerIn: parent
          width: parent.width - 16
          height: 1
          color: Theme.m3OutlineVariant
        }

        M3Text {
          visible: row.isHdr
          x: 16
          anchors.verticalCenter: parent.verticalCenter
          text: row.modelData.header !== undefined ? row.modelData.header : ""
          color: Theme.m3OnSurfaceVariant
          font.pixelSize: 12
          font.weight: Font.Medium
        }

        Rectangle {
          id: entry
          visible: !row.isSep && !row.isHdr
          anchors.fill: parent
          radius: 14
          readonly property color fg: row.modelData.danger === true ? Theme.m3Error : Theme.m3OnSurface
          color: ma.pressed ? Qt.alpha(Theme.m3OnSurface, 0.12)
               : (ma.containsMouse ? Qt.alpha(Theme.m3OnSurface, 0.08) : "transparent")

          Icon {
            x: 14
            anchors.verticalCenter: parent.verticalCenter
            visible: name !== ""
            name: row.modelData.icon || ""
            size: 20
            color: entry.fg
          }
          M3Text {
            x: 48
            anchors.verticalCenter: parent.verticalCenter
            text: row.modelData.label || ""
            color: entry.fg
            font.pixelSize: 14
          }
          Icon {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            visible: row.modelData.check === true
            name: "check"
            size: 18
            color: Theme.m3Primary
          }

          MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              const action = row.modelData.act
              const keep = row.modelData.keepOpen === true
              if (!keep) Store.closeOverlay()
              if (action) action()
            }
          }
        }
      }
    }
  }
}
