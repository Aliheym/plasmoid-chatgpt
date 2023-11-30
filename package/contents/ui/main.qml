import QtQuick 2.2
import QtQuick.Layouts 1.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.19 as Kirigami

import QtWebEngine 1.9

Item {
  id: root

  property bool pinned: false;
  property int focusTimerInterval: 100;

  Plasmoid.icon: plasmoid.configuration.icon

  Plasmoid.fullRepresentation: ColumnLayout {
    anchors.fill: parent

    Layout.minimumWidth: 240 * PlasmaCore.Units.devicePixelRatio
    Layout.minimumHeight: 470 * PlasmaCore.Units.devicePixelRatio
		Layout.preferredWidth: 540 * PlasmaCore.Units.devicePixelRatio
    Layout.preferredHeight: 920 * PlasmaCore.Units.devicePixelRatio

    Timer {
      id: focusTimer
      interval: root.focusTimerInterval
      running: false

      onTriggered: {
        chatGptWebView.forceActiveFocus();
        chatGptWebView.focus = true;
        chatGptWebView.runJavaScript("tryToFocusPromptInput()");
      }
    }

    Connections {
      target: plasmoid

      function onExpandedChanged() {
				console.debug(`(onExpandedChanged): plasmoid.plasmoid = "${plasmoid.expanded}"`)

        if (plasmoid.expanded && chatGptWebView.loadProgress === 100) {
          focusTimer.start();
        }
			}
    }

    Binding {
      target: plasmoid
      property: "hideOnWindowDeactivate"
      value: !root.pinned
    }

    PlasmaExtras.PlasmoidHeading {
      Layout.fillWidth: true

      RowLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.mediumSpacing

        Kirigami.Heading {
          Layout.fillWidth: true

          text: i18n("ChatGPT")
          color: theme.textColor
        }

        PlasmaComponents.ToolButton {
          text: i18n("Refresh")
          icon.name: "view-refresh"
          display: PlasmaComponents.ToolButton.IconOnly
          PlasmaComponents.ToolTip.text: text
          PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
          PlasmaComponents.ToolTip.visible: hovered
          onClicked: chatGptWebView.reload()
        }

        PlasmaComponents.ToolButton {
          checkable: true
          checked: root.pinned
          icon.name: "window-pin"
          text: i18n("Pin")
          display: PlasmaComponents.ToolButton.IconOnly
          PlasmaComponents.ToolTip.text: text
          PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
          PlasmaComponents.ToolTip.visible: hovered
          onToggled: root.pinned = checked
        }
      }
    }

    ColumnLayout {
      WebEngineView {
        id: chatGptWebView

        Layout.fillWidth: true
        Layout.fillHeight: true

        url: "https://chat.openai.com/chat"
        focus: true
        zoomFactor: plasmoid.configuration.zoomFactor

        profile: WebEngineProfile {
          id: chatGptProfile

          storageName: "chatgpt"
          offTheRecord: false
          httpCacheType: WebEngineProfile.DiskHttpCache
          persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies

          userScripts: [
            WebEngineScript {
              injectionPoint: WebEngineScript.Deferred
              sourceUrl: "./browser/chatgpt.js"
              worldId: WebEngineScript.MainWorld
            }
          ]
        }

        onLoadingChanged: {
          if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
            // Force focus on the prompt input
            chatGptWebView.forceActiveFocus();
            chatGptWebView.runJavaScript("tryToFocusPromptInput()");
          }
        }

        onNavigationRequested: {
          const currentUrl = chatGptWebView.url.toString();
          // Only allow external links to be opened from the chat pages
          // ChatGPT chat page's URL example: https://chat.openai.com/c/uuid or https://chat.openai.com/chat/uuid
          if (!currentUrl.startsWith("https://chat.openai.com/c")) {
            return;
          }

          const requestedUrl = request.url.toString();
          if (requestedUrl.includes("openai.com")) {
            request.action = WebEngineView.AcceptRequest;
          } else {
            request.action = WebEngineView.IgnoreRequest;

            Qt.openUrlExternally(request.url);
          }
        }

        onJavaScriptConsoleMessage: {
          if (!message.startsWith("Refused")) {
            console.debug(`(onJavaScriptConsoleMessage): ${message}`);
          }
        }
      }
    }
  }
}
