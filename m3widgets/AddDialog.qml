import QtQuick

Item {
  id: root

  property string screenName: ""
  property real boundsW: 1920
  property real boundsH: 1080

  width: Math.min(780, boundsW - 64)
  height: Math.min(620, boundsH - 64)
  x: (boundsW - width) / 2
  y: (boundsH - height) / 2

  opacity: 0
  scale: 0.96
  Behavior on opacity { NumberAnimation { duration: 160 } }
  Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
  Component.onCompleted: Qt.callLater(function () { root.opacity = 1; root.scale = 1 })

  Rectangle { anchors.fill: parent; radius: 28; color: Theme.m3SurfaceContainerHigh }
  MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }

  Item {
    id: header
    x: 28
    y: 24
    width: parent.width - 56
    height: 48

    Column {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2
      M3Text { text: "Add a widget"; font.pixelSize: 24 }
      M3Text { text: "Pick one to place it on your desktop"; font.pixelSize: 13; color: Theme.m3OnSurfaceVariant }
    }

    Rectangle {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      width: 40
      height: 40
      radius: 20
      color: xa.containsMouse ? Qt.alpha(Theme.m3OnSurface, 0.1) : "transparent"
      Icon { anchors.centerIn: parent; name: "close"; size: 22; color: Theme.m3OnSurfaceVariant }
      MouseArea { id: xa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Store.closeOverlay() }
    }
  }

  Flickable {
    anchors.top: header.bottom
    anchors.topMargin: 16
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.leftMargin: 28
    anchors.rightMargin: 28
    anchors.bottomMargin: 24
    contentWidth: width
    contentHeight: flow.height
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Flow {
      id: flow
      width: parent.width
      spacing: 14

      Repeater {
        model: Catalog.order
        delegate: Item {
          id: tile
          required property string modelData
          readonly property var def: Catalog.kinds[modelData]
          readonly property var d: Catalog.dims(modelData, Catalog.defaultSize(modelData))
          width: Math.floor((flow.width - 14 * 2) / 3)
          height: 176

          Rectangle {
            anchors.fill: parent
            radius: 22
            color: tma.pressed ? Theme.m3SurfaceContainerHighest
                 : (tma.containsMouse ? Theme.m3SurfaceContainerHighest : Theme.m3SurfaceContainer)
            border.width: tma.containsMouse ? 2 : 0
            border.color: Theme.m3Primary
          }

          Item {
            id: pv
            x: 12
            y: 12
            width: parent.width - 24
            height: 100
            clip: true

            Loader {
              id: pl
              readonly property real k: Math.min(pv.width / tile.d.w, pv.height / tile.d.h, 1)
              width: tile.d.w
              height: tile.d.h
              x: (pv.width - width * k) / 2
              y: (pv.height - height * k) / 2
              scale: k
              transformOrigin: Item.TopLeft
              enabled: false
              source: Qt.resolvedUrl(tile.def.file)
              onLoaded: {
                item.preview = true
                item.cfg = Catalog.defaults(tile.modelData)
                item.cw = tile.d.cw
                item.ch = tile.d.ch
              }
            }
          }

          Column {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            spacing: 1
            M3Text { width: parent.width; elide: Text.ElideRight; text: tile.def.name; font.pixelSize: 15; font.weight: Font.Medium }
            M3Text { width: parent.width; elide: Text.ElideRight; text: tile.def.desc + " · " + Catalog.defaultSize(tile.modelData).replace("x", " × "); font.pixelSize: 12; color: Theme.m3OnSurfaceVariant }
          }

          MouseArea {
            id: tma
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              const kind = tile.modelData
              const scr = root.screenName
              const x = Store.addX
              const y = Store.addY
              Store.closeOverlay()
              Store.add(kind, scr, x, y)
            }
          }
        }
      }
    }
  }
}
