import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Modules.Clipboard
import qs.Modules.Launcher
import qs.Modules.Notifications
import qs.Modules.Panels
import qs.Modules.overview
import qs.Services
import Quickshell.Hyprland

Item {
    id: root

    required property Context context

    NotificationManager {
        id: notifManager

        globalState: root.context.appState
    }

    NotificationToast {
        id: toast

        manager: notifManager
        colors: root.context.colors
    }

    SidePanel {
        id: sidePanel

        globalState: root.context.appState
        notifManager: notifManager
        colors: root.context.colors
        volumeService: root.context.volume
        bluetoothService: root.context.bluetooth
    }

    WallpaperPanel {
        id: wallpaperPanel

        globalState: root.context.appState
    }

    PowerMenu {
        id: powerMenu

        isOpen: root.context.appState.powerMenuOpen
        globalState: root.context.appState
        colors: root.context.colors
    }

    InfoPanel {
        id: infoPanel

        globalState: root.context.appState
    }

    AppLauncher {
        id: launcher

        colors: root.context.colors
        globalState: root.context.appState
    }

    Clipboard {
        id: clipboard

        globalState: root.context.appState
        colors: root.context.colors
    }

    Connections {
        target: Quickshell

        function onReloadCompleted()
        {
            Quickshell.inhibitReloadPopup();
        }
    }

    Overview {
        id: overview
        globalStates: root.context.appState
    }

    IpcHandler {
        function toggle()
        {
            root.context.appState.toggleLauncher();
        }

        target: "launcher"
    }

    IpcHandler {
        function toggle()
        {
            root.context.appState.toggleClipboard();
        }

        target: "clipboard"
    }

    IpcHandler {
        function open()
        {
            sidePanel.show();
        }

        function close()
        {
            sidePanel.hide();
        }

        function toggle()
        {
            if (sidePanel.anyOpen)
                sidePanel.hide();
            else
                sidePanel.show();
            }

            target: "sidePanel"
        }

        IpcHandler {
            function toggle()
            {
                root.context.appState.toggleWallpaperPanel();
            }

            target: "wallpaperpanel"
        }

        IpcHandler {
            function toggle()
            {
                root.context.appState.togglePowerMenu();
            }

            target: "powermenu"
        }

        IpcHandler {
            function toggle()
            {
                root.context.appState.toggleInforPanel();
            }

            target: "inforpanel"
        }

        IpcHandler {
            function toggle()
            {
                root.context.appState.toggleSettings();
            }

            target: "settings"
        }

        IpcHandler {
            target: "overview"
            function toggle()
            {
                root.context.appState.toggleOverview()
            }

            function close()
            {
                root.context.appState.toggleOverviewClose()
            }
            function open()
            {
                root.context.appState.toggleOverviewOpen()
            }

        }

        IpcHandler {
            function update()
            {
                clipboard.refresh();
            }

            target: "cliphistService"
        }

        IpcHandler {
            function set(path: string)
            {
                WallpaperService.changeWallpaper(path, undefined);
            }

            target: "wallpaper"
        }

        
    }
