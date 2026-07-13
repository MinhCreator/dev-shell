import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Core
import qs.Services

PanelWindow {
    id: root

    required property var globalState
    property bool internalOpen: false
        property int currentScreenIndex: 0
            property string searchText: ""
                property var filteredList: []
                property string selectedWallpaper: ""

                    IpcHandler {
                        function toggle()
                        {
                            globalState.toggleWallPicker()
                        }
                        target: "wallpicker"
                    }

                    function updateFilteredList()
                    {
                        if (Quickshell.screens[currentScreenIndex])
                        {
                            var screenName = Quickshell.screens[currentScreenIndex].name;
                            var list = WallpaperService.getWallpapersList(screenName);
                            if (searchText === "")
                            {
                                filteredList = list;
                            } else {
                            var lower = searchText.toLowerCase();
                            var filtered = [];
                            for (var i = 0; i < list.length; i++) {
                                var name = list[i].split("/").pop().toLowerCase();
                                if (name.indexOf(lower) !== -1)
                                    filtered.push(list[i]);
                            }
                            filteredList = filtered;
                        }
                    }
                }

                function updateCurrentWallpaper()
                {
                    if (Quickshell.screens[currentScreenIndex])
                    {
                        var screenName = Quickshell.screens[currentScreenIndex].name;
                        selectedWallpaper = WallpaperService.getWallpaper(screenName);
                    }
                }

                color: "transparent"
                visible: false
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
                WlrLayershell.namespace: "wall-picker"
                WlrLayershell.exclusiveZone: -1

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                
                Connections {
                    function onWallPickerOpenChanged()
                    {
                        if (globalState.wallPickerOpen)
                        {
                            closeTimer.stop();
                            root.visible = true;
                            openTimer.restart();
                            updateFilteredList();
                            updateCurrentWallpaper();
                        } else {
                        openTimer.stop();
                        internalOpen = false;
                        closeTimer.restart();
                    }
                }

                target: globalState
            }

            Connections {
                function onWallpaperChanged(screenName, path)
                {
                    if (Quickshell.screens[currentScreenIndex] && screenName === Quickshell.screens[currentScreenIndex].name)
                        updateCurrentWallpaper();
                }

                function onWallpaperListChanged(screenName, count)
                {
                    if (Quickshell.screens[currentScreenIndex] && screenName === Quickshell.screens[currentScreenIndex].name)
                        updateFilteredList();
                }

                target: WallpaperService
            }

            Timer {
                id: openTimer

                interval: 10
                onTriggered: root.internalOpen = true
            }

            Timer {
                id: closeTimer

                interval: 250
                onTriggered: root.visible = false
            }

            Colors {
                id: theme
            }

            MouseArea {
                anchors.fill: parent
                onClicked: globalState.wallPickerOpen = false
                z: -1
            }

            Item {
                id: slideContainer

                height: parent.height * 0.45
                width: parent.width * 0.45
                anchors.centerIn: parent

                Rectangle {
                    id: panelBg

                    anchors.fill: parent
                    color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.85)
                    radius: 20
                    border.color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0)
                    border.width: 1
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 20

                        Rectangle {
                            Layout.fillWidth: true
                            height: 48
                            color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.6)
                            radius: 12

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 10

                                Text {
                                    text: ""
                                    font.family: Config.fontFamily
                                    font.pixelSize: 16
                                    color: theme.subtext
                                }

                                TextField {
                                    id: searchField

                                    Layout.fillWidth: true
                                    placeholderText: "Search wallpapers..."
                                    placeholderTextColor: theme.subtext
                                    color: theme.fg
                                    background: null
                                    font.family: Config.fontFamily
                                    font.pixelSize: 14
                                    verticalAlignment: TextInput.AlignVCenter
                                    onTextChanged: {
                                        searchText = text;
                                        updateFilteredList();
                                    }
                                    Keys.onEscapePressed: globalState.wallPickerOpen = false
                                }
                            }
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded
                            ScrollBar.vertical.width: 6

                            GridView {
                                id: grid

                                property int columns: 4

                                    width: parent.width
                                    cellWidth: width / columns
                                    cellHeight: cellWidth * 0.75
                                    model: filteredList
                                    keyNavigationEnabled: true
                                    focus: true

                                    delegate: Item {
                                        id: delegateRoot

                                        required property string modelData
                                        required property int index
                                        property bool isSelected: modelData === selectedWallpaper
                                            property bool isHovered: cardMouse.containsMouse
                                                property string fileName: modelData.split("/").pop()

                                                width: grid.cellWidth
                                                height: grid.cellHeight

                                                Rectangle {
                                                    id: card

                                                    anchors.fill: parent
                                                    anchors.margins: 15
                                                    radius: 14
                                                    color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.4)
                                                    border.color: delegateRoot.isSelected ? Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.8) : delegateRoot.isHovered ? Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.3) : "transparent"
                                                    border.width: delegateRoot.isSelected ? 3 : 1

                                                    // ClippingWrapperRectangle {
                                                    ClippingRectangle {
                                                        anchors.fill: parent
                                                        anchors.margins: card.border.width
                                                        radius: 15
                                                        // bottomMargin: 10

                                                        Image {
                                                            id: thumb

                                                            readonly property string fileExt: delegateRoot.fileName.split(".").pop().toLowerCase()
                                                            readonly property bool hasThumb: ["jpg", "jpeg", "png", "webp", "bmp"].includes(fileExt)
                                                            readonly property string thumbPath: WallpaperService.previewDirectory + "/" + delegateRoot.fileName
                                                                readonly property string originalSource: "file://" + delegateRoot.modelData
                                                                    readonly property string thumbSource: hasThumb ? ("file://" + thumbPath) : originalSource

                                                                        anchors.fill: parent
                                                                        source: thumbSource
                                                                        sourceSize.width: 400
                                                                        sourceSize.height: 300
                                                                        fillMode: Image.PreserveAspectCrop
                                                                        asynchronous: true
                                                                        cache: true
                                                                        smooth: true
                                                                        opacity: status === Image.Ready ? 1 : 0

                                                                        onStatusChanged: {
                                                                            if (status === Image.Error && source !== originalSource)
                                                                                source = originalSource;
                                                                        }

                                                                        Behavior on opacity {
                                                                        NumberAnimation {
                                                                            duration: Animations.fast
                                                                        }
                                                                    }

                                                                    layer.enabled: true
                                                                    layer.effect: OpacityMask {
                                                                        maskSource: Rectangle {
                                                                            width: thumb.width
                                                                            height: thumb.height
                                                                            radius: 12
                                                                        }
                                                                    }
                                                                }
                                                            }

                                                            Rectangle {
                                                                anchors.fill: parent
                                                                radius: parent.radius
                                                                color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.3)
                                                                visible: thumb.status === Image.Loading
                                                                // anchors.margins: 100
                                                                Text {
                                                                    anchors.centerIn: parent
                                                                    text: " "
                                                                    font.family: Config.fontFamily
                                                                    font.pixelSize: 24
                                                                    color: theme.subtext
                                                                    opacity: 0.5

                                                                    SequentialAnimation on rotation {
                                                                    loops: Animation.Infinite
                                                                    running: thumb.status === Image.Loading

                                                                    NumberAnimation {
                                                                        from: 0
                                                                        to: 360
                                                                        duration: 1000
                                                                    }
                                                                }
                                                            }
                                                        }

                                                        MouseArea {
                                                            id: cardMouse

                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: {
                                                                grid.currentIndex = index;
                                                                WallpaperService.changeWallpaper(delegateRoot.modelData, undefined);
                                                            }
                                                        }

                                                        Behavior on border.color {
                                                        ColorAnimation {
                                                            duration: Animations.fast
                                                        }
                                                    }

                                                    Behavior on border.width {
                                                    NumberAnimation {
                                                        duration: Animations.fast
                                                    }
                                                }
                                            }

                                            Text {

                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                anchors.bottomMargin: -5
                                                width: parent.width - 20
                                                text: delegateRoot.fileName
                                                color: delegateRoot.isSelected ? theme.fg : theme.subtext
                                                font.family: Config.fontFamily
                                                font.pixelSize: 11
                                                elide: Text.ElideRight
                                                horizontalAlignment: Text.AlignHCenter

                                                Behavior on color {
                                                ColorAnimation {
                                                    duration: Animations.fast
                                                }
                                            }
                                        }
                                    }

                                    Keys.onReturnPressed: {
                                        if (currentItem && filteredList[currentIndex])
                                            WallpaperService.changeWallpaper(filteredList[currentIndex], undefined);
                                    }

                                    Keys.onEnterPressed: {
                                        if (currentItem && filteredList[currentIndex])
                                            WallpaperService.changeWallpaper(filteredList[currentIndex], undefined);
                                    }

                                    Keys.onEscapePressed: globalState.wallPickerOpen = false
                                    Keys.onUpPressed: currentIndex = (currentIndex - grid.columns + count) % count
                                    Keys.onDownPressed: currentIndex = (currentIndex + grid.columns) % count
                                    Keys.onLeftPressed: currentIndex = Math.max(0, currentIndex - 1)
                                    Keys.onRightPressed: currentIndex = Math.min(count - 1, currentIndex + 1)
                                }
                            }
                        }
                    }
                }
            }
