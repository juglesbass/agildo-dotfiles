pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.Models
import qs.components.controls
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    title: {
        const c = nState.selectedWallpaperCategory;
        return c.slice(0, 1).toUpperCase() + c.slice(1);
    }
    isSubPage: true

    property int displayLimit: 24

    readonly property var fullList: {
        return Wallpapers.list.filter(w => Wallpapers.getCategoryFor(w) === root.nState.selectedWallpaperCategory).sort((a, b) => a.name.localeCompare(b.name));
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.small

        Item {
            visible: false
            implicitWidth: 0
            implicitHeight: 0

            Connections {
                target: root.flickable
                function onContentYChanged() {
                    if (root.flickable && root.flickable.contentY + root.flickable.height >= root.flickable.contentHeight - 600) {
                        if (root.displayLimit < root.fullList.length) {
                            root.displayLimit = Math.min(root.displayLimit + 24, root.fullList.length);
                        }
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true

            columns: Config.nexus.wallpapersPerRow
            rowSpacing: Tokens.spacing.medium
            columnSpacing: Tokens.spacing.large

            Repeater {
                model: {
                    const walls = root.fullList.slice(0, root.displayLimit);
                    while (walls.length < Config.nexus.wallpapersPerRow)
                        walls.push(null);
                    return walls;
                }

                WallItem {
                    required property FileSystemEntry modelData

                    // Empty placeholders for sizing
                    opacity: modelData ? 1 : 0
                    enabled: modelData

                    source: String(modelData?.path ?? "")
                    text: modelData?.name ?? ""
                    onClicked: {
                        Wallpapers.setWallpaper(modelData.path);
                        root.nState.closeSubPage();
                        root.nState.closeSubPage();
                    }
                }
            }
        }

        IconTextButton {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Tokens.spacing.medium
            Layout.bottomMargin: Tokens.spacing.large
            visible: root.displayLimit < root.fullList.length
            icon: "expand_more"
            text: qsTr("Carregar mais (%1 de %2)").arg(root.displayLimit).arg(root.fullList.length)
            type: IconTextButton.Tonal
            isRound: true
            shapeMorph: true
            onClicked: root.displayLimit = Math.min(root.displayLimit + 36, root.fullList.length)
        }
    }
}
