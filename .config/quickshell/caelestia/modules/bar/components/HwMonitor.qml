pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Caelestia.Config
import Caelestia.Services
import qs.components
import qs.services

StyledRect {
    id: root

    // Service references to enable live updates
    ServiceRef {
        service: Cpu
    }
    ServiceRef {
        service: Gpu
    }
    ServiceRef {
        service: Memory
    }

    property int fallbackCpu: 0
    property int fallbackGpu: 0
    property int fallbackRam: 0

    // Dynamic temperature and memory values with sysfs fallback
    readonly property int cpuTemp: Math.round(Cpu.temperature > 0 ? Cpu.temperature : fallbackCpu)
    readonly property int gpuTemp: Math.round(Gpu.temperature > 0 ? Gpu.temperature : fallbackGpu)
    readonly property int ramPercent: Math.round(Memory.percentage > 0 ? Memory.percentage * 100 : fallbackRam)

    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.full
    clip: true

    implicitWidth: Tokens.sizes.bar.innerWidth
    implicitHeight: layout.implicitHeight + Tokens.padding.extraSmall * 2

    // Background process to read sensors with 2.5s interval
    Process {
        id: hwmonProc
        command: ["/bin/bash", Quickshell.env("HOME") + "/.local/bin/quickshell-hwmon.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")[0].trim().split(/\s+/);
                if (parts.length >= 3) {
                    root.fallbackCpu = parseInt(parts[0]) || 0;
                    root.fallbackGpu = parseInt(parts[1]) || 0;
                    root.fallbackRam = parseInt(parts[2]) || 0;
                }
            }
        }
    }

    Timer {
        id: pollTimer
        interval: 2500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!hwmonProc.running)
                hwmonProc.running = true;
        }
    }

    ColumnLayout {
        id: layout

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Tokens.padding.extraSmall
        spacing: Tokens.spacing.extraSmall / 2

        // --- CPU Monitor ---
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "memory"
                color: root.cpuTemp >= 80 ? Colours.palette.m3error : root.cpuTemp >= 70 ? Colours.palette.m3tertiary : Colours.palette.m3primary
                fontStyle: Tokens.font.icon.small
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: `${root.cpuTemp}°`
                color: root.cpuTemp >= 80 ? Colours.palette.m3error : Colours.palette.m3onSurface
                font: Tokens.font.body.builders.small.scale(0.8).weight(Font.Bold).build()
            }
        }

        // Divider
        StyledRect {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Math.max(8, Tokens.sizes.bar.innerWidth - 12)
            implicitHeight: 1
            color: Qt.alpha(Colours.palette.m3outlineVariant, 0.4)
        }

        // --- GPU Monitor ---
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "developer_board"
                color: root.gpuTemp >= 80 ? Colours.palette.m3error : root.gpuTemp >= 70 ? Colours.palette.m3tertiary : Colours.palette.m3secondary
                fontStyle: Tokens.font.icon.small
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: `${root.gpuTemp}°`
                color: root.gpuTemp >= 80 ? Colours.palette.m3error : Colours.palette.m3onSurface
                font: Tokens.font.body.builders.small.scale(0.8).weight(Font.Bold).build()
            }
        }

        // Divider
        StyledRect {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Math.max(8, Tokens.sizes.bar.innerWidth - 12)
            implicitHeight: 1
            color: Qt.alpha(Colours.palette.m3outlineVariant, 0.4)
        }

        // --- RAM Monitor ---
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "memory_alt"
                color: root.ramPercent >= 85 ? Colours.palette.m3error : root.ramPercent >= 75 ? Colours.palette.m3secondary : Colours.palette.m3tertiary
                fontStyle: Tokens.font.icon.small
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: `${root.ramPercent}%`
                color: root.ramPercent >= 85 ? Colours.palette.m3error : Colours.palette.m3onSurface
                font: Tokens.font.body.builders.small.scale(0.8).weight(Font.Bold).build()
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["sh", "-c", "alacritty -e btop || konsole -e btop || foot -e btop"]);
        }
    }
}
