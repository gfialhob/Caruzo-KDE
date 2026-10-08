import QtQuick
import QtQuick.Effects

// Fundo "vidro fosco" retangular pra campos (usuario/senha). Calcula sua
// propria posicao absoluta via mapToItem, entao funciona tanto solto na tela
// quanto usado como `background:` de um TextField/ComboBox (onde x/y sao
// relativos ao proprio controle, nao a tela).
Item {
    id: root

    property Item source                 // item com o fundo ja desfocado (blurredBg)
    property Item stage                  // item que cobre a tela inteira, mesma origem de `source`
    property color tint: "#0a0a0a"
    property real tintOpacity: 0.55
    property real blurAmount: 1.0
    property real radius: 4
    property color borderColor: "#004f3d"
    property real borderWidth: 1

    readonly property point absPos: stage ? root.mapToItem(stage, 0, 0) : Qt.point(root.x, root.y)

    ShaderEffectSource {
        id: capture
        width: root.width
        height: root.height
        sourceItem: root.source
        sourceRect: Qt.rect(root.absPos.x, root.absPos.y, root.width, root.height)
        visible: false
        live: true
    }

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

    MultiEffect {
        anchors.fill: parent
        source: capture
        autoPaddingEnabled: false
        blurEnabled: true
        blur: root.blurAmount
        blurMax: 48
        brightness: 0.04
        saturation: 0.05
        maskEnabled: true
        maskSource: maskItem
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.tint
        opacity: root.tintOpacity
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.width: root.borderWidth
        border.color: root.borderColor
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }
}
