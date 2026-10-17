import QtQuick
import QtQuick.Effects

Item {
  id: root
  property alias source: img.source
  property real radius: 24
  readonly property bool ready: img.status === Image.Ready

  Image {
    id: img
    anchors.fill: parent
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: false
    visible: false
    sourceSize.width: Math.max(1, root.width * 2)
    sourceSize.height: Math.max(1, root.height * 2)
  }

  Item {
    id: mask
    anchors.fill: parent
    layer.enabled: true
    visible: false
    Rectangle { anchors.fill: parent; radius: root.radius; color: "black" }
  }

  MultiEffect {
    anchors.fill: parent
    source: img
    maskEnabled: true
    maskSource: mask
    visible: root.ready
  }
}
