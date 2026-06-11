import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    property string version: "Linux"

    Process {
        id: kernelProc

        command: ["uname", "-r"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    version = data.trim();

            }
        }

    }

}
