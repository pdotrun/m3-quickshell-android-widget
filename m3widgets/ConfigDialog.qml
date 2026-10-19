// ConfigDialog.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick

Item {
  id: root

  property string wid: ""
  property real boundsW: 1920
  property real boundsH: 1080

  readonly property var w: Store.get(wid)
  readonly property var def: w ? Catalog.kinds[w.kind] : null
  readonly property var cfgObj: {
    if (!w) return ({})
    try { return JSON.parse(w.cfg) } catch (e) { return ({}) }
  }

  width: Math.min(480, boundsW - 48)
  height: body.implicitHeight + 56
  x: (boundsW - width) / 2
  y: Math.max(24, (boundsH - height) / 2)

  opacity: 0
  scale: 0.96
  Behavior on opacity { NumberAnimation { duration: 160 } }
  Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
  Component.onCompleted: Qt.callLater(function () { root.opacity = 1; root.scale = 1 })

  onWChanged: if (!w) Store.closeOverlay()

  Rectangle { anchors.fill: parent; radius: 28; color: Theme.m3SurfaceContainerHigh }
  MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }

  Column {
    id: body
    x: 28
    y: 28
    width: parent.width - 56
    spacing: 18

    M3Text { text: root.def ? root.def.name + " settings" : ""; font.pixelSize: 24 }

    Column {
      visible: root.def !== null && root.def.sizes.length > 1
      width: parent.width
      spacing: 8
      M3Text { text: "Size"; font.pixelSize: 13; color: Theme.m3OnSurfaceVariant }
      MSegmented {
        width: parent.width
        options: {
          if (!root.def) return []
          return root.def.sizes.map(function (s) { return { v: s.id, l: s.label } })
        }
        value: root.w ? root.w.sizeId : ""
        onPicked: v => Store.setSize(root.wid, v)
      }
    }

    Repeater {
      model: root.def ? root.def.fields : []
      delegate: Column {
        id: field
        required property var modelData
        readonly property var cur: root.cfgObj[modelData.key] !== undefined
                                   ? root.cfgObj[modelData.key]
                                   : (root.def.defaults[modelData.key])
        width: body.width
        spacing: 8

        Item {
          visible: field.modelData.type === "bool"
          width: parent.width
          height: visible ? 40 : 0
          M3Text { anchors.verticalCenter: parent.verticalCenter; text: field.modelData.label; font.pixelSize: 15 }
          MSwitch {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            checked: field.cur === true
            onToggled: v => Store.setConfig(root.wid, field.modelData.key, v)
          }
        }

        M3Text {
          visible: field.modelData.type !== "bool"
          text: field.modelData.label
          font.pixelSize: 13
          color: Theme.m3OnSurfaceVariant
        }

        MSegmented {
          visible: field.modelData.type === "choice"
          width: parent.width
          options: field.modelData.options || []
          value: field.cur
          onPicked: v => Store.setConfig(root.wid, field.modelData.key, v)
        }

        MTextField {
          visible: field.modelData.type === "text"
          width: parent.width
          text: field.cur === undefined ? "" : String(field.cur)
          placeholder: field.modelData.hint || ""
          onCommitted: v => Store.setConfig(root.wid, field.modelData.key, v)
        }
      }
    }

    Row {
      anchors.right: parent.right
      spacing: 8
      MButton { variant: "text"; label: "Reset"; icon: "refresh"; onClicked: Store.resetConfig(root.wid) }
      MButton { variant: "filled"; label: "Done"; onClicked: Store.closeOverlay() }
    }
  }
}
