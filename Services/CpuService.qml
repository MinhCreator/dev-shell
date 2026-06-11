import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    property int usage: 0
    Behavior on usage { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
    property var lastIdle: 0
    property var lastTotal: 0

    Process {
        id: cpuProc

        command: ["sh", "-c", "head -1 /proc/stat"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split(/\s+/);
                var user = parseInt(parts[1]) || 0;
                var nice = parseInt(parts[2]) || 0;
                var system = parseInt(parts[3]) || 0;
                var idle = parseInt(parts[4]) || 0;
                var iowait = parseInt(parts[5]) || 0;
                var irq = parseInt(parts[6]) || 0;
                var softirq = parseInt(parts[7]) || 0;
                var total = user + nice + system + idle + iowait + irq + softirq;
                var idleTime = idle + iowait;
                if (lastTotal > 0) {
                    var totalDiff = total - lastTotal;
                    var idleDiff = idleTime - lastIdle;
                    if (totalDiff > 0)
                        usage = Math.round(100 * (totalDiff - idleDiff) / totalDiff);

                }
                lastTotal = total;
                lastIdle = idleTime;
            }
        }

    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: cpuProc.running = true
    }

}
