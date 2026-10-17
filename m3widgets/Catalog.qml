pragma Singleton
import QtQuick
import Quickshell

Singleton {
  id: root

  readonly property var order: [
    "glance", "clockDigital", "clockAnalog", "weather",
    "calendar", "battery", "media", "search"
  ]

  readonly property var weatherFields: [
    { key: "city", label: "Location", type: "text", hint: "City name, e.g. Kuala Lumpur" },
    { key: "unit", label: "Temperature unit", type: "choice",
      options: [ { v: "c", l: "°C" }, { v: "f", l: "°F" } ] }
  ]

  readonly property var kinds: ({
    glance: {
      name: "At a Glance",
      desc: "Date and weather",
      file: "WGlance.qml",
      sizes: [ { id: "3x1", label: "3 × 1", cw: 3, ch: 1 }, { id: "4x1", label: "4 × 1", cw: 4, ch: 1 } ],
      defaults: { style: "none", city: "Petaling Jaya", unit: "c" },
      fields: [
        { key: "style", label: "Background", type: "choice",
          options: [ { v: "none", l: "None" }, { v: "card", l: "Card" } ] },
        { key: "city", label: "Location", type: "text", hint: "City name, e.g. Kuala Lumpur" },
        { key: "unit", label: "Temperature unit", type: "choice",
          options: [ { v: "c", l: "°C" }, { v: "f", l: "°F" } ] }
      ]
    },
    clockDigital: {
      name: "Clock",
      desc: "Digital clock",
      file: "WClockDigital.qml",
      sizes: [ { id: "2x2", label: "2 × 2", cw: 2, ch: 2 }, { id: "4x2", label: "4 × 2", cw: 4, ch: 2 } ],
      defaults: { use24h: false, showDate: true },
      fields: [
        { key: "use24h", label: "24-hour time", type: "bool" },
        { key: "showDate", label: "Show date (wide size)", type: "bool" }
      ]
    },
    clockAnalog: {
      name: "Analog clock",
      desc: "Scalloped analog clock",
      file: "WClockAnalog.qml",
      sizes: [ { id: "2x2", label: "2 × 2", cw: 2, ch: 2 }, { id: "3x3", label: "3 × 3", cw: 3, ch: 3 } ],
      defaults: { seconds: true },
      fields: [ { key: "seconds", label: "Second hand", type: "bool" } ]
    },
    weather: {
      name: "Weather",
      desc: "Current conditions and forecast",
      file: "WWeather.qml",
      sizes: [ { id: "2x2", label: "2 × 2", cw: 2, ch: 2 }, { id: "4x2", label: "4 × 2", cw: 4, ch: 2 } ],
      defaults: { city: "Petaling Jaya", unit: "c" },
      fields: weatherFields
    },
    calendar: {
      name: "Calendar",
      desc: "Date tile or month view",
      file: "WCalendar.qml",
      sizes: [ { id: "2x2", label: "2 × 2", cw: 2, ch: 2 }, { id: "4x4", label: "4 × 4", cw: 4, ch: 4 } ],
      defaults: { weekStart: "sun" },
      fields: [
        { key: "weekStart", label: "Week starts on", type: "choice",
          options: [ { v: "sun", l: "Sunday" }, { v: "mon", l: "Monday" } ] }
      ]
    },
    battery: {
      name: "Battery",
      desc: "Charge level and time left",
      file: "WBattery.qml",
      sizes: [ { id: "2x2", label: "2 × 2", cw: 2, ch: 2 }, { id: "4x1", label: "4 × 1", cw: 4, ch: 1 } ],
      defaults: { showTime: true },
      fields: [ { key: "showTime", label: "Show time remaining", type: "bool" } ]
    },
    media: {
      name: "Media player",
      desc: "Now playing with controls",
      file: "WMedia.qml",
      sizes: [ { id: "4x2", label: "4 × 2", cw: 4, ch: 2 }, { id: "4x1", label: "4 × 1", cw: 4, ch: 1 } ],
      defaults: {},
      fields: []
    },
    search: {
      name: "Search bar",
      desc: "Runs a command when clicked",
      file: "WSearch.qml",
      sizes: [
        { id: "2x1", label: "2 × 1", cw: 2, ch: 1 },
        { id: "3x1", label: "3 × 1", cw: 3, ch: 1 },
        { id: "4x1", label: "4 × 1", cw: 4, ch: 1 }
      ],
      defaults: { label: "Search", command: "xdg-open https://www.google.com" },
      fields: [
        { key: "label", label: "Label", type: "text", hint: "Search" },
        { key: "command", label: "Command to run on click", type: "text", hint: "e.g. fuzzel, rofi -show drun" }
      ]
    }
  })

  function sizeOf(kind, sizeId) {
    const k = kinds[kind]
    if (!k) return null
    for (let i = 0; i < k.sizes.length; i++)
      if (k.sizes[i].id === sizeId) return k.sizes[i]
    return null
  }

  function defaultSize(kind) { return kinds[kind].sizes[0].id }

  function dims(kind, sizeId) {
    const k = kinds[kind]
    if (!k) return { w: Store.px(2), h: Store.px(2), cw: 2, ch: 2 }
    const s = sizeOf(kind, sizeId) || k.sizes[0]
    return { w: Store.px(s.cw), h: Store.px(s.ch), cw: s.cw, ch: s.ch }
  }

  function defaults(kind) { return Object.assign({}, kinds[kind].defaults) }
}
