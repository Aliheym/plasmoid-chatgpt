import QtQuick 2.2
import QtQuick.Controls 1.0 as QQC1
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

Kirigami.FormLayout {
  id: page
  property alias cfg_zoomFactor: zoomFactor.value

  Layout.fillWidth: true
  Layout.fillHeight: true

  ColumnLayout {
    anchors.fill: parent

    spacing: 0

    RowLayout {
      Layout.alignment: Qt.AlignTop

      spacing: Kirigami.Units.smallSpacing

      QQC2.Label {
        text: i18n("Zoom Factor:")
        Layout.alignment: Qt.AlignRight
      }

      QQC1.SpinBox {
        id: zoomFactor
        decimals: 2
        stepSize: 0.05
      }
    }
  }
}
