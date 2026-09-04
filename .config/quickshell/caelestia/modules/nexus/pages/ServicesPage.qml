import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.Services
import qs.components.controls
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    // Lyrics backends, ordered to match config::LyricsBackend (Auto, Local, LRCLIB, NetEase)
    readonly property list<MenuItem> lyricsItems: [
        MenuItem {
            text: qsTr("Automático")
        },
        MenuItem {
            text: "Local"
        },
        MenuItem {
            text: "LRCLIB"
        },
        MenuItem {
            text: "NetEase"
        }
    ]

    // GPU types, ordered to match config::GpuType (Auto, Nvidia, Generic, None)
    readonly property list<MenuItem> gpuItems: [
        MenuItem {
            text: qsTr("Automático")
        },
        MenuItem {
            text: "NVIDIA"
        },
        MenuItem {
            text: qsTr("Genérico")
        },
        MenuItem {
            text: qsTr("Nenhum")
        }
    ]

    title: qsTr("Serviços")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Detected running players, used as default-player options
        Variants {
            id: playerVariants

            model: [...new Set(Players.list.map(p => Players.getIdentity(p)).filter(id => id))]

            MenuItem {
                required property string modelData

                text: modelData
                icon: modelData === GlobalConfig.services.defaultPlayer ? "check" : ""
                activeIcon: "music_note"
            }
        }

        // Notifications
        SectionHeader {
            first: true
            text: qsTr("Notificações")
        }

        NavRow {
            first: true
            last: true
            icon: "notifications"
            text: qsTr("Notificações")
            subtext: qsTr("Notificações, avisos, tempos limite")
            onClicked: root.nState.openSubPage(1)
        }

        // Polling
        SectionHeader {
            text: qsTr("Atualizações periódicas")
        }

        StepperRow {
            first: true
            label: qsTr("Atualização de mídia")
            subtext: qsTr("Frequência de atualização da barra de mídia (ms)")
            value: GlobalConfig.dashboard.mediaUpdateInterval
            from: 100
            to: 2000
            stepSize: 50
            onMoved: v => GlobalConfig.dashboard.mediaUpdateInterval = v
        }

        StepperRow {
            label: qsTr("Status do sistema")
            subtext: qsTr("Intervalo de atualização de CPU, memória e GPU (segundos)")
            value: GlobalConfig.dashboard.resourceUpdateInterval / 1000
            from: 0.5
            to: 10
            stepSize: 0.5
            onMoved: v => GlobalConfig.dashboard.resourceUpdateInterval = Math.round(v * 1000)
        }

        StepperRow {
            last: true
            label: qsTr("Busca de Wi-Fi")
            subtext: qsTr("Frequência de busca de redes disponíveis (segundos)")
            value: GlobalConfig.nexus.networkRescanInterval / 1000
            from: 5
            to: 120
            stepSize: 5
            onMoved: v => GlobalConfig.nexus.networkRescanInterval = Math.round(v * 1000)
        }

        // Media & lyrics
        SectionHeader {
            text: qsTr("Mídia e letras")
        }

        SelectRow {
            first: true
            label: qsTr("Backend de letras")
            subtext: qsTr("Fonte usada para buscar letras sincronizadas")
            menuItems: root.lyricsItems
            active: root.lyricsItems[Lyrics.preferredBackend] ?? root.lyricsItems[0]
            onSelected: item => Lyrics.preferredBackend = root.lyricsItems.indexOf(item)
        }

        SelectRow {
            last: true
            label: qsTr("Player padrão")
            subtext: qsTr("Player preferido quando vários estiverem abertos")
            menuItems: playerVariants.instances
            active: menuItems.find(i => i.text === GlobalConfig.services.defaultPlayer) ?? null
            fallbackIcon: "music_note"
            fallbackText: GlobalConfig.services.defaultPlayer || qsTr("Automático")
            onSelected: item => GlobalConfig.services.defaultPlayer = item.text
        }

        // Input increments
        SectionHeader {
            text: qsTr("Passos de incremento")
        }

        StepperRow {
            first: true
            label: qsTr("Passo do volume")
            subtext: qsTr("Quanto o volume altera por rolagem (%)")
            value: Math.round(GlobalConfig.services.audioIncrement * 100)
            from: 1
            to: 50
            stepSize: 1
            onMoved: v => GlobalConfig.services.audioIncrement = v / 100
        }

        StepperRow {
            label: qsTr("Passo do brilho")
            subtext: qsTr("Quanto o brilho altera por rolagem (%)")
            value: Math.round(GlobalConfig.services.brightnessIncrement * 100)
            from: 1
            to: 50
            stepSize: 1
            onMoved: v => GlobalConfig.services.brightnessIncrement = v / 100
        }

        StepperRow {
            last: true
            label: qsTr("Volume máximo")
            subtext: qsTr("Limite superior para o volume de saída (%)")
            value: Math.round(GlobalConfig.services.maxVolume * 100)
            from: 50
            to: 200
            stepSize: 5
            onMoved: v => GlobalConfig.services.maxVolume = v / 100
        }

        // Service tuning
        SectionHeader {
            text: qsTr("Ajustes de serviços")
        }

        StepperRow {
            first: true
            label: qsTr("Barras do visualizador")
            subtext: qsTr("Número de barras no visualizador de áudio")
            value: GlobalConfig.services.visualiserBars
            from: 10
            to: 120
            stepSize: 2
            onMoved: v => GlobalConfig.services.visualiserBars = v
        }

        ToggleRow {
            text: qsTr("Esquema de cores inteligente")
            subtext: qsTr("Definir modo e variante do tema a partir do papel de parede")
            checked: GlobalConfig.services.smartScheme
            onToggled: GlobalConfig.services.smartScheme = checked
        }

        SelectRow {
            last: true
            label: qsTr("GPU")
            subtext: Gpu.name ? qsTr("Monitorando: %1").arg(Gpu.name) : qsTr("Sobrescrever tipo de GPU")
            menuOnTop: true
            menuItems: root.gpuItems
            active: root.gpuItems[GlobalConfig.services.gpuType]
            onSelected: item => GlobalConfig.services.gpuType = root.gpuItems.indexOf(item)
        }
    }
}
