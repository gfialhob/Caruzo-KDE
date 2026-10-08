import QtQuick
import QtQuick.Effects

// Botao "vidro fosco": amostra a regiao do fundo que fica atras dele,
// aplica blur extra, uma tinta translucida e uma borda fina.
// IMPORTANTE: precisa ser filho direto de um item com a mesma origem/tamanho de `source`
// (aqui, o "stage" que cobre a tela inteira) - assim x/y ja sao as coordenadas no fundo.
Item {
    id: root

    property Item source
    property string text: ""
    property string fontFamily: "JetBrains Mono"
    property real fontSize: 10
    property color tint: "#00995d"
    property color restTint: "#0A0A0A"    // cor do vidro em repouso (antes do hover)
    property real tintOpacity: 0.5        // repouso: vidro escuro (nao mais transparente)
    property real hoverOpacity: 0.9       // hover: quase solido, na cor "tint"
    property real pressedOpacity: 1.0
    property real blurAmount: 1.0
    property real radius: 4
    property color textColor: "#ffffff"        // cor do texto em repouso
    property color hoverTextColor: "#0a0a0a"   // cor do texto no hover/pressed

    signal clicked()

    readonly property bool hovered: mouse.containsMouse
    readonly property bool pressed: mouse.pressed

    implicitWidth: 320
    implicitHeight: 42

    // 1) recorte do fundo (ja desfocado) que fica atras do botao
    ShaderEffectSource {
        id: capture
        width: root.width
        height: root.height
        sourceItem: root.source
        sourceRect: Qt.rect(root.x, root.y, root.width, root.height)
        visible: false
    }

    // 2) mascara com os cantos arredondados
    Item {
        id: maskItem
        anchors.fill: parent
        layer.enabled: true
        visible: false
        Rectangle {
            anchors.fill: parent
            radius: root.radius
            color: "black"
        }
    }

    // 3) blur extra sobre o recorte, ja recortado no formato do botao
    MultiEffect {
        anchors.fill: parent
        source: capture
        autoPaddingEnabled: false
        blurEnabled: true
        blur: root.blurAmount
        blurMax: 48
        brightness: 0.06
        saturation: 0.1
        maskEnabled: true
        maskSource: maskItem
    }

    // 4) tinta translucida
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: (root.hovered || root.pressed) ? root.tint : root.restTint
        opacity: root.pressed ? root.pressedOpacity
                              : (root.hovered ? root.hoverOpacity : root.tintOpacity)
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    // 5) borda fina de vidro
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        // border.width: 1
        // border.color: Qt.rgba(1, 1, 1, root.hovered ? 0.35 : 0.2)
    }

    Text {
        anchors.centerIn: parent
        text: root.text
        color: (root.hovered || root.pressed) ? root.hoverTextColor : root.textColor
        font.family: root.fontFamily
        font.pointSize: root.fontSize
        font.bold: true
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
