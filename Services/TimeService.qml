import QtQuick
import Quickshell
import qs.Core
pragma Singleton

Singleton {
    property string currentTime: Qt.formatDateTime(new Date(), Config.use24HourFormat ? "ddd, MMM dd - HH:mm" : Config.clockFormat)

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: currentTime = Qt.formatDateTime(new Date(), Config.use24HourFormat ? "ddd, MMM dd - HH:mm" : Config.clockFormat)
    }

}
