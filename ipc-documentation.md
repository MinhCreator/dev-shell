# IPC (Inter-Process Communication) Documentation

## Overview

QuickShell IPC enables external programs to call functions inside a running shell instance. Each IPC handler registers a **target name** and exposes **callable functions**. Communication happens over Unix socket, no process spawn needed.

---

## Architecture

```
CLI Command                         QuickShell Process
─────────────                       ──────────────────
qs -c dev-shell ipc call X foo  →   Unix socket → IpcHandler target="X" → foo() executed
```

- `-c dev-shell` matches shell config directory name
- `qs` connects to running instance via socket
- Target name lookup → function dispatch
- Arguments passed as strings, converted to QML types

---

## CLI Reference

### Basic Syntax

```bash
qs -c <configName> ipc call <target> <function> [args...]
```

### List All Targets

```bash
qs -c dev-shell ipc list
```

### Call Function

```bash
qs -c dev-shell ipc call <target> <function>
qs -c dev-shell ipc call <target> <function> "arg1" "arg2"
```

### Config Name (`-c`)

The `-c` flag matches directory name under `~/.config/quickshell/`:

```
~/.config/quickshell/
├── dev-shell/        ← qs -c dev-shell
├── DMS-shell/        ← qs -c DMS-shell
└── my-other-config/  ← qs -c my-other-config
```

Multiple shell instances can run simultaneously. Each has own IPC socket. `-c` selects target instance.

---

## Registering IPC Handler

### Prerequisites

```qml
import Quickshell.Io
```

Required in any file using `IpcHandler`.

### Minimal Example

```qml
IpcHandler {
    function toggle() {
        console.log("toggled!");
    }

    target: "myTarget"
}
```

CLI: `qs -c dev-shell ipc call myTarget toggle`

### Step-by-Step

1. Open target QML file (see Placement below)
2. Add `import Quickshell.Io` if missing
3. Add `IpcHandler { }` block
4. Set `target: "uniqueName"` (lowercase, no spaces)
5. Define public functions inside block
6. Call from CLI

---

## Function Patterns

### No Arguments

```qml
IpcHandler {
    function toggle() {
        globalState.togglePowerMenu();
    }

    target: "powermenu"
}
```

```bash
qs -c dev-shell ipc call powermenu toggle
```

### With Parameters

```qml
IpcHandler {
    function set(path: string) {
        WallpaperService.changeWallpaper(path, undefined);
    }

    target: "wallpaper"
}
```

```bash
qs -c dev-shell ipc call wallpaper set "/path/to/image.png"
```

### Multiple Parameters

```qml
IpcHandler {
    function set(name: string, value: int) {
        Config.setValue(name, value);
    }

    target: "config"
}
```

```bash
qs -c dev-shell ipc call config set "theme" 2
```

### Multiple Functions Per Target

```qml
IpcHandler {
    function open() {
        sidePanel.show();
    }

    function close() {
        sidePanel.hide();
    }

    function toggle() {
        if (sidePanel.anyOpen)
            sidePanel.hide();
        else
            sidePanel.show();
    }

    target: "sidePanel"
}
```

```bash
qs -c dev-shell ipc call sidePanel open
qs -c dev-shell ipc call sidePanel close
qs -c dev-shell ipc call sidePanel toggle
```

### With Return via Signals

IPC calls are fire-and-forget from CLI side. Use QML signals for async results:

```qml
IpcHandler {
    signal resultReady(string data)

    function getData() {
        var result = fetchFromService();
        resultReady(result);
    }

    target: "dataService"
}
```

---

## Type Support

CLI arguments arrive as strings. QML auto-converts:

| QML Type | CLI Input | Example |
|----------|-----------|---------|
| `string` | quoted string | `"hello"` |
| `int` | integer | `42` |
| `real` | float | `3.14` |
| `bool` | `true`/`false` | `true` |
| `var` | JSON string | `"{\"key\":\"value\"}"` |

**Note:** Complex types (arrays, objects) — pass as JSON string, parse in handler:

```qml
IpcHandler {
    function configure(json: string) {
        var data = JSON.parse(json);
        // use data.key
    }

    target: "settings"
}
```

```bash
qs -c dev-shell ipc call settings configure '{"theme":"dark","accent":"blue"}'
```

