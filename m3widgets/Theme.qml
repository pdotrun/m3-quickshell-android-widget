pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  readonly property string fontFamily: "Google Sans"
  readonly property int widgetRadius: 28

  property color m3Primary: "#D0BCFF"
  Behavior on m3Primary { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3OnPrimary: "#381E72"
  Behavior on m3OnPrimary { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3PrimaryContainer: "#4F378B"
  Behavior on m3PrimaryContainer { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3OnPrimaryContainer: "#EADDFF"
  Behavior on m3OnPrimaryContainer { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3Secondary: "#CCC2DC"
  Behavior on m3Secondary { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3OnSecondary: "#332D41"
  Behavior on m3OnSecondary { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3SecondaryContainer: "#4A4458"
  Behavior on m3SecondaryContainer { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3OnSecondaryContainer: "#E8DEF8"
  Behavior on m3OnSecondaryContainer { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3Tertiary: "#EFB8C8"
  Behavior on m3Tertiary { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3OnTertiary: "#492532"
  Behavior on m3OnTertiary { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3TertiaryContainer: "#633B48"
  Behavior on m3TertiaryContainer { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3OnTertiaryContainer: "#FFD8E4"
  Behavior on m3OnTertiaryContainer { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3Error: "#F2B8B5"
  Behavior on m3Error { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3OnError: "#601410"
  Behavior on m3OnError { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3ErrorContainer: "#8C1D18"
  Behavior on m3ErrorContainer { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3OnErrorContainer: "#F9DEDC"
  Behavior on m3OnErrorContainer { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3Surface: "#141218"
  Behavior on m3Surface { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3OnSurface: "#E6E0E9"
  Behavior on m3OnSurface { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3SurfaceVariant: "#49454F"
  Behavior on m3SurfaceVariant { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3OnSurfaceVariant: "#CAC4D0"
  Behavior on m3OnSurfaceVariant { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3Outline: "#938F99"
  Behavior on m3Outline { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3OutlineVariant: "#49454F"
  Behavior on m3OutlineVariant { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3SurfaceContainerLowest: "#0F0D13"
  Behavior on m3SurfaceContainerLowest { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3SurfaceContainerLow: "#1D1B20"
  Behavior on m3SurfaceContainerLow { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3SurfaceContainer: "#211F26"
  Behavior on m3SurfaceContainer { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3SurfaceContainerHigh: "#2B2930"
  Behavior on m3SurfaceContainerHigh { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3SurfaceContainerHighest: "#36343B"
  Behavior on m3SurfaceContainerHighest { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3InverseSurface: "#E6E0E9"
  Behavior on m3InverseSurface { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3InverseOnSurface: "#322F35"
  Behavior on m3InverseOnSurface { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3InversePrimary: "#6750A4"
  Behavior on m3InversePrimary { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3Shadow: "#000000"
  Behavior on m3Shadow { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }
  property color m3Scrim: "#000000"
  Behavior on m3Scrim { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }

  readonly property bool isDark: m3Surface.hslLightness < 0.5

  readonly property string colorsPath: Quickshell.env("HOME") + "/.cache/m3widgets/colors.json"

  function camel(key) {
    return key.split("_").map(function (p) { return p.charAt(0).toUpperCase() + p.slice(1) }).join("")
  }

  function apply(text) {
    let obj
    try { obj = JSON.parse(text) } catch (e) { return }   
    for (const key in obj) {
      const name = "m3" + camel(key)
      const val = obj[key]
      if (typeof root[name] === "undefined") continue
      if (typeof val !== "string" || !/^#[0-9a-fA-F]{6}$/.test(val)) continue
      root[name] = val
    }
  }

  FileView {
    id: file
    path: root.colorsPath
    watchChanges: true
    onFileChanged: debounce.restart()
    onLoaded: root.apply(file.text())
  }

  Timer { id: debounce; interval: 150; onTriggered: file.reload() }

  // Safety net: covers the file not existing yet at startup, and tools that
  // replace the file atomically (which can drop an inotify watch).
  Timer { interval: 5000; repeat: true; running: true; onTriggered: file.reload() }
}
