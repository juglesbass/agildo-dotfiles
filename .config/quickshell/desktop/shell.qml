// ===========================================================================
// 🖥️  Widgets de area de trabalho — relogio + sensores
// ===========================================================================
// Instancia propria do quickshell (`qs -c desktop`), separada do caelestia.
// De proposito: assim sobrevive ao switch-shell.sh e aparece igual nos quatro
// shells (caelestia, waybar, wayle, ml4w), tal como o bloqueio de ecra.
//
// Camada Bottom: acima do wallpaper, ABAIXO das janelas -- desaparece quando
// abres algo por cima, como um widget de desktop deve fazer. Nao recebe clique
// nenhum (mascara vazia), portanto nao atrapalha o rato.
//
// As cores saem de ~/.config/hypr/scheme/current.conf, que e' gerado a partir
// do wallpaper. Com watchChanges, trocar de wallpaper repinta o widget sozinho,
// sem reiniciar nada.
//
// AJUSTES RAPIDOS: as propriedades logo abaixo. Depois de editar:
//   qs -c desktop kill; qs -c desktop -d

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: root

    // ---- AJUSTES -----------------------------------------------------------
    property bool  showSeconds:   false   // true = mostra os segundos no relogio
    property int   timeSize:      92      // tamanho da hora
    property int   dateSize:      21      // tamanho da data
    property int   marginTop:     80      // distancia do topo (px logicos)
    property int   marginRight:   70      // distancia da direita
    property int   panelWidth:    250     // largura do bloco de sensores
    property int   statsGap:      34      // espaco entre o relogio e os sensores
    property int   statsInterval: 3000    // ms entre leituras dos sensores
    property int   marginLeft:    70      // distancia da esquerda (widget do tempo)
    property int   weatherInterval: 300000 // 5 min; o script tem cache propria de 10 min
    property int   tempSize:      72      // tamanho da temperatura
    property int   iconSize:      58      // tamanho do icone de condicao
    property int   tempMin:       35      // inicio da escala de temperatura (°C)
    property int   tempMax:       90      // fim da escala de temperatura (°C)
    // ------------------------------------------------------------------------

    readonly property var loc: Qt.locale("pt_BR")

    // ---- Cores do scheme (mesmo ficheiro que a barra e o hyprlock usam) -----
    property color colTime:  "#e5e7d6"
    property color colLabel: "#aaac9d"
    property color colTrack: "#46493d"
    property color colFill:  "#becd96"
    property color colHot:   "#f97758"

    function applyScheme(txt: string): void {
        const pick = (name, fallback) => {
            const m = txt.match(new RegExp("^\\$" + name + "\\s*=\\s*([0-9a-fA-F]{6})\\s*$", "m"));
            return m ? "#" + m[1] : fallback;
        };
        colTime  = pick("onSurface",        "#e5e7d6");
        colLabel = pick("onSurfaceVariant", "#aaac9d");
        colTrack = pick("outlineVariant",   "#46493d");
        colFill  = pick("primary",          "#becd96");
        colHot   = pick("error",            "#f97758");
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/hypr/scheme/current.conf"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.applyScheme(text())
    }

    // ---- Sensores ----------------------------------------------------------
    property int    cpuTemp:  -1
    property int    gpuTemp:  -1
    property int    ramPct:   -1
    property real   ramUsed:  0
    property real   ramTotal: 0

    Process {
        id: statsProc
        command: ["/bin/bash", Quickshell.env("HOME") + "/.local/bin/desktop-stats.sh"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.cpuTemp  = (d.cpuTemp === null) ? -1 : d.cpuTemp;
                    root.gpuTemp  = (d.gpuTemp === null) ? -1 : d.gpuTemp;
                    root.ramPct   = (d.ramPct  === null) ? -1 : d.ramPct;
                    root.ramUsed  = d.ramUsed  || 0;
                    root.ramTotal = d.ramTotal || 0;
                } catch (e) {
                    // Leitura falhada: mantem os valores anteriores em vez de
                    // piscar "--" no ecra por causa de um unico ciclo perdido.
                }
            }
        }
    }

    Timer {
        interval: root.statsInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProc.running = true
    }

    // ---- Tempo ----------------------------------------------------------
    property bool   wxOk:    false
    property int    wxTemp:  0
    property int    wxFeels: 0
    property int    wxMin:   0
    property int    wxMax:   0
    property int    wxHum:   0
    property int    wxCode:  -1
    property bool   wxDay:   true
    property string wxCity:  ""

    Process {
        id: wxProc
        command: ["/bin/bash", Quickshell.env("HOME") + "/.local/bin/desktop-weather.sh"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    if (!d.ok) return;          // mantem a ultima leitura boa
                    root.wxOk    = true;
                    root.wxTemp  = d.temp;
                    root.wxFeels = d.feels;
                    root.wxMin   = d.tmin;
                    root.wxMax   = d.tmax;
                    root.wxHum   = d.humidity || 0;
                    root.wxCode  = (d.code === null || d.code === undefined) ? -1 : d.code;
                    root.wxDay   = !!d.isDay;
                    root.wxCity  = d.city || "";
                } catch (e) {
                    // Rede em baixo ou resposta truncada: fica o que ja' estava.
                }
            }
        }
    }

    Timer {
        interval: root.weatherInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: wxProc.running = true
    }

    // Codigos WMO do Open-Meteo -> icone (Material Symbols) e descricao.
    // A tabela vive aqui, e nao no script, porque e' apresentacao: o script
    // devolve dados crus e nao precisa de saber que fonte de icones se usa.
    function wxIcon(code, day) {
        if (code < 0) return "cloud";
        if (code === 0 || code === 1) return day ? "clear_day" : "clear_night";
        if (code === 2)               return day ? "partly_cloudy_day" : "partly_cloudy_night";
        if (code === 3)               return "cloud";
        if (code === 45 || code === 48) return "foggy";
        if (code >= 71 && code <= 77)   return "weather_snowy";
        if (code === 85 || code === 86) return "weather_snowy";
        if (code >= 95)                 return "thunderstorm";
        return "rainy";
    }

    // Descricoes em portugues do Brasil. A primeira versao usava termos de
    // Portugal -- "Encoberto", "Aguaceiros", "Nevoeiro" -- que sao corretos
    // mas nao e' como se fala aqui.
    function wxText(code) {
        switch (code) {
        case 0:  return "Céu limpo";
        case 1:  return "Poucas nuvens";
        case 2:  return "Parcialmente nublado";
        case 3:  return "Nublado";
        case 45: case 48: return "Neblina";
        case 51: case 53: case 55: return "Garoa";
        case 56: case 57: return "Garoa congelante";
        case 61: return "Chuva fraca";
        case 63: return "Chuva";
        case 65: return "Chuva forte";
        case 66: case 67: return "Chuva congelante";
        case 71: case 73: case 75: return "Neve";
        case 77: return "Granizo fino";
        case 80: case 81: return "Pancadas de chuva";
        case 82: return "Pancadas fortes";
        case 85: case 86: return "Pancadas de neve";
        case 95: return "Tempestade";
        case 96: case 99: return "Tempestade com granizo";
        default: return "--";
        }
    }

    SystemClock {
        id: clock
        precision: root.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    // Normaliza para 0..1 dentro da escala configurada.
    function normTemp(t) {
        if (t < 0) return 0;
        return Math.max(0, Math.min(1, (t - root.tempMin) / (root.tempMax - root.tempMin)));
    }

    // Interpola da cor primaria para a de erro no ultimo terco da escala, para
    // a barra "aquecer" visualmente em vez de mudar de cor de repente.
    function heatColor(n) {
        const t = Math.max(0, Math.min(1, (n - 0.7) / 0.3));
        return Qt.rgba(colFill.r + (colHot.r - colFill.r) * t,
                       colFill.g + (colHot.g - colFill.g) * t,
                       colFill.b + (colHot.b - colFill.b) * t, 1);
    }

    readonly property var metrics: [
        { label: "CPU", text: cpuTemp < 0 ? "--" : cpuTemp + "°", norm: normTemp(cpuTemp) },
        { label: "GPU", text: gpuTemp < 0 ? "--" : gpuTemp + "°", norm: normTemp(gpuTemp) },
        { label: "RAM", text: ramPct  < 0 ? "--" : ramPct  + "%", norm: ramPct < 0 ? 0 : ramPct / 100 }
    ]

    // ======================= TEMPO (canto superior esquerdo) ==============
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            WlrLayershell.namespace: "desktop-widgets"
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            anchors.top: true
            anchors.left: true
            margins.top: root.marginTop
            margins.left: root.marginLeft

            implicitWidth: wx.implicitWidth
            implicitHeight: wx.implicitHeight

            mask: Region {}

            Column {
                id: wx
                anchors.centerIn: parent
                spacing: 2

                // Icone + temperatura, alinhados pela base para o simbolo
                // assentar na linha dos digitos em vez de flutuar.
                Row {
                    spacing: 14

                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: root.tempSize * 0.18
                        text: root.wxIcon(root.wxCode, root.wxDay)
                        color: root.colFill
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: root.iconSize
                        renderType: Text.NativeRendering
                        style: Text.Raised
                        styleColor: "#66000000"
                    }

                    Text {
                        text: root.wxOk ? root.wxTemp + "°" : "--"
                        color: root.colTime
                        font.family: "SF Pro Display"
                        font.pixelSize: root.tempSize
                        font.weight: Font.Light
                        renderType: Text.NativeRendering
                        style: Text.Raised
                        styleColor: "#66000000"
                    }
                }

                Text {
                    text: root.wxText(root.wxCode) + (root.wxCity ? "  ·  " + root.wxCity : "")
                    color: root.colLabel
                    font.family: "SF Pro Text"
                    font.pixelSize: root.dateSize
                    renderType: Text.NativeRendering
                    style: Text.Raised
                    styleColor: "#66000000"
                }

                Text {
                    visible: root.wxOk
                    topPadding: 6
                    text: "sensação " + root.wxFeels + "°     "
                          + root.wxMin + "° / " + root.wxMax + "°     "
                          + root.wxHum + "%"
                    color: root.colLabel
                    opacity: 0.75
                    font.family: "SF Pro Text"
                    font.pixelSize: 14
                    font.letterSpacing: 0.4
                    renderType: Text.NativeRendering
                    style: Text.Raised
                    styleColor: "#66000000"
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData

            screen: modelData
            WlrLayershell.namespace: "desktop-widgets"
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            anchors.top: true
            anchors.right: true
            margins.top: root.marginTop
            margins.right: root.marginRight

            implicitWidth: content.implicitWidth
            implicitHeight: content.implicitHeight

            // Mascara de entrada vazia: todo o clique atravessa para o que
            // estiver por baixo. Sem isto o widget engolia cliques numa area
            // invisivel do desktop.
            mask: Region {}

            Column {
                id: content
                anchors.centerIn: parent
                spacing: root.statsGap

                // ---------- Relogio ----------
                Column {
                    anchors.right: parent.right
                    spacing: -6

                    Text {
                        anchors.right: parent.right
                        text: clock.date.toLocaleTimeString(root.loc, root.showSeconds ? "HH:mm:ss" : "HH:mm")
                        color: root.colTime
                        font.family: "SF Pro Display"
                        font.pixelSize: root.timeSize
                        font.weight: Font.Light
                        renderType: Text.NativeRendering
                        style: Text.Raised
                        styleColor: "#66000000"
                    }

                    Text {
                        anchors.right: parent.right
                        text: clock.date.toLocaleDateString(root.loc, "dddd, d 'de' MMMM")
                        color: root.colLabel
                        font.family: "SF Pro Text"
                        font.pixelSize: root.dateSize
                        renderType: Text.NativeRendering
                        style: Text.Raised
                        styleColor: "#66000000"
                    }
                }

                // ---------- Sensores ----------
                Column {
                    anchors.right: parent.right
                    spacing: 14

                    Repeater {
                        model: root.metrics

                        Item {
                            required property var modelData
                            width: root.panelWidth
                            height: 30

                            Text {
                                id: lbl
                                anchors.left: parent.left
                                anchors.top: parent.top
                                text: modelData.label
                                color: root.colLabel
                                font.family: "SF Pro Text"
                                font.pixelSize: 13
                                font.letterSpacing: 1.6
                                font.weight: Font.Medium
                                renderType: Text.NativeRendering
                                style: Text.Raised
                                styleColor: "#66000000"
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.baseline: lbl.baseline
                                text: modelData.text
                                color: root.colTime
                                font.family: "SF Pro Display"
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                renderType: Text.NativeRendering
                                style: Text.Raised
                                styleColor: "#66000000"
                            }

                            // Calha
                            Rectangle {
                                id: track
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 3
                                radius: height / 2
                                color: root.colTrack
                                opacity: 0.55

                                // Preenchimento
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * modelData.norm
                                    radius: parent.radius
                                    color: root.heatColor(modelData.norm)

                                    Behavior on width {
                                        NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
                                    }
                                    Behavior on color {
                                        ColorAnimation { duration: 420 }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
