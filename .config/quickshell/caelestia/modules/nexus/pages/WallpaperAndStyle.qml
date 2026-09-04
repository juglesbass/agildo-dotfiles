pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Caelestia.Components
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.images
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Aparência e estilo")

    property real currentScale: 2.0
    readonly property int currentScalePercent: Math.round(currentScale * 100)

    function applyScale(scaleVal: real): void {
        const s = (Math.round(scaleVal * 100) / 100).toFixed(2);
        root.currentScale = Number(s);
        Quickshell.execDetached(["/home/agildo/.local/bin/set-screen-scale.sh", s]);
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.large

        Process {
            id: getScaleProcess
            running: true
            command: ["sh", "-c", "cat /home/agildo/.local/state/caelestia/screen_scale 2>/dev/null || echo 2.0"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const val = parseFloat(text.trim());
                    if (!isNaN(val) && val > 0) {
                        root.currentScale = val;
                    }
                }
            }
        }

        StyledClippingRect {
            id: wallWrapper

            Layout.alignment: Qt.AlignHCenter
            implicitWidth: {
                const screen = root.nState.screen;
                return implicitHeight / screen.height * screen.width;
            }
            implicitHeight: {
                const screen = root.nState.screen;
                const cWidth = root.cappedWidth;
                return Math.min(Math.round(cWidth * 0.4), cWidth / screen.width * screen.height);
            }

            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.large

            Item {
                anchors.fill: parent
                opacity: 1

                Behavior on opacity {
                    Anim {
                        type: Anim.SlowEffects
                    }
                }

                Loader {
                    id: wallIndicatorLoader

                    anchors.centerIn: parent

                    opacity: 0
                    active: opacity > 0

                    sourceComponent: StyledRect {
                        implicitWidth: wallLoadingIndicator.implicitSize + Tokens.padding.largeIncreased * 2
                        implicitHeight: wallLoadingIndicator.implicitSize + Tokens.padding.largeIncreased * 2

                        color: Colours.palette.m3primaryContainer
                        radius: Tokens.rounding.full

                        LoadingIndicator {
                            id: wallLoadingIndicator

                            anchors.centerIn: parent
                            containsIcon: true
                            implicitSize: Math.min(wallWrapper.implicitWidth, wallWrapper.implicitHeight) * 0.4
                        }
                    }

                    Behavior on opacity {
                        Anim {
                            type: Anim.DefaultEffects
                        }
                    }
                }

                Timer {
                    id: wallLoadDebounceTimer

                    interval: 100
                    onTriggered: {
                        if (wallImg.status !== Image.Ready)
                            wallIndicatorLoader.opacity = 1;
                    }
                }

                FadeImage {
                    id: wallImg

                    anchors.fill: parent
                    source: Wallpapers.current
                    preventInit: wallIndicatorLoader.opacity > 0
                    fadeOutAnim: Anim.DefaultEffects
                    fadeInAnim: Anim.SlowEffects

                    onSourceChanged: wallLoadDebounceTimer.restart()

                    onStatusChanged: {
                        if (status === Image.Ready) {
                            wallLoadDebounceTimer.stop();
                            wallIndicatorLoader.opacity = 0;
                        }
                    }
                }
            }
        }

        ButtonRow {
            Layout.alignment: Qt.AlignHCenter
            spacing: Tokens.spacing.small

            IconTextButton {
                icon: "wallpaper"
                text: qsTr("Papéis de parede")
                font: Tokens.font.body.large
                isRound: true
                shapeMorph: true
                type: IconTextButton.Tonal
                horizontalPadding: Tokens.padding.extraLarge
                verticalPadding: Tokens.padding.medium
                disabled: false
                onClicked: root.nState.openSubPage(1) // Wallpaper page
            }

            IconTextButton {
                icon: "palette"
                text: qsTr("Cores")
                font: Tokens.font.body.large
                isRound: true
                shapeMorph: true
                type: IconTextButton.Tonal
                horizontalPadding: Tokens.padding.extraLarge
                verticalPadding: Tokens.padding.medium
                onClicked: root.nState.openSubPage(3) // Colours page
            }
        }

        ToggleRow {
            first: true
            text: qsTr("Transparência")
            subtext: qsTr("Base %1, camadas %2").arg(Colours.transparency.base).arg(Colours.transparency.layers)
            checked: Colours.transparency.enabled
            onToggled: GlobalConfig.appearance.transparency.enabled = checked
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing

            last: true
            text: qsTr("Tema escuro")
            checked: !Colours.light
            onToggled: Colours.setMode(checked ? "dark" : "light")
        }

        // Screen border
        SectionHeader {
            text: qsTr("Contorno da tela")
        }

        StepperRow {
            first: true
            label: qsTr("Espessura do contorno")
            subtext: qsTr("Largura da borda da tela (%1 px — 0 desativa)").arg(Math.round(GlobalConfig.border.thickness))
            from: 0
            to: 30
            stepSize: 1
            value: GlobalConfig.border.thickness
            onMoved: v => GlobalConfig.border.thickness = Math.round(v)
        }

        StepperRow {
            last: true
            label: qsTr("Arredondamento dos cantos")
            subtext: qsTr("Curva dos cantos da moldura da tela (%1 px)").arg(Math.round(GlobalConfig.border.rounding))
            from: 0
            to: 40
            stepSize: 1
            value: GlobalConfig.border.rounding
            onMoved: v => GlobalConfig.border.rounding = Math.round(v)
        }

        // Typography
        SectionHeader {
            text: qsTr("Tipografia")
        }

        StepperRow {
            first: true
            last: true
            label: qsTr("Tamanho da fonte")
            subtext: qsTr("Escala geral do texto da interface (%1%)").arg(Math.round((GlobalConfig.appearance.font.scale || 1.0) * 100))
            from: 70
            to: 160
            stepSize: 5
            value: Math.round((GlobalConfig.appearance.font.scale || 1.0) * 100)
            onMoved: v => GlobalConfig.appearance.font.scale = v / 100
        }

        // Taskbar size
        SectionHeader {
            text: qsTr("Barra de tarefas")
        }

        StepperRow {
            first: true
            last: true
            label: qsTr("Largura da barra (Dock)")
            subtext: qsTr("Espessura da barra e tamanho dos ícones (%1 px)").arg(Tokens.sizes.bar.innerWidth)
            from: 20
            to: 60
            stepSize: 2
            value: Tokens.sizes.bar.innerWidth
            onMoved: v => {
                Tokens.sizes.bar.innerWidth = Math.round(v);
                Quickshell.execDetached(["/home/agildo/.local/bin/set-bar-width.sh", String(Math.round(v))]);
            }
        }

        // Screen scale
        SectionHeader {
            text: qsTr("Escala da tela")
        }

        StepperRow {
            first: true
            last: false
            label: qsTr("Escala do monitor")
            subtext: qsTr("Ajuste manual da escala (%1%)").arg(root.currentScalePercent)
            from: 100
            to: 300
            stepSize: 25
            value: root.currentScalePercent
            onMoved: v => root.applyScale(v / 100)
        }

        ConnectedRect {
            Layout.fillWidth: true
            first: false
            last: true
            implicitHeight: presetsLayout.implicitHeight + Tokens.padding.medium * 2

            ColumnLayout {
                id: presetsLayout
                anchors.fill: parent
                anchors.margins: Tokens.padding.medium
                anchors.leftMargin: Tokens.padding.largeIncreased
                anchors.rightMargin: Tokens.padding.largeIncreased
                spacing: Tokens.spacing.small

                StyledText {
                    text: qsTr("Predefinições de escala")
                    color: Colours.palette.m3outline
                    font: Tokens.font.label.small
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    rowSpacing: Tokens.spacing.small
                    columnSpacing: Tokens.spacing.small

                    Repeater {
                        model: [
                            { label: "100%", tag: qsTr("Nativo"), val: 1.0 },
                            { label: "125%", tag: "", val: 1.25 },
                            { label: "150%", tag: "", val: 1.5 },
                            { label: "175%", tag: "", val: 1.75 },
                            { label: "200%", tag: qsTr("TV 4K"), val: 2.0 },
                            { label: "225%", tag: "", val: 2.25 },
                            { label: "250%", tag: "", val: 2.5 },
                            { label: "300%", tag: "", val: 3.0 }
                        ]

                        TextButton {
                            required property var modelData
                            Layout.fillWidth: true
                            text: modelData.tag ? (modelData.label + " (" + modelData.tag + ")") : modelData.label
                            isToggle: true
                            checked: Math.abs(root.currentScale - modelData.val) < 0.01
                            type: TextButton.Filled
                            onClicked: {
                                internalChecked = true;
                                root.applyScale(modelData.val);
                            }
                        }
                    }
                }
            }
        }

        // Interface rounding
        SectionHeader {
            text: qsTr("Interface")
        }

        StepperRow {
            first: true
            last: true
            label: qsTr("Arredondamento dos elementos")
            subtext: qsTr("Curvatura dos botões e painéis (%1%)").arg(Math.round((GlobalConfig.appearance.rounding.scale || 1.0) * 100))
            from: 40
            to: 200
            stepSize: 10
            value: Math.round((GlobalConfig.appearance.rounding.scale || 1.0) * 100)
            onMoved: v => GlobalConfig.appearance.rounding.scale = v / 100
        }
    }
}
