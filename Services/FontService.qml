import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
pragma Singleton

Singleton {
    id: root

    property var fontList: []
    property string currentFont: Config.fontFamily
    property bool isLoading: true

    function setFont(f) {
        if (f && f !== currentFont) {
            root.currentFont = f;
            Config.fontFamily = f;
        }
    }

    function refresh() {
        listFontProc.running = true;
    }

    Process {
        id: listFontProc
        property string output: ""
        command: ["sh", "-c", "fc-list : family | sort -u"]
        Component.onCompleted: running = true
        onExited: (code) => {
            if (code === 0 && output.length > 0) {
                var fonts = output.trim().split("\n").filter((z) => {
                    return z.length > 0;
                });
                root.fontList = fonts;
                root.isLoading = false;
            }
        }
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (line && line.trim())
                    listFontProc.output += line + "\n";
            }
        }
    }

    Connections {
        target: Config
        function onFontFamilyChanged() {
            root.currentFont = Config.fontFamily;
        }
    }
}