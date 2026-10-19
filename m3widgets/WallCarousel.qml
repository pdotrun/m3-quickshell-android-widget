// WallCarousel.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick
import QtQuick.Effects

Item {
    id: car

    property var model: []
    property var library
    property var theme
    property int currentIndex: 0
    property string currentPath: ""
    property bool springOn: true
    property bool settled: true
    property int previewWidth: 640

    readonly property int count: model ? model.length : 0

    signal activated(int index)

    readonly property real heroW: Math.max(240, Math.min(460, width * 0.34))
    readonly property real gap: 12
    readonly property var widths: [heroW, heroW * 0.64, heroW * 0.27, heroW * 0.11, 0]
    readonly property var centers: {
        const c = [0]
        for (let i = 1; i < widths.length; ++i)
            c.push(c[i - 1] + widths[i - 1] / 2 + gap + widths[i] / 2)
        return c
    }
    implicitHeight: Math.round(heroW * 0.62)

    function lerpAt(arr, a) {
        a = Math.min(Math.abs(a), arr.length - 1)
        const i = Math.min(Math.floor(a), arr.length - 2)
        return arr[i] + (arr[i + 1] - arr[i]) * (a - i)
    }

    function targetX() { return currentIndex * view.slot + view.slot / 2 - view.width / 2 }

    Timer { id: settleTimer; interval: 160; onTriggered: car.settled = true }
    property real lastMove: 0
    function moved() {
        const now = Date.now()
        if (now - lastMove < 160) { settled = false; settleTimer.restart() }
        lastMove = now
    }
    function hush() { settled = false; settleTimer.restart() }

    function jumpTo(i) {
        hush()
        currentIndex = count > 0 ? Math.max(0, Math.min(count - 1, i)) : 0
        spring.stop()
        springOn = false
        view.contentX = targetX()
        springOn = true
    }

    function goTo(i) {
        if (count === 0) return
        i = Math.max(0, Math.min(count - 1, i))
        if (i === currentIndex) return
        if (Math.abs(i - currentIndex) > 8) { jumpTo(i); return }
        moved()
        currentIndex = i
        view.contentX = targetX()
    }

    function step(n) { goTo(currentIndex + n) }

    onModelChanged: jumpTo(0)

    WheelHandler {
        property real acc: 0
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            const dy = event.angleDelta.y
            const dx = event.angleDelta.x
            acc += Math.abs(dy) >= Math.abs(dx) ? dy : dx
            while (acc >= 120)  { acc -= 120; car.step(-1) }
            while (acc <= -120) { acc += 120; car.step(1) }
        }
    }

    ListView {
        id: view
        anchors.fill: parent
        orientation: ListView.Horizontal
        interactive: false
        clip: true
        model: car.model
        boundsBehavior: Flickable.StopAtBounds

        readonly property real slot: Math.max(40, width / 8)
        leftMargin: (width - slot) / 2
        rightMargin: (width - slot) / 2
        cacheBuffer: slot * 2

        onWidthChanged: Qt.callLater(() => car.jumpTo(car.currentIndex))

        Behavior on contentX {
            enabled: car.springOn
            SpringAnimation { id: spring; spring: 3.0; damping: 0.42; epsilon: 0.25 }
        }

        delegate: Item {
            id: dlg

            required property var modelData
            required property int index

            readonly property real slot: view.slot
            readonly property real d: (index * slot + slot / 2 - (view.contentX + view.width / 2)) / slot
            readonly property real ad: Math.abs(d)
            readonly property real cw: car.lerpAt(car.widths, ad)
            readonly property real shift: (d < 0 ? -1 : 1) * car.lerpAt(car.centers, ad) - d * slot
            readonly property bool isCurrent: ad < 0.5

            readonly property bool wantLoad: car.settled && ad < 2.6
            property bool armed: false
            onWantLoadChanged: if (wantLoad) armed = true
            Component.onCompleted: if (wantLoad) armed = true
            readonly property string srcUrl: armed ? car.library.fileUrl(modelData.path) : ""
            readonly property bool ready: img.status === Image.Ready
            readonly property bool broken: img.status === Image.Error

            width: slot
            height: view.height
            z: 100 - ad * 10
            visible: cw > 2

            Item {
                id: card
                width: dlg.cw
                height: dlg.height
                x: (dlg.width - width) / 2 + dlg.shift

                readonly property real r: Math.min(32, width / 2)

                Rectangle {
                    anchors.fill: parent
                    radius: card.r
                    color: car.theme.surfaceContainerHighest

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: car.theme.m3onSurface
                        opacity: 0
                        visible: !dlg.ready && !dlg.broken
                        SequentialAnimation on opacity {
                            running: !dlg.ready && !dlg.broken && dlg.visible
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.10; duration: 700; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 0.02; duration: 700; easing.type: Easing.InOutSine }
                        }
                    }
                }

                Item {
                    id: clipBox
                    anchors.fill: parent
                    clip: true
                    visible: dlg.ready
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: maskItem
                        maskThresholdMin: 0.5
                        maskSpreadAtMin: 1.0
                    }

                    Image {
                        id: img
                        anchors.centerIn: parent
                        width: Math.max(parent.width, car.heroW)
                        height: parent.height
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                        sourceSize.width: car.previewWidth
                        source: dlg.srcUrl
                        opacity: status === Image.Ready ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 240 } }
                    }
                }

                Item {
                    id: maskItem
                    anchors.fill: parent
                    visible: false
                    layer.enabled: true
                    Rectangle { anchors.fill: parent; radius: card.r; color: "black" }
                }

                WallIcon {
                    anchors.centerIn: parent
                    visible: dlg.broken
                    theme: car.theme
                    name: "broken_image"
                    size: 32
                    color: car.theme.m3onSurfaceVariant
                }

                Rectangle {
                    visible: dlg.modelData.path === car.currentPath && card.width > 160
                    x: 14
                    y: 14
                    height: 28
                    width: badgeRow.implicitWidth + 20
                    radius: 14
                    color: car.theme.tertiaryContainer
                    opacity: Math.max(0, 1 - dlg.ad * 1.5)
                    Row {
                        id: badgeRow
                        anchors.centerIn: parent
                        spacing: 4
                        WallIcon { theme: car.theme; name: "check"; size: 14; color: car.theme.m3onTertiaryContainer
                               anchors.verticalCenter: parent.verticalCenter }
                        Text {
                            text: "In use"
                            font.family: car.theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: car.theme.m3onTertiaryContainer
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: dlg.isCurrent ? car.activated(dlg.index) : car.goTo(dlg.index)
                }
            }
        }
    }
}
