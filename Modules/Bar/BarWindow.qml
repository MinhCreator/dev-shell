import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Core
import qs.Modules.Bar

Variants {
    id: root

    required property Context context

    model: Quickshell.screens

    PanelWindow {
        property var modelData
        property string position: root.context.config.barPosition || "top"

        screen: modelData
        visible: root.context.colors.isLoaded
        exclusionMode: root.context.config.hideBar ? ExclusionMode.Ignore : ExclusionMode.Auto
        implicitHeight: {
            switch (root.context.config.barSize) {
            case "compact":
                return 35;
            case "expanded":
                return 50;
            default:
                return 40;
            }
        }
        color: "transparent"

        anchors {
            top: position === "top"
            bottom: position === "bottom"
            left: true
            right: true
        }

        margins {
            top: {
                if (position === "top") {
                    if (root.context.config.hideBar) return -implicitHeight - 10;
                    return root.context.config.floatingBar ? 5 : 0;
                }
                return 0;
            }
            bottom: {
                if (position === "bottom") {
                    if (root.context.config.hideBar) return -implicitHeight - 10;
                    return root.context.config.floatingBar ? 5 : 0;
                }
                return 0;
            }
            left: root.context.config.floatingBar ? 8 : 0
            right: root.context.config.floatingBar ? 8 : 0
        }

        Bar {
            floating: root.context.config.floatingBar
            colors: root.context.colors
            fontFamily: root.context.config.fontFamily
            fontSize: root.context.config.fontSize
            kernelVersion: root.context.os.version
            volumeLevel: root.context.volume.level
            time: root.context.time.currentTime
            volumeService: root.context.volume
            networkService: root.context.network
            globalState: root.context.appState
            compositor: root.context.activeWindow
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }

        }

        Behavior on margins.top {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        Behavior on margins.bottom {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

    }

}
