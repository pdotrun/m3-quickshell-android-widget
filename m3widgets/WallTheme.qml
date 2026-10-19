// WallTheme.qml
// Created by ps2xxtd (ps2string)
// 2026-10-19 19:52:53
// Requires:
// Quickshell v0.3.x
// Qt 6.x.x
// License: GPLv3

import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: theme

    property string colorsPath: ""

    readonly property var fallback: ({
        primary: "#d0bcff",
        on_primary: "#381e72",
        primary_container: "#4f378b",
        on_primary_container: "#eaddff",
        secondary_container: "#4a4458",
        on_secondary_container: "#e8def8",
        tertiary_container: "#633b48",
        on_tertiary_container: "#ffd8e4",
        surface: "#141218",
        surface_container_low: "#1d1b20",
        surface_container: "#211f26",
        surface_container_high: "#2b2930",
        surface_container_highest: "#36343b",
        on_surface: "#e6e0e9",
        on_surface_variant: "#cac4d0",
        outline: "#938f99",
        outline_variant: "#49454f",
        error: "#f2b8b5"
    })

    FileView {
        id: file
        path: theme.colorsPath
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
    }

    function parse() {
        try { return JSON.parse(file.text()) } catch (e) { return ({}) }
    }
    readonly property var palette: parse()

    function pick(name) {
        const v = palette[name]
        return (typeof v === "string" && v.length > 0) ? v : fallback[name]
    }

    function rgb(hex) {
        const m = /^#?([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})/.exec(String(hex))
        return m ? [parseInt(m[1], 16) / 255, parseInt(m[2], 16) / 255, parseInt(m[3], 16) / 255] : null
    }
    function chan(v) { return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4) }
    function lum(c) { return 0.2126 * chan(c[0]) + 0.7152 * chan(c[1]) + 0.0722 * chan(c[2]) }
    function ratio(a, b) {
        const x = lum(a), y = lum(b)
        return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05)
    }
    function readable(fgName, bgNames) {
        const fgHex = pick(fgName)
        const fg = rgb(fgHex)
        const bgs = []
        for (let i = 0; i < bgNames.length; ++i) {
            const b = rgb(pick(bgNames[i]))
            if (b) bgs.push(b)
        }
        if (!fg || bgs.length === 0) return fgHex
        function worst(c) {
            let m = 99
            for (let i = 0; i < bgs.length; ++i) m = Math.min(m, ratio(c, bgs[i]))
            return m
        }
        if (worst(fg) >= 4.5) return fgHex
        const light = "#e6e0e9"
        const dark = "#1d1b20"
        return worst(rgb(light)) >= worst(rgb(dark)) ? light : dark
    }

    readonly property color primary: pick("primary")
    readonly property color m3onPrimary: readable("on_primary", ["primary"])
    readonly property color primaryContainer: pick("primary_container")
    readonly property color m3onPrimaryContainer: readable("on_primary_container", ["primary_container"])
    readonly property color secondaryContainer: pick("secondary_container")
    readonly property color m3onSecondaryContainer: readable("on_secondary_container", ["secondary_container"])
    readonly property color tertiaryContainer: pick("tertiary_container")
    readonly property color m3onTertiaryContainer: readable("on_tertiary_container", ["tertiary_container"])
    readonly property color surface: pick("surface")
    readonly property color surfaceContainerLow: pick("surface_container_low")
    readonly property color surfaceContainer: pick("surface_container")
    readonly property color surfaceContainerHigh: pick("surface_container_high")
    readonly property color surfaceContainerHighest: pick("surface_container_highest")
    readonly property color m3onSurface: readable("on_surface", ["surface_container", "surface_container_highest"])
    readonly property color m3onSurfaceVariant: readable("on_surface_variant", ["surface_container", "surface_container_highest"])
    readonly property color outline: pick("outline")
    readonly property color outlineVariant: pick("outline_variant")
    readonly property color error: pick("error")

    readonly property var families: {
        try { return Qt.fontFamilies() } catch (e) { return [] }
    }
    function firstAvailable(list, fallbackName) {
        for (let i = 0; i < list.length; ++i)
            if (families.indexOf(list[i]) >= 0) return list[i]
        return fallbackName
    }
    readonly property string fontFamily: firstAvailable(
        ["Google Sans Flex", "Google Sans", "Product Sans", "Roboto Flex", "Roboto", "Inter", "Noto Sans"],
        "sans-serif")
    readonly property string symbolsFamily: firstAvailable(
        ["Material Symbols Rounded", "Material Symbols Outlined", "Material Symbols Sharp"], "")
    readonly property bool hasSymbols: symbolsFamily !== ""
}
