import QtQuick

// Flat, tintable weather glyphs drawn on a 100x100 canvas.
Canvas {
  id: cv
  property string kind: "clear"     // clear | partly | cloud | rain | snow | storm | fog
  property bool night: false
  property color sunColor: Theme.m3Tertiary
  property color cloudColor: Theme.m3OnSecondaryContainer
  property color accentColor: Theme.m3Primary

  implicitWidth: 48
  implicitHeight: 48

  onKindChanged: requestPaint()
  onNightChanged: requestPaint()
  onSunColorChanged: requestPaint()
  onCloudColorChanged: requestPaint()
  onAccentColorChanged: requestPaint()
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()

  onPaint: {
    const ctx = getContext("2d")
    ctx.reset()
    const s = Math.min(width, height) / 100
    if (s <= 0) return
    ctx.scale(s, s)
    ctx.lineCap = "round"

    function disc(x, y, r, col) {
      ctx.fillStyle = col
      ctx.beginPath()
      ctx.arc(x, y, r, 0, Math.PI * 2)
      ctx.fill()
    }
    function sun(cx, cy, r) {
      disc(cx, cy, r, cv.sunColor)
      ctx.strokeStyle = cv.sunColor
      ctx.lineWidth = r * 0.3
      for (let i = 0; i < 8; i++) {
        const a = i * Math.PI / 4
        ctx.beginPath()
        ctx.moveTo(cx + Math.cos(a) * r * 1.45, cy + Math.sin(a) * r * 1.45)
        ctx.lineTo(cx + Math.cos(a) * r * 1.9, cy + Math.sin(a) * r * 1.9)
        ctx.stroke()
      }
    }
    function moon(cx, cy, r) {
      disc(cx, cy, r, cv.sunColor)
      ctx.globalCompositeOperation = "destination-out"
      disc(cx + r * 0.55, cy - r * 0.35, r * 0.85, "#000000")
      ctx.globalCompositeOperation = "source-over"
    }
    function cloud(ox, oy, k) {
      disc(ox + 26 * k, oy + 58 * k, 14 * k, cv.cloudColor)
      disc(ox + 46 * k, oy + 46 * k, 20 * k, cv.cloudColor)
      disc(ox + 68 * k, oy + 56 * k, 15 * k, cv.cloudColor)
      ctx.fillStyle = cv.cloudColor
      ctx.fillRect(ox + 26 * k, oy + 56 * k, 42 * k, 16 * k)
    }
    function drops() {
      ctx.strokeStyle = cv.accentColor
      ctx.lineWidth = 6
      const xs = [34, 52, 70]
      for (let i = 0; i < 3; i++) {
        ctx.beginPath()
        ctx.moveTo(xs[i] + 3, 80 + (i === 1 ? 4 : 0))
        ctx.lineTo(xs[i] - 3, 92 + (i === 1 ? 4 : 0))
        ctx.stroke()
      }
    }

    switch (cv.kind) {
    case "clear":
      if (cv.night) moon(50, 50, 28); else sun(50, 50, 19)
      break
    case "partly":
      if (cv.night) moon(36, 36, 17); else sun(36, 36, 13)
      cloud(14, 24, 0.9)
      break
    case "cloud":
      cloud(8, 14, 1.0)
      break
    case "rain":
      cloud(8, 4, 0.95)
      drops()
      break
    case "snow":
      cloud(8, 4, 0.95)
      disc(34, 86, 4.5, cv.accentColor)
      disc(52, 92, 4.5, cv.accentColor)
      disc(70, 86, 4.5, cv.accentColor)
      break
    case "storm":
      cloud(8, 0, 0.95)
      ctx.fillStyle = cv.accentColor
      ctx.beginPath()
      ctx.moveTo(54, 60); ctx.lineTo(38, 82); ctx.lineTo(49, 82)
      ctx.lineTo(44, 99); ctx.lineTo(66, 74); ctx.lineTo(54, 74)
      ctx.lineTo(61, 60); ctx.closePath()
      ctx.fill()
      break
    case "fog":
      cloud(8, -6, 0.9)
      ctx.strokeStyle = cv.accentColor
      ctx.lineWidth = 6
      for (let j = 0; j < 3; j++) {
        ctx.beginPath()
        ctx.moveTo(24 + (j % 2) * 6, 70 + j * 11)
        ctx.lineTo(76 - ((j + 1) % 2) * 6, 70 + j * 11)
        ctx.stroke()
      }
      break
    }
  }
}
