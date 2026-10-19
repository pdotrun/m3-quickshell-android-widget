// WallPicker.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    property string screenName: ""
    signal finished()

    readonly property real transitionDuration: 1.5
    readonly property int transitionFps: 60
    readonly property int sourceColorIndex: 0

    readonly property var schemes: [
        { id: "",                  label: "Default" },
        { id: "scheme-tonal-spot", label: "Tonal spot" },
        { id: "scheme-expressive", label: "Expressive" },
        { id: "scheme-fidelity",   label: "Fidelity" },
        { id: "scheme-content",    label: "Content" },
        { id: "scheme-fruit-salad", label: "Fruit salad" },
        { id: "scheme-rainbow",    label: "Rainbow" },
        { id: "scheme-neutral",    label: "Neutral" },
        { id: "scheme-monochrome", label: "Monochrome" }
    ]

    readonly property string home: Quickshell.env("HOME") || ""
    function expand(p) { return p.replace(/^~(?=\/|$)/, home) }

    readonly property string wallDir: expand(Quickshell.env("WALLSEL_DIR") || "~/Pictures/Wallpapers")
    readonly property string transition: Quickshell.env("WALLSEL_TRANSITION") || "grow"
    readonly property bool useMatugen: Quickshell.env("WALLSEL_NO_MATUGEN") !== "1"
    readonly property string stateBase: (Quickshell.env("XDG_STATE_HOME") || (home + "/.local/state")) + "/wallsel"

    property string mode: "dark"
    property string scheme: ""
    property string searchText: ""
    property bool closing: false

    FileView {
        id: stateFile
        path: root.stateBase + "/state.json"
        blockLoading: true
        printErrors: false
    }

    WallTheme {
        id: appTheme
        colorsPath: Theme.colorsPath
    }

    WallLibrary {
        id: lib
        dir: root.wallDir
        home: root.home
        filter: root.searchText
        focusIndex: carousel.currentIndex
        onLoaded: carousel.jumpTo(lib.initialIndex)
        onDaemonMissing: Quickshell.execDetached(["awww-daemon"])
    }

    readonly property var targetScreen: {
        const screens = Quickshell.screens
        for (let i = 0; i < screens.length; ++i)
            if (screens[i].name === screenName) return screens[i]
        return screens.length > 0 ? screens[0] : null
    }

    Component.onCompleted: {
        try {
            const s = JSON.parse(stateFile.text())
            if (s.mode === "dark" || s.mode === "light") mode = s.mode
            if (typeof s.scheme === "string") scheme = s.scheme
        } catch (e) {}
        Quickshell.execDetached(["mkdir", "-p", stateBase])
        lib.start()
    }

    function close() {
        if (closing) return
        closing = true
        enterAnim.stop()
        exitAnim.start()
    }

    function applyCurrent() {
        if (closing) return
        const it = lib.shown[carousel.currentIndex]
        if (!it) return
        stateFile.setText(JSON.stringify({ mode: mode, scheme: scheme }))
        Quickshell.execDetached(["awww", "img",
            "--transition-type", transition,
            "--transition-duration", String(transitionDuration),
            "--transition-fps", String(transitionFps),
            it.path])
        if (useMatugen) {
            const m = ["matugen", "image", it.path, "--mode", mode]
            if (scheme !== "") m.push("--type", scheme)
            m.push("--source-color-index", String(sourceColorIndex))
            Quickshell.execDetached(m)
        }
        close()
    }

    function cycleScheme(dir) {
        let i = 0
        for (let k = 0; k < schemes.length; ++k) if (schemes[k].id === scheme) i = k
        scheme = schemes[(i + dir + schemes.length) % schemes.length].id
    }

    function handleKey(e) {
        const shift = (e.modifiers & Qt.ShiftModifier) !== 0
        switch (e.key) {
        case Qt.Key_Escape:
        case Qt.Key_Q:
            close(); break
        case Qt.Key_Left:
        case Qt.Key_H:
            carousel.step(shift ? -5 : -1); break
        case Qt.Key_Right:
        case Qt.Key_L:
            carousel.step(shift ? 5 : 1); break
        case Qt.Key_PageUp:
            carousel.step(-5); break
        case Qt.Key_PageDown:
            carousel.step(5); break
        case Qt.Key_Home:
            carousel.goTo(0); break
        case Qt.Key_End:
            carousel.goTo(carousel.count - 1); break
        case Qt.Key_G:
            carousel.goTo(shift ? carousel.count - 1 : 0); break
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Space:
            applyCurrent(); break
        case Qt.Key_Slash:
            searchInput.forceActiveFocus(); break
        case Qt.Key_Tab:
            mode = mode === "dark" ? "light" : "dark"; break
        case Qt.Key_BracketLeft:
            cycleScheme(-1); break
        case Qt.Key_BracketRight:
            cycleScheme(1); break
        default:
            return
        }
        e.accepted = true
    }

    function fmtSize(b) {
        if (b >= 1048576) return (b / 1048576).toFixed(1) + " MB"
        return Math.max(1, Math.round(b / 1024)) + " KB"
    }
    function aspect(w, h) {
        if (w <= 0 || h <= 0) return ""
        const r = w / h
        const known = [[16, 9], [16, 10], [21, 9], [32, 9], [4, 3], [3, 2], [5, 4], [1, 1], [9, 16], [10, 16], [3, 4]]
        for (let i = 0; i < known.length; ++i)
            if (Math.abs(r - known[i][0] / known[i][1]) < 0.02) return known[i][0] + ":" + known[i][1]
        return r.toFixed(2) + ":1"
    }
    function metaFor(it) {
        if (!it) return ""
        const dm = lib.dimsFor(it)
        const parts = []
        if (dm) parts.push(dm.w + " \u00d7 " + dm.h + "  (" + aspect(dm.w, dm.h) + ")")
        parts.push(fmtSize(it.size))
        const slash = it.rel.lastIndexOf("/")
        if (slash > 0) parts.push(it.rel.slice(0, slash))
        return parts.join("  \u00b7  ")
    }

    PanelWindow {
        id: win

        screen: root.targetScreen
        visible: root.targetScreen !== null
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }

        WlrLayershell.namespace: "m3widgets-wallsel"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            id: ui
            anchors.fill: parent
            focus: true

            property real slide: 0

            Keys.onPressed: event => root.handleKey(event)

            Component.onCompleted: { forceActiveFocus(); enterAnim.start() }

            SpringAnimation {
                id: enterAnim
                target: ui
                property: "slide"
                to: 1
                spring: 2.4
                damping: 0.3
                epsilon: 0.002
            }
            NumberAnimation {
                id: exitAnim
                target: ui
                property: "slide"
                to: 0
                duration: 170
                easing.type: Easing.InCubic
                onFinished: root.finished()
            }

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.38 * Math.max(0, Math.min(1, ui.slide))
            }
            MouseArea { anchors.fill: parent; onClicked: root.close() }

            Rectangle {
                id: panel

                width: Math.min(ui.width - 48, 1380)
                implicitHeight: col.implicitHeight + 48
                height: implicitHeight
                x: (ui.width - width) / 2
                y: ui.height - height - 40 + (1 - ui.slide) * 90
                radius: 44
                color: appTheme.surfaceContainer
                opacity: Math.max(0, Math.min(1, ui.slide * 1.6))
                scale: 0.96 + 0.04 * Math.max(0, Math.min(1, ui.slide))
                transformOrigin: Item.Bottom

                Behavior on color { ColorAnimation { duration: 300 } }

                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    id: col
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: "Wallpapers"
                                font.family: appTheme.fontFamily
                                font.pixelSize: 26
                                font.weight: Font.Medium
                                color: appTheme.m3onSurface
                            }
                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                font.family: appTheme.fontFamily
                                font.pixelSize: 13
                                color: lib.error !== "" ? appTheme.error : appTheme.m3onSurfaceVariant
                                text: {
                                    if (lib.scanning) return "Scanning\u2026"
                                    if (lib.error !== "") return lib.error
                                    if (carousel.count === 0) return "No matches"
                                    let s = (carousel.currentIndex + 1) + " of " + carousel.count
                                    return s
                                }
                            }
                        }

                        Rectangle {
                            id: searchBox
                            Layout.preferredWidth: Math.min(300, panel.width * 0.26)
                            Layout.preferredHeight: 48
                            radius: 24
                            color: appTheme.surfaceContainerHighest
                            border.width: searchInput.activeFocus ? 2 : 0
                            border.color: appTheme.primary

                            WallIcon {
                                id: searchIcon
                                theme: appTheme
                                name: "search"
                                size: 22
                                color: appTheme.m3onSurfaceVariant
                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            TextInput {
                                id: searchInput
                                anchors.left: searchIcon.right
                                anchors.leftMargin: 8
                                anchors.right: clearBtn.left
                                anchors.rightMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                                clip: true
                                font.family: appTheme.fontFamily
                                font.pixelSize: 15
                                color: appTheme.m3onSurface
                                selectionColor: appTheme.primary
                                selectedTextColor: appTheme.m3onPrimary
                                onTextChanged: root.searchText = text
                                Keys.onEscapePressed: event => {
                                    if (text.length > 0) text = ""
                                    else ui.forceActiveFocus()
                                    event.accepted = true
                                }
                                Keys.onReturnPressed: event => { ui.forceActiveFocus(); event.accepted = true }
                                Keys.onEnterPressed: event => { ui.forceActiveFocus(); event.accepted = true }
                                Keys.onDownPressed: event => { ui.forceActiveFocus(); event.accepted = true }

                                Text {
                                    visible: searchInput.text.length === 0
                                    text: "Search  ( / )"
                                    font: searchInput.font
                                    color: appTheme.m3onSurfaceVariant
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            Item {
                                id: clearBtn
                                width: searchInput.text.length > 0 ? 36 : 12
                                height: parent.height
                                anchors.right: parent.right
                                WallIcon {
                                    visible: searchInput.text.length > 0
                                    theme: appTheme
                                    name: "close"
                                    size: 18
                                    color: appTheme.m3onSurfaceVariant
                                    anchors.centerIn: parent
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: searchInput.text.length > 0
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { searchInput.text = ""; ui.forceActiveFocus() }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: 48
                            Layout.preferredWidth: modeRow.implicitWidth + 8
                            radius: 24
                            color: appTheme.surfaceContainerHighest
                            Row {
                                id: modeRow
                                anchors.centerIn: parent
                                spacing: 4
                                WallPill {
                                    theme: appTheme
                                    text: "Dark"
                                    icon: "dark_mode"
                                    checkable: false
                                    outlined: false
                                    height: 40
                                    selected: root.mode === "dark"
                                    onClicked: root.mode = "dark"
                                }
                                WallPill {
                                    theme: appTheme
                                    text: "Light"
                                    icon: "light_mode"
                                    checkable: false
                                    outlined: false
                                    height: 40
                                    selected: root.mode === "light"
                                    onClicked: root.mode = "light"
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            radius: closeArea.pressed ? 14 : 24
                            color: appTheme.surfaceContainerHighest
                            Behavior on radius { NumberAnimation { duration: 260; easing.type: Easing.OutBack; easing.overshoot: 2 } }
                            WallIcon { anchors.centerIn: parent; theme: appTheme; name: "close"; size: 22; color: appTheme.m3onSurfaceVariant }
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: appTheme.m3onSurface
                                opacity: closeArea.containsMouse ? 0.08 : 0
                                Behavior on opacity { NumberAnimation { duration: 120 } }
                            }
                            MouseArea {
                                id: closeArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.close()
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: carousel.implicitHeight

                        WallCarousel {
                            id: carousel
                            anchors.fill: parent
                            theme: appTheme
                            library: lib
                            model: lib.shown
                            currentPath: lib.currentPath
                            onActivated: root.applyCurrent()
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: carousel.count === 0
                            text: lib.scanning ? "Scanning\u2026"
                                : (lib.error !== "" ? lib.error : "No wallpapers match")
                            font.family: appTheme.fontFamily
                            font.pixelSize: 18
                            color: appTheme.m3onSurfaceVariant
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            readonly property var cur: lib.shown[carousel.currentIndex]
                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideMiddle
                                text: parent.cur ? parent.cur.name : ""
                                font.family: appTheme.fontFamily
                                font.pixelSize: 22
                                font.weight: Font.Medium
                                color: appTheme.m3onSurface
                            }
                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: root.metaFor(parent.cur)
                                font.family: appTheme.fontFamily
                                font.pixelSize: 14
                                color: appTheme.m3onSurfaceVariant
                            }
                        }

                        Rectangle {
                            id: applyBtn
                            Layout.preferredHeight: 56
                            Layout.preferredWidth: applyRow.implicitWidth + 56
                            radius: applyArea.pressed ? 16 : 28
                            color: appTheme.primaryContainer
                            opacity: carousel.count > 0 ? 1 : 0.4
                            scale: applyArea.pressed ? 0.96 : 1
                            Behavior on radius { NumberAnimation { duration: 280; easing.type: Easing.OutBack; easing.overshoot: 2.2 } }
                            Behavior on scale { SpringAnimation { spring: 4; damping: 0.3; epsilon: 0.001 } }
                            Behavior on color { ColorAnimation { duration: 300 } }

                            Row {
                                id: applyRow
                                anchors.centerIn: parent
                                spacing: 10
                                WallIcon { theme: appTheme; name: "check"; size: 22; color: appTheme.m3onPrimaryContainer
                                       anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "Set wallpaper"
                                    font.family: appTheme.fontFamily
                                    font.pixelSize: 16
                                    font.weight: Font.Medium
                                    color: appTheme.m3onPrimaryContainer
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: appTheme.m3onPrimaryContainer
                                opacity: applyArea.pressed ? 0.12 : (applyArea.containsMouse ? 0.08 : 0)
                                Behavior on opacity { NumberAnimation { duration: 120 } }
                            }
                            MouseArea {
                                id: applyArea
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: carousel.count > 0
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.applyCurrent()
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        Flickable {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            contentWidth: chipRow.width
                            contentHeight: 40
                            clip: true
                            interactive: contentWidth > width
                            flickableDirection: Flickable.HorizontalFlick

                            Row {
                                id: chipRow
                                spacing: 8
                                Repeater {
                                    model: root.schemes
                                    delegate: WallPill {
                                        required property var modelData
                                        theme: appTheme
                                        text: modelData.label
                                        selected: root.scheme === modelData.id
                                        onClicked: root.scheme = modelData.id
                                    }
                                }
                            }
                        }

                        Text {
                            visible: panel.width > 1050
                            text: "\u2190 \u2192 browse    \u23ce apply    / search    Tab dark/light    [ ] palette    Esc close"
                            font.family: appTheme.fontFamily
                            font.pixelSize: 12
                            color: appTheme.m3onSurfaceVariant
                        }
                    }
                }
            }
        }
    }
}
