pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.modules.bar as Bar

Region {
    id: root

    required property Bar.BarWrapper bar
    required property Panels panels
    required property var win

    readonly property real borderThickness: win.contentItem.Config.border.thickness
    readonly property real clampedThickness: win.contentItem.Config.border.clampedThickness

    x: bar.clampedWidth + win.dragMaskPadding
    y: clampedThickness + win.dragMaskPadding
    width: win.width - bar.clampedWidth - clampedThickness - win.dragMaskPadding * 2
    height: win.height - clampedThickness - win.dragMaskPadding * 2
    intersection: Intersection.Xor

    readonly property real dashCenterX: root.bar.implicitWidth + root.panels.dashboard.x + root.panels.dashboard.width / 2
    readonly property real dashTriggerHalfWidth: 250

    R {
        panel: root.panels.dashboard
        x: root.win.screenState.dashboard ? (panel.x + root.bar.implicitWidth) : (root.dashCenterX - root.dashTriggerHalfWidth)
        y: 0
        width: root.win.screenState.dashboard ? panel.width : (root.dashTriggerHalfWidth * 2)
        height: Math.max(8, panel.height * (1 - root.panels.dashboard.offsetScale) + root.borderThickness)
    }

    R {
        panel: root.panels.launcher
        y: 0
        height: panel.height * (1 - root.panels.launcher.offsetScale) + root.borderThickness
    }

    R {
        id: sessionRegion

        panel: root.panels.sessionWrapper
        x: root.win.width - width
        width: panel.width * (1 - root.panels.session.offsetScale) + root.borderThickness + sidebarRegion.width
    }

    R {
        id: sidebarRegion

        panel: root.panels.sidebar
        x: root.win.width - width
        width: panel.width * (1 - root.panels.sidebar.offsetScale) + root.borderThickness
    }

    R {
        panel: root.panels.osdWrapper
        x: root.win.width - width
        width: panel.width * (1 - root.panels.osd.offsetScale) + root.borderThickness + sessionRegion.width
    }

    R {
        panel: root.panels.notifications
        y: 0
        height: panel.height + root.borderThickness
    }

    R {
        panel: root.panels.utilities
        x: root.win.width - width
        y: 0
        width: panel.width
        height: Math.max(12, panel.height * (1 - root.panels.utilities.offsetScale) + root.borderThickness)
    }

    R {
        panel: root.panels.popoutsWrapper
        width: panel.width * (1 - root.panels.popoutsWrapper.offsetScale)
    }

    component R: Region {
        required property Item panel

        x: panel.x + root.bar.implicitWidth
        y: panel.y + root.borderThickness
        width: panel.width
        height: panel.height
        intersection: Intersection.Subtract
    }
}
