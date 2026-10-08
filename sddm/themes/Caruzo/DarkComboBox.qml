import QtQuick
import QtQuick.Controls

// ComboBox escuro (o padrao do Qt vem com texto preto sobre fundo claro).
ComboBox {
    id: control

    property color accent: "#00995d"
    property color fieldColor: "#0a0a0a"
    property int fieldRadius: 4

    delegate: ItemDelegate {
        id: item
        required property var model
        required property int index
        width: control.width
        height: 34
        highlighted: control.highlightedIndex === index
        contentItem: Text {
            text: item.model[control.textRole]
            color: "#ffffff"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 3
            color: item.highlighted ? control.accent : "transparent"
        }
    }

    indicator: Image {
        x: control.width - width - 12
        y: (control.height - height) / 2
        width: 14
        height: 14
        sourceSize: Qt.size(28, 28)
        source: "images/icons/chevron.svg"
    }

    contentItem: Text {
        leftPadding: 12
        rightPadding: control.indicator.width + 20
        text: control.displayText
        color: "#ffffff"
        font: control.font
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        color: control.fieldColor
        radius: control.fieldRadius
        border.width: 1
        border.color: control.activeFocus || control.popup.visible ? control.accent : "#1c1c1c"
    }

    // abre pra cima (o seletor fica no rodape da tela)
    popup: Popup {
        y: -height - 6
        width: control.width
        padding: 4
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
        }
        background: Rectangle {
            color: control.fieldColor
            radius: control.fieldRadius
            border.width: 1
            border.color: "#1f1f1f"
        }
    }
}
