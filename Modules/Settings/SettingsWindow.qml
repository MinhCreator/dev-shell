import "./Pages" as Pages
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Effects
import QtQuick.Dialogs
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import qs.Core
import qs.Services
import qs.Widgets

FloatingWindow {
    id: root

    required property var context
    property var colors: context.colors
    property int windowWidth: 800
    property int windowHeight: 550
    property string activePage: "General"
    property bool sidebarCollapsed: false
    property string username: "user"
    property string searchText: ""
    property var menuItems: [
        { "label": "General",     "icon": "󰒓", "page": "General" },
        { "label": "Bar",         "icon": "󰛡", "page": "Bar" },
        { "label": "Background",  "icon": "󰸉", "page": "Background" },
        { "label": "Lock Screen", "icon": "󰌾", "page": "LockScreen" },
        { "label": "Interface",   "icon": "󰏇", "page": "Interface" },
        { "label": "Services",    "icon": "󰒋", "page": "Services" },
        { "label": "About",       "icon": "",   "page": "About", "imageSource": "../../Assets/logo.svg" },
        { "label": "Update",      "icon": "󰛡", "page": "Update" }
    ]
    readonly property var filteredMenuItems: {
        if (searchText === "") return menuItems;
        var lower = searchText.toLowerCase();
        return menuItems.filter(function(item) {
            return item.label.toLowerCase().indexOf(lower) !== -1;
        });
    }

    Process {
        id: whoamiProc
        command: ["whoami"]
        running: true
        stdout: SplitParser {
                onRead: (data) => {
                    if (data) root.username = data.trim();
                }
            }
    }

    FileDialog {
        id: avatarFileDialog
        title: "Choose Avatar Image"
        nameFilters: ["Images (*.png *.jpg *.jpeg *.svg *.webp)"]
        onAccepted: {
            var path = selectedFile.toString();
            if (path.startsWith("file://"))
                path = path.substring(7);
            Config.avatarPath = path;
        }
    }

    visible: context.appState.settingsOpen
    onVisibleChanged: {
        if (!visible)
            context.appState.settingsOpen = false;

    }
    implicitWidth: windowWidth
    implicitHeight: windowHeight
    minimumSize: Qt.size(800, 680)
    title: "Settings"
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: colors.bg
        radius: 16
        border.width: 0
        clip: true

        RowLayout {
            anchors.fill: parent
            spacing: 0

            

            Rectangle {
                Layout.preferredWidth: sidebarCollapsed ? 80 : 240
                Layout.fillHeight: true
                color: Qt.rgba(0, 0, 0, 0.3)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰅁"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 20
                            color: colors.muted
                            rotation: sidebarCollapsed ? -90 : 90

                            Behavior on rotation {
                                NumberAnimation {
                                    duration: 200
                                }

                            }

                        }

                        TapHandler {
                            onTapped: sidebarCollapsed = !sidebarCollapsed
                            cursorShape: Qt.PointingHandCursor
                        }

                    }

                    // ── Avatar section ──
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Item {
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 56

                            Rectangle {
                                anchors.fill: parent
                                radius: 28
                                color: Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.2)
                                visible: Config.avatarPath === "" || avatarImage.status !== Image.Ready

                                Text {
                                    anchors.centerIn: parent
                                    text: root.username.charAt(0).toUpperCase()
                                    font.pixelSize: 24
                                    font.bold: true
                                    font.family: Config.fontFamily
                                    color: colors.accent
                                }
                            }

                           

                                Image {
                                    id: avatarImage
                                    anchors.fill: parent
                                    source: Config.avatarPath !== "" ? (Config.avatarPath.startsWith("/") ? "file://" + Config.avatarPath : Config.avatarPath) : ""
                                    sourceSize: Qt.size(56, 56)
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    visible: status === Image.Ready
                                }
                            
                             OpacityMask {
                                anchors.fill: parent
                                source: avatarImage
                                visible: avatarImage.status === Image.Ready
                                maskSource: Rectangle {
                                    width: 56
                                    height: 56
                                    radius: 28
                                }
                            }

                            TapHandler {
                                onTapped: avatarFileDialog.open()
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            visible: !sidebarCollapsed

                            Text {
                                text: root.username
                                font.pixelSize: 14
                                font.bold: true
                                font.family: Config.fontFamily
                                color: colors.fg
                            }
                            Text {
                                text: "coding"
                                font.pixelSize: 12
                                font.family: Config.fontFamily
                                color: Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.5)
                            }
                        }
                    }

                    // ── Search bar ──
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 10
                        color: "transparent"
                        border.width: searchInput.activeFocus ? 2 : 1
                        border.color: searchInput.activeFocus ? colors.accent : Qt.rgba(colors.border.r, colors.border.g, colors.border.b, 0.3)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text {
                                text: ""
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                color: colors.muted
                            }

                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                placeholderText: "Search..."
                                font.family: Config.fontFamily
                                font.pixelSize: 13
                                color: colors.fg
                                background: Item {}
                                leftPadding: 0
                                rightPadding: 0
                                onTextChanged: root.searchText = text
                            }
                        }
                    }

                    // ── Config file button ──
                    // Rectangle {
                    //     Layout.fillWidth: true
                    //     Layout.preferredHeight: 48
                    //     radius: 24
                    //     color: colors.accent
                    //     visible: !sidebarCollapsed

                    //     RowLayout {
                    //         anchors.centerIn: parent
                    //         spacing: 12
                    //         Text {
                    //             text: "󰐏"
                    //             font.family: "Symbols Nerd Font"
                    //             font.pixelSize: 18
                    //             color: colors.bg
                    //         }
                    //         Text {
                    //             text: "Config file"
                    //             color: colors.bg
                    //             font.pixelSize: 14
                    //             font.bold: true
                    //         }
                    //     }
                    //     TapHandler {
                    //         onTapped: Qt.openUrlExternally("file://" + Config.configPath)
                    //         cursorShape: Qt.PointingHandCursor
                    //     }
                    // }

                    // ── Spacer ──
                    Item {
                        height: 8
                        width: 1
                    }

                    // ── Filtered menu items ──
                    Repeater {
                        model: root.filteredMenuItems

                        SidebarItem {
                            label: modelData.label
                            icon: modelData.icon || ""
                            imageSource: modelData.imageSource || ""
                            page: modelData.page
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    component SidebarItem: Rectangle {
                        property string label
                        property string icon
                        property string imageSource: ""
                        property string page
                        property bool isActive: root.activePage === page
                        property bool isVisible: true
                        property color inactiveColor: Qt.rgba(colors.fg.r, colors.fg.g, colors.fg.b, 0.5)

                        Layout.fillWidth: true
                        Layout.preferredHeight: isVisible ? 44 : 0
                        visible: isVisible
                        opacity: isVisible ? 1 : 0
                        radius: 12
                        color: isActive ? Qt.rgba(colors.surface.r, colors.surface.g, colors.surface.b, 0.8) : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: sidebarCollapsed ? 0 : 16
                            spacing: sidebarCollapsed ? 0 : 16

                            Text {
                                text: icon
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 18
                                color: isActive ? colors.accent : inactiveColor
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                Layout.fillWidth: sidebarCollapsed
                                horizontalAlignment: Text.AlignHCenter
                                visible: imageSource === ""
                            }

                            Image {
                                source: imageSource
                                sourceSize: Qt.size(20, 20)
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                Layout.fillWidth: sidebarCollapsed
                                horizontalAlignment: Image.AlignHCenter
                                visible: imageSource !== ""
                                smooth: true
                            }

                            Text {
                                text: label
                                color: isActive ? colors.fg : inactiveColor
                                font.pixelSize: 14
                                font.weight: isActive ? Font.Bold : Font.Normal
                                visible: !sidebarCollapsed
                                opacity: sidebarCollapsed ? 0 : 1
                            }

                            Item {
                                Layout.fillWidth: true
                                visible: !sidebarCollapsed
                            }

                        }

                        TapHandler {
                            onTapped: root.activePage = page
                            cursorShape: Qt.PointingHandCursor
                        }

                        HoverHandler {
                            id: hover

                            cursorShape: Qt.PointingHandCursor
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: colors.surface
                            opacity: hover.hovered && !isActive ? 0.3 : 0
                            radius: 12
                        }

                    }

                }

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }

                }

            }


            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    width: 32
                    height: 32
                    radius: 16
                    color: closeHover.containsMouse ? colors.surface : "transparent"
                    z: 100

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: colors.muted
                    }

                    TapHandler {
                        onTapped: context.appState.settingsOpen = false
                        cursorShape: Qt.PointingHandCursor
                    }

                    HoverHandler {
                        id: closeHover

                        cursorShape: Qt.PointingHandCursor
                    }

                }

                

                ScrollView {
                    anchors.fill: parent
                    anchors.topMargin: 20
                    clip: true
                    contentWidth: availableWidth

                    Loader {
                        anchors.fill: parent
                        anchors.margins: 32
                        source: {
                            switch (root.activePage) {
                            case "General":
                                return "Pages/GeneralPage.qml";
                            case "Bar":
                                return "Pages/BarPage.qml";
                            case "Background":
                                return "Pages/BackgroundPage.qml";
                            case "LockScreen":
                                return "Pages/LockScreenPage.qml";
                            case "Interface":
                                return "Pages/InterfacePage.qml";
                            case "Services":
                                return "Pages/ServicesPage.qml";
                            case "About":
                                return "Pages/AboutPage.qml";
                            case "Update":
                                return "Pages/UpdatePage.qml";
                            default:
                                return "Pages/GeneralPage.qml";
                            }
                        }
                        onLoaded: {
                            item.context = context;
                        }
                    }

                }

            }

        }

    }

}
