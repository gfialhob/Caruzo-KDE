import QtQuick
import QtQuick.Effects

// Fundo "vidro fosco" circular, mesma tecnica do GlassButton mas recortado
// em circulo (pra usar atras do avatar). Precisa ser filho do mesmo item
// que preenche a tela usado como `source` (aqui, o "stage").
Item {
    id: root

    property Item source
    property color tint: "#ffffff"
    property color borderColor: "#00995d"   // borda solida
    property real tintOpacity: 0.55
    property real blurAmount: 1.0

    ShaderEffectSource {
        id: capture
        width: root.width
        height: root.height
        sourceItem: root.source
        sourceRect: Qt.rect(root.x, root.y, root.width, root.height)
        visible: false
    }

    Item {
        id: maskItem
        anchors.fill: parent
        layer.enabled: true
        visible: false
        Rectangle {
            anchors.fill: parent
            radius: width / 2
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
        brightness: 0.1
        saturation: 0.05
        maskEnabled: true
        maskSource: maskItem
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.tint
        opacity: root.tintOpacity
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: root.borderColor
    }
}