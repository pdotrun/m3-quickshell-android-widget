import QtQuick

// Outlined text field. Emits `committed` (debounced while typing, and on Enter / focus loss).
Rectangle {
  id: root
  property string text: ""
  property string placeholder: ""
  signal committed(string value)

  implicitHeight: 48
  radius: 12
  color: Theme.m3SurfaceContainerHighest
  border.width: input.activeFocus ? 2 : 1
  border.color: input.activeFocus ? Theme.m3Primary : Theme.m3Outline

  onTextChanged: if (input.text !== text) input.text = text

  TextInput {
    id: input
    anchors.fill: parent
    anchors.leftMargin: 14
    anchors.rightMargin: 14
    verticalAlignment: TextInput.AlignVCenter
    clip: true
    selectByMouse: true
    color: Theme.m3OnSurface
    selectionColor: Theme.m3PrimaryContainer
    selectedTextColor: Theme.m3OnPrimaryContainer
    font.family: Theme.fontFamily
    font.pixelSize: 15
    text: root.text
    onTextEdited: debounce.restart()
    onEditingFinished: { debounce.stop(); root.committed(text) }
  }

  M3Text {
    anchors.left: parent.left
    anchors.leftMargin: 14
    anchors.verticalCenter: parent.verticalCenter
    visible: input.text.length === 0
    text: root.placeholder
    color: Theme.m3OnSurfaceVariant
    opacity: 0.7
    font.pixelSize: 15
  }

  Timer { id: debounce; interval: 800; onTriggered: root.committed(input.text) }
}
