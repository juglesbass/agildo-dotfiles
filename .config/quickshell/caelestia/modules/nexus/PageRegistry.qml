pragma Singleton

import QtQuick

QtObject {
    id: root

    readonly property list<var> pages: [
        // Appearance
        {
            label: qsTr("Aparência e estilo"),
            icon: "palette",
            description: qsTr("Contorno da tela, fontes, cores e tema"),
            category: "appearance"
        },

        // Connectivity
        // TODO
        // {
        //     label: qsTr("Tela"),
        //     icon: "monitor",
        //     description: qsTr("Configuração de exibição"),
        //     category: "connectivity"
        // },
        {
            label: qsTr("Rede"),
            icon: "wifi",
            description: qsTr("Wi-Fi, ethernet, VPN"),
            category: "connectivity"
        },
        {
            label: qsTr("Dispositivos conectados"),
            icon: "devices_other",
            description: qsTr("Bluetooth, pareamento"),
            category: "connectivity",
            noFill: true
        },
        {
            label: qsTr("Áudio"),
            icon: "volume_up",
            description: qsTr("Volume dos apps, dispositivos de som"),
            category: "connectivity"
        },

        // System
        {
            label: qsTr("Atualizações"),
            icon: "update",
            description: qsTr("Atualizações do sistema"),
            category: "system"
        },
        {
            label: qsTr("Plugins"),
            icon: "extension",
            description: qsTr("Gerenciar plugins"),
            category: "system"
        },

        // Shell
        {
            label: qsTr("Painéis"),
            icon: "dock_to_bottom",
            description: qsTr("Painel, barra de tarefas, inicializador, lateral"),
            category: "shell"
        },
        {
            label: qsTr("Aplicativos"),
            icon: "apps",
            description: qsTr("Apps padrão, favoritos, apps ocultos"),
            category: "shell"
        },
        {
            label: qsTr("Serviços"),
            icon: "build",
            description: qsTr("Intervalos de atualização, letras"),
            category: "shell"
        },
        {
            label: qsTr("Idioma e região"),
            icon: "globe",
            description: qsTr("Idioma da interface, clima, unidades"),
            category: "shell"
        },

        // About
        {
            label: qsTr("Sobre"),
            icon: "info",
            description: qsTr("Informações do sistema, créditos"),
            category: "about"
        },
    ]
}
