// WallIcon.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick

Text {
    id: icon

    property var theme
    property string name: ""
    property real size: 22

    readonly property var glyphs: ({
        search: "\u2315",
        close: "\u2715",
        check: "\u2713",
        dark_mode: "\u263E",
        light_mode: "\u263C",
        broken_image: "\u26A0"
    })

    text: (theme && theme.hasSymbols) ? name : (glyphs[name] || "\u2022")
    font.family: (theme && theme.hasSymbols) ? theme.symbolsFamily : (theme ? theme.fontFamily : "sans-serif")
    font.pixelSize: size
    color: theme ? theme.m3onSurface : "white"
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
