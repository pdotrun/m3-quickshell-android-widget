import QtQuick
import Quickshell
import Quickshell.Io

// Keyless weather via Open-Meteo (needs `curl`). One instance per widget.
//   geocode:  geocoding-api.open-meteo.com  -> latitude / longitude
//   forecast: api.open-meteo.com            -> current + next hours + today's range
Scope {
  id: root

  property string city: ""
  property string unit: "c"          // "c" | "f"
  property bool demo: false          // sample data for the widget picker

  property bool loading: false
  property bool valid: false
  property string error: ""
  property string place: ""
  property real temp: 0
  property real hi: 0
  property real lo: 0
  property int code: 0
  property bool isDay: true
  property var hourly: []

  property real lat: 0
  property real lon: 0
  property string geoCity: ""
  property string requested: ""

  readonly property string kind: iconKind(code)
  readonly property string summary: describe(code)

  function describe(c) {
    if (c === 0) return "Clear sky"
    if (c === 1) return "Mostly clear"
    if (c === 2) return "Partly cloudy"
    if (c === 3) return "Overcast"
    if (c === 45 || c === 48) return "Fog"
    if (c >= 51 && c <= 57) return "Drizzle"
    if (c === 66 || c === 67) return "Freezing rain"
    if (c >= 61 && c <= 65) return "Rain"
    if (c >= 71 && c <= 77) return "Snow"
    if (c >= 80 && c <= 82) return "Rain showers"
    if (c === 85 || c === 86) return "Snow showers"
    if (c >= 95) return "Thunderstorm"
    return "Cloudy"
  }

  function iconKind(c) {
    if (c === 0 || c === 1) return "clear"
    if (c === 2) return "partly"
    if (c === 3) return "cloud"
    if (c === 45 || c === 48) return "fog"
    if ((c >= 51 && c <= 67) || (c >= 80 && c <= 82)) return "rain"
    if ((c >= 71 && c <= 77) || c === 85 || c === 86) return "snow"
    if (c >= 95) return "storm"
    return "cloud"
  }

  function applyDemo() {
    place = "Preview"
    temp = 28; hi = 31; lo = 24; code = 2; isDay = true
    hourly = [
      { h: "2 PM", t: 30, k: "partly", night: false },
      { h: "3 PM", t: 31, k: "clear", night: false },
      { h: "4 PM", t: 29, k: "rain", night: false },
      { h: "5 PM", t: 27, k: "rain", night: false }
    ]
    valid = true
    loading = false
    error = ""
  }

  function fail(msg) {
    loading = false
    error = msg
  }

  function refresh() {
    if (demo) { applyDemo(); return }
    const c = city.trim()
    if (c === "") { valid = false; error = "Set a location"; return }
    if (geo.running || fc.running) return
    error = ""
    loading = true
    requested = c
    if (geoCity === c) {
      fetchForecast()
    } else {
      geo.command = ["curl", "-fsS", "--max-time", "15",
        "https://geocoding-api.open-meteo.com/v1/search?count=1&language=en&format=json&name="
          + encodeURIComponent(c)]
      geo.running = true
    }
  }

  function fetchForecast() {
    const u = unit === "f" ? "fahrenheit" : "celsius"
    fc.command = ["curl", "-fsS", "--max-time", "15",
      "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon
        + "&current=temperature_2m,weather_code,is_day"
        + "&hourly=temperature_2m,weather_code"
        + "&daily=temperature_2m_max,temperature_2m_min"
        + "&timezone=auto&forecast_days=2&temperature_unit=" + u]
    fc.running = true
  }

  function onGeo(text) {
    if (requested !== city.trim()) { loading = false; retry.restart(); return }
    let d
    try { d = JSON.parse(text) } catch (e) { fail("Bad response"); return }
    if (!d.results || d.results.length === 0) { valid = false; fail("Location not found"); return }
    const r = d.results[0]
    lat = r.latitude
    lon = r.longitude
    place = r.name || requested
    geoCity = requested
    fetchForecast()
  }

  function onForecast(text) {
    let d
    try { d = JSON.parse(text) } catch (e) { fail("Bad response"); return }
    if (!d.current || !d.daily || !d.hourly) { fail("Bad response"); return }
    temp = d.current.temperature_2m
    code = d.current.weather_code
    isDay = d.current.is_day === 1
    hi = d.daily.temperature_2m_max[0]
    lo = d.daily.temperature_2m_min[0]

    const times = d.hourly.time
    const temps = d.hourly.temperature_2m
    const codes = d.hourly.weather_code
    const nowH = (d.current.time || "").slice(0, 13)
    let idx = times.findIndex(function (t) { return t.slice(0, 13) === nowH })
    if (idx < 0) idx = 0
    const out = []
    for (let i = idx + 1; i < Math.min(times.length, idx + 5); i++) {
      const h = parseInt(times[i].slice(11, 13))
      out.push({
        h: (h % 12 || 12) + (h < 12 ? " AM" : " PM"),
        t: Math.round(temps[i]),
        k: iconKind(codes[i]),
        night: h < 6 || h >= 19
      })
    }
    hourly = out
    valid = true
    loading = false
    error = ""
    if (requested !== city.trim()) retry.restart()
  }

  Process {
    id: geo
    stdout: StdioCollector { onStreamFinished: root.onGeo(this.text) }
    onExited: (exitCode, exitStatus) => { if (exitCode !== 0) root.fail("Offline") }
  }

  Process {
    id: fc
    stdout: StdioCollector { onStreamFinished: root.onForecast(this.text) }
    onExited: (exitCode, exitStatus) => { if (exitCode !== 0) root.fail("Offline") }
  }

  Timer {
    interval: 20 * 60 * 1000
    repeat: true
    running: !root.demo && root.city.trim() !== ""
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Timer { id: retry; interval: 500; onTriggered: root.refresh() }
  onCityChanged: if (!demo) retry.restart()
  onUnitChanged: if (!demo) retry.restart()
  onDemoChanged: if (demo) applyDemo()
  Component.onCompleted: if (demo) applyDemo()
}
