import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: root
    anchors.fill: parent
    color: "#111111"

    // ---- configuracao (theme.conf) -------------------------------------------------
    readonly property string uiFont: config.fontFamily ? config.fontFamily : "JetBrains Mono"
    readonly property real uiSize: config.fontSize ? Number(config.fontSize) : 10
    readonly property real bgBlur: config.backgroundBlur ? Number(config.backgroundBlur) : 1.0
    readonly property real btnBlur: config.buttonBlur ? Number(config.buttonBlur) : 1.0
    readonly property real dimAmount: config.dimOpacity ? Number(config.dimOpacity) : 0.45
    readonly property var uiLocale: Qt.locale(config.locale ? config.locale : "pt_BR")

    // ---- paleta ----------------------------------------------------------------------
    readonly property color accent: "#00995d"
    readonly property color fieldColor: "#0A0A0A"
    readonly property int fieldRadius: 4
    readonly property int fieldWidth: 320
    readonly property int fieldHeight: 36

    function cap(s) { return s.length ? s.charAt(0).toUpperCase() + s.slice(1) : s }
    function updateClock() {
        var now = new Date()
        timeLabel.text = Qt.formatTime(now, "hh:mm")
        dateLabel.text = cap(now.toLocaleDateString(uiLocale, "dddd, d 'de' MMMM 'de' yyyy"))
    }
    function doLogin() {
        var name = userList.currentItem ? userList.currentItem.userName : ""
        sddm.login(name, passwordField.text, sessionSelector.currentIndex)
    }

    // ---- fundo: imagem inteira em blur -------------------------------------------------
    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.background ? config.background : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
    }

    MultiEffect {
        id: blurredBg
        anchors.fill: parent
        source: wallpaper
        autoPaddingEnabled: false
        blurEnabled: true
        blur: root.bgBlur
        blurMax: 50
    }

    // escurece um pouco, na cor da marca, pra dar leitura ao texto
    Rectangle {
        anchors.fill: parent
        color: "#111111"
        opacity: root.dimAmount
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateClock()
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "Usuário ou senha incorretos"
            errorMessage.visible = true
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }

    // ---- tudo abaixo cobre a tela inteira (mesma origem do fundo) ------------------------
    Item {
        id: stage
        anchors.fill: parent

        // relogio no topo
        Column {
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Text {
                id: timeLabel
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#FFFFFF"
                font.family: root.uiFont
                font.pointSize: root.uiSize * 6
                font.bold: true
            }
            Text {
                id: dateLabel
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#d6d6d6"
                font.family: root.uiFont
                font.pointSize: root.uiSize * 1.5
                font.bold: true
            }
        }

        // avatar
        Item {
            id: avatar
            width: 128
            height: 128
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -90

            GlassCircle {
                anchors.fill: parent
                source: blurredBg
                tint: "#0A0A0A"
                tintOpacity: 0.55
                blurAmount: root.bgBlur
            }

            Image {
                anchors.fill: parent
                anchors.margins: 18
                source: "images/avatar.svg"
                sourceSize: Qt.size(width * 2, height * 2)   // renderiza o SVG em alta resolucao (nitido em HiDPI)
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }

        // nome do usuario selecionado (a lista serve pra ler os dados do modelo)
        ListView {
            id: userList
            anchors.top: avatar.bottom
            anchors.topMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.fieldWidth
            height: 28
            model: userModel
            currentIndex: Math.max(0, userModel.lastIndex)
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 200
            interactive: false
            clip: true

            delegate: Item {
                width: userList.width
                height: userList.height
                property string userName: model.name

                Text {
                    anchors.centerIn: parent
                    text: model.realName ? model.realName : model.name
                    color: "#FFFFFF"
                    font.family: root.uiFont
                    font.pointSize: root.uiSize * 1.5
                    font.bold: true
                }
            }
        }

        TextField {
            id: passwordField
            anchors.top: userList.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.fieldWidth
            height: root.fieldHeight
            echoMode: TextInput.Password
            placeholderText: "Senha"
            placeholderTextColor: "#707070"
            color: "#FFFFFF"
            selectionColor: root.accent
            font.family: root.uiFont
            font.pointSize: root.uiSize * 1.2
            leftPadding: 12
            rightPadding: 12
            verticalAlignment: TextInput.AlignVCenter
            background: GlassField {
                source: blurredBg
                stage: stage
                blurAmount: root.btnBlur
                radius: root.fieldRadius
                borderColor: passwordField.activeFocus ? root.accent : "#004F3D"
            }
            onAccepted: root.doLogin()
            Component.onCompleted: forceActiveFocus()
        }

        // botao de login com blur (vidro fosco)
        GlassButton {
            id: loginButton
            anchors.top: passwordField.bottom
            anchors.topMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter
            width: 120
            height: 36
            source: blurredBg
            text: "Login"
            fontFamily: root.uiFont
            fontSize: root.uiSize * 1.2
            tint: root.accent
            blurAmount: root.btnBlur
            radius: root.fieldRadius
            onClicked: root.doLogin()
        }

        Text {
            id: errorMessage
            anchors.top: loginButton.bottom
            anchors.topMargin: 14
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.fieldWidth
            visible: false
            color: "#da4453"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.family: root.uiFont
            font.pointSize: root.uiSize
        }

        // rodape: sessao a esquerda, ações a direita
        Item {
            id: bottomBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 28
            height: 40

            DarkComboBox {
                id: sessionSelector
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 240
                height: 36
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
                visible: count > 1
                accent: root.accent
                fieldColor: root.fieldColor
                fieldRadius: root.fieldRadius
                font.family: root.uiFont
                font.pointSize: root.uiSize
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                ActionButton {
                    id: switchUserButton
                    iconName: "switch-user"
                    label: "Alterar usuário"
                    fontFamily: root.uiFont
                    fontSize: root.uiSize
                    accent: root.accent
                    onClicked: userPopup.open()
                }
                ActionButton {
                    iconName: "suspend"
                    label: "Suspender"
                    visible: sddm.canSuspend
                    fontFamily: root.uiFont
                    fontSize: root.uiSize
                    accent: root.accent
                    onClicked: sddm.suspend()
                }
                ActionButton {
                    iconName: "reboot"
                    label: "Reiniciar"
                    visible: sddm.canReboot
                    fontFamily: root.uiFont
                    fontSize: root.uiSize
                    accent: root.accent
                    onClicked: sddm.reboot()
                }
                ActionButton {
                    iconName: "shutdown"
                    label: "Desligar"
                    visible: sddm.canPowerOff
                    fontFamily: root.uiFont
                    fontSize: root.uiSize
                    accent: root.accent
                    onClicked: sddm.powerOff()
                }
            }
        }

        // lista de usuarios (abre acima do botao "Alterar usuario")
        Popup {
            id: userPopup
            parent: switchUserButton
            x: switchUserButton.width - width
            y: -height - 8
            width: 280
            padding: 4
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            background: Rectangle {
                color: root.fieldColor
                radius: root.fieldRadius
                border.width: 1
                border.color: "#004E2F"
            }

            contentItem: Column {
                spacing: 2
                Repeater {
                    model: userModel
                    delegate: Rectangle {
                        width: userPopup.width - 8
                        height: 34
                        radius: 3
                        color: itemMouse.containsMouse ? root.accent : "transparent"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 12
                            width: parent.width - 24
                            elide: Text.ElideRight
                            text: model.realName ? model.realName + "  (" + model.name + ")" : model.name
                            color: "#FFFFFF"
                            font.family: root.uiFont
                            font.pointSize: root.uiSize
                        }
                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                userList.currentIndex = index
                                userPopup.close()
                                passwordField.text = ""
                                passwordField.forceActiveFocus()
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
