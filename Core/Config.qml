import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    readonly property var defaults: ({
        fontFamily: "JetBrainsMono Nerd Font",
        fontSize: 14,
        wallpaperDirectory: Quickshell.env("HOME") + "/Pictures/Wallpapers",
        disableHover: false,
        floatingBar: false,
        hideBar: false,
        barPosition: "top",
        barSize: "fluid",
        colors: null,
        openRgbDevices: [0],
        disableLockBlur: false,
        disableLockAnimation: false,
        lockScreenCustomBackground: false,
        lockScreenMusicMode: false,
        lazyLoadLockScreen: true,
        debug: false,
        hideWorkspaceNumbers: false,
        hideAppIcons: false,
        use24HourFormat: true,
        clockFormat: "",
        barOpacity: 1.0,
        avatarPath: "",
        corner: true,
        timeZone: ""
    })

    property string fontFamily: defaults.fontFamily
    property int fontSize: defaults.fontSize
    property string wallpaperDirectory: defaults.wallpaperDirectory
    property bool disableHover: defaults.disableHover
    property bool floatingBar: defaults.floatingBar
    property bool hideBar: defaults.hideBar
    property string barPosition: defaults.barPosition
    property string barSize: defaults.barSize
    property var colors: defaults.colors
    property var openRgbDevices: defaults.openRgbDevices
    property bool disableLockBlur: defaults.disableLockBlur
    property bool disableLockAnimation: defaults.disableLockAnimation
    property bool lockScreenCustomBackground: defaults.lockScreenCustomBackground
    property bool lockScreenMusicMode: defaults.lockScreenMusicMode
    property bool lazyLoadLockScreen: defaults.lazyLoadLockScreen
    property bool debug: defaults.debug
    property bool hideWorkspaceNumbers: defaults.hideWorkspaceNumbers
    property bool hideAppIcons: defaults.hideAppIcons
    property bool use24HourFormat: defaults.use24HourFormat
    property string clockFormat: defaults.clockFormat
    property real barOpacity: defaults.barOpacity
    property string avatarPath: defaults.avatarPath
    property bool corner: defaults.corner
    property string timeZone: defaults.timeZone

    readonly property string configPath: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/dev-shell/config.json"

    FileView {
        id: configFile
        path: configPath
        watchChanges: true

        onLoaded: {
            var s = configAdapter
            root.fontFamily = s.fontFamily !== undefined && s.fontFamily !== "" ? s.fontFamily : defaults.fontFamily
            root.fontSize = s.fontSize !== undefined && s.fontSize !== 0 ? s.fontSize : defaults.fontSize
            root.wallpaperDirectory = s.wallpaperDirectory !== undefined && s.wallpaperDirectory !== "" ? s.wallpaperDirectory : defaults.wallpaperDirectory
            root.disableHover = s.disableHover !== undefined ? s.disableHover : defaults.disableHover
            root.floatingBar = s.floatingBar !== undefined ? s.floatingBar : defaults.floatingBar
            root.hideBar = s.hideBar !== undefined ? s.hideBar : defaults.hideBar
            root.barPosition = s.barPosition !== undefined && s.barPosition !== "" ? s.barPosition : defaults.barPosition
            root.barSize = s.barSize !== undefined && s.barSize !== "" ? s.barSize : defaults.barSize
            root.colors = s.colors !== undefined ? s.colors : defaults.colors
            root.openRgbDevices = s.openRgbDevices !== undefined ? s.openRgbDevices : defaults.openRgbDevices
            root.disableLockBlur = s.disableLockBlur !== undefined ? s.disableLockBlur : defaults.disableLockBlur
            root.disableLockAnimation = s.disableLockAnimation !== undefined ? s.disableLockAnimation : defaults.disableLockAnimation
            root.lockScreenCustomBackground = s.lockScreenCustomBackground !== undefined ? s.lockScreenCustomBackground : defaults.lockScreenCustomBackground
            root.lockScreenMusicMode = s.lockScreenMusicMode !== undefined ? s.lockScreenMusicMode : defaults.lockScreenMusicMode
            root.lazyLoadLockScreen = s.lazyLoadLockScreen !== undefined ? s.lazyLoadLockScreen : defaults.lazyLoadLockScreen
            root.debug = s.debug !== undefined ? s.debug : defaults.debug
            root.hideWorkspaceNumbers = s.hideWorkspaceNumbers !== undefined ? s.hideWorkspaceNumbers : defaults.hideWorkspaceNumbers
            root.hideAppIcons = s.hideAppIcons !== undefined ? s.hideAppIcons : defaults.hideAppIcons
            root.use24HourFormat = s.use24HourFormat !== undefined ? s.use24HourFormat : defaults.use24HourFormat
            root.clockFormat = s.clockFormat !== undefined ? s.clockFormat : defaults.clockFormat
            root.barOpacity = s.barOpacity !== undefined ? s.barOpacity : defaults.barOpacity
            root.avatarPath = s.avatarPath !== undefined ? s.avatarPath : defaults.avatarPath
            root.corner = s.corner !== undefined ? s.corner : defaults.corner
            root.timeZone = s.timeZone !== undefined ? s.timeZone : defaults.timeZone
            
            Logger.i("Config", "Loaded settings from", configPath)
        }

        onLoadFailed: (error) => {
            Logger.w("Config", "No config file found, using defaults")
        }

        adapter: JsonAdapter {
            id: configAdapter
            property string fontFamily: ""
            property int fontSize: 0
            property string wallpaperDirectory: ""
            property bool disableHover: false
            property bool floatingBar: false
            property bool hideBar: false
            property string barPosition: ""
            property string barSize: ""
            property var colors: null
            property var openRgbDevices: [0]
            property bool disableLockBlur: false
            property bool disableLockAnimation: false
            property bool lockScreenCustomBackground: false
            property bool lockScreenMusicMode: false
            property bool lazyLoadLockScreen: true
            property bool debug: false
            property bool hideWorkspaceNumbers: false
            property bool hideAppIcons: false
            property bool use24HourFormat: true
            property string clockFormat: ""
            property real barOpacity: 1.0
            property string avatarPath: ""
            property string timeZone: ""
            property bool corner: true
        }
    }

    Timer {
        id: saveTimer
        interval: 500
        repeat: false
        onTriggered: {
            configAdapter.fontFamily = root.fontFamily
            configAdapter.fontSize = root.fontSize
            configAdapter.wallpaperDirectory = root.wallpaperDirectory
            configAdapter.disableHover = root.disableHover
            configAdapter.floatingBar = root.floatingBar
            configAdapter.hideBar = root.hideBar
            configAdapter.barPosition = root.barPosition
            configAdapter.barSize = root.barSize
            configAdapter.colors = root.colors
            configAdapter.openRgbDevices = root.openRgbDevices
            configAdapter.disableLockBlur = root.disableLockBlur
            configAdapter.disableLockAnimation = root.disableLockAnimation
            configAdapter.lockScreenCustomBackground = root.lockScreenCustomBackground
            configAdapter.lockScreenMusicMode = root.lockScreenMusicMode
            configAdapter.lazyLoadLockScreen = root.lazyLoadLockScreen
            configAdapter.debug = root.debug
            configAdapter.hideWorkspaceNumbers = root.hideWorkspaceNumbers
            configAdapter.hideAppIcons = root.hideAppIcons
            configAdapter.use24HourFormat = root.use24HourFormat
            configAdapter.clockFormat = root.clockFormat
            configAdapter.barOpacity = root.barOpacity
            configAdapter.avatarPath = root.avatarPath
            configAdapter.corner = root.corner
            configAdapter.timeZone = root.timeZone
            configFile.writeAdapter()
        }
    }

    onFontFamilyChanged: save()
    onFontSizeChanged: save()
    onWallpaperDirectoryChanged: save()
    onDisableHoverChanged: save()
    onFloatingBarChanged: save()
    onHideBarChanged: save()
    onBarPositionChanged: save()
    onBarSizeChanged: save()
    onColorsChanged: save()
    onOpenRgbDevicesChanged: save()
    onDisableLockBlurChanged: save()
    onDisableLockAnimationChanged: save()
    onLockScreenCustomBackgroundChanged: save()
    onLockScreenMusicModeChanged: save()
    onLazyLoadLockScreenChanged: save()
    onDebugChanged: save()
    onHideWorkspaceNumbersChanged: save()
    onHideAppIconsChanged: save()
    onUse24HourFormatChanged: save()
    onClockFormatChanged: save()
    onBarOpacityChanged: save()
    onAvatarPathChanged: save()
    onCornerChanged: save()
    onTimeZoneChanged: save()
    Component.onCompleted: load()

    function save() {
        saveTimer.restart()
    }

    function load() {
        configFile.reload()
    }

    function resetDefaults() {
        fontFamily = defaults.fontFamily
        fontSize = defaults.fontSize
        wallpaperDirectory = defaults.wallpaperDirectory
        disableHover = defaults.disableHover
        floatingBar = defaults.floatingBar
        hideBar = defaults.hideBar
        barPosition = defaults.barPosition
        barSize = defaults.barSize
        colors = defaults.colors
        openRgbDevices = defaults.openRgbDevices
        disableLockBlur = defaults.disableLockBlur
        disableLockAnimation = defaults.disableLockAnimation
        lockScreenCustomBackground = defaults.lockScreenCustomBackground
        lockScreenMusicMode = defaults.lockScreenMusicMode
        lazyLoadLockScreen = defaults.lazyLoadLockScreen
        debug = defaults.debug
        hideWorkspaceNumbers = defaults.hideWorkspaceNumbers
        hideAppIcons = defaults.hideAppIcons
        use24HourFormat = defaults.use24HourFormat
        clockFormat = defaults.clockFormat
        barOpacity = defaults.barOpacity
        avatarPath = defaults.avatarPath
        corner = defaults.corner
        timeZone = defaults.timeZone
        Logger.i("Config", "Settings reset to defaults")
    }

    function exportSettings(filePath) {
        var settings = {
            fontFamily: fontFamily,
            fontSize: fontSize,
            wallpaperDirectory: wallpaperDirectory,
            disableHover: disableHover,
            floatingBar: floatingBar,
            hideBar: hideBar,
            barPosition: barPosition,
            barSize: barSize,
            colors: colors,
            openRgbDevices: openRgbDevices,
            disableLockBlur: disableLockBlur,
            disableLockAnimation: disableLockAnimation,
            lockScreenCustomBackground: lockScreenCustomBackground,
            lockScreenMusicMode: lockScreenMusicMode,
            lazyLoadLockScreen: lazyLoadLockScreen,
            debug: debug,
            hideWorkspaceNumbers: hideWorkspaceNumbers,
            hideAppIcons: hideAppIcons,
            use24HourFormat: use24HourFormat,
            clockFormat: clockFormat,
            barOpacity: barOpacity,
            avatarPath: avatarPath,
            corner: corner,
            timeZone: timeZone
        }
        exportProc.settingsJson = JSON.stringify(settings, null, 2)
        exportProc.filePath = filePath
        exportProc.running = true
    }

    function importSettings(filePath) {
        importProc.filePath = filePath
        importProc.running = true
    }

    Process {
        id: exportProc
        property string filePath: ""
        property string settingsJson: ""
        command: ["sh", "-c", "echo '" + settingsJson + "' > " + filePath]
    }

    Process {
        id: importProc
        property string filePath: ""
        command: ["cat", filePath]
        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var settings = JSON.parse(data)
                    if (settings.fontFamily !== undefined) fontFamily = settings.fontFamily
                    if (settings.fontSize !== undefined) fontSize = settings.fontSize
                    if (settings.wallpaperDirectory !== undefined) wallpaperDirectory = settings.wallpaperDirectory
                    if (settings.disableHover !== undefined) disableHover = settings.disableHover
                    if (settings.floatingBar !== undefined) floatingBar = settings.floatingBar
                    if (settings.hideBar !== undefined) hideBar = settings.hideBar
                    if (settings.barPosition !== undefined) barPosition = settings.barPosition
                    if (settings.barSize !== undefined) barSize = settings.barSize
                    if (settings.colors !== undefined) colors = settings.colors
                    if (settings.openRgbDevices !== undefined) openRgbDevices = settings.openRgbDevices
                    if (settings.disableLockBlur !== undefined) disableLockBlur = settings.disableLockBlur
                    if (settings.disableLockAnimation !== undefined) disableLockAnimation = settings.disableLockAnimation
                    if (settings.lockScreenCustomBackground !== undefined) lockScreenCustomBackground = settings.lockScreenCustomBackground
                    if (settings.lockScreenMusicMode !== undefined) lockScreenMusicMode = settings.lockScreenMusicMode
                    if (settings.lazyLoadLockScreen !== undefined) lazyLoadLockScreen = settings.lazyLoadLockScreen
                    if (settings.debug !== undefined) debug = settings.debug
                    if (settings.hideWorkspaceNumbers !== undefined) hideWorkspaceNumbers = settings.hideWorkspaceNumbers
                    if (settings.hideAppIcons !== undefined) hideAppIcons = settings.hideAppIcons
                    if (settings.use24HourFormat !== undefined) use24HourFormat = settings.use24HourFormat
                    if (settings.clockFormat !== undefined) clockFormat = settings.clockFormat
                    if (settings.barOpacity !== undefined) barOpacity = settings.barOpacity
                    if (settings.avatarPath !== undefined) avatarPath = settings.avatarPath
                    if (settings.corner !== undefined) corner = settings.corner
                    if (settings.timeZone !== undefined) timeZone = settings.timeZone
                    Logger.i("Config", "Settings imported successfully")
                } catch (e) {
                    Logger.e("Config", "Import failed: " + e)
                }
            }
        }
    }
}
