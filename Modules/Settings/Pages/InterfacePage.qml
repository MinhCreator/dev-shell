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