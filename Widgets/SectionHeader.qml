import QtQuick
import QtQuick.Layouts
import qs.Core

RowLayout {
    id: root

    required property string title   
    required property real fontSize
    required property bool showDivider

    spacing: 12
    Layout.fillWidth: true
    Layout.topMargin: 8
    Layout.bottomMargin: 8

    // Rectangle {
    //     width: 4
    //     height: 24
    //     radius: 2
    //     color: context.colors
    // }

    Text {
        text: root.title
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: colors.border
        opacity: 0.3
        visible: root.showDivider
    }
}