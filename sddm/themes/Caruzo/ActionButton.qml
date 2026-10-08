import QtQuick

// Botao de rodape: icone + rotulo. No hover, icone e texto ficam verdes.
Item {
    id: root

    property string iconName: ""
    property string label: ""
    property string fontFamily: "JetBrains Mono"
    property real fontSize: 10
    property color accent: "#00995d"

    signal clicked()

    readonly property bool hovered: mouse.containsMouse

    implicitWidth: row.implicitWidth + 24
    implicitHeight: 36

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: "#ffffff"
        opacity: root.hovered ? 0.08 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Image {
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            sourceSize: Qt.size(48, 48)
            smooth: true
            source: "images/icons/" + root.iconName + (root.hovered ? "-hover" : "") + ".svg"
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.hovered ? root.accent : "#e6e6e6"
            font.family: root.fontFamily
            font.pointSize: root.fontSize
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