---

## Placement Rules

### Where to Put IpcHandler

Any QML file **instantiated in shell tree**. Most common:

| Location | Use Case |
|----------|----------|
| `Modules/Overlays/Overlays.qml` | Panel toggles, launcher, clipboard, wallpaper |
| `Modules/Lock/Lock.qml` | Lock screen |
| Any `Services/*.qml` | Service-specific IPC (rare) |
| Any `Modules/**/*.qml` | Module-specific control |

### Instantiation Check

File must be part of `shell.qml` tree:

```
shell.qml → Overlays.qml → IpcHandler targets work
                           ↓
                     instantiated in ShellRoot
```

If component is lazy-loaded (`Loader.active: false`), IpcHandler not registered until active.

---

## All Registered Targets

| Target | File | Functions | CLI Example |
|--------|------|-----------|-------------|
| `launcher` | Overlays.qml:73 | `toggle` | `qs -c dev-shell ipc call launcher toggle` |
| `clipboard` | Overlays.qml:81 | `toggle` | `qs -c dev-shell ipc call clipboard toggle` |
| `sidePanel` | Overlays.qml:89 | `open`, `close`, `toggle` | `qs -c dev-shell ipc call sidePanel open` |
| `wallpaperpanel` | Overlays.qml:108 | `toggle` | `qs -c dev-shell ipc call wallpaperpanel toggle` |
| `powermenu` | Overlays.qml:116 | `toggle` | `qs -c dev-shell ipc call powermenu toggle` |
| `infopanel` | Overlays.qml:124 | `toggle` | `qs -c dev-shell ipc call infopanel toggle` |
| `settings` | Overlays.qml:132 | `toggle` | `qs -c dev-shell ipc call settings toggle` |
| `cliphistService` | Overlays.qml:140 | `update` | `qs -c dev-shell ipc call cliphistService update` |
| `wallpaper` | Overlays.qml:148 | `set(path: string)` | `qs -c dev-shell ipc call wallpaper set /path` |
| `lock` | Lock.qml:35 | `lock` | `qs -c dev-shell ipc call lock lock` |

---

## Integration Examples

### Hyprland Keybindings

```ini
# ~/.config/hypr/hyprland.conf

bind = SUPER, D, exec, qs -c dev-shell ipc call launcher toggle
bind = SUPER, P, exec, qs -c dev-shell ipc call powermenu toggle
bind = SUPER, L, exec, qs -c dev-shell ipc call lock lock
bind = SUPER, V, exec, qs -c dev-shell ipc call clipboard toggle
bind = SUPER, N, exec, qs -c dev-shell ipc call sidePanel toggle
bind = SUPER, I, exec, qs -c dev-shell ipc call infopanel toggle
bind = , Print, exec, qs -c dev-shell ipc call settings toggle
```

### Bash Scripts

```bash
#!/bin/bash
# wallpaper-switch.sh

WALLPAPER="$1"
if [ -z "$WALLPAPER" ]; then
    echo "Usage: $0 <path>"
    exit 1
fi

qs -c dev-shell ipc call wallpaper set "$WALLPAPER"
```

### Cron Jobs

```bash
# Rotate wallpaper every hour
0 * * * * qs -c dev-shell ipc call wallpaper set "$(find ~/Wallpapers -type f | shuf -n 1)"
```

### From QML Process

```qml
Process {
    id: lockTrigger

    command: ["qs", "-c", "dev-shell", "ipc", "call", "lock", "lock"]
    running: false
}

// elsewhere:
// lockTrigger.running = true
```

### Python Script

```python
import subprocess

def toggle_launcher():
    subprocess.run([
        "qs", "-c", "dev-shell", "ipc", "call", "launcher", "toggle"
    ])

def set_wallpaper(path):
    subprocess.run([
        "qs", "-c", "dev-shell", "ipc", "call", "wallpaper", "set", path
    ])
```

---

## Error Handling

### Common Errors

**Target not found:**
```
qs -c dev-shell ipc call nonexistent toggle
# Error: No IPC handler with target "nonexistent"
```

**Function not found:**
```
qs -c dev-shell ipc call launcher nonexistent
# Error: No function "nonexistent" in target "launcher"
```

