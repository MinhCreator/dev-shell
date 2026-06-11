import QtQuick
import qs.Core
import qs.Services
import qs.Services.Compositor

Item {
    id: root

    property var config: Config
    property alias colors: colorsService
    property var cpu: CpuService
    property var os: OsService
    property var mem: MemService
    property var disk: DiskService
    property var time: TimeService
    property var timezone: TimeZone
    property var volume: VolumeService
    property alias activeWindow: compositorService
    property alias layout: compositorService
    property alias appState: appStateService
    property var network: NetworkService
    property var bluetooth: BluetoothService

    Colors {
        id: colorsService
    }

    Compositor {
        id: compositorService
    }

    GlobalState {
        id: appStateService
    }
}
