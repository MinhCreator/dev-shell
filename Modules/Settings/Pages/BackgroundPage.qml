import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs.Core
import qs.Services
import qs.Widgets

ColumnLayout {
    property var context
    property var colors: context.colors

    spacing: 16

    SectionHeader {
       title: "Background" 
       fontSize: Config.fontFamily * 2
       showDivider: false
    }

    // Current Wallpaper Preview - Scalable and Flexible
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 200 // Ensure it doesn't get too small

        Rectangle {
            id: imageCard
            anchors.fill: parent
            radius: 16
            color: colors.surface
            border.width: 1
            border.color: colors.border
            
            // ClippingRectangle handles the rounded corners

            ClippingRectangle {
                anchors.fill: parent
                radius: 16

                Image {
                    id: currentWallpaperImg
                    anchors.fill: parent
                    source: "file://" + WallpaperService.getWallpaper(Quickshell.screens[0]?.name || "")
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 1920 
                    sourceSize.height: 1080
                    asynchronous: true
                    cache: false 

                    // Reload when wallpaper changes
                    Connections {
                        target: WallpaperService
                        function onWallpaperChanged() {
                            currentWallpaperImg.source = "file://" + WallpaperService.getWallpaper(Quickshell.screens[0]?.name || "")
                        }
                    }
                }
                
                OpacityMask {
                    anchors.fill: parent
                    source: currentWallpaperImg
                    maskSource: Rectangle {
                        width: imageCard.width
                        height: imageCard.height
                        radius: 16
                    }
                }
            }
        }
        
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 24
            horizontalOffset: 0
            verticalOffset: 4
            color: Qt.rgba(0,0,0,0.2)
        }
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

    // Setting Items
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 16
        Layout.topMargin: 8

        SettingItem {
            label: "Wallpaper Directory"
            sublabel: "Path to wallpaper folder"
            icon: "󰸉"
            colors: context.colors

            TextField {
                Layout.preferredWidth: 350
                Layout.fillWidth: true
                text: Config.wallpaperDirectory
                font.pixelSize: 13
                color: colors.fg
                horizontalAlignment: TextInput.AlignLeft
                leftPadding: 12
                rightPadding: 12
                
                background: Rectangle {
                    color: parent.activeFocus ? colors.surface : colors.tile
                    radius: 8
                    border.width: 1
                    border.color: parent.activeFocus ? colors.accent : colors.border
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
                
                onEditingFinished: {
                    if (text !== "")
                        Config.wallpaperDirectory = text;
                }
            }
        }

        SettingItem {
            label: "Wallpaper Panel"
            sublabel: "Browse and select wallpapers"
            icon: "󰋩"
            colors: context.colors

            Button {
                id: panelBtn
                Layout.preferredWidth: 160
                Layout.preferredHeight: 36
                
                background: Rectangle {
                    radius: 8
                    color: panelBtn.down ? Qt.darker(colors.accent, 1.1) : 
                           panelBtn.hovered ? Qt.lighter(colors.accent, 1.1) : 
                           colors.accent
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                contentItem: Text {
                    text: "Select Wallpaper"
                    font.family: Config.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                    color: colors.bg
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: context.appState.toggleWallPicker()
            }
        }
    }
}