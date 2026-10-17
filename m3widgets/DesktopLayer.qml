import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
  id: win

  required property var modelData
  readonly property string screenName: modelData.name

  screen: modelData
  anchors { top: true; bottom: true; left: true; right: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Bottom
  WlrLayershell.namespace: "m3widgets"

  Item {
    id: stage
    anchors.fill: parent

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
          Store.openDesktopMenu(win.screenName, mouse.x, mouse.y)
        } else {
          Store.selectedId = ""
          if (Store.editMode) Store.editMode = false
        }
      }
    }

    Repeater {
      model: Store.model
      WidgetHost { screenName: win.screenName }
    }

    MouseArea {
      anchors.fill: parent
      z: 1000
      visible: Store.carryId !== "" && Store.carryScreen === win.screenName
      enabled: visible
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      cursorShape: Qt.SizeAllCursor
      onPositionChanged: mouse => Store.carryTo(mouse.x, mouse.y)
      onClicked: mouse => {
        if (mouse.button === Qt.RightButton) Store.cancelCarry()
        else Store.dropCarry()
      }
    }

    Rectangle {
      visible: Store.editMode || Store.carryId !== ""
      z: 900
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 36
      height: 52
      width: hint.implicitWidth + 32
      radius: 26
      color: Theme.m3InverseSurface

      MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }   // swallow clicks

      Row {
        id: hint
        anchors.centerIn: parent
        spacing: 16

        M3Text {
          anchors.verticalCenter: parent.verticalCenter
          text: Store.carryId !== "" ? "Click to place · right-click to cancel"
                                     : "Drag widgets to move them"
          color: Theme.m3InverseOnSurface
        }

        Rectangle {
          visible: Store.carryId === ""
          anchors.verticalCenter: parent.verticalCenter
          width: doneText.implicitWidth + 24
          height: 36
          radius: 18
          color: doneArea.containsMouse ? Qt.alpha(Theme.m3InversePrimary, 0.2) : "transparent"
          M3Text {
            id: doneText
            anchors.centerIn: parent
            text: "Done"
            color: Theme.m3InversePrimary
            font.weight: Font.Medium
          }
          MouseArea {
            id: doneArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: Store.editMode = false
          }
        }
      }
    }
  }
}
