import QtQuick

Rectangle {
  id: root
  property string label: ""
  property string icon: ""
  property string variant: "tonal"      // filled | tonal | text
  signal clicked()

  readonly property color fg: variant === "filled" ? Theme.m3OnPrimary
                            : variant === "tonal" ? Theme.m3OnSecondaryContainer
                            : Theme.m3Primary

  implicitHeight: 40
  implicitWidth: row.implicitWidth + (variant === "text" ? 24 : 40)
  radius: height / 2
  color: variant === "filled" ? Theme.m3Primary
       : variant === "tonal" ? Theme.m3SecondaryContainer
       : "transparent"

  Rectangle {
    anchors.fill: parent
    radius: parent.radius
    color: root.fg
    opacity: ma.pressed ? 0.12 : (ma.containsMouse ? 0.08 : 0)
  }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 8
    Icon { visible: root.icon !== ""; name: root.icon; size: 18; color: root.fg; anchors.verticalCenter: parent.verticalCenter }
    M3Text { text: root.label; color: root.fg; font.pixelSize: 14; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
  }

  MouseArea {
    id: ma
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
