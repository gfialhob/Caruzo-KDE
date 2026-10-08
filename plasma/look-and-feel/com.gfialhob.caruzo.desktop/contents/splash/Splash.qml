/*
    Ozurac - tela de carregamento do Plasma
*/
import QtQuick

Rectangle {
    id: root
    anchors.fill: parent
    color: "#0a0a0a"

    property int stage

    Column {
        anchors.centerIn: parent
        spacing: 18

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "CARUZO"
            color: "#ffffff"
            font.pixelSize: 28
            font.letterSpacing: 6
            font.weight: Font.Light
        }

        Image {
            id: spinner
            anchors.horizontalCenter: parent.horizontalCenter
            source: "images/busywidget.svg"
            width: 48
            height: 48
            smooth: true

            RotationAnimation on rotation {
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 1400
                running: true
            }
        }
    }
}
