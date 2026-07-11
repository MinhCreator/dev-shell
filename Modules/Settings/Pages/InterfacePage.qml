import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services
import qs.Widgets

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services
import qs.Widgets

ColumnLayout {
    property var context
    property var colors: context.colors

    spacing: 16

    SectionHeader {
       title: "Interface" 
       fontSize: Config.fontFamily * 2
       showDivider: false
    }

    // Color Preview Card
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 200
        radius: 16
        color: colors.surface
        border.width: 1
        border.color: colors.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "Color Theme Preview"
                font.pixelSize: 14
                font.bold: true
                color: colors.fg
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Color swatches
                Repeater {
                    model: [
                        { name: "Accent", color: colors.accent },
                        { name: "Background", color: colors.bg },
                        { name: "Foreground", color: colors.fg },
                        { name: "Surface", color: colors.surface },
                        { name: "Muted", color: colors.muted }
                    ]

                    Rectangle {
                        Layout.preferredWidth: Config.fontSize * 8.7
                        Layout.preferredHeight: Config.fontSize * 6
                        radius: 8
                        color: modelData.color
                        border.width: 1
                        border.color: Qt.rgba(colors.border.r, colors.border.g, colors.border.b, 0.5)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Item { Layout.fillHeight: true }

                            Text {
                                text: modelData.name
                                font.pixelSize: Config.fontSize * 0.85
                                color: modelData.name === "Foreground" ? colors.bg : colors.secondary
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }

            // Font Preview
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: 8
                color: Qt.rgba(colors.bg.r, colors.bg.g, colors.bg.b, 0.5)

                Text {
                    anchors.centerIn: parent
                    text: "The quick brown fox jumps over the lazy dog"
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize
                    color: colors.fg
                }
            }
        }
    }

    // Bar Preview
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        radius: 12
        color: colors.surface
        border.width: 1
        border.color: colors.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                text: "Bar Preview"
                font.pixelSize: 14
                font.bold: true
                color: colors.fg
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                radius: 6
                color: Qt.rgba(colors.bg.r, colors.bg.g, colors.bg.b, Config.barOpacity)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 12

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 4
                        color: colors.accent
                    }

                    Text {
                        text: "10:30"
                        font.pixelSize: 12
                        color: colors.fg
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: colors.accent
                    }

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: colors.muted
                    }
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 16
    }

    Text {
        text: "Corner"
        font.family: Config.fontFamily
        font.pixelSize: 18
        font.bold: true
        color: colors.fg
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Toggle corner"
        sublabel: ""
        icon: "󰘇"
        active: Config.corner
        colors: context.colors
        onActiveChanged: {
            if ( Config.corner !== active)
                Config.corner = active;

        }
    }

    Item { Layout.fillHeight: true }
}