import QtQuick

// pushes `cfg`, `cw` and `ch` in.
Item {
  property var cfg: ({})
  property int cw: 2
  property int ch: 2
  property bool preview: false     

  function opt(key, def) {
    return (cfg && cfg[key] !== undefined) ? cfg[key] : def
  }
}
