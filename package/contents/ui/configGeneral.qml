import QtQuick 2.2
import QtQuick.Controls 1.0 as QQC1
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.9 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kquickcontrolsaddons 2.1 as KQuickAddons

Kirigami.FormLayout {
  id: page

  property alias cfg_icon: plasmoidIcon.icon.name
  property alias cfg_zoomFactor: zoomFactor.value

  property int commonIconSize: PlasmaCore.Units.iconSizes.smallMedium

  Layout.fillWidth: true

  Item {
    Kirigami.FormData.label: i18n("Behavior")
    Kirigami.FormData.isSection: true
  }

  ColumnLayout {
    RowLayout {
      QQC2.Label {
        text: i18n("Zoom Factor:")
      }

      QQC1.SpinBox {
        id: zoomFactor
        decimals: 2
        stepSize: 0.05

        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: i18n("Zoom factor uses to scale the plasmoid")
      }
    }
  }

  Kirigami.Separator {
    Layout.fillWidth: true
    Kirigami.FormData.isSection: true
  }

  Item {
    Kirigami.FormData.label: i18n("Appearance")
    Kirigami.FormData.isSection: true
  }

  KQuickAddons.IconDialog {
    id: plasmoidIconDialog
    iconSize: commonIconSize

    property var icon

    onIconNameChanged: icon.name = iconName
  }

  ColumnLayout {
    RowLayout {
      QQC2.Label {
        text: i18n("Plasmoid Icon:")
      }

      QQC2.Button {
        id: plasmoidIcon

        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: i18n("Select icon for plasmoid")

        icon.width: commonIconSize
        icon.height: commonIconSize

        onClicked: {
          plasmoidIconDialog.open()
          plasmoidIconDialog.icon = plasmoidIcon.icon
        }
      }

      QQC2.Button {
        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: i18n("Set default icon for plasmoid")

        icon.name: "edit-clear"
        icon.width: commonIconSize
        icon.height: commonIconSize

        onClicked: plasmoidIcon.icon.name = "go-jump"
      }
    }
  }
}
