// WallLibrary.qml
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
    id: lib

    property string dir: ""
    property string home: ""
    property string filter: ""
    property int focusIndex: 0

    readonly property var extensions: ["jpg", "jpeg", "png", "gif", "webp", "bmp",
                                       "tif", "tiff", "tga", "pnm", "ppm", "avif", "jxl"]

    property var all: []
    property var shown: []
    property bool scanning: true
    property string error: ""
    property int readyRev: 0
    property string currentPath: ""
    property int initialIndex: 0

    signal loaded()
    signal daemonMissing()

    property var dims: ({})
    property bool scanDone: false
    property bool queryDone: false
    property bool loadedEmitted: false
    property string queryText: ""
    property string baseDir: ""
    property string dimsPath: ""
    property bool dimsBroken: false

    function start() {
        baseDir = dir.replace(/\/+$/, "")
        const args = ["find", "-L", baseDir, "-type", "f", "("]
        for (let i = 0; i < extensions.length; ++i) {
            if (i > 0) args.push("-o")
            args.push("-iname", "*." + extensions[i])
        }
        args.push(")", "-printf", "%P\t%s\n")
        scanFiles.command = args
        scanFiles.running = true
        query.running = true
        queryGuard.start()
    }

    function fileUrl(p) {
        return "file://" + encodeURI(p).replace(/#/g, "%23").replace(/\?/g, "%3F")
    }
    function dimsFor(it) { const _ = readyRev; return it ? (dims[it.path] || null) : null }

    Process {
        id: scanFiles
        stdout: StdioCollector { id: filesOut; onStreamFinished: lib.build() }
        stderr: StdioCollector { id: filesErr }
    }

    function build() {
        const items = []
        const fl = filesOut.text.split("\n")
        for (let i = 0; i < fl.length; ++i) {
            const p = fl[i].split("\t")
            if (p.length < 2) continue
            const rel = p[0]
            const comps = rel.split("/")
            let hidden = false
            for (let c = 0; c < comps.length; ++c) if (comps[c].startsWith(".")) { hidden = true; break }
            if (hidden) continue
            items.push({
                path: baseDir + "/" + rel,
                rel: rel,
                name: comps[comps.length - 1],
                size: parseInt(p[1]),
                lower: rel.toLowerCase()
            })
        }
        items.sort((a, b) => a.lower < b.lower ? -1 : (a.lower > b.lower ? 1 : 0))
        all = items
        if (items.length === 0) {
            const e = filesErr.text.trim().split("\n")[0]
            error = "No images found in " + baseDir + (e !== "" ? "  \u2014  " + e : "")
        }
        applyFilter()
        scanning = false
        scanDone = true
        maybeLoaded()
    }

    Process {
        id: query
        command: ["awww", "query"]
        stdout: StdioCollector {
            id: queryOut
            onStreamFinished: {
                lib.queryText = queryOut.text
                lib.queryDone = true
                lib.maybeLoaded()
            }
        }
        onExited: (code, status) => { if (code !== 0) lib.daemonMissing() }
    }
    Timer {
        id: queryGuard
        interval: 1500
        onTriggered: { if (!lib.queryDone) { lib.queryDone = true; lib.maybeLoaded() } }
    }

    function findCurrent() {
        if (queryText === "") return -1
        let best = -1, idx = -1
        for (let i = 0; i < all.length; ++i) {
            const p = all[i].path
            let pos = queryText.indexOf(p)
            if (pos < 0 && home !== "" && p.indexOf(home + "/") === 0)
                pos = queryText.indexOf("~" + p.slice(home.length))
            if (pos >= 0 && (best < 0 || pos < best)) { best = pos; idx = i }
        }
        if (idx >= 0) return idx
        for (let i = 0; i < all.length; ++i) {
            const pos = queryText.indexOf("/" + all[i].name)
            if (pos >= 0 && (best < 0 || pos < best)) { best = pos; idx = i }
        }
        return idx
    }

    function maybeLoaded() {
        if (!scanDone || !queryDone || loadedEmitted) return
        loadedEmitted = true
        let idx = findCurrent()
        if (idx >= 0) currentPath = all[idx].path
        else idx = 0
        initialIndex = idx
        focusIndex = idx
        loaded()
        fetchDims()
    }

    function applyFilter() {
        const f = filter.trim().toLowerCase()
        if (f === "") { shown = all; return }
        const terms = f.split(/\s+/)
        shown = all.filter(it => terms.every(t => it.lower.indexOf(t) >= 0))
    }
    onFilterChanged: { applyFilter(); focusIndex = 0 }
    onFocusIndexChanged: fetchDims()

    Process {
        id: dimsProc
        stdout: StdioCollector {
            id: dimsOut
            onStreamFinished: {
                const m = /(\d+)\s+(\d+)/.exec(dimsOut.text)
                if (m && lib.dimsPath !== "") {
                    lib.dims[lib.dimsPath] = { w: parseInt(m[1]), h: parseInt(m[2]) }
                    lib.readyRev++
                }
                lib.dimsPath = ""
                lib.fetchDims()
            }
        }
        onExited: (code, status) => {
            if (code !== 0) { lib.dimsBroken = true; lib.dimsPath = "" }
        }
    }
    function fetchDims() {
        if (!loadedEmitted || dimsBroken || dimsPath !== "") return
        const it = shown[focusIndex]
        if (!it || dims[it.path]) return
        dimsPath = it.path
        dimsProc.command = ["identify", "-ping", "-format", "%w %h", it.path + "[0]"]
        dimsProc.running = true
    }
}