**Wrong argument count:**
```
qs -c dev-shell ipc call wallpaper set
# Error: Expected 1 argument, got 0
```

**Shell not running:**
```
qs -c dev-shell ipc call launcher toggle
# Error: Could not connect to shell instance
```

### In-Shell Error Handling

QML side catches errors via `Connections`:

```qml
Connections {
    target: Ipc

    function onColorGenFinished(code) {
        if (code === 0) {
            Logger.d("Wallpaper", "Color generation finished successfully");
        } else {
            Logger.e("Wallpaper", "Color generation failed with code:", code);
        }
    }
}
```

---

## Common Patterns

### State Toggle via GlobalState

Most panels use `GlobalState` booleans:

```qml
// GlobalState.qml
property bool launcherOpen: false
property bool powerMenuOpen: false
property bool settingsOpen: false

function toggleLauncher() { launcherOpen = !launcherOpen; }
function togglePowerMenu() { powerMenuOpen = !powerMenuOpen; }
function toggleSettings() { settingsOpen = !settingsOpen; }
```

```qml
// Overlays.qml
IpcHandler {
    function toggle() {
        root.context.appState.toggleLauncher();
    }
    target: "launcher"
}
```

### Direct Panel Control

```qml
IpcHandler {
    function open() { sidePanel.show(); }
    function close() { sidePanel.hide(); }
    function toggle() {
        if (sidePanel.anyOpen) sidePanel.hide();
        else sidePanel.show();
    }
    target: "sidePanel"
}
```

### Service Method Call

```qml
IpcHandler {
    function set(path: string) {
        WallpaperService.changeWallpaper(path, undefined);
    }
    target: "wallpaper"
}
```

---

## Debugging

### List Active Targets

```bash
qs -c dev-shell ipc list
```

### Test Call

```bash
qs -c dev-shell ipc call <target> <function>
```

### Shell Logs

```bash
# systemd user service
journalctl --user -u quickshell --no-pager -n 100

# or direct quickshell logs
qs -c dev-shell log
```

### QML Console Output

Handlers can log calls:

```qml
IpcHandler {
    function toggle() {
        console.log("IPC: launcher toggle called");
        root.context.appState.toggleLauncher();
    }
    target: "launcher"
}
```

### Verify IPC Handler Registration

Add temporary log in handler:

```qml
IpcHandler {
    Component.onCompleted: console.log("IPC registered: myTarget")
    function doThing() { /* ... */ }
    target: "myTarget"
}
```

---

## Pitfalls

### 1. Duplicate Target Names

Two `IpcHandler` with same `target` string = conflict. Last loaded wins.

**Fix:** Unique target names across entire shell tree.

### 2. Target Not Reachable

`IpcHandler` in lazy-loaded component (`Loader.active: false`) not registered until active.

**Fix:** Move IPC handler to always-loaded parent, or ensure component loads on startup.

### 3. Argument Quoting

Shell splits arguments on spaces. Quote paths:

```bash
# Wrong
qs -c dev-shell ipc call wallpaper set /path with spaces

# Correct
qs -c dev-shell ipc call wallpaper set "/path with spaces"
```

### 4. Case Sensitivity

Target names are case-sensitive: `PowerMenu` ≠ `powermenu`.

### 5. Config Name Mismatch

`-c` must match directory name exactly:

```bash
ls ~/.config/quickshell/
# dev-shell/  ← use -c dev-shell
# DMS-shell/  ← use -c DMS-shell
```

---

## Security Considerations

- IPC calls execute functions with shell process permissions
- No authentication between CLI and shell instance
- Anyone with access to socket can call any registered function
- Sensitive operations (shutdown, lock) exposed via IPC
- Consider socket permissions in shared environments

---

## Creating New IPC Target (Full Template)

```qml
import QtQuick
import Quickshell.Io

Item {
    // Your component logic here

    IpcHandler {
        function toggle() {
            // your logic
        }

        function doSomething(param: string) {
            // handle param
        }

        function getValue(): string {
            return "result";
        }

        target: "myNewTarget"
    }
}
```

**CLI usage:**
```bash
qs -c dev-shell ipc call myNewTarget toggle
qs -c dev-shell ipc call myNewTarget doSomething "test"
qs -c dev-shell ipc call myNewTarget getValue
```
