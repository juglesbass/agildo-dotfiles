import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    spacing: Tokens.spacing.small

    StyledText {
        text: `Caps Lock: ${Hypr.capsLock ? "Ativado" : "Desativado"}`
    }

    StyledText {
        text: `Num Lock: ${Hypr.numLock ? "Ativado" : "Desativado"}`
    }
}
