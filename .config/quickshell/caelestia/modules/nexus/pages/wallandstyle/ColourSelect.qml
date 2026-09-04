pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Cores e temas")
    isSubPage: true

    readonly property list<MenuItem> variantItems: [
        MenuItem { text: qsTr("Tonal Spot (Padrão)"); property string variant: "tonalspot" },
        MenuItem { text: qsTr("Vibrante"); property string variant: "vibrant" },
        MenuItem { text: qsTr("Expressivo"); property string variant: "expressive" },
        MenuItem { text: qsTr("Arco-íris"); property string variant: "rainbow" },
        MenuItem { text: qsTr("Salada de Frutas"); property string variant: "fruitsalad" },
        MenuItem { text: qsTr("Fidelidade"); property string variant: "fidelity" },
        MenuItem { text: qsTr("Neutro"); property string variant: "neutral" },
        MenuItem { text: qsTr("Monocromático"); property string variant: "monochrome" }
    ]

    readonly property var themes: [
        {
            name: "dynamic",
            flavour: "default",
            label: qsTr("Dinâmico (Papel de parede)"),
            subtext: qsTr("Extrai as cores automaticamente da imagem de fundo"),
            icon: "auto_awesome",
            surfaceColor: "#1e1e2e",
            primaryColor: Colours.palette.m3primary
        },
        {
            name: "catppuccin",
            flavour: "mocha",
            label: qsTr("Catppuccin Mocha"),
            subtext: qsTr("Tema escuro pastel sofisticado e confortável"),
            icon: "palette",
            surfaceColor: "#1e1e2e",
            primaryColor: "#cba6f7"
        },
        {
            name: "catppuccin",
            flavour: "latte",
            label: qsTr("Catppuccin Latte"),
            subtext: qsTr("Versão clara, moderna e suave do Catppuccin"),
            icon: "light_mode",
            surfaceColor: "#eff1f5",
            primaryColor: "#8839ef"
        },
        {
            name: "tokyonight",
            flavour: "medium",
            label: qsTr("Tokyo Night"),
            subtext: qsTr("Inspirado nas luzes noturnas de Tóquio"),
            icon: "nights_stay",
            surfaceColor: "#1a1b26",
            primaryColor: "#7aa2f7"
        },
        {
            name: "dracula",
            flavour: "medium",
            label: qsTr("Dracula"),
            subtext: qsTr("Tema escuro vibrante com destaque em roxo e rosa"),
            icon: "dark_mode",
            surfaceColor: "#282a36",
            primaryColor: "#bd93f9"
        },
        {
            name: "nord",
            flavour: "medium",
            label: qsTr("Nord"),
            subtext: qsTr("Paleta ártica minimalista com tons gélidos"),
            icon: "ac_unit",
            surfaceColor: "#2e3440",
            primaryColor: "#88c0d0"
        },
        {
            name: "gruvbox",
            flavour: "hard",
            label: qsTr("Gruvbox"),
            subtext: qsTr("Paleta retrô acolhedora com tons terrosos e quentes"),
            icon: "coffee",
            surfaceColor: "#1d2021",
            primaryColor: "#d79921"
        },
        {
            name: "everforest",
            flavour: "hard",
            label: qsTr("Everforest"),
            subtext: qsTr("Tons relaxantes e calmos de verde floresta"),
            icon: "forest",
            surfaceColor: "#272e33",
            primaryColor: "#a7c080"
        },
        {
            name: "rosepine",
            flavour: "main",
            label: qsTr("Rosé Pine"),
            subtext: qsTr("Cores elegantes de vinho, lavanda e pinho"),
            icon: "spa",
            surfaceColor: "#191724",
            primaryColor: "#ebbcba"
        },
        {
            name: "onedark",
            flavour: "default",
            label: qsTr("One Dark"),
            subtext: qsTr("Visual icônico e equilibrado do editor Atom"),
            icon: "code",
            surfaceColor: "#282c34",
            primaryColor: "#61afef"
        }
    ]

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: qsTr("Estilo de cores dinâmicas")
        }

        SelectRow {
            first: true
            last: true
            label: qsTr("Variante do Material You")
            subtext: qsTr("Modo de geração quando o tema dinâmico estiver ativo")
            menuItems: root.variantItems
            fallbackText: qsTr("Tonal Spot")
            onSelected: item => {
                if (item.variant) {
                    Quickshell.execDetached(["caelestia", "scheme", "set", "-v", item.variant]);
                }
            }
        }

        SectionHeader {
            text: qsTr("Paletas e temas")
        }

        Repeater {
            model: root.themes

            RowButton {
                required property var modelData
                required property int index

                first: index === 0
                last: index === root.themes.length - 1

                icon: modelData.icon
                text: modelData.label
                subtext: modelData.subtext
                trailingIcon: Colours.scheme === modelData.name && (modelData.flavour === "default" || modelData.name === "dynamic" || Colours.flavour === modelData.flavour) ? "check" : ""

                onClicked: {
                    if (modelData.name === "dynamic") {
                        Quickshell.execDetached(["caelestia", "scheme", "set", "-n", "dynamic"]);
                    } else if (modelData.flavour === "latte") {
                        Quickshell.execDetached(["caelestia", "scheme", "set", "-n", modelData.name, "-f", modelData.flavour, "-m", "light"]);
                    } else {
                        Quickshell.execDetached(["caelestia", "scheme", "set", "-n", modelData.name, "-f", modelData.flavour]);
                    }
                }
            }
        }
    }
}
