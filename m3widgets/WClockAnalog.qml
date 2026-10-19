// WClockAnalog.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick
import Quickshell

WidgetBase {
  id: root

  readonly property bool secs: opt("seconds", true)
  readonly property real d: Math.min(width, height)

  SystemClock { id: clk; precision: root.secs ? SystemClock.Seconds : SystemClock.Minutes }

  readonly property real hourAngle: ((clk.date.getHours() % 12) + clk.date.getMinutes() / 60) * 30
  readonly property real minuteAngle: (clk.date.getMinutes() + clk.date.getSeconds() / 60) * 6
  readonly property real secondAngle: clk.date.getSeconds() * 6

  component Hand: Item {
    property real len: 10
    property real thick: 4
    property real tail: 0
    property color tint: "white"
    width: 0
    height: 0
    Rectangle {
      x: -parent.thick / 2
      y: -parent.len
      width: parent.thick
      height: parent.len + parent.tail
      radius: parent.thick / 2
      color: parent.tint
    }
  }

  CookieShape {
    anchors.centerIn: parent
    width: root.d
    height: root.d
    sides: 9
    amp: 0.075
    color: Theme.m3SecondaryContainer
  }

  Repeater {
    model: 12
    delegate: Rectangle {
      required property int index
      readonly property bool major: index % 3 === 0
      readonly property real a: index * Math.PI / 6
      readonly property real rad: root.d * 0.36
      width: root.d * (major ? 0.045 : 0.026)
      height: width
      radius: width / 2
      x: root.width / 2 + Math.sin(a) * rad - width / 2
      y: root.height / 2 - Math.cos(a) * rad - height / 2
      color: Theme.m3OnSecondaryContainer
      opacity: major ? 0.85 : 0.4
    }
  }

  Hand {
    x: root.width / 2
    y: root.height / 2
    rotation: root.hourAngle
    len: root.d * 0.22
    thick: root.d * 0.06
    tint: Theme.m3Primary
  }
  Hand {
    x: root.width / 2
    y: root.height / 2
    rotation: root.minuteAngle
    len: root.d * 0.32
    thick: root.d * 0.045
    tint: Theme.m3OnSecondaryContainer
  }
  Hand {
    visible: root.secs
    x: root.width / 2
    y: root.height / 2
    rotation: root.secondAngle
    len: root.d * 0.34
    thick: root.d * 0.018
    tail: root.d * 0.07
    tint: Theme.m3Tertiary
  }

  Rectangle {
    anchors.centerIn: parent
    width: root.d * 0.075
    height: width
    radius: width / 2
    color: Theme.m3Primary
    Rectangle { anchors.centerIn: parent; width: parent.width * 0.4; height: width; radius: width / 2; color: Theme.m3SecondaryContainer }
  }
}
