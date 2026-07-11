import Qt.labs.folderlistmodel
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Services
pragma Singleton

Singleton {
    id: root

    property string defaultDirectory: Config.wallpaperDirectory
    property var currentWallpapers: ({
    })
    property var wallpaperLists: ({
    })
    property int scanningCount: 0
    readonly property bool scanning: (scanningCount > 0)
    property bool isInitialized: false
    property string wallpaperCacheFile: Quickshell.env("HOME") + "/.cache/dev-shell/wallpapers.json"
    property string defaultWallpaper: ""
    property string previewDirectory: Quickshell.env("HOME") + "/.cache/dev-shell/wallpreviews_large"
    readonly property string systemDefaultWallpaper: Quickshell.shellDir + "/Assets/default_wallpaper.png"
    property var availableOpenRgbDevices: []

    signal wallpaperChanged(string screenName, string path)
    signal wallpaperListChanged(string screenName, int count)

    function refreshOpenRgbDevices() {
        Logger.d("Wallpaper", "Refreshing OpenRGB devices...");
        Ipc.listOpenRgbDevices();
    }

    function init() {
        Logger.i("Wallpaper", "Starting service");
        Ipc.createDirs();
        Qt.callLater(loadFromCache);
        Qt.callLater(loadFromCache);
        Qt.callLater(refreshWallpapersList);
        Qt.callLater(refreshOpenRgbDevices);
    }

    function loadFromCache() {
        wallpaperCacheView.path = wallpaperCacheFile;
    }

    function getWallpaper(screenName) {
        return currentWallpapers[screenName] || root.defaultWallpaper || root.systemDefaultWallpaper;
    }

    function changeWallpaper(path, screenName) {
        if (screenName !== undefined) {
            _setWallpaper(screenName, path);
        } else {
            for (var i = 0; i < Quickshell.screens.length; i++) {
                _setWallpaper(Quickshell.screens[i].name, path);
            }
        }
    }

    function _setWallpaper(screenName, path) {
        if (path === "" || path === undefined)
            return ;

        if (screenName === undefined) {
            Logger.w("Wallpaper", "No screen specified");
            return ;
        }
        var oldPath = currentWallpapers[screenName] || "";
        currentWallpapers[screenName] = path;
        saveTimer.restart();
        root.wallpaperChanged(screenName, path);
        Logger.d("Wallpaper", "Set wallpaper for", screenName, "to", path);
        Ipc.copyWallpaper(path, Quickshell.env("HOME") + "/.cache/dev-shell/current_wallpaper");
        generateColors(path);
    }
    function generateColors(path) {
        if (!path)
            return ;

         // Call matugen instead of ColorService
        matugenProc.command = ["matugen", "image", path]
        matugenProc.running = true;

        Logger.d("Wallpaper", "Generating colors via matugen:", path);
    }

    Process {
        id: matugenProc
        command: ["matugen", "image", ""]
        onRunningChanged: {
            if (!running) {
                Logger.d("Wallpaper", "matugen completed, colors.json updated");
            }
        }
    }

    function applyOpenRGB() {
        var selectedColor = ColorService.accentColor;
        if (selectedColor) {
            var hex = selectedColor.toString().replace("#", "");
            Logger.d("Wallpaper", "Applying OpenRGB color:", hex);
            var args = ["openrgb"];
            var devices = Config.openRgbDevices;
            if (devices && devices.length > 0) {
                for (var i = 0; i < devices.length; i++) {
                    args.push("--device");
                    args.push(devices[i].toString());
                    args.push("--color");
                    args.push(hex);
                }
                Logger.d("Wallpaper", "OpenRGB command:", args.join(" "));
                Ipc.runOpenRgb(args);
            } else {
                Logger.d("Wallpaper", "No OpenRGB devices selected, skipping sync");
            }
        } else {
            Logger.e("Wallpaper", "No accent color available");
        }
    }

    function getWallpapersList(screenName) {
        if (screenName !== undefined && wallpaperLists[screenName] !== undefined)
            return wallpaperLists[screenName];

        return [];
    }

    function refreshWallpapersList() {
        Logger.d("Wallpaper", "Refreshing wallpapers list");
        Ipc.generateThumbnails(Quickshell.shellDir + "/Scripts/generate_previews.py", root.defaultDirectory, root.previewDirectory);
        scanningCount = 0;
        for (var i = 0; i < wallpaperScanners.count; i++) {
            var scanner = wallpaperScanners.objectAt(i);
            if (scanner)
                (function(s) {
                var directory = root.defaultDirectory;
                s.currentDirectory = "/tmp";
                Qt.callLater(function() {
                    s.currentDirectory = directory;
                });
            })(scanner);

        }
    }

    Component.onCompleted: init()

    Connections {
        function onColorsExtracted() {
            Logger.d("Wallpaper", "Colors extracted successfully");
            Qt.callLater(applyOpenRGB);
        }

        function onThumbnailGenerationFinished(code) {
            if (code === 0)
                Logger.d("Wallpaper", "Thumbnails generated successfully");
            else
                Logger.e("Wallpaper", "Thumbnail generation failed:", code);
        }

        function onOpenRgbFinished(code) {
            if (code !== 0) {
                Logger.e("Wallpaper", "OpenRGB failed with code:", code);
                Logger.e("Wallpaper", "Try running manually: openrgb --list-devices");
            } else {
                Logger.d("Wallpaper", "OpenRGB updated successfully");
            }
        }

        function onWallpaperCopyFinished(code) {
            if (code === 0)
                Logger.d("Wallpaper", "Current wallpaper copied to cache");
            else
                Logger.e("Wallpaper", "Failed to copy wallpaper:", code);
        }

        function onOpenRgbDevicesListFetched(output) {
            Logger.d("Wallpaper", "Fetched OpenRGB devices list");
            var lines = output.split("\n");
            var devices = [];
            var currentDevice = null;
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (line === "")
                    continue;

                var match = line.match(/^(\d+):\s*(.*)$/);
                if (match) {
                    currentDevice = {
                        "id": parseInt(match[1]),
                        "name": match[2].trim()
                    };
                    devices.push(currentDevice);
                } else if (currentDevice && line.startsWith("Description:")) {
                    if (currentDevice.name === "") {
                        var desc = line.substring(12).trim();
                        if (desc !== "")
                            currentDevice.name = desc;

                    }
                }
            }
            if (devices.length > 0) {
                for (var k = 0; k < devices.length; k++) {
                    if (devices[k].name === "")
                        devices[k].name = "Device " + devices[k].id;

                }
            }
            root.availableOpenRgbDevices = devices;
            root.availableOpenRgbDevicesChanged();
            var validIndices = devices.map((d) => {
                return d.id;
            });
            var currentConfig = Config.openRgbDevices || [];
            var newConfig = currentConfig.filter((id) => {
                return validIndices.includes(id);
            });
            var changed = false;
            if (currentConfig.length !== newConfig.length) {
                changed = true;
            } else {
                for (var j = 0; j < currentConfig.length; j++) {
                    if (currentConfig[j] !== newConfig[j]) {
                        changed = true;
                        break;
                    }
                }
            }
            if (changed) {
                Logger.i("Wallpaper", "Updating OpenRGB config, removing unavailable devices");
                Config.openRgbDevices = newConfig;
            }
        }

        target: Ipc
    }

    FileView {
        id: wallpaperCacheView

        path: ""
        onLoaded: {
            root.currentWallpapers = wallpaperCacheAdapter.wallpapers || {
            };
            root.defaultWallpaper = wallpaperCacheAdapter.defaultWallpaper || "";
            Logger.i("Wallpaper", "Loaded wallpapers from cache:", Object.keys(root.currentWallpapers).length, "screens");
            var screens = Object.keys(root.currentWallpapers);
            if (screens.length > 0) {
                var first = root.currentWallpapers[screens[0]];
                Logger.d("Wallpaper", "Generating initial colors from:", first);
                generateColors(first);
            }
            root.isInitialized = true;
        }
        onLoadFailed: (error) => {
            Logger.d("Wallpaper", "Cache not found, starting fresh");
            root.currentWallpapers = {
            };
            // Generate colors from system default wallpaper on first run
            Logger.d("Wallpaper", "Generating initial colors from default wallpaper:", root.systemDefaultWallpaper);
            generateColors(root.systemDefaultWallpaper);
            root.isInitialized = true;
        }

        adapter: JsonAdapter {
            id: wallpaperCacheAdapter

            property var wallpapers: ({
            })
            property string defaultWallpaper: ""
        }

    }

    Timer {
        id: saveTimer

        interval: 500
        repeat: false
        onTriggered: {
            wallpaperCacheAdapter.wallpapers = root.currentWallpapers;
            wallpaperCacheAdapter.defaultWallpaper = root.defaultWallpaper;
            wallpaperCacheView.writeAdapter();
            Logger.d("Wallpaper", "Saved wallpapers to cache");
        }
    }

    Instantiator {
        id: wallpaperScanners

        model: Quickshell.screens

        delegate: FolderListModel {
            property string screenName: modelData.name
            property string currentDirectory: root.defaultDirectory

            folder: "file://" + currentDirectory
            nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.gif", "*.webp", "*.bmp", "*.svg"]
            showDirs: false
            sortField: FolderListModel.Name
            onCurrentDirectoryChanged: folder = "file://" + currentDirectory
            onStatusChanged: {
                if (status === FolderListModel.Null) {
                    root.wallpaperLists[screenName] = [];
                    root.wallpaperListChanged(screenName, 0);
                } else if (status === FolderListModel.Loading) {
                    root.wallpaperLists[screenName] = [];
                    scanningCount++;
                } else if (status === FolderListModel.Ready) {
                    var files = [];
                    for (var i = 0; i < count; i++) {
                        var directory = root.defaultDirectory;
                        var fp = directory + "/" + get(i, "fileName");
                        files.push(fp);
                    }
                    root.wallpaperLists[screenName] = files;
                    scanningCount--;
                    Logger.d("Wallpaper", "Refreshed:", screenName, "count:", files.length);
                    root.wallpaperListChanged(screenName, files.length);
                }
            }
        }

    }

}
