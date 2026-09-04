import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Painéis")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        NavRow {
            first: true
            icon: "dashboard"
            text: qsTr("Painel de controle")
            subtext: Config.dashboard.enabled ? qsTr("Ativado") : qsTr("Desativado")
            onClicked: root.nState.openSubPage(1)
        }

        NavRow {
            icon: "dock_to_bottom"
            text: qsTr("Barra de tarefas")
            subtext: Config.bar.persistent ? qsTr("Sempre visível") : Config.bar.showOnHover ? qsTr("Exibir ao passar o mouse") : qsTr("Exibir ao arrastar")
            onClicked: root.nState.openSubPage(2)
        }

        NavRow {
            icon: "apps"
            text: qsTr("Inicializador")
            subtext: Config.launcher.enabled ? qsTr("Ativado") : qsTr("Desativado")
            onClicked: root.nState.openSubPage(3)
        }

        NavRow {
            icon: "dock_to_right"
            text: qsTr("Barra lateral")
            subtext: Config.sidebar.enabled ? qsTr("Ativado") : qsTr("Desativado")
            onClicked: root.nState.openSubPage(4)
        }

        NavRow {
            last: true
            icon: "construction"
            text: qsTr("Utilitários")
            subtext: Config.utilities.enabled ? qsTr("Ativado") : qsTr("Desativado")
            onClicked: root.nState.openSubPage(5)
        }
    }
}
