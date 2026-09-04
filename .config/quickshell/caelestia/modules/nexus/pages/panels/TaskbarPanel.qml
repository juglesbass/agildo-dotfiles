pragma ComponentBehavior: Bound

import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Barra de tarefas")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Behaviour
        SectionHeader {
            first: true
            text: qsTr("Comportamento e tamanho")
        }

        StepperRow {
            first: true
            label: qsTr("Largura da barra (Dock)")
            subtext: qsTr("Espessura da barra e tamanho dos ícones (%1 px)").arg(Tokens.sizes.bar.innerWidth)
            value: Tokens.sizes.bar.innerWidth
            from: 20
            to: 60
            stepSize: 2
            onMoved: v => {
                Tokens.sizes.bar.innerWidth = Math.round(v);
                Quickshell.execDetached(["/home/agildo/.local/bin/set-bar-width.sh", String(Math.round(v))]);
            }
        }

        ToggleRow {
            text: qsTr("Sempre visível")
            subtext: qsTr("Manter a barra visível o tempo todo")
            checked: Config.bar.persistent
            onToggled: GlobalConfig.bar.persistent = checked
        }

        ToggleRow {
            text: qsTr("Exibir ao passar o mouse")
            subtext: qsTr("Revelar a barra quando o cursor tocar a borda inferior")
            checked: Config.bar.showOnHover
            onToggled: GlobalConfig.bar.showOnHover = checked
        }

        StepperRow {
            last: true
            label: qsTr("Distância de arrasto")
            subtext: qsTr("Pixels arrastados para revelar a barra")
            value: Config.bar.dragThreshold
            from: 0
            to: 200
            stepSize: 5
            onMoved: v => GlobalConfig.bar.dragThreshold = v
        }

        // Components
        SectionHeader {
            text: qsTr("Componentes da barra")
        }

        NavRow {
            first: true
            icon: "workspaces"
            text: qsTr("Espaços de trabalho")
            subtext: qsTr("Indicadores e ícones de janelas")
            onClicked: root.nState.openSubPage(6)
        }

        NavRow {
            icon: "web_asset"
            text: qsTr("Janela ativa")
            subtext: qsTr("Título do app e popout")
            onClicked: root.nState.openSubPage(7)
        }

        NavRow {
            icon: "widgets"
            text: qsTr("Bandeja do sistema")
            subtext: qsTr("Ícones da área de notificação / tray")
            onClicked: root.nState.openSubPage(8)
        }

        NavRow {
            icon: "signal_cellular_alt"
            text: qsTr("Ícones de status")
            subtext: qsTr("Rede, som, bateria e teclado")
            onClicked: root.nState.openSubPage(9)
        }

        NavRow {
            last: true
            icon: "schedule"
            text: qsTr("Relógio")
            subtext: qsTr("Data, hora e formato")
            onClicked: root.nState.openSubPage(10)
        }

        // Scroll actions
        SectionHeader {
            text: qsTr("Ações ao rolar a roda do mouse")
        }

        ToggleRow {
            first: true
            text: qsTr("Trocar áreas de trabalho")
            subtext: qsTr("Rolar sobre a barra para alternar entre workspaces")
            checked: Config.bar.scrollActions.workspaces
            onToggled: GlobalConfig.bar.scrollActions.workspaces = checked
        }

        ToggleRow {
            text: qsTr("Ajustar volume")
            subtext: qsTr("Rolar sobre a metade da barra para alterar o volume")
            checked: Config.bar.scrollActions.volume
            onToggled: GlobalConfig.bar.scrollActions.volume = checked
        }

        ToggleRow {
            last: true
            text: qsTr("Ajustar brilho")
            subtext: qsTr("Rolar sobre a barra para alterar o brilho da tela")
            checked: Config.bar.scrollActions.brightness
            onToggled: GlobalConfig.bar.scrollActions.brightness = checked
        }
    }
}
