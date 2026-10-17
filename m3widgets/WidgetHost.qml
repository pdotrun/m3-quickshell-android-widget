import QtQuick
import QtQuick.Effects

Item {
  id: host

  required property string wid
  required property string kind
  required property string scr
  required property real posX
  required property real posY
  required property string sizeId
  required property string cfg

  property string screenName: ""

  readonly property bool shows: Store.screenFor(scr) === screenName
  readonly property var dims: Catalog.dims(kind, sizeId)
  readonly property var cfgObj: { try { return JSON.parse(cfg) } catch (e) { return ({}) } }
  readonly property bool selected: Store.selectedId === wid
  readonly property bool carried: Store.carryId === wid
  readonly property bool lifted: dragging || carried

  property bool dragging: false
  property real dragX: 0
  property real dragY: 0
  property bool appeared: false
  property bool animateMoves: false

  visible: shows
  width: dims.w
  height: dims.h
  x: clampX(dragging ? dragX : posX)
  y: clampY(dragging ? dragY : posY)
  z: lifted ? 100 : (selected ? 10 : 1)
  opacity: appeared ? 1 : 0
  scale: (lifted ? 1.03 : 1) * (appeared ? 1 : 0.92)

  Behavior on x { enabled: host.animateMoves && !host.lifted; NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
  Behavior on y { enabled: host.animateMoves && !host.lifted; NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
  Behavior on width { enabled: host.animateMoves; NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
  Behavior on height { enabled: host.animateMoves; NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
  Behavior on opacity { NumberAnimation { duration: 260 } }
  Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

  Component.onCompleted: {
    appeared = true
    Qt.callLater(function () { host.animateMoves = true })
  }

  layer.enabled: lifted
  layer.effect: MultiEffect {
    shadowEnabled: true
    shadowColor: Qt.alpha(Theme.m3Shadow, 0.8)
    shadowBlur: 1.0
    shadowVerticalOffset: 10
  }

  function clampX(v) { return parent ? Math.max(0, Math.min(parent.width - width, v)) : v }
  function clampY(v) { return parent ? Math.max(0, Math.min(parent.height - height, v)) : v }

  function finishDrag() {
    let nx = clampX(dragX)
    let ny = clampY(dragY)
    if (Store.snap) {
      nx = clampX(Store.snapValue(nx))
      ny = clampY(Store.snapValue(ny))
    }
    Store.setPos(wid, nx, ny)  
    dragging = false
  }

  function nextSize() {
    const list = Catalog.kinds[kind].sizes
    let i = 0
    for (let j = 0; j < list.length; j++) if (list[j].id === sizeId) i = j
    Store.setSize(wid, list[(i + 1) % list.length].id)
  }

  function push() {
    if (!content.item) return
    content.item.cfg = cfgObj
    content.item.cw = dims.cw
    content.item.ch = dims.ch
  }

  Loader {
    id: content
    anchors.fill: parent
    active: host.shows
    source: Catalog.kinds[host.kind] ? Qt.resolvedUrl(Catalog.kinds[host.kind].file) : ""
    onLoaded: host.push()
  }

  Connections {
    target: host
    function onCfgObjChanged() { host.push() }
    function onDimsChanged() { host.push() }
  }

  MouseArea {
    id: area
    anchors.fill: parent
    z: Store.editMode ? 5 : -1
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: host.dragging ? Qt.ClosedHandCursor
               : (Store.editMode && !Store.locked ? Qt.OpenHandCursor : Qt.ArrowCursor)
    onClicked: mouse => {
      if (mouse.button === Qt.RightButton) {
        const p = area.mapToItem(null, mouse.x, mouse.y)
        Store.openWidgetMenu(host.screenName, p.x, p.y, host.wid)
      } else {
        Store.selectedId = host.wid
      }
    }
  }

  DragHandler {
    id: dh
    target: null
    acceptedButtons: Qt.LeftButton
    enabled: !Store.locked && Store.carryId === ""
    property real startX: 0
    property real startY: 0
    onActiveChanged: {
      if (active) {
        startX = host.x
        startY = host.y
        host.dragX = host.x
        host.dragY = host.y
        host.dragging = true
        Store.selectedId = host.wid
      } else if (host.dragging) {
        host.finishDrag()
      }
    }
    onActiveTranslationChanged: {
      if (active) {
        host.dragX = startX + activeTranslation.x
        host.dragY = startY + activeTranslation.y
      }
    }
  }

  TapHandler {
    acceptedButtons: Qt.LeftButton
    longPressThreshold: 0.9
    onLongPressed: if (!host.dragging) Store.editMode = true
  }

  Rectangle {
    anchors.fill: parent
    anchors.margins: -4
    z: 4
    radius: Theme.widgetRadius + 4
    color: "transparent"
    border.width: 2
    border.color: host.selected ? Theme.m3Primary : Qt.alpha(Theme.m3Primary, 0.55)
    visible: Store.editMode
  }

  component Badge: Rectangle {
    id: badge
    property string icon: ""
    property color fg: "white"
    signal activated()
    width: 32
    height: 32
    radius: 16
    Icon { anchors.centerIn: parent; name: badge.icon; size: 18; color: badge.fg }
    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      cursorShape: Qt.PointingHandCursor
      onClicked: badge.activated()
    }
  }

  Row {
    visible: Store.editMode && !host.lifted
    z: 6
    anchors.right: parent.right
    anchors.rightMargin: -6
    anchors.top: parent.top
    anchors.topMargin: -14
    spacing: 6

    Badge {
      visible: Catalog.kinds[host.kind] ? Catalog.kinds[host.kind].sizes.length > 1 : false
      color: Theme.m3SecondaryContainer
      fg: Theme.m3OnSecondaryContainer
      icon: "resize"
      onActivated: host.nextSize()
    }
    Badge {
      color: Theme.m3SecondaryContainer
      fg: Theme.m3OnSecondaryContainer
      icon: "settings"
      onActivated: Store.openConfig(host.screenName, host.wid)
    }
    Badge {
      color: Theme.m3ErrorContainer
      fg: Theme.m3OnErrorContainer
      icon: "close"
      onActivated: Store.remove(host.wid)
    }
  }
}
