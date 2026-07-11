import "../Components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

BentoCard {
    id: root

    required property var colors

    property string kernelVersion: "..."
    property string distroName: "Linux"
    property string hostname: "localhost"
    property string shellName: "sh"
    property string wmName: "Hyprland"
    property string uptime: "..."

    cardColor: colors.surface
    borderColor: colors.border

    Component.onCompleted: {
        kernelProc.running = true
        hostnameProc.running = true
        shellProc.running = true
        wmProc.running = true
        uptimeProc.running = true
    }

    Process {
        id: kernelProc
        command: ["uname", "-r"]
        stdout: SplitParser {
            onRead: (data) => root.kernelVersion = data.trim()
        }
    }

    Process {
        id: hostnameProc
        command: ["hostname"]
        stdout: SplitParser {
            onRead: (data) => root.hostname = data.trim()
        }
    }

    Process {
        id: shellProc
        command: ["sh", "-c", "echo $SHELL"]
        stdout: SplitParser {
            onRead: (data) => {
                var shell = data.trim().split("/").pop()
                root.shellName = shell
            }
        }
    }

    Process {
        id: wmProc
        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]
        stdout: SplitParser {
            onRead: (data) => {
                var wm = data.trim()
                if (wm) root.wmName = wm
            }
        }
    }

    Process {
        id: uptimeProc
        command: ["sh", "-c", "uptime -p"]
        stdout: SplitParser {
            onRead: (data) => root.uptime = data.trim().replace("up ", "")
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 24

        Text {
            text: "󰣇"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 100
            color: root.colors.accent
        }

        ColumnLayout {
            spacing: 5

            Text {
                text: Quickshell.env("USER") + "@" + root.hostname
                font.weight: Font.Bold
                font.pixelSize: 16
                color: root.colors.accent
                font.family: "JetBrainsMono Nerd Font"
                Layout.bottomMargin: 4
            }

            Rectangle {
                Layout.preferredWidth: 180
                Layout.preferredHeight: 2
                color: root.colors.subtext
                opacity: 0.4
                Layout.bottomMargin: 4
            }

            Repeater {
                model: [{
                    "label": "OS",
                    "value": root.distroName,
                    "icon": "",
                    "color": root.colors.blue
                }, {
                    "label": "Host",
                    "value": root.hostname,
                    "icon": "",
                    "color": root.colors.purple
                }, {
                    "label": "Kernel",
                    "value": root.kernelVersion,
                    "icon": "",
                    "color": root.colors.green
                }, {
                    "label": "Uptime",
                    "value": root.uptime,
                    "icon": "",
                    "color": root.colors.yellow
                }, {
                    "label": "Shell",
                    "value": root.shellName,
                    "icon": "",
                    "color": root.colors.orange
                }, {
                    "label": "WM",
                    "value": root.wmName,
                    "icon": "",
                    "color": root.colors.red
                }]

                RowLayout {
                    required property var modelData

                    spacing: 10

                    Text {
                        text: modelData.icon
                        color: modelData.color
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 13
                    }

                    Text {
                        text: modelData.label + ":"
                        color: modelData.color
                        font.weight: Font.Bold
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        text: modelData.value
                        color: root.colors.fg
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font"
                    }

                }

            }

            RowLayout {
                spacing: 5
                Layout.topMargin: 8

                Repeater {
                    model: [root.colors.red, root.colors.green, root.colors.yellow, root.colors.blue, root.colors.purple, root.colors.teal]

                    Rectangle {
                        required property color modelData

                        width: 22
                        height: 11
                        radius: 2
                        color: modelData
                    }

                }

            }

        }

    }

}
