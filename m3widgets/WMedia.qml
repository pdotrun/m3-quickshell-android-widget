// WMedia.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

WidgetBase {
  id: root

  readonly property bool compact: ch < 2

  readonly property var player: {
    const v = Mpris.players.values
    for (let i = 0; i < v.length; i++)
      if (v[i].isPlaying) return v[i]
    return v.length > 0 ? v[0] : null
  }
  readonly property bool has: player !== null
  readonly property bool playing: has && player.isPlaying

  readonly property string title: preview ? "Midnight City"
    : (has ? (player.trackTitle || "Unknown title") : "Nothing playing")
  readonly property string artist: preview ? "M83"
    : (has ? (player.trackArtist || "") : "Play something to see it here")
  readonly property string art: has ? player.trackArtUrl : ""
  readonly property real progress: (has && player.lengthSupported && player.length > 0)
    ? Math.max(0, Math.min(1, player.position / player.length)) : 0

  Timer {
    interval: 1000
    repeat: true
    running: root.playing && root.visible
    onTriggered: root.player.positionChanged()
  }

  component Ctrl: Rectangle {
    id: ctrl
    property string icon: ""
    property bool active: true
    property bool blocked: false
    signal activated()
    width: 44
    height: 44
    radius: 22
    color: ma.containsMouse && ctrl.active ? Qt.alpha(Theme.m3OnSecondaryContainer, 0.12) : "transparent"
    opacity: ctrl.active ? 1 : 0.4
    Icon { anchors.centerIn: parent; name: ctrl.icon; size: 26; color: Theme.m3OnSecondaryContainer }
    MouseArea {
      id: ma
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton
      cursorShape: Qt.PointingHandCursor
      onClicked: if (ctrl.active && !ctrl.blocked) ctrl.activated()
    }
  }

  component PlayButton: Rectangle {
    id: pb
    property bool compactMode: false
    property bool isPlaying: false
    property bool enabledBtn: false
    signal activated()
    width: compactMode ? 52 : 64
    height: compactMode ? 44 : 52
    radius: isPlaying ? 16 : height / 2
    color: Theme.m3Primary
    Behavior on radius { NumberAnimation { duration: 240; easing.type: Easing.OutBack } }
    Icon {
      anchors.centerIn: parent
      name: pb.isPlaying ? "pause" : "play"
      size: 28
      color: Theme.m3OnPrimary
    }
    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      cursorShape: Qt.PointingHandCursor
      onClicked: if (pb.enabledBtn) pb.activated()
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.widgetRadius
    color: Theme.m3SecondaryContainer
  }

  Item {
    id: artBox
    x: root.compact ? 12 : 16
    y: root.compact ? 12 : 16
    width: root.compact ? root.height - 24 : root.height - 32
    height: width

    Rectangle {
      anchors.fill: parent
      radius: root.compact ? 18 : 28
      color: Theme.m3PrimaryContainer
      visible: !artImg.ready
      Icon { anchors.centerIn: parent; name: "music"; size: parent.width * 0.4; color: Theme.m3OnPrimaryContainer }
    }
    RoundedImage {
      id: artImg
      anchors.fill: parent
      radius: root.compact ? 18 : 28
      source: root.art
    }
  }

  Item {
    visible: !root.compact
    anchors.left: artBox.right
    anchors.leftMargin: 16
    anchors.right: parent.right
    anchors.rightMargin: 16
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    Column {
      y: 18
      width: parent.width
      spacing: 1
      M3Text { width: parent.width; elide: Text.ElideRight; text: root.title; color: Theme.m3OnSecondaryContainer; font.pixelSize: 18; font.weight: Font.Bold }
      M3Text { width: parent.width; elide: Text.ElideRight; text: root.artist; color: Theme.m3OnSecondaryContainer; opacity: 0.75; font.pixelSize: 14 }
    }

    Item {
      id: bar
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: controls.top
      anchors.bottomMargin: 4
      height: 16
      visible: root.has && root.player.lengthSupported

      Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 6; radius: 3; color: Qt.alpha(Theme.m3OnSecondaryContainer, 0.2) }
      Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width * root.progress; height: 6; radius: 3; color: Theme.m3Primary }
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
          if (root.has && root.player.canSeek && root.player.length > 0)
            root.player.position = mouse.x / width * root.player.length
        }
      }
    }

    Row {
      id: controls
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 12
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 6
      Ctrl { icon: "prev"; blocked: root.preview; active: root.has && root.player.canGoPrevious; onActivated: root.player.previous() }
      PlayButton { compactMode: root.compact; isPlaying: root.playing; enabledBtn: root.has && root.player.canTogglePlaying && !root.preview; onActivated: root.player.togglePlaying() }
      Ctrl { icon: "next"; blocked: root.preview; active: root.has && root.player.canGoNext; onActivated: root.player.next() }
    }
  }

  Item {
    visible: root.compact
    anchors.left: artBox.right
    anchors.leftMargin: 14
    anchors.right: parent.right
    anchors.rightMargin: 12
    anchors.verticalCenter: parent.verticalCenter
    height: parent.height

    Column {
      anchors.left: parent.left
      anchors.right: compactCtl.left
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      spacing: 1
      M3Text { width: parent.width; elide: Text.ElideRight; text: root.title; color: Theme.m3OnSecondaryContainer; font.pixelSize: 16; font.weight: Font.Bold }
      M3Text { width: parent.width; elide: Text.ElideRight; text: root.artist; color: Theme.m3OnSecondaryContainer; opacity: 0.75; font.pixelSize: 13 }
    }
    Row {
      id: compactCtl
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2
      PlayButton { compactMode: root.compact; isPlaying: root.playing; enabledBtn: root.has && root.player.canTogglePlaying && !root.preview; onActivated: root.player.togglePlaying() }
      Ctrl { icon: "next"; blocked: root.preview; active: root.has && root.player.canGoNext; onActivated: root.player.next() }
    }
  }
}
