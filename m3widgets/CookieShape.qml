import QtQuick
import QtQuick.Shapes

// Scalloped "cookie" shape from Material 3 Expressive, generated as a polyline
// r(t) = R * (1 - amp/2 * (1 - cos(sides * t))).
Item {
  id: root
  property color color: Theme.m3SecondaryContainer
  property int sides: 9
  property real amp: 0.08
  property real phase: 0

  readonly property var pts: {
    const out = []
    const n = 240
    const cx = width / 2
    const cy = height / 2
    const r = Math.min(width, height) / 2
    for (let i = 0; i <= n; i++) {
      const t = i / n * 2 * Math.PI
      const rr = r * (1 - amp * 0.5 * (1 - Math.cos(sides * t + phase)))
      out.push(Qt.point(cx + rr * Math.cos(t), cy + rr * Math.sin(t)))
    }
    return out
  }

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      fillColor: root.color
      strokeWidth: -1
      PathPolyline { path: root.pts }
    }
  }
}
