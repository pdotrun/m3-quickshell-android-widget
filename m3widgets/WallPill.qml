// WallPill.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick

Rectangle {
    id: pill

    property var theme
    property string text: ""
    property string icon: ""
    property bool selected: false
    property bool checkable: true
    property bool outlined: true
    property real baseRadius: 14
    property color idleColor: "transparent"

    signal clicked()

    implicitHeight: 40
    implicitWidth: content.implicitWidth + 32

    radius: selected ? height / 2 : baseRadius
    color: selected ? theme.secondaryContainer : idleColor
    border.width: (selected || !outlined) ? 0 : 1
    border.color: theme.outlineVariant

    Behavior on radius {
        NumberAnimation { duration: 340; easing.type: Easing.OutBack; easing.overshoot: 1.8 }
    }
    Behavior on color { ColorAnimation { duration: 200 } }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 6

        WallIcon {
            visible: pill.icon !== "" || (pill.selected && pill.checkable)
            theme: pill.theme
            name: pill.icon !== "" ? pill.icon : "check"
            size: 18
            color: pill.selected ? pill.theme.m3onSecondaryContainer : pill.theme.m3onSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: pill.text
            font.family: pill.theme.fontFamily
            font.pixelSize: 14
            font.weight: Font.Medium
            color: pill.selected ? pill.theme.m3onSecondaryContainer : pill.theme.m3onSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: pill.radius
        color: pill.selected ? pill.theme.m3onSecondaryContainer : pill.theme.m3onSurface
        opacity: area.pressed ? 0.12 : (area.containsMouse ? 0.08 : 0)
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: pill.clicked()
    }
}
