// Store.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  readonly property int cell: 92
  readonly property int gap: 8
  readonly property int margin: 24
  function px(n) { return n * cell - gap }

  property bool snap: true
  property bool locked: false
  onSnapChanged: save()
  onLockedChanged: save()

  property bool editMode: false
  property string selectedId: ""

  property string carryId: ""
  property string carryScreen: ""
  property real carryOrigX: 0
  property real carryOrigY: 0

  property string overlayKind: ""
  property string overlayScreen: ""
  property real overlayX: 0
  property real overlayY: 0
  property string overlayTarget: ""
  property real addX: 0
  property real addY: 0

  property alias model: widgetModel
  ListModel { id: widgetModel }

  property bool dirReady: false
  property bool loaded: false
  property bool loading: false

  Process {
    command: ["mkdir", "-p", Quickshell.stateDir]
    running: true
    onExited: root.dirReady = true
  }

  FileView {
    id: file
    path: root.dirReady ? Quickshell.statePath("widgets.json") : ""
    onLoaded: root.loadFrom(file.text())
    onLoadFailed: root.seed()
  }

  Timer { id: saveTimer; interval: 350; onTriggered: root.saveNow() }
  Component.onDestruction: if (saveTimer.running) saveNow()

  function save() {
    if (loaded && !loading) saveTimer.restart()
  }

  function saveNow() {
    saveTimer.stop()
    const arr = []
    for (let i = 0; i < widgetModel.count; i++) {
      const w = widgetModel.get(i)
      let c = {}
      try { c = JSON.parse(w.cfg) } catch (e) {}
      arr.push({ id: w.wid, kind: w.kind, screen: w.scr, x: w.posX, y: w.posY, size: w.sizeId, cfg: c })
    }
    file.setText(JSON.stringify({ version: 1, snap: snap, locked: locked, widgets: arr }, null, 2))
  }

  function loadFrom(text) {
    let d
    try { d = JSON.parse(text) } catch (e) {
      console.warn("m3widgets: could not parse state file, starting fresh")
      seed()
      return
    }
    loading = true
    widgetModel.clear()
    snap = d.snap !== false
    locked = d.locked === true
    const list = d.widgets || []
    for (let i = 0; i < list.length; i++) {
      const w = list[i]
      if (!w || !Catalog.kinds[w.kind]) continue
      const size = Catalog.sizeOf(w.kind, w.size) ? w.size : Catalog.defaultSize(w.kind)
      const cfg = Object.assign({}, Catalog.defaults(w.kind), w.cfg || {})
      widgetModel.append({
        wid: w.id || newId(), kind: w.kind, scr: w.screen || "",
        posX: Number(w.x) || 0, posY: Number(w.y) || 0, sizeId: size, cfg: JSON.stringify(cfg)
      })
    }
    loading = false
    loaded = true
  }

  function seed() {
    const scr = Quickshell.screens.length > 0 ? Quickshell.screens[0].name : ""
    loading = true
    widgetModel.clear()
    const put = function (kind, col, row, size) {
      addRaw(kind, scr, margin + col * cell, margin + row * cell, size, Catalog.defaults(kind))
    }
    put("glance", 0, 0, "4x1")
    put("clockDigital", 0, 1, "2x2")
    put("weather", 2, 1, "2x2")
    put("calendar", 0, 3, "2x2")
    put("battery", 2, 3, "2x2")
    put("media", 0, 5, "4x2")
    loading = false
    loaded = true
    save()
  }

  function resetLayout() {
    editMode = false
    carryId = ""
    seed()
  }

  function newId() {
    return "w" + Date.now().toString(36) + Math.floor(Math.random() * 46656).toString(36)
  }

  function indexOfId(id) {
    for (let i = 0; i < widgetModel.count; i++)
      if (widgetModel.get(i).wid === id) return i
    return -1
  }

  function get(id) {
    const i = indexOfId(id)
    return i < 0 ? null : widgetModel.get(i)
  }

  function cfgOf(id) {
    const w = get(id)
    if (!w) return ({})
    try { return JSON.parse(w.cfg) } catch (e) { return ({}) }
  }

  function addRaw(kind, scr, x, y, sizeId, cfgObj) {
    const id = newId()
    widgetModel.append({
      wid: id, kind: kind, scr: scr, posX: x, posY: y,
      sizeId: sizeId, cfg: JSON.stringify(cfgObj)
    })
    return id
  }

  function screenFor(name) {
    const s = Quickshell.screens
    for (let i = 0; i < s.length; i++)
      if (s[i].name === name) return name
    return s.length > 0 ? s[0].name : ""
  }

  function screenSize(name) {
    const s = Quickshell.screens
    for (let i = 0; i < s.length; i++)
      if (s[i].name === name) return { w: s[i].width, h: s[i].height }
    return { w: 1920, h: 1080 }
  }

  function snapValue(v) { return Math.round((v - margin) / cell) * cell + margin }

  function clampPos(screenName, kind, sizeId, x, y) {
    const sz = screenSize(screenName)
    const d = Catalog.dims(kind, sizeId)
    return {
      x: Math.max(0, Math.min(sz.w - d.w, x)),
      y: Math.max(0, Math.min(sz.h - d.h, y))
    }
  }

  function add(kind, screenName, x, y) {
    const size = Catalog.defaultSize(kind)
    let px = x, py = y
    if (snap) { px = snapValue(px); py = snapValue(py) }
    const p = clampPos(screenName, kind, size, px, py)
    const id = addRaw(kind, screenName, p.x, p.y, size, Catalog.defaults(kind))
    selectedId = id
    save()
  }

  function remove(id) {
    const i = indexOfId(id)
    if (i < 0) return
    widgetModel.remove(i)
    if (selectedId === id) selectedId = ""
    if (carryId === id) carryId = ""
    save()
  }

  function duplicate(id) {
    const w = get(id)
    if (!w) return
    let c = {}
    try { c = JSON.parse(w.cfg) } catch (e) {}
    const p = clampPos(w.scr, w.kind, w.sizeId, w.posX + cell / 2, w.posY + cell / 2)
    selectedId = addRaw(w.kind, w.scr, p.x, p.y, w.sizeId, c)
    save()
  }

  function setPos(id, x, y) {
    const i = indexOfId(id)
    if (i < 0) return
    widgetModel.setProperty(i, "posX", x)
    widgetModel.setProperty(i, "posY", y)
    save()
  }

  function setSize(id, sizeId) {
    const i = indexOfId(id)
    if (i < 0) return
    widgetModel.setProperty(i, "sizeId", sizeId)
    save()
  }

  function setConfig(id, key, value) {
    const i = indexOfId(id)
    if (i < 0) return
    const c = cfgOf(id)
    c[key] = value
    widgetModel.setProperty(i, "cfg", JSON.stringify(c))
    save()
  }

  function resetConfig(id) {
    const i = indexOfId(id)
    if (i < 0) return
    widgetModel.setProperty(i, "cfg", JSON.stringify(Catalog.defaults(widgetModel.get(i).kind)))
    save()
  }

  function startCarry(id, screenName) {
    const w = get(id)
    if (!w) return
    carryOrigX = w.posX
    carryOrigY = w.posY
    carryScreen = screenName
    carryId = id
    selectedId = id
  }

  function carryTo(gx, gy) {
    const i = indexOfId(carryId)
    if (i < 0) return
    const w = widgetModel.get(i)
    const d = Catalog.dims(w.kind, w.sizeId)
    const p = clampPos(carryScreen, w.kind, w.sizeId, gx - d.w / 2, gy - d.h / 2)
    widgetModel.setProperty(i, "posX", p.x)
    widgetModel.setProperty(i, "posY", p.y)
    widgetModel.setProperty(i, "scr", carryScreen)
  }

  function dropCarry() {
    const i = indexOfId(carryId)
    if (i >= 0 && snap) {
      const w = widgetModel.get(i)
      const p = clampPos(carryScreen, w.kind, w.sizeId, snapValue(w.posX), snapValue(w.posY))
      widgetModel.setProperty(i, "posX", p.x)
      widgetModel.setProperty(i, "posY", p.y)
    }
    carryId = ""
    save()
  }

  function cancelCarry() {
    const i = indexOfId(carryId)
    if (i >= 0) {
      widgetModel.setProperty(i, "posX", carryOrigX)
      widgetModel.setProperty(i, "posY", carryOrigY)
    }
    carryId = ""
  }

  function openDesktopMenu(screenName, x, y) {
    selectedId = ""
    overlayScreen = screenName
    overlayX = x
    overlayY = y
    overlayTarget = ""
    addX = x
    addY = y
    overlayKind = "desktopMenu"
  }

  function openWidgetMenu(screenName, x, y, id) {
    selectedId = id
    overlayScreen = screenName
    overlayX = x
    overlayY = y
    overlayTarget = id
    overlayKind = "widgetMenu"
  }

  function openAdd(screenName) {
    overlayScreen = screenName
    overlayTarget = ""
    overlayKind = "add"
  }

  function openConfig(screenName, id) {
    overlayScreen = screenName
    overlayTarget = id
    selectedId = id
    overlayKind = "config"
  }

  property bool wallOpen: false
  property string wallScreen: ""
  function openWallpapers(screenName) { wallScreen = screenName; wallOpen = true }
  function closeWallpapers() { wallOpen = false }

  function closeOverlay() {
    overlayKind = ""
    overlayTarget = ""
  }
}
